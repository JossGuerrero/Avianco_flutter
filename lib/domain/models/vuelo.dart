class Vuelo {
  final int id;
  final String numeroVuelo;
  final String origen;
  final String destino;
  final DateTime fechaSalida;
  final DateTime fechaLlegada;
  final String estado;
  final double precioBase;
  final int aeronaveId;

  Vuelo({
    required this.id,
    required this.numeroVuelo,
    required this.origen,
    required this.destino,
    required this.fechaSalida,
    required this.fechaLlegada,
    required this.estado,
    required this.precioBase,
    required this.aeronaveId,
  });

  factory Vuelo.fromJson(Map<String, dynamic> json) {
    return Vuelo(
      id: json['id'],
      numeroVuelo: json['numero_vuelo'] ?? '',
      origen: json['origen_nombre'] ?? json['origen'].toString(),
      destino: json['destino_nombre'] ?? json['destino'].toString(),
      fechaSalida: DateTime.parse(json['fecha_salida']),
      fechaLlegada: DateTime.parse(json['fecha_llegada']),
      estado: json['estado_nombre'] ?? json['estado'].toString(),
      precioBase: double.tryParse(json['precio_base'].toString()) ?? 0.0,
      aeronaveId: json['aeronave'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'numero_vuelo': numeroVuelo,
      'origen': origen,
      'destino': destino,
      'fecha_salida': fechaSalida.toIso8601String(),
      'fecha_llegada': fechaLlegada.toIso8601String(),
      'estado': estado,
      'precio_base': precioBase,
      'aeronave': aeronaveId,
    };
  }
}
