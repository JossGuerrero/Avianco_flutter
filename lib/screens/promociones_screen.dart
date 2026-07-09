import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class PromotionsScreen extends StatefulWidget {
  const PromotionsScreen({super.key});

  @override
  State<PromotionsScreen> createState() => _PromotionsScreenState();
}

class _PromotionsScreenState extends State<PromotionsScreen> {
  List<dynamic> _items = [];
  bool _loading = true;
  bool _isStaff = false;

  static const _blue = Color(0xFF1565C0);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    _isStaff = await AuthService.isStaff();
    final data = await ApiService.getPromociones();
    if (!mounted) return;
    setState(() {
      _items = data;
      _loading = false;
    });
  }

  Future<void> _delete(int id) async {
    final ok = await ApiService.deletePromocion(id);
    if (!mounted) return;
    if (ok) {
      _load();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Promoción eliminada')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al eliminar'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _confirmDelete(Map p) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar promoción'),
        content: Text('¿Eliminar ${p['codigo']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) _delete(p['id']);
  }

  Future<void> _showForm({Map? promocion}) async {
    final codigoCtrl = TextEditingController(text: promocion?['codigo'] ?? '');
    final descripcionCtrl = TextEditingController(
      text: promocion?['descripcion'] ?? '',
    );
    final descuentoCtrl = TextEditingController(
      text: promocion?['descuento']?.toString() ?? '',
    );
    final fechaFinCtrl = TextEditingController(
      text: promocion?['fecha_fin'] ?? '',
    );
    bool activa = promocion?['activa'] ?? true;
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(promocion == null ? 'Nueva Promoción' : 'Editar Promoción'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: codigoCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Código (ej: VERANO25)',
                    ),
                    textCapitalization: TextCapitalization.characters,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Requerido' : null,
                  ),
                  TextFormField(
                    controller: descripcionCtrl,
                    decoration: const InputDecoration(labelText: 'Descripción'),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Requerido' : null,
                  ),
                  TextFormField(
                    controller: descuentoCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Descuento (%)',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Requerido' : null,
                  ),
                  TextFormField(
                    controller: fechaFinCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Fecha fin (2026-12-31)',
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Requerido' : null,
                  ),
                  SwitchListTile(
                    title: const Text('Activa'),
                    value: activa,
                    activeThumbColor: _blue,
                    onChanged: (v) => setDialogState(() => activa = v),
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
                  'codigo': codigoCtrl.text.toUpperCase(),
                  'descripcion': descripcionCtrl.text,
                  'descuento': int.tryParse(descuentoCtrl.text) ?? 0,
                  'fecha_fin': fechaFinCtrl.text,
                  'activa': activa,
                };
                bool ok;
                if (promocion == null) {
                  ok = await ApiService.createPromocion(data);
                } else {
                  ok = await ApiService.updatePromocion(
                    promocion['id'],
                    data,
                  );
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
                      backgroundColor: Colors.red,
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Promociones'),
        backgroundColor: _blue,
      ),
      floatingActionButton: _isStaff
          ? FloatingActionButton(
              backgroundColor: _blue,
              onPressed: () => _showForm(),
              child: const Icon(Icons.add),
            )
          : null,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
          ? const Center(child: Text('No hay promociones disponibles'))
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = _items[index];
                  final activa = item['activa'] == true;
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: activa ? _blue : Colors.grey,
                        child: const Icon(
                          Icons.local_offer,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        item['codigo'] ?? 'Promoción',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${item['descripcion'] ?? ''}\n${item['descuento'] ?? 0}% · Vence: ${item['fecha_fin'] ?? '—'}',
                      ),
                      isThreeLine: true,
                      trailing: _isStaff
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    size: 20,
                                    color: _blue,
                                  ),
                                  onPressed: () => _showForm(promocion: item),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    size: 20,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => _confirmDelete(item),
                                ),
                              ],
                            )
                          : null,
                    ),
                  );
                },
              ),
            ),
    );
  }
}
