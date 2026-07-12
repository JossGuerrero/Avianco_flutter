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

  String _getImg(String iata) {
    return 'https://picsum.photos/seed/$iata/400/400';
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AeropuertosProvider>(context);
    final aeropuertos = provider.items;

    return Container(
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Text(
              'Nuestra Red Global',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.dark, letterSpacing: -0.5),
            ),
          ),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : aeropuertos.isEmpty
                    ? const Center(child: Text('No hay aeropuertos disponibles', style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 140),
                        physics: const BouncingScrollPhysics(),
                        itemCount: aeropuertos.length,
                        itemBuilder: (ctx, i) => _buildAirportCard(aeropuertos[i]),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildAirportCard(a) {
    return Container(
      height: 140,
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 120,
            height: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(32)),
              image: DecorationImage(
                image: NetworkImage(_getImg(a.codigoIata)),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(32)),
                gradient: LinearGradient(
                  colors: [Colors.black.withValues(alpha: 0.4), Colors.transparent],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
              alignment: Alignment.bottomCenter,
              padding: const EdgeInsets.all(12),
              child: Text(
                a.codigoIata,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20, letterSpacing: 1),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    a.nombre,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.dark),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${a.ciudad}, ${a.pais}',
                          style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
