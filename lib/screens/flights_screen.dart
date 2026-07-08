import 'package:flutter/material.dart';

class FlightsScreen extends StatelessWidget {
  const FlightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final flights = [
      {
        'code': 'AV-101',
        'route': 'Bogotá → Medellín',
        'hour': '08:30',
        'status': 'En hora',
      },
      {
        'code': 'AV-205',
        'route': 'Cali → Cartagena',
        'hour': '11:45',
        'status': 'Confirmado',
      },
      {
        'code': 'AV-330',
        'route': 'Barranquilla → Lima',
        'hour': '16:10',
        'status': 'Retrasado',
      },
    ];

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: flights.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = flights[index];
        return Card(
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFF2E7D32),
              child: Icon(Icons.flight_takeoff, color: Colors.white),
            ),
            title: Text(item['code']!),
            subtitle: Text('${item['route']} · ${item['hour']}'),
            trailing: Chip(label: Text(item['status']!)),
          ),
        );
      },
    );
  }
}
