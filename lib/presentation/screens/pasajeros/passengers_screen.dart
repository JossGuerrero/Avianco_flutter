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
    final provider = Provider.of<PasajerosProvider>(context);
    final pasajeros = provider.items;

    return Container(
      color: AppColors.background,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (val) => provider.fetchPasajeros(search: val),
              decoration: InputDecoration(
                hintText: 'Buscar pasajero...',
                prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : pasajeros.isEmpty
                    ? const Center(child: Text('No se encontraron pasajeros', style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                        physics: const BouncingScrollPhysics(),
                        itemCount: pasajeros.length,
                        itemBuilder: (ctx, i) {
                          final p = pasajeros[i];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 15, offset: const Offset(0, 5)),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: CircleAvatar(
                                radius: 28,
                                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                                child: Text(
                                  p.nombre[0].toUpperCase(),
                                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 18),
                                ),
                              ),
                              title: Text(
                                '${p.nombre} ${p.apellido}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.dark),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  'DOCUMENTO: ${p.documentoIdentidad}',
                                  style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w600),
                                ),
                              ),
                              trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
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
