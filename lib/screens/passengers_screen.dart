import 'package:flutter/material.dart';

class PassengersScreen extends StatelessWidget {
  const PassengersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final passengers = [
      {'name': 'Ana García', 'document': 'CC 1023456789', 'seat': '12A'},
      {'name': 'Sofía Torres', 'document': 'TI 987654321', 'seat': '8C'},
      {'name': 'Daniel Vega', 'document': 'CC 456789123', 'seat': '5B'},
    ];

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: passengers.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = passengers[index];
        return Card(
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFFE65100),
              child: Icon(Icons.person, color: Colors.white),
            ),
            title: Text(item['name']!),
            subtitle: Text('${item['document']} · Asiento ${item['seat']}'),
            trailing: const Icon(Icons.chevron_right),
          ),
        );
      },
    );
  }
}
