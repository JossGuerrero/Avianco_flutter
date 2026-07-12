import 'dart:io';
import 'package:flutter/material.dart';
import '../config/api.dart';
import '../config/app_colors.dart';
import '../services/api_service.dart';
import '../widgets/photo_picker.dart';

class AircraftsScreen extends StatefulWidget {
  const AircraftsScreen({super.key});

  @override
  State<AircraftsScreen> createState() => _AircraftsScreenState();
}

class _AircraftsScreenState extends State<AircraftsScreen> {
  List<dynamic> _aeronaves = [];
  bool _loading = true;
  final _searchCtrl = TextEditingController();

  static const _blue = AppColors.darkAlt;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({String search = ''}) async {
    setState(() => _loading = true);
    final data = await ApiService.getAeronaves(search: search);
    if (!mounted) return;
    setState(() {
      _aeronaves = data;
      _loading = false;
    });
  }

  Future<void> _delete(int id) async {
    final ok = await ApiService.deleteAeronave(id);
    if (!mounted) return;
    if (ok) {
      _load();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Aeronave eliminada')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se puede eliminar, tiene vuelos asociados'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _confirmDelete(Map a) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar aeronave'),
        content: Text('¿Eliminar ${a['modelo']}?'),
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
    if (confirm == true) _delete(a['id']);
  }

  /// Crea un tipo de avión inline (cuando el catálogo está vacío).
  Future<bool> _crearTipoAvion() async {
    final nombreCtrl = TextEditingController();
    final fabricanteCtrl = TextEditingController();
    final creado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Nuevo tipo de avión'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nombreCtrl,
              decoration: const InputDecoration(
                labelText: 'Nombre/Modelo (ej: Boeing 737)',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: fabricanteCtrl,
              decoration: const InputDecoration(
                labelText: 'Fabricante (ej: Boeing)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
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
              if (nombreCtrl.text.isEmpty) return;
              final ok = await ApiService.createTipoAvion({
                'nombre': nombreCtrl.text,
                'modelo': nombreCtrl.text,
                'fabricante': fabricanteCtrl.text,
              });
              if (!ctx.mounted) return;
              Navigator.pop(ctx, ok);
            },
            child: const Text('Crear', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    return creado == true;
  }

  Future<void> _showForm({Map? aeronave}) async {
    // Catálogo de tipos de avión para no escribir el modelo a mano
    final tipos = await ApiService.getTiposAvion();
    if (!mounted) return;
    final nombresTipos = tipos
        .map<String>(
          (t) => (t['nombre'] ?? t['modelo'] ?? '').toString(),
        )
        .where((n) => n.isNotEmpty)
        .toSet()
        .toList();

    final matriculaCtrl = TextEditingController(
      text: aeronave?['matricula'] ?? '',
    );
    final modeloCtrl = TextEditingController(text: aeronave?['modelo'] ?? '');
    final modeloActual = aeronave?['modelo']?.toString();
    String? modeloSel =
        nombresTipos.contains(modeloActual) ? modeloActual : null;
    final capacidadCtrl = TextEditingController(
      text: aeronave?['capacidad']?.toString() ?? '',
    );
    File? foto;
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.airplanemode_active, color: _blue),
            const SizedBox(width: 8),
            Text(aeronave == null ? 'Nueva Aeronave' : 'Editar Aeronave'),
          ],
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: matriculaCtrl,
                decoration: const InputDecoration(
                  labelText: 'Matrícula (ej: HC-CJX)',
                ),
                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
              ),
              if (nombresTipos.isNotEmpty)
                DropdownButtonFormField<String>(
                  initialValue: modeloSel,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Modelo'),
                  items: nombresTipos
                      .map(
                        (n) => DropdownMenuItem(
                          value: n,
                          child: Text(n, overflow: TextOverflow.ellipsis),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => modeloSel = v,
                  validator: (v) => v == null ? 'Requerido' : null,
                )
              else ...[
                TextFormField(
                  controller: modeloCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Modelo (ej: Boeing 737)',
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Requerido' : null,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      final creado = await _crearTipoAvion();
                      if (creado && mounted) _showForm(aeronave: aeronave);
                    },
                    icon: const Icon(
                      Icons.add,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    label: const Text(
                      'Crear tipo de avión',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
              TextFormField(
                controller: capacidadCtrl,
                decoration: const InputDecoration(labelText: 'Capacidad'),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              // Foto de la aeronave
              if (foto != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    foto!,
                    height: 110,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                )
              else if (Api.mediaUrl(aeronave?['foto']) != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    Api.mediaUrl(aeronave?['foto'])!,
                    height: 110,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, e, s) => const SizedBox(),
                  ),
                ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () async {
                    final f = await pickFoto(ctx);
                    if (f != null) setDialogState(() => foto = f);
                  },
                  icon: const Icon(
                    Icons.add_a_photo,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  label: Text(
                    foto == null ? 'Agregar foto' : 'Cambiar foto',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
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
                'matricula': matriculaCtrl.text,
                'modelo': nombresTipos.isNotEmpty
                    ? (modeloSel ?? '')
                    : modeloCtrl.text,
                'capacidad': int.tryParse(capacidadCtrl.text) ?? 0,
              };
              bool ok;
              if (aeronave == null) {
                ok = await ApiService.createAeronaveConFoto(data, foto);
              } else {
                ok = await ApiService.updateAeronaveConFoto(
                  aeronave['id'],
                  data,
                  foto,
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
            child: const Text('Guardar', style: TextStyle(color: Colors.white)),
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
        backgroundColor: _blue,
        title: const Text(
          'Aeronaves',
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
                hintText: 'Buscar aeronave...',
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
                    child: CircularProgressIndicator(color: _blue),
                  )
                : _aeronaves.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.airplanemode_inactive,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'No hay aeronaves',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _load,
                    child: ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemCount: _aeronaves.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (ctx, i) {
                        final a = _aeronaves[i];
                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: Api.mediaUrl(a['foto']) != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      Api.mediaUrl(a['foto'])!,
                                      width: 52,
                                      height: 52,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, e, s) =>
                                          const CircleAvatar(
                                        backgroundColor: _blue,
                                        child: Icon(
                                          Icons.airplanemode_active,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  )
                                : const CircleAvatar(
                                    backgroundColor: _blue,
                                    child: Icon(
                                      Icons.airplanemode_active,
                                      color: Colors.white,
                                    ),
                                  ),
                            title: Text(
                              a['modelo'] ?? '—',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              '${a['matricula'] ?? '—'} · ${a['capacidad'] ?? 0} pasajeros',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    size: 20,
                                    color: _blue,
                                  ),
                                  onPressed: () => _showForm(aeronave: a),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    size: 20,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => _confirmDelete(a),
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
