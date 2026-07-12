class Reserva {
  final int id;
  final int vueloId;
  final int pasajeroId;
  final String asiento;
  final DateTime fechaReserva;
  final String estado;
  final String? vueloNumero;
  final String? pasajeroNombre;

  Reserva({
    required this.id,
    required this.vueloId,
    required this.pasajeroId,
    required this.asiento,
    required this.fechaReserva,
    required this.estado,
    this.vueloNumero,
    this.pasajeroNombre,
  });

  factory Reserva.fromJson(Map<String, dynamic> json) {
    return Reserva(
      id: json['id'],
      vueloId: json['vuelo'],
      pasajeroId: json['pasajero'],
      asiento: json['asiento'] ?? '',
      fechaReserva: DateTime.parse(json['fecha_reserva']),
      estado: json['estado'] ?? '',
      vueloNumero: json['vuelo_numero'],
      pasajeroNombre: json['pasajero_nombre'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vuelo': vueloId,
      'pasajero': pasajeroId,
      'asiento': asiento,
      'estado': estado,
    };
  }
}
