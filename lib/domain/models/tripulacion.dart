class Tripulacion {
  final int id;
  final String nombre;
  final String apellido;
  final String rol;
  final String licencia;
  final bool activo;

  Tripulacion({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.rol,
    required this.licencia,
    required this.activo,
  });

  factory Tripulacion.fromJson(Map<String, dynamic> json) {
    return Tripulacion(
      id: json['id'],
      nombre: json['nombre'] ?? '',
      apellido: json['apellido'] ?? '',
      rol: json['rol'] ?? '',
      licencia: json['licencia'] ?? '',
      activo: json['activo'] ?? false,
    );
  }
}
