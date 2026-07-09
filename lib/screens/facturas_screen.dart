import 'package:flutter/material.dart';
import '../services/api_service.dart';

class InvoicesScreen extends StatefulWidget {
  const InvoicesScreen({super.key});

  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> {
  List<dynamic> _items = [];
  bool _loading = true;

  static const _grey = Color(0xFF9E9E9E);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final data = await ApiService.getFacturas();
    if (!mounted) return;
    setState(() {
      _items = data;
      _loading = false;
    });
  }

  Color _estadoColor(String estado) {
    switch (estado) {
      case 'pagada':
        return const Color(0xFF2E7D32);
      case 'pendiente':
        return const Color(0xFFE65100);
      case 'anulada':
        return Colors.red;
      default:
        return _grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Facturas'), backgroundColor: _grey),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
          ? const Center(child: Text('No hay facturas'))
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = _items[index];
                  final total = item['total'] ?? '0.00';
                  final impuestos = item['impuestos'] ?? '0.00';
                  final estado = (item['estado'] ?? '').toString();
                  return Card(
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: _grey,
                        child: Icon(Icons.receipt_long, color: Colors.white),
                      ),
                      title: Text('Factura #${item['id']}'),
                      subtitle: Text(
                        'Total: \$$total · Impuestos: \$$impuestos',
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _estadoColor(estado),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          estado,
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
    );
  }
}
