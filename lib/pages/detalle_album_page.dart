import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../models/models.dart';
import '../services/database.dart';
import '../services/notifier.dart';

class DetalleAlbumPage extends StatefulWidget {
  final Album album;
  const DetalleAlbumPage({super.key, required this.album});

  @override
  State<DetalleAlbumPage> createState() => _DetalleAlbumPageState();
}

class _DetalleAlbumPageState extends State<DetalleAlbumPage> {
  late Album _albumActual;
  List<Usuario> _miembros = [];
  List<String> _fotos = [];

  @override
  void initState() {
    super.initState();
    _albumActual = widget.album;
    _cargarDatos();
  }

  void _cargarDatos() async {
    final m = await MomentoDatabase.instance.obtenerMiembros(_albumActual.id!);
    final f =
        await MomentoDatabase.instance.obtenerFotosAlbum(_albumActual.id!);
    setState(() {
      _miembros = m;
      _fotos = f;
    });
  }

  Future<void> _subirFoto() async {
    final picker = ImagePicker();

    // Mostramos el menú de opciones
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Añadir foto al álbum",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.orange),
                title: const Text('Elegir de la galería'),
                onTap: () async {
                  Navigator.pop(context); // Cerramos el menú
                  final XFile? image = await picker.pickImage(
                    source: ImageSource.gallery,
                    imageQuality: 80, // Opcional: optimiza el tamaño
                  );
                  _procesarImagen(image);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.orange),
                title: const Text('Tomar fotografía'),
                onTap: () async {
                  Navigator.pop(context); // Cerramos el menú
                  final XFile? image = await picker.pickImage(
                    source: ImageSource.camera,
                    imageQuality: 80,
                  );
                  _procesarImagen(image);
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Future<void> _procesarImagen(XFile? image) async {
    if (image != null) {
      await MomentoDatabase.instance.subirFoto(_albumActual.id!, image.path);
      _cargarDatos(); // Recargar la galería
    }
  }

  void _verFotoGrande(String ruta) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.file(File(ruta), fit: BoxFit.contain),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cerrar",
                  style: TextStyle(color: Colors.white, fontSize: 18)),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userLogueado = Provider.of<SessionNotifier>(context).usuarioActual!;
    final bool tienePermisos = userLogueado.esAdministrador == 1 ||
        userLogueado.id == _albumActual.administradorId;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 242, 221),
      appBar: AppBar(
        title: Text(_albumActual.titulo),
        backgroundColor: Colors.orange.shade100,
        actions: [
          if (tienePermisos) ...[
            IconButton(
                icon: const Icon(Icons.edit), onPressed: _editarInfoCompleta),
            IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: _confirmarBorrado),
          ]
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoCard(),
                  const SizedBox(height: 20),
                  _buildMapaSeccion(),
                  const SizedBox(height: 30),
                  const Text("Galería de Fotos",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 10),
                  _buildGaleriaFotos(),
                  const SizedBox(height: 30),
                  _buildBotonesAccion(tienePermisos, userLogueado.id!),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _subirFoto,
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add_a_photo, color: Colors.white),
      ),
    );
  }

  Widget _buildGaleriaFotos() {
    if (_fotos.isEmpty) {
      return const Center(child: Text("Aún no hay fotos en este álbum."));
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _fotos.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => _verFotoGrande(_fotos[index]),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.file(File(_fotos[index]), fit: BoxFit.cover),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 250,
      width: double.infinity,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
        child: _albumActual.portada.startsWith('assets')
            ? Image.asset(_albumActual.portada, fit: BoxFit.cover)
            : Image.file(File(_albumActual.portada), fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.orange.shade100, blurRadius: 10)
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_albumActual.titulo,
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange)),
          const Divider(),
          Row(children: [
            const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
            const SizedBox(width: 10),
            Text(
                "Fecha: ${_albumActual.fecha.day}/${_albumActual.fecha.month}/${_albumActual.fecha.year}")
          ]),
          const SizedBox(height: 8),
          Row(children: [
            const Icon(Icons.location_on, size: 18, color: Colors.grey),
            const SizedBox(width: 10),
            Expanded(child: Text("Dirección: ${_albumActual.direccion}"))
          ]),
        ],
      ),
    );
  }

  Widget _buildMapaSeccion() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
          border: Border.all(color: Colors.orange.shade300, width: 2),
          borderRadius: BorderRadius.circular(15)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: FlutterMap(
          options: MapOptions(
              initialCenter: LatLng(_albumActual.lat, _albumActual.lng),
              initialZoom: 15),
          children: [
            TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName: 'com.momento.app.final'),
            MarkerLayer(markers: [
              Marker(
                  point: LatLng(_albumActual.lat, _albumActual.lng),
                  width: 40,
                  height: 40,
                  child: const Icon(Icons.location_pin,
                      color: Colors.red, size: 40))
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildBotonesAccion(bool tienePermisos, int myId) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _mostrarModalMiembros,
            icon: const Icon(Icons.people),
            label: const Text("VER MIEMBROS DEL ÁLBUM"),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.orange,
              side: const BorderSide(color: Colors.orange),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
          ),
        ),
        if (!tienePermisos) ...[
          const SizedBox(height: 15),
          TextButton(
              onPressed: () => _expulsar(myId),
              child: const Text("SALIR DEL ÁLBUM",
                  style: TextStyle(color: Colors.red))),
        ]
      ],
    );
  }

  void _editarInfoCompleta() async {
    final titleCtrl = TextEditingController(text: _albumActual.titulo);
    final dirCtrl = TextEditingController(text: _albumActual.direccion);
    DateTime fechaEditada = _albumActual.fecha;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Editar Información"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(labelText: "Título")),
                TextField(
                    controller: dirCtrl,
                    decoration: const InputDecoration(labelText: "Dirección")),
                const SizedBox(height: 15),
                ListTile(
                  title: Text(
                      "Fecha: ${fechaEditada.day}/${fechaEditada.month}/${fechaEditada.year}"),
                  trailing: const Icon(Icons.calendar_month),
                  onTap: () async {
                    final picked = await showDatePicker(
                        context: context,
                        initialDate: fechaEditada,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100));
                    if (picked != null)
                      setDialogState(() => fechaEditada = picked);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancelar")),
            TextButton(
              onPressed: () async {
                final nuevo = Album(
                    id: _albumActual.id,
                    titulo: titleCtrl.text,
                    fecha: fechaEditada,
                    portada: _albumActual.portada,
                    administradorId: _albumActual.administradorId,
                    clave: _albumActual.clave,
                    lat: _albumActual.lat,
                    lng: _albumActual.lng,
                    esDemo: 0,
                    direccion: dirCtrl.text);
                await MomentoDatabase.instance.actualizarAlbum(nuevo);
                setState(() => _albumActual = nuevo);
                Navigator.pop(context);
              },
              child: const Text("Guardar"),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarModalMiembros() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            const Text("Miembros",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Flexible(
              child: ListView.builder(
                itemCount: _miembros.length,
                itemBuilder: (context, i) {
                  final m = _miembros[i];
                  return ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text("${m.nombre} ${m.apellido}"),
                    subtitle: Text(m.id == _albumActual.administradorId
                        ? "Admin"
                        : "Miembro"),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmarBorrado() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("¿Eliminar Álbum?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text("No")),
          TextButton(
            onPressed: () async {
              await MomentoDatabase.instance.eliminarAlbum(_albumActual.id!);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("Sí, Eliminar"),
          ),
        ],
      ),
    );
  }

  void _expulsar(int userId) async {
    await MomentoDatabase.instance.removerMiembro(_albumActual.id!, userId);
    Navigator.pop(context);
  }
}
