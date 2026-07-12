import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:avianco/presentation/providers/tripulacion_provider.dart';
import 'package:avianco/core/app_colors.dart';

class CrewScreen extends StatefulWidget {
  const CrewScreen({super.key});

  @override
  State<CrewScreen> createState() => _CrewScreenState();
}

class _CrewScreenState extends State<CrewScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero).then((_) {
      Provider.of<TripulacionProvider>(context, listen: false).fetchTripulacion();
    });
  }

  @override
  Widget build(BuildContext context) {
    final crewData = Provider.of<TripulacionProvider>(context);
    final crew = crewData.items;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tripulación', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: crewData.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : crew.isEmpty
              ? const Center(child: Text('No hay personal registrado.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: crew.length,
                  itemBuilder: (ctx, i) {
                    final t = crew[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: t.activo ? Colors.teal : Colors.grey,
                          child: const Icon(Icons.person, color: Colors.white),
                        ),
                        title: Text('${t.nombre} ${t.apellido}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${t.rol} · Licencia: ${t.licencia}'),
                        trailing: Icon(Icons.circle, size: 12, color: t.activo ? Colors.green : Colors.red),
                      ),
                    );
                  },
                ),
    );
  }
}
