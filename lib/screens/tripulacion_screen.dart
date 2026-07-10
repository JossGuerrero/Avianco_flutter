import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../services/api_service.dart';

class CrewScreen extends StatefulWidget {
  const CrewScreen({super.key});

  @override
  State<CrewScreen> createState() => _CrewScreenState();
}

class _CrewScreenState extends State<CrewScreen> {
  List<dynamic> _tripulacion = [];
  bool _loading = true;
  final _searchCtrl = TextEditingController();

  static const _teal = AppColors.deepRed;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({String search = ''}) async {
    setState(() => _loading = true);
    final data = await ApiService.getTripulacion(search: search);
    if (!mounted) return;
    setState(() {
      _tripulacion = data;
      _loading = false;
    });
  }

  IconData _rolIcon(String rol) {
    switch (rol) {
      case 'piloto':
        return Icons.flight;
      case 'copiloto':
        return Icons.flight_class;
      case 'azafata':
        return Icons.support_agent;
      case 'tecnico':
        return Icons.build;
      default:
        return Icons.person;
    }
  }

  Future<void> _delete(int id) async {
    final ok = await ApiService.deleteTripulacion(id);
    if (!mounted) return;
    if (ok) {
      _load();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Miembro eliminado')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al eliminar'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _confirmDelete(Map t) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar miembro'),
        content: Text('¿Eliminar a ${t['nombre']} ${t['apellido']}?'),
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
    if (confirm == true) _delete(t['id']);
  }

  Future<void> _showForm({Map? miembro}) async {
    final nombreCtrl = TextEditingController(text: miembro?['nombre'] ?? '');
    final apellidoCtrl = TextEditingController(
      text: miembro?['apellido'] ?? '',
    );
    final licenciaCtrl = TextEditingController(
      text: miembro?['licencia'] ?? '',
    );
    String rol = miembro?['rol'] ?? 'piloto';
    bool activo = miembro?['activo'] ?? true;
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.people, color: _teal),
              const SizedBox(width: 8),
              Text(miembro == null ? 'Nuevo Miembro' : 'Editar Miembro'),
            ],
          ),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nombreCtrl,
                    decoration: const InputDecoration(labelText: 'Nombre'),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Requerido' : null,
                  ),
                  TextFormField(
                    controller: apellidoCtrl,
                    decoration: const InputDecoration(labelText: 'Apellido'),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Requerido' : null,
                  ),
                  DropdownButtonFormField<String>(
                    initialValue: rol,
                    decoration: const InputDecoration(labelText: 'Rol'),
                    items: const [
                      DropdownMenuItem(value: 'piloto', child: Text('Piloto')),
                      DropdownMenuItem(
                        value: 'copiloto',
                        child: Text('Copiloto'),
                      ),
                      DropdownMenuItem(
                        value: 'azafata',
                        child: Text('Azafata'),
                      ),
                      DropdownMenuItem(
                        value: 'tecnico',
                        child: Text('Técnico'),
                      ),
                    ],
                    onChanged: (v) =>
                        setDialogState(() => rol = v ?? 'piloto'),
                  ),
                  TextFormField(
                    controller: licenciaCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Licencia (ej: PIL-001)',
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Requerido' : null,
                  ),
                  SwitchListTile(
                    title: const Text('Activo'),
                    value: activo,
                    activeThumbColor: _teal,
                    onChanged: (v) => setDialogState(() => activo = v),
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
              style: ElevatedButton.styleFrom(backgroundColor: _teal),
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final data = {
                  'nombre': nombreCtrl.text,
                  'apellido': apellidoCtrl.text,
                  'rol': rol,
                  'licencia': licenciaCtrl.text,
                  'activo': activo,
                };
                bool ok;
                if (miembro == null) {
                  ok = await ApiService.createTripulacion(data);
                } else {
                  ok = await ApiService.updateTripulacion(
                    miembro['id'],
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
        backgroundColor: _teal,
        title: const Text(
          'Tripulación',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => _showForm(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Buscar por nombre o licencia...',
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
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: _teal),
                  )
                : _tripulacion.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'No hay tripulación',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _load,
                    child: ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemCount: _tripulacion.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (ctx, i) {
                        final t = _tripulacion[i];
                        final activo = t['activo'] == true;
                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: activo ? _teal : Colors.grey,
                              child: Icon(
                                _rolIcon(t['rol'] ?? ''),
                                color: Colors.white,
                              ),
                            ),
                            title: Text(
                              '${t['nombre'] ?? ''} ${t['apellido'] ?? ''}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              '${t['rol'] ?? '—'} · Licencia: ${t['licencia'] ?? '—'}',
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
                                    color: activo ? _teal : Colors.grey,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    activo ? 'Activo' : 'Inactivo',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    size: 20,
                                    color: _teal,
                                  ),
                                  onPressed: () => _showForm(miembro: t),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    size: 20,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => _confirmDelete(t),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
