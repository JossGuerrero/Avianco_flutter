import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../services/api_service.dart' as api;

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  List<dynamic> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final data = await api.ApiService.getServicios();
    if (!mounted) return;
    setState(() {
      _items = data;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_items.isEmpty)
      return const Center(child: Text('No hay servicios disponibles'));

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = _items[index];
        final name = item['nombre'] ?? item['name'] ?? '';
        final price = item['precio'] ?? item['price'] ?? '';
        return Card(
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: AppColors.deepRed,
              child: Icon(Icons.room_service, color: Colors.white),
            ),
            title: Text(name.toString()),
            subtitle: Text('USD $price'),
            trailing: const Icon(Icons.chevron_right),
          ),
        );
      },
    );
  }
}
