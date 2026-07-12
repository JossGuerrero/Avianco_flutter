import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:avianco/presentation/providers/servicios_provider.dart';
import 'package:avianco/core/app_colors.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero).then((_) {
      Provider.of<ServiciosProvider>(context, listen: false).fetchServicios();
    });
  }

  @override
  Widget build(BuildContext context) {
    final serviciosData = Provider.of<ServiciosProvider>(context);
    final servicios = serviciosData.items;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Servicios Adicionales', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: serviciosData.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : servicios.isEmpty
              ? const Center(child: Text('No hay servicios disponibles en este momento.'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: servicios.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (ctx, i) {
                    final s = servicios[i];
                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFF22A6B3),
                          child: Icon(Icons.room_service, color: Colors.white),
                        ),
                        title: Text(s.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(s.descripcion),
                        trailing: Text('\$${s.precio}', style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    );
                  },
                ),
    );
  }
}
