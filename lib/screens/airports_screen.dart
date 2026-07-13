import 'dart:io';
import 'package:flutter/material.dart';
import '../config/api.dart';
import '../config/app_colors.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../widgets/photo_picker.dart';

class AirportsScreen extends StatefulWidget {
  const AirportsScreen({super.key});

  @override
  State<AirportsScreen> createState() => _AirportsScreenState();
}

class _AirportsScreenState extends State<AirportsScreen> {
  List<dynamic> _aeropuertos = [];
  bool _loading = true;
  bool _isStaff = false;
  final _searchCtrl = TextEditingController();

  static const _purple = AppColors.darkAlt;

  // Fotos de stock por IATA (fallback cuando el aeropuerto no tiene foto)
  static const Map<String, String> _airportImgs = {
    'UIO': 'https://images.unsplash.com/photo-1531968455001-5c5272a41129?w=400',
    'GYE': 'https://images.unsplash.com/photo-1444723121867-7a241cacace9?w=400',
    'BOG': 'https://images.unsplash.com/photo-1539037116277-4db20889f2d4?w=400',
    'LIM': 'https://images.unsplash.com/photo-1526392060635-9d6019884377?w=400',
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({String search = ''}) async {
    setState(() => _loading = true);
    _isStaff = await AuthService.isStaff();
    final data = await ApiService.getAeropuertos(search: search);
    if (!mounted) return;
    setState(() {
      _aeropuertos = data;
      _loading = false;
    });
  }

  Future<void> _delete(int id) async {
    final ok = await ApiService.deleteAeropuerto(id);
    if (!mounted) return;
    if (ok) {
      _load();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Aeropuerto eliminado')));
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
        title: const Text('Eliminar aeropuerto'),
        content: Text('¿Eliminar ${a['nombre']}?'),
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

  /// Crea un país (y opcionalmente su primera ciudad) inline.
  Future<bool> _crearPais() async {
    final nombreCtrl = TextEditingController();
    final creado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Nuevo país'),
        content: TextField(
          controller: nombreCtrl,
          decoration: const InputDecoration(labelText: 'Nombre (ej: Ecuador)'),
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
              final ok = await ApiService.createPais({
                'nombre': nombreCtrl.text,
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

  Future<bool> _crearCiudad(int paisId) async {
    final nombreCtrl = TextEditingController();
    final creado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Nueva ciudad'),
        content: TextField(
          controller: nombreCtrl,
          decoration: const InputDecoration(labelText: 'Nombre (ej: Quito)'),
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
              final ok = await ApiService.createCiudad({
                'nombre': nombreCtrl.text,
                'pais': paisId,
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

  Future<void> _showForm({Map? aeropuerto}) async {
    // Catálogos de países/ciudades (fallback a texto libre si están vacíos)
    final catalogos = await Future.wait([
      ApiService.getPaises(),
      ApiService.getCiudades(),
    ]);
    if (!mounted) return;
    final paises = catalogos[0];
    final ciudades = catalogos[1];

    final codigoCtrl = TextEditingController(
      text: aeropuerto?['codigo_iata'] ?? '',
    );
    final nombreCtrl = TextEditingController(text: aeropuerto?['nombre'] ?? '');
    final ciudadCtrl = TextEditingController(text: aeropuerto?['ciudad'] ?? '');
    final paisCtrl = TextEditingController(text: aeropuerto?['pais'] ?? '');
    int? paisId;
    String? ciudadSel;
    File? foto;
    final formKey = GlobalKey<FormState>();

    String nombreDe(dynamic x) => (x['nombre'] ?? '').toString();
    List<dynamic> ciudadesDe(int? pais) => ciudades
        .where(
          (c) =>
              pais == null ||
              c['pais'] == pais ||
              c['pais']?['id'] == pais,
        )
        .toList();
    String paisNombre(int? id) {
      final match = paises.where((p) => p['id'] == id);
      return match.isNotEmpty ? nombreDe(match.first) : '';
    }

    await showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.location_on, color: _purple),
            const SizedBox(width: 8),
            Text(aeropuerto == null ? 'Nuevo Aeropuerto' : 'Editar Aeropuerto'),
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
                    labelText: 'Código IATA (ej: UIO)',
                  ),
                  maxLength: 3,
                  textCapitalization: TextCapitalization.characters,
                  validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                ),
                TextFormField(
                  controller: nombreCtrl,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                ),
                if (paises.isNotEmpty) ...[
                  DropdownButtonFormField<int>(
                    initialValue: paisId,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'País'),
                    items: paises
                        .map<DropdownMenuItem<int>>(
                          (p) => DropdownMenuItem(
                            value: p['id'],
                            child: Text(
                              nombreDe(p),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setDialogState(() {
                      paisId = v;
                      ciudadSel = null;
                    }),
                    validator: (v) => v == null ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    key: ValueKey('ciudades-$paisId'),
                    initialValue: ciudadSel,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Ciudad'),
                    items: ciudadesDe(paisId)
                        .map<DropdownMenuItem<String>>(
                          (c) => DropdownMenuItem(
                            value: nombreDe(c),
                            child: Text(
                              nombreDe(c),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setDialogState(() => ciudadSel = v),
                    validator: (v) => v == null ? 'Requerido' : null,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: paisId == null
                          ? null
                          : () async {
                              final creado = await _crearCiudad(paisId!);
                              if (creado && ctx.mounted) {
                                Navigator.pop(ctx);
                                _showForm(aeropuerto: aeropuerto);
                              }
                            },
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text(
                        'Nueva ciudad',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ] else ...[
                  TextFormField(
                    controller: ciudadCtrl,
                    decoration: const InputDecoration(labelText: 'Ciudad'),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: paisCtrl,
                    decoration: const InputDecoration(labelText: 'País'),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Requerido' : null,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () async {
                        final creado = await _crearPais();
                        if (creado && ctx.mounted) {
                          Navigator.pop(ctx);
                          _showForm(aeropuerto: aeropuerto);
                        }
                      },
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text(
                        'Crear país',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                // Foto del aeropuerto
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
                else if (Api.mediaUrl(aeropuerto?['foto']) != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      Api.mediaUrl(aeropuerto?['foto'])!,
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
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _purple),
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final data = {
                'codigo_iata': codigoCtrl.text.toUpperCase(),
                'nombre': nombreCtrl.text,
                'ciudad': paises.isNotEmpty
                    ? (ciudadSel ?? '')
                    : ciudadCtrl.text,
                'pais': paises.isNotEmpty
                    ? paisNombre(paisId)
                    : paisCtrl.text,
              };
              bool ok;
              if (aeropuerto == null) {
                ok = await ApiService.createAeropuertoConFoto(data, foto);
              } else {
                ok = await ApiService.updateAeropuertoConFoto(
                  aeropuerto['id'],
                  data,
                  foto,
                );
              }
              if (!ctx.mounted) return;
              Navigator.pop(ctx);
              if (ok) {
                _load();
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('Guardado exitosamente')),
                );
              } else {
                ScaffoldMessenger.of(ctx).showSnackBar(
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
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: _searchCtrl,
            decoration: InputDecoration(
              hintText: 'Buscar aeropuerto...',
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
                style: ElevatedButton.styleFrom(backgroundColor: _purple),
                onPressed: () => _showForm(),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  'Nuevo Aeropuerto',
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
              : _aeropuertos.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_off, size: 64, color: Colors.grey),
                      SizedBox(height: 8),
                      Text(
                        'No hay aeropuertos',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: _aeropuertos.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (ctx, i) {
                      final a = _aeropuertos[i];
                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: (Api.mediaUrl(a['foto']) ??
                                      _airportImgs[a['codigo_iata']]) !=
                                  null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    (Api.mediaUrl(a['foto']) ??
                                        _airportImgs[a['codigo_iata']])!,
                                    width: 52,
                                    height: 52,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, e, s) => Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _purple,
                                        borderRadius:
                                            BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        a['codigo_iata'] ?? '—',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _purple,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    a['codigo_iata'] ?? '—',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                          title: Text(
                            a['nombre'] ?? '—',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${a['ciudad'] ?? '—'}, ${a['pais'] ?? '—'}',
                          ),
                          trailing: _isStaff
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        size: 20,
                                        color: _purple,
                                      ),
                                      onPressed: () => _showForm(aeropuerto: a),
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
