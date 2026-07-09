import 'package:flutter/material.dart';
import '../services/api_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _loading = true;
  int _vuelos = 0;
  int _reservas = 0;
  int _pasajeros = 0;
  int _aeropuertos = 0;
  List<dynamic> _reservasRecientes = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final results = await Future.wait([
      ApiService.getVuelosCount(),
      ApiService.getReservasCount(),
      ApiService.getPasajerosCount(),
      ApiService.getAeropuertosCount(),
      ApiService.getReservas(),
    ]);
    if (!mounted) return;
    final reservas = results[4] as List<dynamic>;
    setState(() {
      _vuelos = results[0] as int;
      _reservas = results[1] as int;
      _pasajeros = results[2] as int;
      _aeropuertos = results[3] as int;
      _reservasRecientes = reservas.take(3).toList();
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_loading) return const Center(child: CircularProgressIndicator());

    return RefreshIndicator(
      onRefresh: _load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Panel general',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Resumen rápido del sistema',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _StatCard(
                  title: 'Vuelos',
                  value: '$_vuelos',
                  color: const Color(0xFF2E7D32),
                ),
                _StatCard(
                  title: 'Reservas',
                  value: '$_reservas',
                  color: const Color(0xFF1565C0),
                ),
                _StatCard(
                  title: 'Pasajeros',
                  value: '$_pasajeros',
                  color: const Color(0xFFE65100),
                ),
                _StatCard(
                  title: 'Aeropuertos',
                  value: '$_aeropuertos',
                  color: const Color(0xFF7B2D8B),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reservas recientes',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_reservasRecientes.isEmpty)
                      Text(
                        'No hay reservas registradas',
                        style: TextStyle(color: Colors.grey[600]),
                      )
                    else
                      for (var i = 0; i < _reservasRecientes.length; i++) ...[
                        if (i > 0) const Divider(),
                        _ActivityRow(
                          title: 'Reserva #${_reservasRecientes[i]['id']}',
                          subtitle:
                              'Vuelo ${_reservasRecientes[i]['vuelo']} · Asiento ${_reservasRecientes[i]['asiento'] ?? '—'}',
                          estado: (_reservasRecientes[i]['estado'] ?? '')
                              .toString(),
                        ),
                      ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  const _StatCard({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final String estado;
  const _ActivityRow({
    required this.title,
    required this.subtitle,
    required this.estado,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.circle, size: 10, color: Color(0xFF7B2D8B)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(subtitle, style: TextStyle(color: Colors.grey[600])),
            ],
          ),
        ),
        Text(
          estado,
          style: TextStyle(color: Colors.grey[500], fontSize: 12),
        ),
      ],
    );
  }
}
