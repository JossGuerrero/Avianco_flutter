import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class CheckinsScreen extends StatefulWidget {
  const CheckinsScreen({super.key});

  @override
  State<CheckinsScreen> createState() => _CheckinsScreenState();
}

class _CheckinsScreenState extends State<CheckinsScreen> {
  List<dynamic> _items = [];
  bool _loading = true;
  bool _isStaff = false;

  static const _blue = Color(0xFF0277BD);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    _isStaff = await AuthService.isStaff();
    final data = await ApiService.getCheckins();
    if (!mounted) return;
    setState(() {
      _items = data;
      _loading = false;
    });
  }

  Future<void> _showForm() async {
    final reservaCtrl = TextEditingController();
    final puertaCtrl = TextEditingController();
    final estadoCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nuevo Check-in'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: reservaCtrl,
                  decoration: const InputDecoration(labelText: 'ID Reserva'),
                  keyboardType: TextInputType.number,
                  validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                ),
                TextFormField(
                  controller: puertaCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Puerta (ej: B12)',
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                ),
                TextFormField(
                  controller: estadoCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Estado (opcional)',
                  ),
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
            style: ElevatedButton.styleFrom(backgroundColor: _blue),
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final data = {
                'reserva': int.tryParse(reservaCtrl.text) ?? 0,
                'puerta': puertaCtrl.text,
                'estado': estadoCtrl.text.isEmpty
                    ? 'Pendiente'
                    : estadoCtrl.text,
              };
              final ok = await ApiService.createCheckin(data);
              if (!ctx.mounted) return;
              Navigator.pop(ctx);
              if (ok) {
                _load();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Check-in creado')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Error al crear'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Crear', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Check-ins'),
        backgroundColor: _blue,
      ),
      floatingActionButton: _isStaff
          ? FloatingActionButton(
              backgroundColor: _blue,
              onPressed: _showForm,
              child: const Icon(Icons.add),
            )
          : null,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : (_items.isEmpty
                ? const Center(child: Text('No hay check-ins registrados'))
                : RefreshIndicator(
                    onRefresh: _load,
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = _items[index];
                        final reserva = item['reserva'] ?? '';
                        final puerta = item['puerta'] ?? '—';
                        final estado = item['estado'] ?? '';
                        return Card(
                          child: ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: _blue,
                              child: Icon(
                                Icons.check_circle,
                                color: Colors.white,
                              ),
                            ),
                            title: Text('Reserva #$reserva'),
                            subtitle: Text('Puerta $puerta · $estado'),
                            trailing: const Icon(Icons.chevron_right),
                          ),
                        );
                      },
                    ),
                  )),
    );
  }
}
