import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../services/api_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _loading = true;
  int _vuelos = 0;
  int _reservas = 0;
  int _pasajeros = 0;
  int _aeropuertos = 0;
  Map<String, dynamic> _reservasStats = {};
  Map<String, dynamic> _vuelosStats = {};
  Map<String, dynamic> _aeronavesStats = {};
  List<dynamic> _aeronaves = [];
  List<dynamic> _ultimasReservas = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final results = await Future.wait([
      ApiService.getVuelosCount(),
      ApiService.getReservasCount(),
      ApiService.getPasajerosCount(),
      ApiService.getAeropuertosCount(),
      ApiService.getReservasEstadisticas(),
      ApiService.getVuelosEstadisticas(),
      ApiService.getAeronavesEstadisticas(),
      ApiService.getAeronaves(),
      ApiService.getReservas(),
    ]);
    if (!mounted) return;
    setState(() {
      _vuelos = results[0] as int;
      _reservas = results[1] as int;
      _pasajeros = results[2] as int;
      _aeropuertos = results[3] as int;
      _reservasStats = results[4] as Map<String, dynamic>;
      _vuelosStats = results[5] as Map<String, dynamic>;
      _aeronavesStats = results[6] as Map<String, dynamic>;
      _aeronaves = results[7] as List<dynamic>;
      _ultimasReservas = (results[8] as List<dynamic>).take(5).toList();
      _loading = false;
    });
  }

  /// Extrae un conteo por estado de una respuesta de estadísticas,
  /// tolerando distintas formas de respuesta del backend.
  int _statOf(Map<String, dynamic> stats, String estado) {
    final direct = stats[estado];
    if (direct is num) return direct.toInt();
    for (final key in ['por_estado', 'estados', 'data', 'results']) {
      final list = stats[key];
      if (list is List) {
        for (final item in list) {
          if (item is Map && item['estado'] == estado) {
            final v = item['total'] ?? item['count'] ?? item['cantidad'];
            if (v is num) return v.toInt();
          }
        }
      }
    }
    return 0;
  }

  /// Lista (etiqueta, capacidad) para el gráfico de aeronaves: intenta el
  /// endpoint de estadísticas y cae a la lista real de aeronaves.
  List<MapEntry<String, double>> _capacidades() {
    final fromStats = _aeronavesStats['aeronaves'] ?? _aeronavesStats['results'];
    final source = fromStats is List && fromStats.isNotEmpty
        ? fromStats
        : _aeronaves;
    return source
        .take(6)
        .map<MapEntry<String, double>>(
          (a) => MapEntry(
            (a['matricula'] ?? a['modelo'] ?? '—').toString(),
            (a['capacidad'] is num) ? (a['capacidad'] as num).toDouble() : 0,
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Panel general',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.dark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Estadísticas en tiempo real',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            const SizedBox(height: 16),

            // ---- Cards de estadísticas 2x2 ----
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _StatCard(
                  title: 'Vuelos',
                  value: '$_vuelos',
                  icon: Icons.flight_takeoff,
                  gradient: const [AppColors.primary, AppColors.dark],
                ),
                _StatCard(
                  title: 'Reservas',
                  value: '$_reservas',
                  icon: Icons.book_online,
                  gradient: const [AppColors.darkRed, AppColors.dark],
                ),
                _StatCard(
                  title: 'Pasajeros',
                  value: '$_pasajeros',
                  icon: Icons.people,
                  gradient: const [AppColors.deepRed, AppColors.dark],
                ),
                _StatCard(
                  title: 'Aeropuertos',
                  value: '$_aeropuertos',
                  icon: Icons.location_on,
                  gradient: const [AppColors.darkAlt, AppColors.dark],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ---- Barras: reservas por estado ----
            _ChartCard(
              title: 'Reservas por estado',
              child: SizedBox(
                height: 200,
                child: _reservasStats.isEmpty
                    ? const _NoData()
                    : _buildReservasBarChart(),
              ),
            ),
            const SizedBox(height: 16),

            // ---- Pastel: vuelos por estado ----
            _ChartCard(
              title: 'Vuelos por estado',
              child: SizedBox(
                height: 210,
                child: _vuelosStats.isEmpty
                    ? const _NoData()
                    : _buildVuelosPieChart(),
              ),
            ),
            const SizedBox(height: 16),

            // ---- Barras: capacidad por aeronave ----
            _ChartCard(
              title: 'Capacidad por aeronave',
              child: SizedBox(
                height: 200,
                child: _capacidades().isEmpty
                    ? const _NoData()
                    : _buildAeronavesBarChart(),
              ),
            ),
            const SizedBox(height: 20),

            // ---- Últimas reservas ----
            const Text(
              'Últimas reservas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.dark,
              ),
            ),
            const SizedBox(height: 12),
            if (_ultimasReservas.isEmpty)
              const _NoData()
            else
              ..._ultimasReservas.map(
                (r) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.primary,
                      child: Icon(
                        Icons.book_online,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      'Reserva #${r['id']} · Asiento ${r['asiento'] ?? '—'}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Text(
                      'Vuelo ${r['vuelo']} · Pasajero ${r['pasajero']}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: (r['estado'] == 'cancelada')
                            ? AppColors.primary
                            : AppColors.dark,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        (r['estado'] ?? '').toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildReservasBarChart() {
    final confirmadas = _statOf(_reservasStats, 'confirmada').toDouble();
    final canceladas = _statOf(_reservasStats, 'cancelada').toDouble();
    final embarcadas = _statOf(_reservasStats, 'embarcado').toDouble();
    final maxY = [confirmadas, canceladas, embarcadas]
        .reduce((a, b) => a > b ? a : b);

    BarChartGroupData group(int x, double y, Color color) {
      return BarChartGroupData(
        x: x,
        barRods: [
          BarChartRodData(
            toY: y,
            color: color,
            width: 34,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(6),
            ),
          ),
        ],
      );
    }

    const labels = ['Confirmadas', 'Canceladas', 'Embarcadas'];
    return BarChart(
      BarChartData(
        maxY: maxY == 0 ? 5 : maxY * 1.2,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (v) => FlLine(
            color: Colors.grey.withValues(alpha: 0.15),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (v, meta) => Text(
                v.toInt().toString(),
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, meta) => Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  labels[v.toInt()],
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.dark,
                  ),
                ),
              ),
            ),
          ),
        ),
        barGroups: [
          group(0, confirmadas, AppColors.primary),
          group(1, canceladas, AppColors.dark),
          group(2, embarcadas, AppColors.greyDark),
        ],
      ),
    );
  }

  Widget _buildVuelosPieChart() {
    final estados = {
      'programado': AppColors.primary,
      'cancelado': AppColors.dark,
      'despegado': AppColors.darkRed,
      'aterrizado': AppColors.greyDark,
    };
    final values = {
      for (final e in estados.keys) e: _statOf(_vuelosStats, e),
    };
    final total = values.values.fold<int>(0, (a, b) => a + b);
    if (total == 0) return const _NoData();

    return Row(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sectionsSpace: 3,
              centerSpaceRadius: 32,
              sections: estados.entries
                  .where((e) => values[e.key]! > 0)
                  .map(
                    (e) => PieChartSectionData(
                      value: values[e.key]!.toDouble(),
                      color: e.value,
                      radius: 55,
                      title:
                          '${(values[e.key]! * 100 / total).round()}%',
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: estados.entries
              .map(
                (e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: e.value,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${e.key} (${values[e.key]})',
                        style: const TextStyle(fontSize: 11),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildAeronavesBarChart() {
    final caps = _capacidades();
    final maxY = caps
        .map((e) => e.value)
        .fold<double>(0, (a, b) => a > b ? a : b);

    return BarChart(
      BarChartData(
        maxY: maxY == 0 ? 5 : maxY * 1.2,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (v) => FlLine(
            color: Colors.grey.withValues(alpha: 0.15),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (v, meta) => Text(
                v.toInt().toString(),
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              getTitlesWidget: (v, meta) {
                final i = v.toInt();
                if (i < 0 || i >= caps.length) return const SizedBox();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    caps[i].key,
                    style: const TextStyle(
                      fontSize: 9,
                      color: AppColors.dark,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: [
          for (var i = 0; i < caps.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: caps[i].value,
                  width: 22,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6),
                  ),
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.darkRed],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final List<Color> gradient;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: gradient.first.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: Colors.white70, size: 22),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _ChartCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.dark,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _NoData extends StatelessWidget {
  const _NoData();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart, size: 40, color: Colors.grey),
            SizedBox(height: 6),
            Text('— Sin datos —', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
