import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/models.dart';
import '../services/database.dart';
import '../services/notifier.dart';

class CrearAlbumPage extends StatefulWidget {
  const CrearAlbumPage({super.key});

  @override
  State<CrearAlbumPage> createState() => _CrearAlbumPageState();
}

class _CrearAlbumPageState extends State<CrearAlbumPage> {
  final _tituloController = TextEditingController();
  final _claveController = TextEditingController();
  final _direccionController = TextEditingController();

  DateTime? _fechaSeleccionada;
  File? _imagenSeleccionada;

  LatLng? _ubicacionSeleccionada;
  final MapController _mapController = MapController();

  Future<void> _seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (fecha != null) {
      setState(() => _fechaSeleccionada = fecha);
    }
  }

  Future<void> _seleccionarImagen() async {
    final picker = ImagePicker();

    // Diálogo para elegir entre Cámara o Galería
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galería'),
                onTap: () async {
                  final XFile? picked =
                      await picker.pickImage(source: ImageSource.gallery);
                  if (picked != null) {
                    setState(() => _imagenSeleccionada = File(picked.path));
                  }
                  if (mounted) Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Cámara'),
                onTap: () async {
                  final XFile? picked =
                      await picker.pickImage(source: ImageSource.camera);
                  if (picked != null) {
                    setState(() => _imagenSeleccionada = File(picked.path));
                  }
                  if (mounted) Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _crearAlbum() async {
    final session = Provider.of<SessionNotifier>(context, listen: false);
    final usuario = session.usuarioActual;

    if (usuario == null) return;

    if (_tituloController.text.isEmpty ||
        _claveController.text.isEmpty ||
        _fechaSeleccionada == null ||
        _direccionController.text.isEmpty ||
        _ubicacionSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Completa todos los campos (incluyendo el mapa)")),
      );
      return;
    }

    final album = Album(
      id: null,
      titulo: _tituloController.text,
      fecha: _fechaSeleccionada!,
      portada: _imagenSeleccionada != null
          ? _imagenSeleccionada!.path
          : 'assets/images/cumple.jpg',
      administradorId: usuario.id!,
      clave: _claveController.text,
      lat: _ubicacionSeleccionada!.latitude,
      lng: _ubicacionSeleccionada!.longitude,
      direccion: _direccionController.text,
    );

    await MomentoDatabase.instance.crearAlbum(album);
    if (mounted) Navigator.pop(context);
  }

  Widget _buildImagenPreview() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: _imagenSeleccionada != null
          ? Image.file(_imagenSeleccionada!,
              height: 180, width: double.infinity, fit: BoxFit.cover)
          : Image.asset('assets/images/cumple.jpg',
              height: 180, width: double.infinity, fit: BoxFit.cover),
    );
  }

  Widget _buildMapaGratis() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Ubicación exacta (Toca el mapa)",
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Container(
          height: 250,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.orange.shade300, width: 2),
            borderRadius: BorderRadius.circular(15),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(13),
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: const LatLng(-31.5375, -68.5364),
                initialZoom: 13,
                onTap: (_, point) =>
                    setState(() => _ubicacionSeleccionada = point),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.momento.app',
                ),
                if (_ubicacionSeleccionada != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _ubicacionSeleccionada!,
                        width: 40,
                        height: 40,
                        child: const Icon(Icons.location_pin,
                            size: 40, color: Colors.red),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Nuevo Álbum"),
          backgroundColor: const Color.fromARGB(255, 255, 242, 221)),
      backgroundColor: const Color.fromARGB(255, 255, 242, 221),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Título", style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(controller: _tituloController),
            const SizedBox(height: 15),
            const Text("Clave privada",
                style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
                controller: _claveController,
                decoration: const InputDecoration(hintText: "Ej: 1234")),
            const SizedBox(height: 15),
            const Text("Dirección",
                style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
                controller: _direccionController,
                decoration:
                    const InputDecoration(hintText: "Ej: Calle Falsa 123")),
            const SizedBox(height: 15),
            const Text("Fecha del evento",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            GestureDetector(
              onTap: _seleccionarFecha,
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _fechaSeleccionada == null
                      ? "Seleccionar fecha"
                      : "${_fechaSeleccionada!.day}/${_fechaSeleccionada!.month}/${_fechaSeleccionada!.year}",
                  style: TextStyle(
                      color: _fechaSeleccionada == null
                          ? Colors.grey
                          : Colors.black),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildImagenPreview(),
            TextButton.icon(
                onPressed: _seleccionarImagen,
                icon: const Icon(Icons.image),
                label: const Text("Cambiar portada")),
            const SizedBox(height: 20),
            _buildMapaGratis(),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _crearAlbum,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text("CREAR ÁLBUM",
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
