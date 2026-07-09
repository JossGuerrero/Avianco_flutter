import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

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
    setState(() {
      _vuelos = data;
      _loading = false;
    });
  }

  Color _estadoColor(String estado) {
    switch (estado) {
      case 'programado':
        return const Color(0xFF2E7D32);
      case 'cancelado':
        return Colors.red;
      case 'despegado':
        return const Color(0xFF1565C0);
      case 'aterrizado':
        return const Color(0xFF7B2D8B);
      default:
        return Colors.grey;
    }
  }

  Future<void> _delete(int id) async {
    final ok = await ApiService.deleteVuelo(id);
    if (ok) {
      _load();
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Vuelo eliminado')));
    }
  }

  Future<void> _showForm({Map? vuelo}) async {
    final origenCtrl = TextEditingController(
      text: vuelo?['origen']?.toString() ?? '',
    );
    final destinoCtrl = TextEditingController(
      text: vuelo?['destino']?.toString() ?? '',
    );
    final aeronaveCtrl = TextEditingController(
      text: vuelo?['aeronave']?.toString() ?? '',
    );
    final salidaCtrl = TextEditingController(
      text: vuelo?['fecha_salida'] ?? '',
    );
    final llegadaCtrl = TextEditingController(
      text: vuelo?['fecha_llegada'] ?? '',
    );
    final precioCtrl = TextEditingController(text: vuelo?['precio'] ?? '');

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(vuelo == null ? 'Nuevo Vuelo' : 'Editar Vuelo'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: origenCtrl,
                decoration: const InputDecoration(labelText: 'ID Origen'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: destinoCtrl,
                decoration: const InputDecoration(labelText: 'ID Destino'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: aeronaveCtrl,
                decoration: const InputDecoration(labelText: 'ID Aeronave'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: salidaCtrl,
                decoration: const InputDecoration(
                  labelText: 'Salida (2026-07-01T08:00:00)',
                ),
              ),
              TextField(
                controller: llegadaCtrl,
                decoration: const InputDecoration(
                  labelText: 'Llegada (2026-07-01T09:00:00)',
                ),
              ),
              TextField(
                controller: precioCtrl,
                decoration: const InputDecoration(labelText: 'Precio'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7B2D8B),
            ),
            onPressed: () async {
              final data = {
                'origen': int.tryParse(origenCtrl.text) ?? 0,
                'destino': int.tryParse(destinoCtrl.text) ?? 0,
                'aeronave': int.tryParse(aeronaveCtrl.text) ?? 0,
                'fecha_salida': salidaCtrl.text,
                'fecha_llegada': llegadaCtrl.text,
                'precio': precioCtrl.text,
                'estado': 'programado',
              };
              bool ok;
              if (vuelo == null) {
                ok = await ApiService.createVuelo(data);
              } else {
                ok = await ApiService.updateVuelo(vuelo['id'], data);
              }
              if (mounted) {
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
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Guardar', style: TextStyle(color: Colors.white)),
          ),
        ],
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
                borderRadius: BorderRadius.circular(12),
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
                  backgroundColor: const Color(0xFF7B2D8B),
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
                  child: CircularProgressIndicator(color: Color(0xFF7B2D8B)),
                )
              : _vuelos.isEmpty
              ? const Center(child: Text('No hay vuelos'))
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
                    return Card(
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFF2E7D32),
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
                                  color: Color(0xFF7B2D8B),
                                ),
                                onPressed: () => _showForm(vuelo: v),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  size: 18,
                                  color: Colors.red,
                                ),
                                onPressed: () => _delete(v['id']),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
