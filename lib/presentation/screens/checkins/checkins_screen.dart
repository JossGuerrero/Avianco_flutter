import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:avianco/presentation/providers/checkins_provider.dart';
import 'package:avianco/core/app_colors.dart';

class CheckinsScreen extends StatefulWidget {
  const CheckinsScreen({super.key});

  @override
  State<CheckinsScreen> createState() => _CheckinsScreenState();
}

class _CheckinsScreenState extends State<CheckinsScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero).then((_) {
      Provider.of<CheckinsProvider>(context, listen: false).fetchCheckins();
    });
  }

  @override
  Widget build(BuildContext context) {
    final checkinsData = Provider.of<CheckinsProvider>(context);
    final checkins = checkinsData.items;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Check-ins', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: checkinsData.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : checkins.isEmpty
              ? const Center(child: Text('No hay registros de check-in.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: checkins.length,
                  itemBuilder: (ctx, i) {
                    final c = checkins[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.green,
                          child: Icon(Icons.check, color: Colors.white),
                        ),
                        title: Text('Reserva #${c.reservaId}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Puerta: ${c.puerta} · Estado: ${c.estado}'),
                        trailing: Text(c.fechaCheckin.toString().split(' ').first, style: const TextStyle(fontSize: 12)),
                      ),
                    );
                  },
                ),
    );
  }
}
