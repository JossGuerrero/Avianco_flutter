class Promocion {
  final int id;
  final String codigo;
  final String descripcion;
  final double descuento;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final bool activa;

  Promocion({
    required this.id,
    required this.codigo,
    required this.descripcion,
    required this.descuento,
    required this.fechaInicio,
    required this.fechaFin,
    required this.activa,
  });

  factory Promocion.fromJson(Map<String, dynamic> json) {
    return Promocion(
      id: json['id'],
      codigo: json['codigo'] ?? '',
      descripcion: json['descripcion'] ?? '',
      descuento: double.tryParse(json['descuento'].toString()) ?? 0.0,
      fechaInicio: DateTime.parse(json['fecha_inicio']),
      fechaFin: DateTime.parse(json['fecha_fin']),
      activa: json['activa'] ?? false,
    );
  }
}
