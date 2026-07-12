class Aeropuerto {
  final int id;
  final String nombre;
  final String codigoIata;
  final String ciudad;
  final String pais;

  Aeropuerto({
    required this.id,
    required this.nombre,
    required this.codigoIata,
    required this.ciudad,
    required this.pais,
  });

  factory Aeropuerto.fromJson(Map<String, dynamic> json) {
    return Aeropuerto(
      id: json['id'],
      nombre: json['nombre'] ?? '',
      codigoIata: json['codigo_iata'] ?? '',
      ciudad: json['ciudad_nombre'] ?? json['ciudad'].toString(),
      pais: json['pais_nombre'] ?? json['pais'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'codigo_iata': codigoIata,
      'ciudad': ciudad,
      'pais': pais,
    };
  }
}
