import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/home_page.dart';
import 'package:flutter_application_1/pages/configperfil_page.dart';
import 'package:flutter_application_1/pages/detalle_album_page.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../services/database.dart';
import '../services/notifier.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  void _refrescar() => setState(() {});

  Widget _buildAvatar(String? fotoRuta) {
    if (fotoRuta != null && fotoRuta.isNotEmpty && File(fotoRuta).existsSync()) {
      return CircleAvatar(backgroundImage: FileImage(File(fotoRuta)));
    }
    return const CircleAvatar(backgroundImage: AssetImage('assets/images/avatar.jpg'));
  }

  @override
  Widget build(BuildContext context) {
    final session = Provider.of<SessionNotifier>(context);
    final usuarioActual = session.usuarioActual;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 242, 221),
        elevation: 0,
        actions: [
          IconButton(
            icon: _buildAvatar(usuarioActual?.fotoPerfil), // FOTO DINÁMICA
            onPressed: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (_) => const ConfigPerfilPage()));
              _refrescar();
            },
          ),
          TextButton(
            onPressed: () => _cerrarSesion(context),
            child: const Text('Cerrar Sesión', style: TextStyle(color: Colors.pinkAccent)),
          ),
        ],
      ),
      backgroundColor: const Color.fromARGB(255, 255, 242, 221),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await Navigator.pushNamed(context, 'unirseAlbumPage');
                      _refrescar();
                    },
                    icon: const Icon(Icons.favorite_border, color: Colors.white),
                    label: const Text('Unirse a un Álbum', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await Navigator.pushNamed(context, 'crearAlbumPage');
                      _refrescar();
                    },
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text('Nuevo Álbum', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: usuarioActual == null
                ? const Center(child: Text("Usuario no encontrado"))
                : FutureBuilder<List<Album>>(
                    future: MomentoDatabase.instance.obtenerAlbumesVisibles(usuarioActual),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                      if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text("No hay álbumes todavía"));
                      final albums = snapshot.data!;
                      return ListView.builder(
                        itemCount: albums.length,
                        itemBuilder: (context, index) {
                          final album = albums[index];
                          return _buildCardAlbum(album);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardAlbum(Album album) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: InkWell(
        onTap: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => DetalleAlbumPage(album: album)));
          _refrescar();
        },
        child: Card(
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                child: album.portada.startsWith('assets')
                    ? Image.asset(album.portada, height: 150, fit: BoxFit.cover)
                    : Image.file(File(album.portada), height: 150, fit: BoxFit.cover),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(album.titulo, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text("${album.fecha.day}/${album.fecha.month}/${album.fecha.year}", style: const TextStyle(color: Colors.grey)),
                    Text(album.direccion, style: const TextStyle(fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _cerrarSesion(BuildContext context) {
  Provider.of<SessionNotifier>(context, listen: false).logout();
  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const IniciarSesionPage()), (route) => false);
}