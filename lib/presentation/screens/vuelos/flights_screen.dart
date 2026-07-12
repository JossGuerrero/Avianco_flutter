import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:avianco/presentation/providers/vuelos_provider.dart';
import 'package:avianco/domain/models/vuelo.dart';

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

  Color _estadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'programado':
        return const Color(0xFF2E7D32);
      case 'cancelado':
        return Colors.red;
      case 'despegado':
        return const Color(0xFF1565C0);
      case 'aterrizado':
        return const Color(0xFF7B2D8B);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final vuelosData = Provider.of<VuelosProvider>(context);
    final vuelos = vuelosData.items;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: _searchCtrl,
            decoration: InputDecoration(
              hintText: 'Buscar vuelo...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchCtrl.clear();
                  vuelosData.fetchVuelos();
                },
              ),
            ),
            onChanged: (v) => vuelosData.fetchVuelos(search: v),
          ),
        ),
        Expanded(
          child: vuelosData.isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFF7B2D8B)),
                )
              : vuelos.isEmpty
              ? const Center(child: Text('No hay vuelos'))
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: vuelos.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (ctx, i) {
                    final v = vuelos[i];
                    return Card(
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFF2E7D32),
                          child: Icon(
                            Icons.flight_takeoff,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          '${v.origen} → ${v.destino}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${v.fechaSalida.toString().substring(0, 16)} · \$${v.precioBase}',
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _estadoColor(v.estado),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            v.estado,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
