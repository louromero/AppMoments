import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/models.dart';

class MomentoDatabase {
  static final MomentoDatabase instance = MomentoDatabase._init();
  static Database? _database;

  MomentoDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('momento.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    // Cambiamos a versión 4 para asegurar que se cree la tabla de fotos
    return await openDatabase(
      path, 
      version: 4, 
      onCreate: _createDB,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 4) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS fotos (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              album_id INTEGER,
              ruta TEXT,
              fecha_subida TEXT,
              FOREIGN KEY (album_id) REFERENCES albumes(id) ON DELETE CASCADE
            )
          ''');
        }
      }
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE usuarios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT, apellido TEXT, correo TEXT UNIQUE,
        contrasena TEXT, foto_perfil TEXT, es_administrador INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE albumes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        titulo TEXT, fecha TEXT, portada TEXT,
        administrador_id INTEGER, clave TEXT,
        lat REAL, lng REAL, direccion TEXT, es_demo INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE usuario_album (
        usuario_id INTEGER, album_id INTEGER,
        PRIMARY KEY (usuario_id, album_id)
      )
    ''');
    await db.execute('''
      CREATE TABLE fotos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        album_id INTEGER,
        ruta TEXT,
        fecha_subida TEXT,
        FOREIGN KEY (album_id) REFERENCES albumes(id) ON DELETE CASCADE
      )
    ''');
  }

  // --- MÉTODOS DE FOTOS (UBICACIÓN CORRECTA) ---
  Future<void> subirFoto(int albumId, String ruta) async {
    final db = await instance.database;
    await db.insert('fotos', {
      'album_id': albumId,
      'ruta': ruta,
      'fecha_subida': DateTime.now().toIso8601String(),
    });
  }

  Future<List<String>> obtenerFotosAlbum(int albumId) async {
    final db = await instance.database;
    final res = await db.query('fotos', where: 'album_id = ?', whereArgs: [albumId]);
    return res.map((e) => e['ruta'] as String).toList();
  }

  // --- RESTO DE MÉTODOS ---
  Future<Usuario?> loginUsuario(String email, String password) async {
    final db = await instance.database;
    final res = await db.query('usuarios', 
        where: 'correo = ? AND contrasena = ?', whereArgs: [email, password]);
    
    if (res.isNotEmpty) {
      final user = Usuario.fromMap(res.first);
      if (user.esAdministrador == 0) await _asegurarDemos(user.id!);
      return user;
    }
    return null;
  }

  Future<void> _asegurarDemos(int usuarioId) async {
    final db = await instance.database;
    List<Map<String, dynamic>> demos = [
      {'titulo': 'Jardín Japonés', 'clave': '1234', 'lat': -34.5751, 'lng': -58.4090, 'direccion': 'Palermo, CABA', 'portada': 'assets/images/jardin.jpg'},
      {'titulo': 'Obelisco', 'clave': '1234', 'lat': -34.6037, 'lng': -58.3816, 'direccion': 'Centro, CABA', 'portada': 'assets/images/obelisco.jpg'}
    ];

    for (var d in demos) {
      final checkRelacion = await db.rawQuery('''
        SELECT 1 FROM usuario_album ua 
        JOIN albumes a ON ua.album_id = a.id 
        WHERE ua.usuario_id = ? AND a.titulo = ?
      ''', [usuarioId, d['titulo']]);

      if (checkRelacion.isEmpty) {
        var resAlbum = await db.query('albumes', where: 'titulo = ?', whereArgs: [d['titulo']]);
        int albumId;
        if (resAlbum.isEmpty) {
          albumId = await db.insert('albumes', {
            ...d, 'fecha': DateTime.now().toIso8601String(), 'administrador_id': 0, 'es_demo': 1
          });
        } else {
          albumId = resAlbum.first['id'] as int;
        }
        await db.insert('usuario_album', {'usuario_id': usuarioId, 'album_id': albumId}, 
            conflictAlgorithm: ConflictAlgorithm.ignore);
      }
    }
  }

  Future<List<Album>> obtenerAlbumesVisibles(Usuario user) async {
    final db = await instance.database;
    if (user.esAdministrador == 1) {
      final res = await db.query('albumes');
      return res.map((e) => Album.fromMap(e)).toList();
    } else {
      final res = await db.rawQuery('''
        SELECT a.* FROM albumes a 
        INNER JOIN usuario_album ua ON a.id = ua.album_id 
        WHERE ua.usuario_id = ?
      ''', [user.id]);
      return res.map((e) => Album.fromMap(e)).toList();
    }
  }

  Future<void> crearAlbum(Album album) async {
    final db = await instance.database;
    final id = await db.insert('albumes', album.toMap());
    await db.insert('usuario_album', {'usuario_id': album.administradorId, 'album_id': id});
  }

  Future<void> actualizarAlbum(Album album) async {
    final db = await instance.database;
    await db.update('albumes', album.toMap(), where: 'id = ?', whereArgs: [album.id]);
  }

  Future<void> eliminarAlbum(int albumId) async {
    final db = await instance.database;
    await db.delete('albumes', where: 'id = ?', whereArgs: [albumId]);
    await db.delete('usuario_album', where: 'album_id = ?', whereArgs: [albumId]);
  }

  Future<void> removerMiembro(int albumId, int usuarioId) async {
    final db = await instance.database;
    await db.delete('usuario_album', 
        where: 'album_id = ? AND usuario_id = ?', 
        whereArgs: [albumId, usuarioId]);
  }

  Future<bool> unirseAlbum(String titulo, String clave, int usuarioId) async {
    final db = await instance.database;
    final res = await db.query('albumes', where: 'titulo = ? AND clave = ?', whereArgs: [titulo, clave]);
    if (res.isEmpty) return false;
    await db.insert('usuario_album', {'usuario_id': usuarioId, 'album_id': res.first['id']}, conflictAlgorithm: ConflictAlgorithm.ignore);
    return true;
  }
  
  Future<bool> emailExists(String email) async => (await (await database).query('usuarios', where: 'correo = ?', whereArgs: [email])).isNotEmpty;
  Future<void> registrarUsuario(Usuario u) async => (await database).insert('usuarios', u.toMap());
  
  Future<List<Usuario>> obtenerMiembros(int albumId) async {
    final db = await instance.database;
    final res = await db.rawQuery('''
      SELECT u.* FROM usuarios u 
      JOIN usuario_album ua ON u.id = ua.usuario_id 
      WHERE ua.album_id = ?
    ''', [albumId]);
    return res.map((e) => Usuario.fromMap(e)).toList();
  }
}