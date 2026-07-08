import 'package:flutter/material.dart';

class AirportsScreen extends StatelessWidget {
  const AirportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final airports = [
      {'name': 'Aeropuerto El Dorado', 'city': 'Bogotá', 'code': 'BOG'},
      {
        'name': 'Aeropuerto José María Córdova',
        'city': 'Medellín',
        'code': 'MDE',
      },
      {'name': 'Aeropuerto Rafael Núñez', 'city': 'Cartagena', 'code': 'CTG'},
    ];

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: airports.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = airports[index];
        return Card(
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFF7B2D8B),
              child: Icon(Icons.local_airport, color: Colors.white),
            ),
            title: Text(item['name']!),
            subtitle: Text('${item['city']} · ${item['code']}'),
          ),
        );
      },
    );
  }
}
