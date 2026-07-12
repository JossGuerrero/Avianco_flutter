class Asiento {
  final int id;
  final String codigo;
  final int fila;
  final String columna;
  final bool disponible;
  final int vueloId;

  Asiento({
    required this.id,
    required this.codigo,
    required this.fila,
    required this.columna,
    required this.disponible,
    required this.vueloId,
  });

  factory Asiento.fromJson(Map<String, dynamic> json) {
    return Asiento(
      id: json['id'],
      codigo: json['codigo'] ?? '',
      fila: json['fila'] ?? 0,
      columna: json['columna'] ?? '',
      disponible: json['disponible'] ?? false,
      vueloId: json['vuelo'] ?? 0,
    );
  }
}
