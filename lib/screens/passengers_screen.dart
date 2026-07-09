import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class PassengersScreen extends StatefulWidget {
  const PassengersScreen({super.key});

  @override
  State<PassengersScreen> createState() => _PassengersScreenState();
}

class _PassengersScreenState extends State<PassengersScreen> {
  List<dynamic> _pasajeros = [];
  bool _loading = true;
  bool _isStaff = false;
  final _searchCtrl = TextEditingController();

  static const _purple = Color(0xFF7B2D8B);
  static const _orange = Color(0xFFE65100);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({String search = ''}) async {
    setState(() => _loading = true);
    _isStaff = await AuthService.isStaff();
    final data = await ApiService.getPasajeros(search: search);
    if (!mounted) return;
    setState(() {
      _pasajeros = data;
      _loading = false;
    });
  }

  Future<void> _delete(int id) async {
    final ok = await ApiService.deletePasajero(id);
    if (!mounted) return;
    if (ok) {
      _load();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Pasajero eliminado')));
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
        title: const Text('Eliminar pasajero'),
        content: Text(
          '¿Eliminar a ${p['nombre_completo'] ?? 'este pasajero'}?',
        ),
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

  Future<void> _showForm({Map? pasajero}) async {
    final usuarioCtrl = TextEditingController(
      text: pasajero?['usuario']?.toString() ?? '',
    );
    final pasaporteCtrl = TextEditingController(
      text: pasajero?['numero_pasaporte'] ?? '',
    );
    final nacionalidadCtrl = TextEditingController(
      text: pasajero?['nacionalidad'] ?? '',
    );
    final nacimientoCtrl = TextEditingController(
      text: pasajero?['fecha_nacimiento'] ?? '',
    );
    final telefonoCtrl = TextEditingController(
      text: pasajero?['telefono'] ?? '',
    );
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.person, color: _orange),
            const SizedBox(width: 8),
            Text(pasajero == null ? 'Nuevo Pasajero' : 'Editar Pasajero'),
          ],
        ),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: usuarioCtrl,
                  decoration: const InputDecoration(labelText: 'ID Usuario'),
                  keyboardType: TextInputType.number,
                  validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                ),
                TextFormField(
                  controller: pasaporteCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Número de Pasaporte',
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                ),
                TextFormField(
                  controller: nacionalidadCtrl,
                  decoration: const InputDecoration(labelText: 'Nacionalidad'),
                  validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                ),
                TextFormField(
                  controller: nacimientoCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nacimiento (1990-05-15)',
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                ),
                TextFormField(
                  controller: telefonoCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Teléfono (opcional)',
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
            style: ElevatedButton.styleFrom(backgroundColor: _orange),
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final data = {
                'usuario': int.tryParse(usuarioCtrl.text) ?? 0,
                'numero_pasaporte': pasaporteCtrl.text,
                'nacionalidad': nacionalidadCtrl.text,
                'fecha_nacimiento': nacimientoCtrl.text,
                'telefono': telefonoCtrl.text,
              };
              bool ok;
              if (pasajero == null) {
                ok = await ApiService.createPasajero(data);
              } else {
                ok = await ApiService.updatePasajero(pasajero['id'], data);
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
              hintText: 'Buscar pasajero...',
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
                style: ElevatedButton.styleFrom(backgroundColor: _orange),
                onPressed: () => _showForm(),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  'Nuevo Pasajero',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        Expanded(
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(color: _purple),
                )
              : _pasajeros.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_off, size: 64, color: Colors.grey),
                      SizedBox(height: 8),
                      Text(
                        'No hay pasajeros',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: _pasajeros.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (ctx, i) {
                      final p = _pasajeros[i];
                      final nombre = (p['nombre_completo'] ?? '')
                          .toString()
                          .trim();
                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _orange,
                            child: Text(
                              nombre.isNotEmpty
                                  ? nombre[0].toUpperCase()
                                  : 'P',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            nombre.isNotEmpty ? nombre : 'Pasajero #${p['id']}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Pasaporte: ${p['numero_pasaporte'] ?? '—'}',
                              ),
                              Text(
                                '${p['nacionalidad'] ?? '—'} · Nac: ${p['fecha_nacimiento'] ?? '—'}',
                              ),
                            ],
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
                                        color: _orange,
                                      ),
                                      onPressed: () => _showForm(pasajero: p),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        size: 20,
                                        color: Colors.red,
                                      ),
                                      onPressed: () => _confirmDelete(p),
                                    ),
                                  ],
                                )
                              : null,
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }
}
