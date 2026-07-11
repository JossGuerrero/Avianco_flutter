import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class ReservationsScreen extends StatefulWidget {
  const ReservationsScreen({super.key});

  @override
  State<ReservationsScreen> createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen> {
  List<dynamic> _reservas = [];
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
    var data = await ApiService.getReservas();
    // Usuario normal: solo SUS reservas (las de sus propios pasajeros).
    // El backend devuelve todas, así que se filtra en el cliente.
    if (!_isStaff) {
      final userId = await AuthService.getUserId();
      final pasajeros = await ApiService.getPasajeros();
      final misPasajeros = pasajeros
          .where((p) => p['usuario'] == userId)
          .map((p) => p['id'])
          .toSet();
      data = data.where((r) => misPasajeros.contains(r['pasajero'])).toList();
    }
    if (!mounted) return;
    setState(() {
      _reservas = data;
      _loading = false;
    });
  }

  Color _estadoColor(String estado) {
    switch (estado) {
      case 'confirmada':
        return AppColors.success;
      case 'cancelada':
        return AppColors.primary;
      case 'embarcado':
        return AppColors.greyDark;
      default:
        return Colors.grey;
    }
  }

  Future<void> _delete(int id) async {
    final ok = await ApiService.deleteReserva(id);
    if (!mounted) return;
    if (ok) {
      _load();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Reserva eliminada')));
    }
  }

  Future<void> _showForm({Map? reserva}) async {
    // Catálogos para dropdowns
    final results = await Future.wait([
      ApiService.getVuelos(),
      ApiService.getPasajeros(),
    ]);
    if (!mounted) return;
    final vuelos = results[0];
    final pasajeros = results[1];

    if (vuelos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay vuelos disponibles para reservar'),
          backgroundColor: AppColors.primary,
        ),
      );
      return;
    }

    int? vueloId = reserva?['vuelo'];
    int? pasajeroId = reserva?['pasajero'];
    final asientoCtrl = TextEditingController(text: reserva?['asiento'] ?? '');
    final formKey = GlobalKey<FormState>();

    String vueloLabel(dynamic v) {
      final o = v['origen_detalle']?['codigo_iata'] ?? v['origen'];
      final d = v['destino_detalle']?['codigo_iata'] ?? v['destino'];
      final fecha = (v['fecha_salida'] ?? '').toString().split('T').first;
      return '$o → $d · $fecha';
    }

    String pasajeroLabel(dynamic p) {
      final nombre = (p['nombre_completo'] ?? '').toString().trim();
      return nombre.isNotEmpty ? nombre : 'Pasajero #${p['id']}';
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
              const Icon(Icons.book_online, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(reserva == null ? 'Nueva Reserva' : 'Editar Reserva'),
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
                  if (pasajeros.isNotEmpty)
                    DropdownButtonFormField<int>(
                      initialValue: pasajeroId,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Pasajero',
                      ),
                      items: pasajeros
                          .map<DropdownMenuItem<int>>(
                            (p) => DropdownMenuItem(
                              value: p['id'],
                              child: Text(
                                pasajeroLabel(p),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setDialogState(() => pasajeroId = v),
                      validator: (v) => v == null ? 'Requerido' : null,
                    ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: asientoCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Asiento (ej: 12A)',
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Requerido' : null,
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
                  'vuelo': vueloId,
                  'pasajero': pasajeroId,
                  'asiento': asientoCtrl.text,
                  'estado': reserva?['estado'] ?? 'confirmada',
                };
                bool ok;
                if (reserva == null) {
                  ok = await ApiService.createReserva(data);
                } else {
                  ok = await ApiService.updateReserva(reserva['id'], data);
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
                      backgroundColor: AppColors.primary,
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
    return Column(
      children: [
        // Solo staff crea reservas manuales (gestión directa sin pago).
        // El usuario normal reserva desde Vuelos: selector de asiento + pago.
        if (_isStaff)
          Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.dark,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () => _showForm(),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  'Nueva Reserva',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          )
        else
          Container(
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.horizontal(
                right: Radius.circular(16),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
              border: const Border(
                left: BorderSide(
                  color: AppColors.primary,
                  width: 4,
                ),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: AppColors.primary,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Para reservar un boleto, ve a Vuelos y toca "Reservar" '
                    'en el vuelo que desees.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[800],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
              : _reservas.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.book_online, size: 64, color: Colors.grey),
                      SizedBox(height: 8),
                      Text(
                        'No hay reservas',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: _reservas.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (ctx, i) {
                    final r = _reservas[i];
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: AppColors.greyDark,
                          child: Icon(Icons.book_online, color: Colors.white),
                        ),
                        title: Text(
                          'Reserva #${r['id']} — Asiento ${r['asiento']}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Vuelo: ${r['vuelo']} | Pasajero: ${r['pasajero']}',
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
                                color: _estadoColor(r['estado']),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                r['estado'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            if (_isStaff) ...[
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  size: 18,
                                  color: AppColors.dark,
                                ),
                                onPressed: () => _showForm(reserva: r),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  size: 18,
                                  color: AppColors.primary,
                                ),
                                onPressed: () => _delete(r['id']),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
