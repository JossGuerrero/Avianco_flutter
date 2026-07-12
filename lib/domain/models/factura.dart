class Factura {
  final int id;
  final int reservaId;
  final double total;
  final double impuestos;
  final DateTime fechaEmision;
  final String estado;

  Factura({
    required this.id,
    required this.reservaId,
    required this.total,
    required this.impuestos,
    required this.fechaEmision,
    required this.estado,
  });

  factory Factura.fromJson(Map<String, dynamic> json) {
    return Factura(
      id: json['id'],
      reservaId: json['reserva'],
      total: double.tryParse(json['total'].toString()) ?? 0.0,
      impuestos: double.tryParse(json['impuestos'].toString()) ?? 0.0,
      fechaEmision: DateTime.parse(json['fecha_emision']),
      estado: json['estado'] ?? '',
    );
  }
}
