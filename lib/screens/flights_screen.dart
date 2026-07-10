import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'seat_selector_screen.dart';

class FlightsScreen extends StatefulWidget {
  const FlightsScreen({super.key});

  @override
  State<FlightsScreen> createState() => _FlightsScreenState();
}

class _FlightsScreenState extends State<FlightsScreen> {
  List<dynamic> _vuelos = [];
  bool _loading = true;
  bool _isStaff = false;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({String search = ''}) async {
    setState(() => _loading = true);
    _isStaff = await AuthService.isStaff();
    final data = await ApiService.getVuelos(search: search);
    if (!mounted) return;
    setState(() {
      _vuelos = data;
      _loading = false;
    });
  }

  Color _estadoColor(String estado) {
    switch (estado) {
      case 'programado':
        return AppColors.success;
      case 'cancelado':
        return AppColors.primary;
      case 'despegado':
        return AppColors.greyDark;
      case 'aterrizado':
        return AppColors.dark;
      default:
        return Colors.grey;
    }
  }

  Future<void> _delete(int id) async {
    final ok = await ApiService.deleteVuelo(id);
    if (!mounted) return;
    if (ok) {
      _load();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vuelo eliminado')));
    }
  }

  /// Detalle del vuelo: escalas y timeline de estados.
  void _showDetalles(Map v) {
    final origen = v['origen_detalle']?['codigo_iata'] ?? v['origen'];
    final destino = v['destino_detalle']?['codigo_iata'] ?? v['destino'];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.35,
        maxChildSize: 0.9,
        builder: (ctx, scrollCtrl) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: FutureBuilder<List<List<dynamic>>>(
            future: Future.wait([
              ApiService.getEscalasPorVuelo(v['id']),
              ApiService.getEstadosVueloPorVuelo(v['id']),
            ]),
            builder: (ctx, snap) {
              if (!snap.hasData) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }
              final escalas = snap.data![0];
              final estados = snap.data![1];
              return ListView(
                controller: scrollCtrl,
                padding: const EdgeInsets.all(20),
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Text(
                    'Vuelo #${v['id']} · $origen → $destino',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.dark,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Escalas',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (escalas.isEmpty)
                    const Text(
                      'Vuelo directo, sin escalas.',
                      style: TextStyle(color: Colors.grey),
                    )
                  else
                    ...escalas.map(
                      (e) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.connecting_airports,
                          color: AppColors.primary,
                        ),
                        title: Text(
                          (e['aeropuerto_detalle']?['nombre'] ??
                                  'Aeropuerto ${e['aeropuerto']}')
                              .toString(),
                        ),
                        subtitle: Text(
                          'Orden ${e['orden'] ?? '—'} · '
                          'Duración ${e['duracion'] ?? e['duracion_minutos'] ?? '—'}',
                        ),
                      ),
                    ),
                  const SizedBox(height: 14),
                  const Text(
                    'Historial de estados',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (estados.isEmpty)
                    const Text(
                      'Sin historial de estados.',
                      style: TextStyle(color: Colors.grey),
                    )
                  else
                    ...estados.map(
                      (e) => Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              const Icon(
                                Icons.circle,
                                size: 12,
                                color: AppColors.primary,
                              ),
                              Container(
                                width: 2,
                                height: 28,
                                color: Colors.grey[300],
                              ),
                            ],
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  (e['estado'] ?? '—').toString(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  (e['fecha'] ?? e['fecha_cambio'] ?? '')
                                      .toString()
                                      .replaceAll('T', ' '),
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 20),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)}T${two(d.hour)}:${two(d.minute)}:00';
  }

  Future<DateTime?> _pickDateTime(DateTime? initial) async {
    final date = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (date == null || !mounted) return null;
    final time = await showTimePicker(
      context: context,
      initialTime: initial != null
          ? TimeOfDay.fromDateTime(initial)
          : TimeOfDay.now(),
    );
    if (time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<void> _showForm({Map? vuelo}) async {
    // Carga catálogos para los dropdowns
    final results = await Future.wait([
      ApiService.getAeropuertos(),
      ApiService.getAeronaves(),
    ]);
    if (!mounted) return;
    final aeropuertos = results[0];
    final aeronaves = results[1];

    if (aeropuertos.isEmpty || aeronaves.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Primero registra aeropuertos y aeronaves'),
          backgroundColor: AppColors.primary,
        ),
      );
      return;
    }

    int? origenId = vuelo?['origen'];
    int? destinoId = vuelo?['destino'];
    int? aeronaveId = vuelo?['aeronave'];
    DateTime? salida = DateTime.tryParse(vuelo?['fecha_salida'] ?? '');
    DateTime? llegada = DateTime.tryParse(vuelo?['fecha_llegada'] ?? '');
    final precioCtrl = TextEditingController(
      text: vuelo?['precio']?.toString() ?? '',
    );
    final formKey = GlobalKey<FormState>();

    String airportLabel(dynamic a) =>
        '${a['ciudad'] ?? a['nombre'] ?? ''} (${a['codigo_iata'] ?? ''})';
    String aircraftLabel(dynamic a) =>
        '${a['modelo'] ?? ''} - ${a['matricula'] ?? ''}';

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Row(
            children: [
              const Icon(Icons.flight_takeoff, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(vuelo == null ? 'Nuevo Vuelo' : 'Editar Vuelo'),
            ],
          ),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<int>(
                    initialValue: origenId,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Origen'),
                    items: aeropuertos
                        .map<DropdownMenuItem<int>>(
                          (a) => DropdownMenuItem(
                            value: a['id'],
                            child: Text(
                              airportLabel(a),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setDialogState(() => origenId = v),
                    validator: (v) => v == null ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    initialValue: destinoId,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Destino'),
                    items: aeropuertos
                        .map<DropdownMenuItem<int>>(
                          (a) => DropdownMenuItem(
                            value: a['id'],
                            child: Text(
                              airportLabel(a),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setDialogState(() => destinoId = v),
                    validator: (v) {
                      if (v == null) return 'Requerido';
                      if (v == origenId) {
                        return 'Debe ser distinto al origen';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    initialValue: aeronaveId,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Aeronave'),
                    items: aeronaves
                        .map<DropdownMenuItem<int>>(
                          (a) => DropdownMenuItem(
                            value: a['id'],
                            child: Text(
                              aircraftLabel(a),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setDialogState(() => aeronaveId = v),
                    validator: (v) => v == null ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.calendar_today,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    title: Text(
                      salida == null
                          ? 'Fecha y hora de salida'
                          : 'Salida: ${_formatDateTime(salida!).replaceAll('T', ' ').substring(0, 16)}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    trailing: const Icon(Icons.edit, size: 16),
                    onTap: () async {
                      final picked = await _pickDateTime(salida);
                      if (picked != null) {
                        setDialogState(() => salida = picked);
                      }
                    },
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.calendar_month,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    title: Text(
                      llegada == null
                          ? 'Fecha y hora de llegada'
                          : 'Llegada: ${_formatDateTime(llegada!).replaceAll('T', ' ').substring(0, 16)}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    trailing: const Icon(Icons.edit, size: 16),
                    onTap: () async {
                      final picked = await _pickDateTime(llegada);
                      if (picked != null) {
                        setDialogState(() => llegada = picked);
                      }
                    },
                  ),
                  TextFormField(
                    controller: precioCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Precio (USD)',
                      prefixText: '\$ ',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Requerido' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.dark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                if (salida == null || llegada == null) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(
                      content: Text('Selecciona fechas de salida y llegada'),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                  return;
                }
                final data = {
                  'origen': origenId,
                  'destino': destinoId,
                  'aeronave': aeronaveId,
                  'fecha_salida': _formatDateTime(salida!),
                  'fecha_llegada': _formatDateTime(llegada!),
                  'precio': precioCtrl.text,
                  'estado': vuelo?['estado'] ?? 'programado',
                };
                bool ok;
                if (vuelo == null) {
                  ok = await ApiService.createVuelo(data);
                } else {
                  ok = await ApiService.updateVuelo(vuelo['id'], data);
                }
                if (!ctx.mounted) return;
                Navigator.pop(ctx);
                if (ok) {
                  _load();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Guardado exitosamente')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Error al guardar'),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                }
              },
              child: const Text(
                'Guardar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: _searchCtrl,
            decoration: InputDecoration(
              hintText: 'Buscar vuelo...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchCtrl.clear();
                  _load();
                },
              ),
            ),
            onChanged: (v) => _load(search: v),
          ),
        ),
        if (_isStaff)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.dark,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () => _showForm(),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  'Nuevo Vuelo',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        Expanded(
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
              : _vuelos.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.flight_takeoff, size: 64, color: Colors.grey),
                      SizedBox(height: 8),
                      Text(
                        'No hay vuelos',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: _vuelos.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (ctx, i) {
                    final v = _vuelos[i];
                    final origen =
                        v['origen_detalle']?['codigo_iata'] ??
                        v['origen'].toString();
                    final destino =
                        v['destino_detalle']?['codigo_iata'] ??
                        v['destino'].toString();
    Future<void> abrirSelector(Map v) async {
                      final reservado = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SeatSelectorScreen(vuelo: v),
                        ),
                      );
                      if (reservado == true) _load();
                    }

                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          ListTile(
                        onTap: v['estado'] == 'programado'
                            ? () => abrirSelector(v)
                            : null,
                        leading: const CircleAvatar(
                          backgroundColor: AppColors.primary,
                          child: Icon(
                            Icons.flight_takeoff,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          '$origen → $destino',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${v['fecha_salida'].toString().substring(0, 16).replaceAll('T', ' ')} · \$${v['precio']}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _estadoColor(v['estado']),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                v['estado'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            if (_isStaff) ...[
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  size: 18,
                                  color: AppColors.dark,
                                ),
                                onPressed: () => _showForm(vuelo: v),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  size: 18,
                                  color: AppColors.primary,
                                ),
                                onPressed: () => _delete(v['id']),
                              ),
                            ],
                          ],
                        ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                            child: Row(
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    height: 44,
                                    child: OutlinedButton.icon(
                                      onPressed: () => _showDetalles(v),
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(
                                          color: AppColors.dark,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                        ),
                                      ),
                                      icon: const Icon(
                                        Icons.info_outline,
                                        color: AppColors.dark,
                                        size: 16,
                                      ),
                                      label: const Text(
                                        'DETALLES',
                                        style: TextStyle(
                                          color: AppColors.dark,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                if (v['estado'] == 'programado') ...[
                                  const SizedBox(width: 10),
                                  Expanded(
                                    flex: 2,
                                    child: SizedBox(
                                      height: 44,
                                      child: ElevatedButton.icon(
                                        onPressed: () => abrirSelector(v),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(14),
                                          ),
                                        ),
                                        icon: const Icon(
                                          Icons.event_seat,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                        label: const Text(
                                          'RESERVAR',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.2,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
