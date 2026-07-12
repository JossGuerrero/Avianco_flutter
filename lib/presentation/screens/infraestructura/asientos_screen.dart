import 'package:flutter/material.dart';
import 'package:avianco/services/api_service.dart';
import 'package:avianco/services/auth_service.dart';

class SeatsScreen extends StatefulWidget {
  const SeatsScreen({super.key});

  @override
  State<SeatsScreen> createState() => _SeatsScreenState();
}

class _SeatsScreenState extends State<SeatsScreen> {
  List<dynamic> _items = [];
  bool _loading = true;
  bool _isStaff = false;

  static const _purple = Color(0xFF7B2D8B);

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
    final codigoCtrl = TextEditingController();
    final filaCtrl = TextEditingController();
    final columnaCtrl = TextEditingController();
    final vueloCtrl = TextEditingController();
    final disponibleCtrl = TextEditingController(text: 'true');
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nuevo Asiento'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: codigoCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Código (ej: 12A)',
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                ),
                TextFormField(
                  controller: filaCtrl,
                  decoration: const InputDecoration(labelText: 'Fila'),
                  keyboardType: TextInputType.number,
                  validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                ),
                TextFormField(
                  controller: columnaCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Columna (ej: A)',
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                ),
                TextFormField(
                  controller: vueloCtrl,
                  decoration: const InputDecoration(labelText: 'ID Vuelo'),
                  keyboardType: TextInputType.number,
                  validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                ),
                TextFormField(
                  controller: disponibleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Disponible (true/false)',
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
            style: ElevatedButton.styleFrom(backgroundColor: _purple),
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final data = {
                'codigo': codigoCtrl.text,
                'fila': int.tryParse(filaCtrl.text) ?? 0,
                'columna': columnaCtrl.text,
                'vuelo': int.tryParse(vueloCtrl.text) ?? 0,
                'disponible': disponibleCtrl.text.toLowerCase() == 'true',
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
        title: const Text('Asientos'),
        backgroundColor: _purple,
      ),
      floatingActionButton: _isStaff
          ? FloatingActionButton(
              backgroundColor: _purple,
              onPressed: _showForm,
              child: const Icon(Icons.add),
            )
          : null,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
          ? const Center(child: Text('No hay asientos registrados'))
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
                  final disponible = item['disponible']?.toString() ?? 'false';
                  return Card(
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: _purple,
                        child: Icon(Icons.event_seat, color: Colors.white),
                      ),
                      title: Text('Asiento $codigo'),
                      subtitle: Text(
                        'Fila $fila · Columna $columna · Disponible: $disponible',
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
