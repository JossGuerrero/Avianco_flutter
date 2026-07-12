class Servicio {
  final int id;
  final String nombre;
  final String descripcion;
  final double precio;

  Servicio({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
  });

  factory Servicio.fromJson(Map<String, dynamic> json) {
    return Servicio(
      id: json['id'],
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'] ?? '',
      precio: double.tryParse(json['precio'].toString()) ?? 0.0,
    );
  }
}
