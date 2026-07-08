import 'package:flutter/material.dart';

class ReservationsScreen extends StatelessWidget {
  const ReservationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final reservations = [
      {
        'id': 'R-1042',
        'name': 'Carlos Díaz',
        'flight': 'AV-101',
        'state': 'Confirmada',
      },
      {
        'id': 'R-1045',
        'name': 'Laura Pérez',
        'flight': 'AV-205',
        'state': 'Pendiente',
      },
      {
        'id': 'R-1048',
        'name': 'Mateo Ruiz',
        'flight': 'AV-330',
        'state': 'Cancelada',
      },
    ];

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: reservations.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = reservations[index];
        return Card(
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFF1565C0),
              child: Icon(Icons.book_online, color: Colors.white),
            ),
            title: Text(item['name']!),
            subtitle: Text('Reserva ${item['id']} · Vuelo ${item['flight']}'),
            trailing: Chip(label: Text(item['state']!)),
          ),
        );
      },
    );
  }
}
