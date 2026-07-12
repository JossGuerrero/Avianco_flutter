import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:avianco/presentation/providers/checkins_provider.dart';
import 'package:avianco/core/app_colors.dart';

class CheckinsScreen extends StatefulWidget {
  const CheckinsScreen({super.key});

  @override
  State<CheckinsScreen> createState() => _CheckinsScreenState();
}

class _CheckinsScreenState extends State<CheckinsScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero).then((_) {
      Provider.of<CheckinsProvider>(context, listen: false).fetchCheckins();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CheckinsProvider>(context);
    final checkins = provider.items;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Tarjetas de Embarque', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
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
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : checkins.isEmpty
                    ? const Center(child: Text('Sin registros de check-in', style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                        physics: const BouncingScrollPhysics(),
                        itemCount: checkins.length,
                        itemBuilder: (ctx, i) => _buildCheckinItem(checkins[i]),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckinItem(c) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('RESERVA #${c.reservaId}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.dark)),
                  const SizedBox(height: 4),
                  Text(c.fechaCheckin.toString().substring(0, 16), style: TextStyle(color: Colors.grey[400], fontSize: 13, fontWeight: FontWeight.w500)),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(16)),
                child: const Icon(Icons.qr_code_2_rounded, color: AppColors.success, size: 32),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Row(
              children: List.generate(20, (i) => Expanded(child: Container(height: 1, color: i % 2 == 0 ? Colors.grey[200] : Colors.transparent))),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _infoNode('PUERTA', c.puerta),
              _infoNode('ESTADO', c.estado.toUpperCase(), isSuccess: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoNode(String label, String value, {bool isSuccess = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isSuccess ? AppColors.success : AppColors.dark)),
      ],
    );
  }
}
