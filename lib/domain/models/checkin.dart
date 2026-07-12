class Checkin {
  final int id;
  final int reservaId;
  final DateTime fechaCheckin;
  final String puerta;
  final String estado;

  Checkin({
    required this.id,
    required this.reservaId,
    required this.fechaCheckin,
    required this.puerta,
    required this.estado,
  });

  factory Checkin.fromJson(Map<String, dynamic> json) {
    return Checkin(
      id: json['id'],
      reservaId: json['reserva'],
      fechaCheckin: DateTime.parse(json['fecha_checkin']),
      puerta: json['puerta'] ?? '',
      estado: json['estado'] ?? '',
    );
  }
}
