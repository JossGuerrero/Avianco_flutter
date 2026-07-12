class Aeronave {
  final int id;
  final String matricula;
  final String modelo;
  final int capacidad;
  final String estado;

  Aeronave({
    required this.id,
    required this.matricula,
    required this.modelo,
    required this.capacidad,
    required this.estado,
  });

  factory Aeronave.fromJson(Map<String, dynamic> json) {
    return Aeronave(
      id: json['id'],
      matricula: json['matricula'] ?? '',
      modelo: json['modelo_nombre'] ?? json['modelo'].toString(),
      capacidad: json['capacidad'] ?? 0,
      estado: json['estado'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'matricula': matricula,
      'modelo': modelo,
      'capacidad': capacidad,
      'estado': estado,
    };
  }
}
