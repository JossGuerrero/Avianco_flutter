import 'package:flutter/material.dart';
import 'package:avianco/services/api_service.dart';
import 'package:avianco/services/auth_service.dart';
import 'package:avianco/core/app_colors.dart';

class SeatsScreen extends StatefulWidget {
  const SeatsScreen({super.key});

  @override
  State<SeatsScreen> createState() => _SeatsScreenState();
}

class _SeatsScreenState extends State<SeatsScreen> {
  List<dynamic> _items = [];
  bool _loading = true;
  bool _isStaff = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    _isStaff = await AuthService.isStaff();
    final data = await ApiService.getAsientos();
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
        title: const Text('Distribución de Asientos', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
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
                    ? const Center(child: Text('Sin registros de asientos', style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                        physics: const BouncingScrollPhysics(),
                        itemCount: _items.length,
                        itemBuilder: (ctx, i) => _buildSeatCard(_items[i]),
                      ),
          ),
        ],
      ),
      floatingActionButton: _isStaff ? _buildFAB() : null,
    );
  }

  Widget _buildSeatCard(item) {
    final bool disp = item['disponible'] == true;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(20),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: (disp ? AppColors.success : AppColors.primary).withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(Icons.event_seat, color: disp ? AppColors.success : AppColors.primary, size: 28),
        ),
        title: Text('Asiento ${item['codigo']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.dark)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text('FILA: ${item['fila']} · COLUMNA: ${item['columna']}', style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: (disp ? AppColors.success : AppColors.primary).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            disp ? 'LIBRE' : 'OCUPADO',
            style: TextStyle(color: disp ? AppColors.success : AppColors.primary, fontWeight: FontWeight.w900, fontSize: 10),
          ),
        ),
      ),
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton(
      backgroundColor: AppColors.primary,
      onPressed: () {},
      elevation: 4,
      child: const Icon(Icons.add, color: Colors.white),
    );
  }
}
