import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class ReservationsScreen extends StatefulWidget {
  const ReservationsScreen({super.key});

  @override
  State<ReservationsScreen> createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen> {
  List<dynamic> _reservas = [];
  bool _loading = true;
  bool _isStaff = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    _isStaff = await AuthService.isStaff();
    final data = await ApiService.getReservas();
    setState(() {
      _reservas = data;
      _loading = false;
    });
  }

  Color _estadoColor(String estado) {
    switch (estado) {
      case 'confirmada':
        return const Color(0xFF2E7D32);
      case 'cancelada':
        return Colors.red;
      case 'embarcado':
        return const Color(0xFF1565C0);
      default:
        return Colors.grey;
    }
  }

  Future<void> _delete(int id) async {
    final ok = await ApiService.deleteReserva(id);
    if (ok) {
      _load();
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Reserva eliminada')));
    }
  }

  Future<void> _showForm({Map? reserva}) async {
    final vueloCtrl = TextEditingController(
      text: reserva?['vuelo']?.toString() ?? '',
    );
    final pasajeroCtrl = TextEditingController(
      text: reserva?['pasajero']?.toString() ?? '',
    );
    final asientoCtrl = TextEditingController(text: reserva?['asiento'] ?? '');

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(reserva == null ? 'Nueva Reserva' : 'Editar Reserva'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: vueloCtrl,
              decoration: const InputDecoration(labelText: 'ID Vuelo'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: pasajeroCtrl,
              decoration: const InputDecoration(labelText: 'ID Pasajero'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: asientoCtrl,
              decoration: const InputDecoration(labelText: 'Asiento (ej: 12A)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1565C0),
            ),
            onPressed: () async {
              final data = {
                'vuelo': int.tryParse(vueloCtrl.text) ?? 0,
                'pasajero': int.tryParse(pasajeroCtrl.text) ?? 0,
                'asiento': asientoCtrl.text,
                'estado': 'confirmada',
              };
              bool ok;
              if (reserva == null) {
                ok = await ApiService.createReserva(data);
              } else {
                ok = await ApiService.updateReserva(reserva['id'], data);
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
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
              ),
              onPressed: () => _showForm(),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Nueva Reserva',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
        Expanded(
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFF1565C0)),
                )
              : _reservas.isEmpty
              ? const Center(child: Text('No hay reservas'))
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: _reservas.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (ctx, i) {
                    final r = _reservas[i];
                    return Card(
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFF1565C0),
                          child: Icon(Icons.book_online, color: Colors.white),
                        ),
                        title: Text(
                          'Reserva #${r['id']} — Asiento ${r['asiento']}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Vuelo: ${r['vuelo']} | Pasajero: ${r['pasajero']}',
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
                                color: _estadoColor(r['estado']),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                r['estado'],
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
                                  color: Color(0xFF1565C0),
                                ),
                                onPressed: () => _showForm(reserva: r),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  size: 18,
                                  color: Colors.red,
                                ),
                                onPressed: () => _delete(r['id']),
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
