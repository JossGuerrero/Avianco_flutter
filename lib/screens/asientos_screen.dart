import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class SeatsScreen extends StatefulWidget {
  const SeatsScreen({super.key});

  @override
  State<SeatsScreen> createState() => _SeatsScreenState();
}

class _SeatsScreenState extends State<SeatsScreen> {
  List<dynamic> _items = [];
  bool _loading = true;
  bool _isStaff = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({String search = ''}) async {
    setState(() => _loading = true);
    _isStaff = await AuthService.isStaff();
    final data = await ApiService.getAsientos(search: search);
    if (!mounted) return;
    setState(() {
      _items = data;
      _loading = false;
    });
  }

  Future<void> _showForm() async {
    final vuelos = await ApiService.getVuelos();
    if (!mounted) return;
    if (vuelos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Primero registra vuelos'),
          backgroundColor: AppColors.primary,
        ),
      );
      return;
    }

    int? vueloId;
    final codigoCtrl = TextEditingController();
    final filaCtrl = TextEditingController();
    final columnaCtrl = TextEditingController();
    bool disponible = true;
    final formKey = GlobalKey<FormState>();

    String vueloLabel(dynamic v) {
      final o = v['origen_detalle']?['codigo_iata'] ?? v['origen'];
      final d = v['destino_detalle']?['codigo_iata'] ?? v['destino'];
      final fecha = (v['fecha_salida'] ?? '').toString().split('T').first;
      return '$o → $d · $fecha';
    }

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.event_seat, color: AppColors.primary),
              SizedBox(width: 8),
              Text('Nuevo Asiento'),
            ],
          ),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<int>(
                    initialValue: vueloId,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Vuelo'),
                    items: vuelos
                        .map<DropdownMenuItem<int>>(
                          (v) => DropdownMenuItem(
                            value: v['id'],
                            child: Text(
                              vueloLabel(v),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setDialogState(() => vueloId = v),
                    validator: (v) => v == null ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: codigoCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Código (ej: 12A)',
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Requerido' : null,
                  ),
                  TextFormField(
                    controller: filaCtrl,
                    decoration: const InputDecoration(labelText: 'Fila'),
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Requerido' : null,
                  ),
                  TextFormField(
                    controller: columnaCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Columna (ej: A)',
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Requerido' : null,
                  ),
                  SwitchListTile(
                    title: const Text('Disponible'),
                    value: disponible,
                    activeThumbColor: AppColors.primary,
                    onChanged: (v) => setDialogState(() => disponible = v),
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
                  'codigo': codigoCtrl.text,
                  'fila': int.tryParse(filaCtrl.text) ?? 0,
                  'columna': columnaCtrl.text,
                  'vuelo': vueloId,
                  'disponible': disponible,
                };
                final ok = await ApiService.createAsiento(data);
                if (!ctx.mounted) return;
                Navigator.pop(ctx);
                if (ok) {
                  await _load();
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Asiento creado')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Error al crear asiento'),
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
          'Asientos',
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
          : _items.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_seat, size: 64, color: Colors.grey),
                  SizedBox(height: 8),
                  Text(
                    'No hay asientos registrados',
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
                  final codigo = item['codigo'] ?? '';
                  final fila = item['fila']?.toString() ?? '';
                  final columna = item['columna'] ?? '';
                  final disponible = item['disponible'] == true;
                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: disponible
                            ? AppColors.success
                            : AppColors.greyAccent,
                        child: const Icon(
                          Icons.event_seat,
                          color: Colors.white,
                        ),
                      ),
                      title: Text('Asiento $codigo'),
                      subtitle: Text('Fila $fila · Columna $columna'),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: disponible
                              ? AppColors.success
                              : AppColors.greyAccent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          disponible ? 'Disponible' : 'Ocupado',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
