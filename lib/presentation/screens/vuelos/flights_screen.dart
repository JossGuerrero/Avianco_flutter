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
    final vuelosData = Provider.of<VuelosProvider>(context);
    final vuelos = vuelosData.items;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Vuelos Disponibles', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildSearchBar(vuelosData),
          Expanded(
            child: vuelosData.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : RefreshIndicator(
                    onRefresh: () => vuelosData.fetchVuelos(),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: vuelos.length,
                      itemBuilder: (ctx, i) {
                        final v = vuelos[i];
                        return _buildFlightTicket(v);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(VuelosProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: TextField(
          controller: _searchCtrl,
          onChanged: (val) => provider.fetchVuelos(search: val),
          decoration: const InputDecoration(
            hintText: 'Buscar por número o destino...',
            border: InputBorder.none,
            icon: Icon(Icons.search, color: AppColors.primary),
          ),
        ),
      ),
    );
  }

  Widget _buildFlightTicket(v) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildAirportNode(v.origen, 'Origen'),
                    const _RutaPunteada(),
                    _buildAirportNode(v.destino, 'Destino', isRight: true),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('FECHA Y HORA', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                        Text(v.fechaSalida.toString().substring(0, 16), style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    _buildStatusChip(v.estado),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.03),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('N° ${v.numeroVuelo}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.dark)),
                Text('\$${v.precioBase}', style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.w900, fontSize: 18)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAirportNode(String iata, String label, {bool isRight = false}) {
    return Column(
      crossAxisAlignment: isRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(iata, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.primary)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildStatusChip(String estado) {
    Color color;
    switch (estado.toLowerCase()) {
      case 'programado': color = AppColors.success; break;
      case 'cancelado': color = AppColors.primary; break;
      default: color = Colors.orange;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(estado.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}

class _RutaPunteada extends StatelessWidget {
  const _RutaPunteada();
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Row(children: List.generate(10, (i) => Expanded(child: Container(height: 1, color: i % 2 == 0 ? Colors.grey[300] : Colors.transparent)))),
            const Icon(Icons.airplanemode_active, color: AppColors.primary, size: 20),
          ],
        ),
      ),
    );
  }
}
