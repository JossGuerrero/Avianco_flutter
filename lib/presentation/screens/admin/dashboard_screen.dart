import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:avianco/presentation/providers/dashboard_provider.dart';
import 'package:avianco/core/app_colors.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero).then((_) {
      Provider.of<DashboardProvider>(context, listen: false).fetchStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dashData = Provider.of<DashboardProvider>(context);
    final stats = dashData.stats;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Analíticas', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: dashData.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              onRefresh: dashData.fetchStats,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Estado del Sistema', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.dark)),
                    const SizedBox(height: 20),
                    _buildStatCard('Vuelos Activos', stats['vuelos'].toString(), Icons.flight_takeoff, const Color(0xFF4834D4)),
                    const SizedBox(height: 16),
                    _buildStatCard('Reservas Totales', stats['reservas'].toString(), Icons.book_online, const Color(0xFF686DE0)),
                    const SizedBox(height: 16),
                    _buildStatCard('Pasajeros Registrados', stats['pasajeros'].toString(), Icons.person, const Color(0xFFF0932B)),
                    const SizedBox(height: 16),
                    _buildStatCard('Aeropuertos Conectados', stats['aeropuertos'].toString(), Icons.map, const Color(0xFFBE2EDD)),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
              Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.dark)),
            ],
          ),
        ],
      ),
    );
  }
}
