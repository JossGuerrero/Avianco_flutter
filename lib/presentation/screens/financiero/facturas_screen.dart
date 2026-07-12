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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Historial de Facturación', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Container(
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : _items.isEmpty
                    ? const Center(child: Text('No se encontraron facturas', style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                        physics: const BouncingScrollPhysics(),
                        itemCount: _items.length,
                        itemBuilder: (ctx, i) => _buildInvoiceCard(_items[i]),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceCard(item) {
    final estado = (item['estado'] ?? '').toString().toLowerCase();
    Color statusCol = estado == 'pagada' ? AppColors.success : (estado == 'anulada' ? AppColors.primary : Colors.orange);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('FACTURA #${item['id']}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.dark, letterSpacing: -0.5)),
                    const SizedBox(height: 4),
                    Text('Emisión: ${item['fecha_emision'].toString().split('T').first}', style: TextStyle(color: Colors.grey[400], fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
                _statusChip(estado, statusCol),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.03),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _amountNode('IVA (15%)', '\$${item['impuestos']}'),
                _amountNode('TOTAL', '\$${item['total']}', isBold: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String text, Color col) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(color: col.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
      child: Text(text.toUpperCase(), style: TextStyle(color: col, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 0.5)),
    );
  }

  Widget _amountNode(String label, String val, {bool isBold = false}) {
    return Column(
      crossAxisAlignment: isBold ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.8)),
        const SizedBox(height: 6),
        Text(val, style: TextStyle(fontWeight: isBold ? FontWeight.w900 : FontWeight.bold, fontSize: isBold ? 24 : 16, color: isBold ? AppColors.primary : AppColors.dark)),
      ],
    );
  }
}
