import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:avianco/presentation/providers/vuelos_provider.dart';
import 'package:avianco/core/app_colors.dart';

class FlightsScreen extends StatefulWidget {
  const FlightsScreen({super.key});

  @override
  State<FlightsScreen> createState() => _FlightsScreenState();
}

class _FlightsScreenState extends State<FlightsScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero).then((_) {
      Provider.of<VuelosProvider>(context, listen: false).fetchVuelos();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<VuelosProvider>(context);
    final vuelos = provider.items;

    return Container(
      color: AppColors.background,
      child: Column(
        children: [
          _buildSearchBox(provider),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : vuelos.isEmpty
                    ? const Center(child: Text('No hay vuelos disponibles'))
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 140),
                        physics: const BouncingScrollPhysics(),
                        itemCount: vuelos.length,
                        itemBuilder: (ctx, i) => _buildFlightCard(vuelos[i]),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBox(VuelosProvider provider) {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: TextField(
        controller: _searchCtrl,
        onChanged: (v) => provider.fetchVuelos(search: v),
        decoration: const InputDecoration(
          hintText: 'Buscar número de vuelo...',
          border: InputBorder.none,
          icon: Icon(Icons.search, color: AppColors.primary),
        ),
      ),
    );
  }

  Widget _buildFlightCard(v) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12)],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _airportNode(v.origen, 'ORIGEN')),
                    const Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Icon(Icons.flight_takeoff, color: AppColors.primary, size: 20)),
                    Expanded(child: _airportNode(v.destino, 'DESTINO', isRight: true)),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('N° ${v.numeroVuelo}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.dark)),
                    _statusBadge(v.estado),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.04),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('\$${v.precioBase}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.primary)),
                const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.primary),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _airportNode(String iata, String label, {bool isRight = false}) {
    return Column(
      crossAxisAlignment: isRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(iata, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.dark), overflow: TextOverflow.ellipsis),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _statusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(status.toUpperCase(), style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 10)),
    );
  }
}
