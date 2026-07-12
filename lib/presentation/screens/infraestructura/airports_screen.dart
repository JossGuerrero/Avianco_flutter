import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:avianco/presentation/providers/aeropuertos_provider.dart';
import 'package:avianco/core/app_colors.dart';

class AirportsScreen extends StatefulWidget {
  const AirportsScreen({super.key});

  @override
  State<AirportsScreen> createState() => _AirportsScreenState();
}

class _AirportsScreenState extends State<AirportsScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero).then((_) {
      Provider.of<AeropuertosProvider>(context, listen: false).fetchAeropuertos();
    });
  }

  @override
  Widget build(BuildContext context) {
    final aeropuertosData = Provider.of<AeropuertosProvider>(context);
    final aeropuertos = aeropuertosData.items;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Aeropuertos', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: aeropuertosData.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : aeropuertos.isEmpty
              ? const Center(child: Text('No hay aeropuertos disponibles.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: aeropuertos.length,
                  itemBuilder: (ctx, i) {
                    final a = aeropuertos[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.location_on, color: AppColors.primary),
                        ),
                        title: Text(a.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${a.codigoIata} · ${a.ciudad}, ${a.pais}'),
                      ),
                    );
                  },
                ),
    );
  }
}
