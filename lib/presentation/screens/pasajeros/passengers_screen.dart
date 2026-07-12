import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:avianco/presentation/providers/pasajeros_provider.dart';
import 'package:avianco/core/app_colors.dart';

class PassengersScreen extends StatefulWidget {
  const PassengersScreen({super.key});

  @override
  State<PassengersScreen> createState() => _PassengersScreenState();
}

class _PassengersScreenState extends State<PassengersScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero).then((_) {
      Provider.of<PasajerosProvider>(context, listen: false).fetchPasajeros();
    });
  }

  @override
  Widget build(BuildContext context) {
    final pasajerosData = Provider.of<PasajerosProvider>(context);
    final pasajeros = pasajerosData.items;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pasajeros', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Buscar pasajero...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (val) => pasajerosData.fetchPasajeros(search: val),
            ),
          ),
          Expanded(
            child: pasajerosData.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : pasajeros.isEmpty
                    ? const Center(child: Text('No se encontraron pasajeros.'))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: pasajeros.length,
                        itemBuilder: (ctx, i) {
                          final p = pasajeros[i];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            child: ListTile(
                              leading: const CircleAvatar(
                                backgroundColor: AppColors.dark,
                                child: Icon(Icons.person, color: Colors.white),
                              ),
                              title: Text('${p.nombre} ${p.apellido}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('Doc: ${p.documentoIdentidad}'),
                              trailing: const Icon(Icons.info_outline, color: AppColors.primary),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
