import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
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
            children: const [
              _StatCard(
                title: 'Vuelos activos',
                value: '24',
                color: Color(0xFF2E7D32),
              ),
              _StatCard(
                title: 'Reservas hoy',
                value: '81',
                color: Color(0xFF1565C0),
              ),
              _StatCard(
                title: 'Pasajeros',
                value: '1.2k',
                color: Color(0xFFE65100),
              ),
              _StatCard(
                title: 'Aeropuertos',
                value: '12',
                color: Color(0xFF7B2D8B),
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
                    'Actividad reciente',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _ActivityRow(
                    title: 'Check-in completado',
                    subtitle: 'Vuelo AV-104',
                    time: 'Hace 10 min',
                  ),
                  const Divider(),
                  _ActivityRow(
                    title: 'Reserva confirmada',
                    subtitle: 'Pasajero: Ana García',
                    time: 'Hace 25 min',
                  ),
                  const Divider(),
                  _ActivityRow(
                    title: 'Aeronave en mantenimiento',
                    subtitle: 'BOEING 737',
                    time: 'Hace 1 hora',
                  ),
                ],
              ),
            ),
          ),
        ],
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
  final String time;
  const _ActivityRow({
    required this.title,
    required this.subtitle,
    required this.time,
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
        Text(time, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
      ],
    );
  }
}
