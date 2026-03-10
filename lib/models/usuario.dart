class Usuario {
  final int? id;
  final String nombre;
  final String apellido;
  final String correo;
  final String contrasena;
  final String? fotoPerfil;
  final int esAdministrador;

  Usuario({
    this.id,
    required this.nombre,
    required this.apellido,
    required this.correo,
    required this.contrasena,
    this.fotoPerfil,
    this.esAdministrador = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'apellido': apellido,
      'correo': correo,
      'contrasena': contrasena,
      'foto_perfil': fotoPerfil,
      'es_administrador': esAdministrador,
    };
  }

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['id'],
      nombre: map['nombre'],
      apellido: map['apellido'],
      correo: map['correo'],
      contrasena: map['contrasena'],
      fotoPerfil: map['foto_perfil'],
      esAdministrador: map['es_administrador'],
    );
  }
}