import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:avianco/presentation/providers/promociones_provider.dart';
import 'package:avianco/core/app_colors.dart';

class PromotionsScreen extends StatefulWidget {
  const PromotionsScreen({super.key});

  @override
  State<PromotionsScreen> createState() => _PromotionsScreenState();
}

class _PromotionsScreenState extends State<PromotionsScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero).then((_) {
      Provider.of<PromocionesProvider>(context, listen: false).fetchPromociones();
    });
  }

  @override
  Widget build(BuildContext context) {
    final promosData = Provider.of<PromocionesProvider>(context);
    final promos = promosData.items;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Promociones', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: promosData.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : promos.isEmpty
              ? const Center(child: Text('No hay promociones activas.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: promos.length,
                  itemBuilder: (ctx, i) {
                    final p = promos[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: AppColors.promoGradient,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(p.codigo, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
                                child: Text('${p.descuento.toInt()}% OFF', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(p.descripcion, style: const TextStyle(color: Colors.white70)),
                          const Divider(color: Colors.white24, height: 24),
                          Text('Válido hasta: ${p.fechaFin.toString().split(' ').first}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
