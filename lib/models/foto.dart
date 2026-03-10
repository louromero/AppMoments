class Foto {
  final int? id;
  final int albumId;
  final int usuarioId;
  final String rutaFoto;
  final String fechaSubida;

  Foto({
    this.id,
    required this.albumId,
    required this.usuarioId,
    required this.rutaFoto,
    required this.fechaSubida,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'album_id': albumId,
      'usuario_id': usuarioId,
      'ruta_foto': rutaFoto,
      'fecha_subida': fechaSubida,
    };
  }

  factory Foto.fromMap(Map<String, dynamic> map) {
    return Foto(
      id: map['id'],
      albumId: map['album_id'],
      usuarioId: map['usuario_id'],
      rutaFoto: map['ruta_foto'],
      fechaSubida: map['fecha_subida'],
    );
  }
}