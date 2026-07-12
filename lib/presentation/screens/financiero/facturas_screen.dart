import 'package:flutter/material.dart';
import 'package:avianco/services/api_service.dart';
import 'package:avianco/core/app_colors.dart';

class InvoicesScreen extends StatefulWidget {
  const InvoicesScreen({super.key});

  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> {
  List<dynamic> _items = [];
  bool _loading = true;

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
    switch (estado.toLowerCase()) {
      case 'pagada':
        return AppColors.success;
      case 'pendiente':
        return Colors.orange;
      case 'anulada':
        return AppColors.primary;
      default:
        return AppColors.greyAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(),
          _loading
              ? const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                )
              : _items.isEmpty
                  ? const SliverFillRemaining(
                      child: Center(child: Text('No hay facturas registradas')),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.all(20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (ctx, i) => _buildInvoiceCard(_items[i]),
                          childCount: _items.length,
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
        title: const Text(
          'Historial de Facturas',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        background: Container(
          decoration: const BoxDecoration(gradient: AppColors.bannerGradient),
          child: Opacity(
            opacity: 0.1,
            child: Icon(Icons.receipt_long, size: 150, color: Colors.white.withValues(alpha: 0.5)),
          ),
        ),
      ),
    );
  }

  Widget _buildInvoiceCard(item) {
    final estado = (item['estado'] ?? '').toString();
    final total = item['total'] ?? '0.00';
    final impuestos = item['impuestos'] ?? '0.00';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Factura #${item['id']}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.dark),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Reserva ID: ${item['reserva']}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
                _buildStatusBadge(estado),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(height: 1, color: Color(0xFFF0F0F0)),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'IMPUESTOS',
                      style: TextStyle(color: Colors.grey[400], fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 4),
                    Text('\$$impuestos', style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.dark)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'TOTAL A PAGAR',
                      style: TextStyle(color: Colors.grey[400], fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$$total',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.primary),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String estado) {
    final color = _estadoColor(estado);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        estado.toUpperCase(),
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 0.5),
      ),
    );
  }
}
