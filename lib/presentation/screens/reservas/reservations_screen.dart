import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:avianco/presentation/providers/reservas_provider.dart';
import 'package:avianco/domain/models/reserva.dart';
import 'package:avianco/core/app_colors.dart';

class ReservationsScreen extends StatefulWidget {
  const ReservationsScreen({super.key});

  @override
  State<ReservationsScreen> createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero).then((_) {
      Provider.of<ReservasProvider>(context, listen: false).fetchReservas();
    });
  }

  @override
  Widget build(BuildContext context) {
    final reservasData = Provider.of<ReservasProvider>(context);
    final reservas = reservasData.items;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Reservas', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: reservasData.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : reservas.isEmpty
              ? const Center(child: Text('No tienes reservas activas.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: reservas.length,
                  itemBuilder: (ctx, i) {
                    final r = reservas[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: const CircleAvatar(
                          backgroundColor: AppColors.primary,
                          child: Icon(Icons.book_online, color: Colors.white),
                        ),
                        title: Text('Vuelo: ${r.vueloNumero ?? r.vueloId}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Pasajero: ${r.pasajeroNombre ?? r.pasajeroId}'),
                            Text('Asiento: ${r.asiento}'),
                            Text('Estado: ${r.estado}', style: TextStyle(color: _getEstadoColor(r.estado), fontWeight: FontWeight.bold)),
                          ],
                        ),
                        trailing: const Icon(Icons.chevron_right),
                      ),
                    );
                  },
                ),
    );
  }

  Color _getEstadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'confirmada':
        return AppColors.success;
      case 'cancelada':
        return AppColors.primary;
      default:
        return Colors.grey;
    }
  }
}
