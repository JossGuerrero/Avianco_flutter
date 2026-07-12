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
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          aeropuertosData.isLoading
              ? const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: AppColors.primary)))
              : aeropuertos.isEmpty
                  ? const SliverFillRemaining(child: Center(child: Text('No hay aeropuertos disponibles')))
                  : SliverPadding(
                      padding: const EdgeInsets.all(20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (ctx, i) => _buildAirportCard(aeropuertos[i]),
                          childCount: aeropuertos.length,
                        ),
                      ),
                    ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: const Text('Aeropuertos', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        background: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.bannerGradient,
          ),
          child: Opacity(
            opacity: 0.1,
            child: Icon(Icons.map, size: 150, color: Colors.white.withValues(alpha: 0.5)),
          ),
        ),
      ),
    );
  }

  Widget _buildAirportCard(a) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 6,
                color: AppColors.primary,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              a.nombre,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.dark),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              a.codigoIata,
                              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 14, color: AppColors.greyAccent),
                          const SizedBox(width: 4),
                          Text('${a.ciudad}, ${a.pais}', style: const TextStyle(color: AppColors.greyAccent, fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
