import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:avianco/presentation/providers/aeronaves_provider.dart';
import 'package:avianco/core/app_colors.dart';

class AircraftsScreen extends StatefulWidget {
  const AircraftsScreen({super.key});

  @override
  State<AircraftsScreen> createState() => _AircraftsScreenState();
}

class _AircraftsScreenState extends State<AircraftsScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero).then((_) {
      Provider.of<AeronavesProvider>(context, listen: false).fetchAeronaves();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AeronavesProvider>(context);
    final aeronaves = provider.items;

    return Container(
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Text(
              'Gestión de Flota',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.dark, letterSpacing: -0.5),
            ),
          ),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : aeronaves.isEmpty
                    ? const Center(child: Text('No hay aeronaves registradas', style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 140),
                        physics: const BouncingScrollPhysics(),
                        itemCount: aeronaves.length,
                        itemBuilder: (ctx, i) => _buildAircraftCard(aeronaves[i]),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildAircraftCard(a) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              Icons.airplanemode_active,
              size: 120,
              color: AppColors.primary.withValues(alpha: 0.03),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.airplanemode_active, color: AppColors.primary, size: 32),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        a.modelo,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.dark),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'MATRÍCULA: ${a.matricula}',
                        style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${a.capacidad}',
                      style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary, fontSize: 20),
                    ),
                    const Text(
                      'PASAJEROS',
                      style: TextStyle(color: Colors.grey, fontSize: 8, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
