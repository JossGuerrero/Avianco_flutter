import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../services/api_service.dart';

/// Asignación de tripulación a vuelos (solo staff).
class CrewAssignmentsScreen extends StatefulWidget {
  const CrewAssignmentsScreen({super.key});

  @override
  State<CrewAssignmentsScreen> createState() => _CrewAssignmentsScreenState();
}

class _CrewAssignmentsScreenState extends State<CrewAssignmentsScreen> {
  List<dynamic> _asignaciones = [];
  List<dynamic> _vuelos = [];
  List<dynamic> _tripulacion = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final results = await Future.wait([
      ApiService.getAsignaciones(),
      ApiService.getVuelos(),
      ApiService.getTripulacion(),
    ]);
    if (!mounted) return;
    setState(() {
      _asignaciones = results[0];
      _vuelos = results[1];
      _tripulacion = results[2];
      _loading = false;
    });
  }

  String _vueloLabel(dynamic idOrMap) {
    final id = idOrMap is Map ? idOrMap['id'] : idOrMap;
    final match = _vuelos.where((v) => v['id'] == id);
    if (match.isEmpty) return 'Vuelo #$id';
    final v = match.first;
    final o = v['origen_detalle']?['codigo_iata'] ?? v['origen'];
    final d = v['destino_detalle']?['codigo_iata'] ?? v['destino'];
    return '$o → $d · ${(v['fecha_salida'] ?? '').toString().split('T').first}';
  }

  String _tripulanteLabel(dynamic idOrMap) {
    final id = idOrMap is Map ? idOrMap['id'] : idOrMap;
    final match = _tripulacion.where((t) => t['id'] == id);
    if (match.isEmpty) return 'Tripulante #$id';
    final t = match.first;
    return '${t['nombre'] ?? ''} ${t['apellido'] ?? ''} (${t['rol'] ?? '—'})';
  }

  Future<void> _showForm() async {
    if (_vuelos.isEmpty || _tripulacion.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Necesitas vuelos y tripulación registrados'),
          backgroundColor: AppColors.primary,
        ),
      );
      return;
    }
    int? vueloId;
    int? tripulanteId;
    final activos = _tripulacion.where((t) => t['activo'] != false).toList();
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.assignment_ind,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            const Text('Nueva Asignación', style: TextStyle(fontSize: 17)),
          ],
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                initialValue: vueloId,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Vuelo'),
                items: _vuelos
                    .map<DropdownMenuItem<int>>(
                      (v) => DropdownMenuItem(
                        value: v['id'],
                        child: Text(
                          _vueloLabel(v['id']),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) => vueloId = v,
                validator: (v) => v == null ? 'Requerido' : null,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<int>(
                initialValue: tripulanteId,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Tripulante'),
                items: activos
                    .map<DropdownMenuItem<int>>(
                      (t) => DropdownMenuItem(
                        value: t['id'],
                        child: Text(
                          _tripulanteLabel(t['id']),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) => tripulanteId = v,
                validator: (v) => v == null ? 'Requerido' : null,
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
              // El nombre del campo FK puede ser 'tripulacion' o 'tripulante'
              // según el serializer; DRF ignora los desconocidos.
              final ok = await ApiService.createAsignacion({
                'vuelo': vueloId,
                'tripulacion': tripulanteId,
                'tripulante': tripulanteId,
              });
              if (!ctx.mounted) return;
              Navigator.pop(ctx);
              if (ok) {
                _load();
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('Asignación creada')),
                );
              } else {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(
                    content: Text('Error al crear asignación'),
                    backgroundColor: AppColors.primary,
                  ),
                );
              }
            },
            child: const Text('Asignar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Asignaciones de vuelo',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.mainGradient),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.dark,
        onPressed: _showForm,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _asignaciones.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_ind, size: 64, color: Colors.grey),
                  SizedBox(height: 8),
                  Text(
                    'No hay asignaciones registradas',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _asignaciones.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final a = _asignaciones[index];
                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: AppColors.deepRed,
                        child: Icon(
                          Icons.assignment_ind,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        _tripulanteLabel(
                          a['tripulacion'] ?? a['tripulante'],
                        ),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(_vueloLabel(a['vuelo'])),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
