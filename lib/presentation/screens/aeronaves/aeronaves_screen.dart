import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:avianco/presentation/providers/aeronaves_provider.dart';
import 'package:avianco/domain/models/aeronave.dart';

class AircraftsScreen extends StatefulWidget {
  const AircraftsScreen({super.key});

  @override
  State<AircraftsScreen> createState() => _AircraftsScreenState();
}

class _AircraftsScreenState extends State<AircraftsScreen> {
  final _searchCtrl = TextEditingController();
  static const _blue = Color(0xFF1565C0);

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero).then((_) {
      Provider.of<AeronavesProvider>(context, listen: false).fetchAeronaves();
    });
  }

  @override
  Widget build(BuildContext context) {
    final aeronavesData = Provider.of<AeronavesProvider>(context);
    final aeronaves = aeronavesData.items;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: _blue,
        title: const Text(
          'Aeronaves',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Buscar aeronave...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchCtrl.clear();
                    aeronavesData.fetchAeronaves();
                  },
                ),
              ),
              onChanged: (v) => aeronavesData.fetchAeronaves(search: v),
            ),
          ),
          Expanded(
            child: aeronavesData.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: _blue),
                  )
                : aeronaves.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.airplanemode_inactive,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'No hay aeronaves',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () => aeronavesData.fetchAeronaves(),
                    child: ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemCount: aeronaves.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (ctx, i) {
                        final a = aeronaves[i];
                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: _blue,
                              child: Icon(
                                Icons.airplanemode_active,
                                color: Colors.white,
                              ),
                            ),
                            title: Text(
                              a.modelo,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              '${a.matricula} · ${a.capacidad} pasajeros',
                            ),
                            trailing: Text(
                              a.estado,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
