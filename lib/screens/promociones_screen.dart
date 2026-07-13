import 'package:flutter/material.dart';
import '../config/app_colors.dart';
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

  static const _blue = AppColors.primaryLight;

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
    final hoy = DateTime.now().toIso8601String().split('T').first;
    final fechaInicioCtrl = TextEditingController(
      text: promocion?['fecha_inicio'] ?? hoy,
    );
    final fechaFinCtrl = TextEditingController(
      text: promocion?['fecha_fin'] ?? '',
    );
    bool activa = promocion?['activa'] ?? true;
    final formKey = GlobalKey<FormState>();

    Future<void> pickFecha(TextEditingController ctrl) async {
      final actual = DateTime.tryParse(ctrl.text) ?? DateTime.now();
      final d = await showDatePicker(
        context: context,
        initialDate: actual,
        firstDate: DateTime(2024),
        lastDate: DateTime(2030),
      );
      if (d != null) ctrl.text = d.toIso8601String().split('T').first;
    }

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _blue.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.local_offer, color: _blue, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  promocion == null ? 'Nueva Promoción' : 'Editar Promoción',
                  style: const TextStyle(fontSize: 17),
                ),
              ),
            ],
          ),
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
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: fechaInicioCtrl,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Fecha inicio',
                      suffixIcon: Icon(
                        Icons.calendar_today,
                        size: 18,
                        color: _blue,
                      ),
                    ),
                    onTap: () => pickFecha(fechaInicioCtrl),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: fechaFinCtrl,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Fecha fin',
                      suffixIcon: Icon(
                        Icons.event,
                        size: 18,
                        color: _blue,
                      ),
                    ),
                    onTap: () => pickFecha(fechaFinCtrl),
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
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.dark,
                minimumSize: const Size(120, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final data = {
                  'codigo': codigoCtrl.text.toUpperCase(),
                  'descripcion': descripcionCtrl.text,
                  'descuento': int.tryParse(descuentoCtrl.text) ?? 0,
                  'fecha_inicio': fechaInicioCtrl.text,
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
                if (!mounted) return;
                if (ok) {
                  _load();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Guardado exitosamente')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        ApiService.lastError.isNotEmpty
                            ? 'Error: ${ApiService.lastError}'
                            : 'Error al guardar',
                      ),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 5),
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Promociones',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.mainGradient),
        ),
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
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = _items[index];
                  final activa = item['activa'] == true;
                  final pct = item['descuento']?.toString() ?? '0';

                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Cabecera con gradiente
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            gradient: activa
                                ? AppColors.promoGradient
                                : const LinearGradient(
                                    colors: [Color(0xFF757575), Color(0xFF424242)],
                                  ),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                item['codigo'] ?? '—',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '$pct% OFF',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Cuerpo de la card
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['descripcion'] ?? '—',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: AppColors.dark,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.calendar_today,
                                          size: 12,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Vence: ${item['fecha_fin'] ?? '—'}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: activa
                                                ? AppColors.primary.withValues(alpha: 0.1)
                                                : Colors.grey.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            activa ? 'Activa' : 'Inactiva',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: activa
                                                  ? AppColors.primary
                                                  : Colors.grey,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              if (_isStaff)
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        size: 20,
                                        color: _blue,
                                      ),
                                      onPressed: () =>
                                          _showForm(promocion: item),
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
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }
}
