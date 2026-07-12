import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:avianco/presentation/providers/reservas_provider.dart';
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
    final provider = Provider.of<ReservasProvider>(context);
    final reservas = provider.items;

    return Container(
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 24, 24, 8),
            child: Text(
              'Mis Viajes',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.dark),
            ),
          ),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : reservas.isEmpty
                    ? const Center(child: Text('No tienes reservas activas.', style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                        padding: const EdgeInsets.all(24),
                        physics: const BouncingScrollPhysics(),
                        itemCount: reservas.length,
                        itemBuilder: (ctx, i) {
                          final r = reservas[i];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 15, offset: const Offset(0, 8)),
                              ],
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'VUELO ${r.vueloNumero ?? r.vueloId}',
                                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.dark),
                                        ),
                                        Text(
                                          'Fecha: ${r.fechaReserva.toString().substring(0, 10)}',
                                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: _getCol(r.estado).withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        r.estado.toUpperCase(),
                                        style: TextStyle(color: _getCol(r.estado), fontWeight: FontWeight.bold, fontSize: 10),
                                      ),
                                    ),
                                  ],
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 20),
                                  child: Divider(height: 1, color: AppColors.background),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    _info('PASAJERO', r.pasajeroNombre ?? 'ID: ${r.pasajeroId}'),
                                    _info('ASIENTO', r.asiento, isRight: true),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _info(String label, String val, {bool isRight = false}) {
    return Column(
      crossAxisAlignment: isRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
        const SizedBox(height: 4),
        Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.dark)),
      ],
    );
  }

  Color _getCol(String s) {
    switch (s.toLowerCase()) {
      case 'confirmada': return AppColors.success;
      case 'cancelada': return AppColors.primary;
      default: return Colors.orange;
    }
  }
}
