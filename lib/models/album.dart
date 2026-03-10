class Album {
  final int? id;
  final String titulo;
  final DateTime fecha;
  final String portada;
  final int administradorId;
  final String clave;
  final double lat;
  final double lng;
  final String direccion;
  final int esDemo;

  Album({
    this.id,
    required this.titulo,
    required this.fecha,
    required this.portada,
    required this.administradorId,
    required this.clave,
    required this.lat,
    required this.lng,
    required this.direccion,
    this.esDemo = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'fecha': fecha.toIso8601String(),
      'portada': portada,
      'administrador_id': administradorId,
      'clave': clave,
      'lat': lat,
      'lng': lng,
      'direccion': direccion,
      'es_demo': esDemo,
    };
  }

  factory Album.fromMap(Map<String, dynamic> map) {
    return Album(
      id: map['id'],
      titulo: map['titulo'],
      fecha: DateTime.parse(map['fecha']),
      portada: map['portada'],
      administradorId: map['administrador_id'],
      clave: map['clave'],
      lat: (map['lat'] as num).toDouble(),
      lng: (map['lng'] as num).toDouble(),
      direccion: map['direccion'],
      esDemo: map['es_demo'] ?? 0,
    );
  }
}