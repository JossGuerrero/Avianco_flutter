class Pasajero {
  final int id;
  final String nombre;
  final String apellido;
  final String documentoIdentidad;
  final String email;
  final String telefono;

  Pasajero({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.documentoIdentidad,
    required this.email,
    required this.telefono,
  });

  factory Pasajero.fromJson(Map<String, dynamic> json) {
    return Pasajero(
      id: json['id'],
      nombre: json['nombre'] ?? '',
      apellido: json['apellido'] ?? '',
      documentoIdentidad: json['documento_identidad'] ?? '',
      email: json['email'] ?? '',
      telefono: json['telefono'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'apellido': apellido,
      'documento_identidad': documentoIdentidad,
      'email': email,
      'telefono': telefono,
    };
  }
}
