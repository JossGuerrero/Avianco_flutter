import 'package:flutter/material.dart';
import 'package:avianco/services/api_service.dart';
import 'package:avianco/services/auth_service.dart';
import 'package:avianco/core/app_colors.dart';

class PublicHomeScreen extends StatefulWidget {
  const PublicHomeScreen({super.key});

  @override
  State<PublicHomeScreen> createState() => _PublicHomeScreenState();
}

class _PublicHomeScreenState extends State<PublicHomeScreen> {
  List<dynamic> _vuelos = [];
  List<dynamic> _promociones = [];
  bool _loading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _load();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final status = await AuthService.isLoggedIn();
    if (mounted) setState(() => _isLoggedIn = status);
  }

  Future<void> _load() async {
    try {
      final results = await Future.wait([
        ApiService.getVuelosPublico(),
        ApiService.getPromocionesPublico(),
      ]);
      if (!mounted) return;
      setState(() {
        _vuelos = results[0].isNotEmpty ? results[0] : _getMockVuelos();
        _promociones = results[1];
        _loading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Map<String, dynamic>> _getMockVuelos() {
    return [
      {'precio': '125.00', 'origen_detalle': {'codigo_iata': 'UIO', 'ciudad': 'Quito'}, 'destino_detalle': {'codigo_iata': 'BOG', 'ciudad': 'Bogotá'}},
      {'precio': '210.00', 'origen_detalle': {'codigo_iata': 'GYE', 'ciudad': 'Guayaquil'}, 'destino_detalle': {'codigo_iata': 'MAD', 'ciudad': 'Madrid'}},
      {'precio': '340.50', 'origen_detalle': {'codigo_iata': 'UIO', 'ciudad': 'Quito'}, 'destino_detalle': {'codigo_iata': 'NYC', 'ciudad': 'New York'}},
    ];
  }

  String _getAviationImg(int index) {
    final imgs = [
      'https://images.unsplash.com/photo-1436491865332-7a61a109cc05?w=800&q=80', // Avion
      'https://images.unsplash.com/photo-1544016768-982d1554f0b9?w=800&q=80', // Terminal
      'https://images.unsplash.com/photo-1517935706615-2717063c2225?w=800&q=80', // Vista avion
    ];
    return imgs[index % imgs.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildAppBar(),
                _buildModernHeader(),
                _buildSearchCard(),
                if (_promociones.isNotEmpty) _buildPromosList(),
                _buildSectionTitle('Vuelos Destacados'),
                _buildFlightsList(),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
      floatingActionButton: _isLoggedIn ? _buildFAB() : null,
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      pinned: true,
      centerTitle: false,
      title: const FittedBox(
        fit: BoxFit.scaleDown,
        child: Text('avianco', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 2)),
      ),
      actions: [
        if (!_isLoggedIn) ...[
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/login'),
            child: const Text('ENTRAR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12, left: 4),
            child: ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/register'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                minimumSize: const Size(0, 32),
              ),
              child: const Text('UNIRSE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
            ),
          ),
        ] else ...[
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/profile'),
            icon: const Icon(Icons.account_circle, color: Colors.white, size: 28),
          ),
        ]
      ],
    );
  }

  Widget _buildModernHeader() {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 60),
        decoration: const BoxDecoration(
          gradient: AppColors.bannerGradient,
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bienvenido\na bordo', style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w900, height: 1.1)),
            SizedBox(height: 10),
            Text('Encuentra tu próximo destino con nosotros', style: TextStyle(color: Colors.white70, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchCard() {
    return SliverToBoxAdapter(
      child: Transform.translate(
        offset: const Offset(0, -35),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 30, offset: const Offset(0, 10))],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: const Icon(Icons.search, color: AppColors.primary),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('DESTINO', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                    Text('¿A dónde quieres ir?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: AppColors.dark)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPromosList() {
    return SliverToBoxAdapter(
      child: Container(
        height: 120,
        margin: const EdgeInsets.only(bottom: 24),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: _promociones.length,
          itemBuilder: (ctx, i) {
            final p = _promociones[i];
            return Container(
              width: 260,
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.promoGradient,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('${p['descuento']}% OFF', style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w900, fontSize: 18)),
                  Text(p['codigo'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String t) => SliverToBoxAdapter(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: Text(t, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.dark)),
    ),
  );

  Widget _buildFlightsList() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (ctx, i) {
            final v = _vuelos[i];
            return Container(
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 10))],
              ),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                    child: Stack(
                      children: [
                        Image.network(
                          _getAviationImg(i),
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                        Positioned(
                          top: 16,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(16)),
                            child: Text('\$${v['precio']}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 18)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(child: _node(v['origen_detalle']?['codigo_iata'] ?? '—', v['origen_detalle']?['ciudad'] ?? 'Origen')),
                            const Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Icon(Icons.flight_takeoff, color: AppColors.primary, size: 24)),
                            Expanded(child: _node(v['destino_detalle']?['codigo_iata'] ?? '—', v['destino_detalle']?['ciudad'] ?? 'Destino', isRight: true)),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.dark,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                              elevation: 0,
                            ),
                            child: const Text('RESERVAR AHORA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
          childCount: _vuelos.length,
        ),
      ),
    );
  }

  Widget _node(String iata, String city, {bool isRight = false}) {
    return Column(
      crossAxisAlignment: isRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(iata, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppColors.dark)),
        Text(city, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton.extended(
      backgroundColor: AppColors.primary,
      onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
      icon: const Icon(Icons.grid_view_rounded, color: Colors.white),
      label: const Text('MI PANEL', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }
}
