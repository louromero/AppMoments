import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../services/database.dart';
import '../services/notifier.dart';

class ConfigPerfilPage extends StatefulWidget {
  const ConfigPerfilPage({super.key});

  @override
  State<ConfigPerfilPage> createState() => _ConfigPerfilPageState();
}

class _ConfigPerfilPageState extends State<ConfigPerfilPage> {
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _correoController = TextEditingController();

  File? _nuevaImagen;
  String? _imagenActual;

  @override
  void initState() {
    super.initState();
    _cargarDatosUsuario();
  }

  void _cargarDatosUsuario() {
    final usuario =
        Provider.of<SessionNotifier>(context, listen: false).usuarioActual;

    if (usuario != null) {
      _nombreController.text = usuario.nombre;
      _apellidoController.text = usuario.apellido;
      _correoController.text = usuario.correo;
      _imagenActual = usuario.fotoPerfil;
    }
  }

  Future<void> _seleccionarImagen() async {
    final picker = ImagePicker();

    // Función auxiliar para actualizar el estado
    void actualizarImagen(XFile? pickedFile) {
      if (pickedFile != null) {
        setState(() {
          _nuevaImagen = File(pickedFile.path);
        });
      }
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              const ListTile(
                title: Text(
                  "Cambiar foto de perfil",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.orange),
                title: const Text('Elegir de la galería'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? pickedFile = await picker.pickImage(
                    source: ImageSource.gallery,
                    imageQuality: 70, // Ideal para fotos de perfil
                  );
                  actualizarImagen(pickedFile);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.orange),
                title: const Text('Tomar una foto'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? pickedFile = await picker.pickImage(
                    source: ImageSource.camera,
                    imageQuality: 70, // Reducimos peso para el perfil
                  );
                  actualizarImagen(pickedFile);
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Future<void> _guardarCambios() async {
    final session = Provider.of<SessionNotifier>(context, listen: false);

    final usuarioActual = session.usuarioActual;

    if (usuarioActual == null) return;

    final usuarioActualizado = Usuario(
      id: usuarioActual.id,
      nombre: _nombreController.text,
      apellido: _apellidoController.text,
      correo: _correoController.text,
      contrasena: usuarioActual.contrasena,
      fotoPerfil: _nuevaImagen != null ? _nuevaImagen!.path : _imagenActual,
      esAdministrador: usuarioActual.esAdministrador,
    );

    final db = await MomentoDatabase.instance.database;

    await db.update(
      'usuarios',
      usuarioActualizado.toMap(),
      where: 'id = ?',
      whereArgs: [usuarioActual.id],
    );

    session.login(usuarioActualizado);

    if (mounted) {
      Navigator.pop(context);
    }
  }

  Widget _buildImagenPerfil() {
    if (_nuevaImagen != null) {
      return CircleAvatar(
        radius: 60,
        backgroundImage: FileImage(_nuevaImagen!),
      );
    }

    if (_imagenActual != null &&
        _imagenActual!.isNotEmpty &&
        File(_imagenActual!).existsSync()) {
      return CircleAvatar(
        radius: 60,
        backgroundImage: FileImage(File(_imagenActual!)),
      );
    }

    return const CircleAvatar(
      radius: 60,
      backgroundImage: AssetImage('assets/images/avatar.jpg'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Editar Perfil"),
        backgroundColor: const Color.fromARGB(255, 255, 242, 221),
      ),
      backgroundColor: const Color.fromARGB(255, 255, 242, 221),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildImagenPerfil(),
            const SizedBox(height: 10),
            TextButton(
              onPressed: _seleccionarImagen,
              child: const Text("Cambiar Foto"),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nombreController,
              decoration: const InputDecoration(labelText: "Nombre"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _apellidoController,
              decoration: const InputDecoration(labelText: "Apellido"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _correoController,
              decoration: const InputDecoration(labelText: "Correo"),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _guardarCambios,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              ),
              child: const Text("Guardar Cambios"),
            ),
          ],
        ),
      ),
    );
  }
}
