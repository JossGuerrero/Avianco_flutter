import 'package:flutter/material.dart';
import '../config/app_colors.dart';
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
    final reservas = await ApiService.getReservas();
    if (!mounted) return;
    if (reservas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay reservas para hacer check-in'),
          backgroundColor: AppColors.primary,
        ),
      );
      return;
    }

    int? reservaId;
    final puertaCtrl = TextEditingController();
    final estadoCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    String reservaLabel(dynamic r) =>
        'Reserva #${r['id']} · Asiento ${r['asiento'] ?? '—'}';

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.how_to_reg, color: AppColors.primary),
              SizedBox(width: 8),
              Text('Nuevo Check-in'),
            ],
          ),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<int>(
                    initialValue: reservaId,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Reserva'),
                    items: reservas
                        .map<DropdownMenuItem<int>>(
                          (r) => DropdownMenuItem(
                            value: r['id'],
                            child: Text(
                              reservaLabel(r),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setDialogState(() => reservaId = v),
                    validator: (v) => v == null ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: puertaCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Puerta (ej: B12)',
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Requerido' : null,
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
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.dark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final data = {
                  'reserva': reservaId,
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
                      backgroundColor: AppColors.primary,
                    ),
                  );
                }
              },
              child: const Text(
                'Crear',
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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Check-ins',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.mainGradient),
        ),
      ),
      floatingActionButton: _isStaff
          ? FloatingActionButton(
              backgroundColor: AppColors.dark,
              onPressed: _showForm,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : (_items.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.how_to_reg, size: 64, color: Colors.grey),
                        SizedBox(height: 8),
                        Text(
                          'No hay check-ins registrados',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
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
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: AppColors.primaryLight,
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
