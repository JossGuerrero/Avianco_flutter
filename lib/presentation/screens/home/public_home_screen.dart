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

  final Map<String, String> _destImages = {
    'UIO': 'https://images.unsplash.com/photo-1599059784346-601446e91983?auto=format&fit=crop&q=80&w=400',
    'GYE': 'https://images.unsplash.com/photo-1589984662646-e7b2e4962f18?auto=format&fit=crop&q=80&w=400',
    'BOG': 'https://images.unsplash.com/photo-1596464716127-f2a82984de30?auto=format&fit=crop&q=80&w=400',
    'MAD': 'https://images.unsplash.com/photo-1539037116277-4db20889f2d4?auto=format&fit=crop&q=80&w=400',
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final results = await Future.wait([
        ApiService.getVuelosPublico(),
        ApiService.getPromocionesPublico(),
      ]);
      if (!mounted) return;
      setState(() {
        _vuelos = results[0];
        _promociones = results[1];
        _loading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              onRefresh: _load,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  _buildHeader(),
                  _buildSearchCard(),
                  if (_promociones.isNotEmpty) ...[
                    _buildSectionTitle('Ofertas Exclusivas'),
                    _buildPromos(),
                  ],
                  _buildSectionTitle('Vuelos Destacados'),
                  _buildVuelos(),
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () => Navigator.pushNamed(context, '/login'),
        icon: const Icon(Icons.person_outline, color: Colors.white),
        label: const Text('Acceder', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildHeader() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(gradient: AppColors.bannerGradient),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                bottom: -20,
                child: Icon(Icons.airplanemode_active, size: 200, color: Colors.white.withValues(alpha: 0.05)),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(24, 80, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('avianco', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: 2)),
                    Text('Conectando el mundo', style: TextStyle(color: Colors.white70, fontSize: 16)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchCard() {
    return SliverToBoxAdapter(
      child: Transform.translate(
        offset: const Offset(0, -30),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 10))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('BUSCAR VUELO', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.greyAccent)),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.location_on, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Text('Desde Ecuador', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.dark)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
        child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.dark)),
      ),
    );
  }

  Widget _buildPromos() {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 140,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: _promociones.length,
          separatorBuilder: (_, __) => const SizedBox(width: 16),
          itemBuilder: (ctx, i) {
            final p = _promociones[i];
            return Container(
              width: 260,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: AppColors.promoGradient,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                    child: Text('${double.tryParse(p['descuento']?.toString() ?? '0')?.toInt() ?? 0}% OFF', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                  const Spacer(),
                  Text(p['codigo'] ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                  Text('Vence ${p['fecha_fin']}', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 11)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildVuelos() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (ctx, i) {
            final v = _vuelos[i];
            final iata = v['destino_detalle']?['codigo_iata'] ?? 'UIO';
            final img = _destImages[iata] ?? 'https://images.unsplash.com/photo-1436491865332-7a61a109cc05?auto=format&fit=crop&q=80&w=400';

            return Container(
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 8))],
              ),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    child: Image.network(img, height: 150, width: double.infinity, fit: BoxFit.cover),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildFlightNode(v['origen_detalle']?['codigo_iata'] ?? '', v['origen_detalle']?['ciudad'] ?? ''),
                            const _RutaPunteada(),
                            _buildFlightNode(v['destino_detalle']?['codigo_iata'] ?? '', v['destino_detalle']?['ciudad'] ?? '', alignRight: true),
                          ],
                        ),
                        const Divider(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('\$${v['precio']}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.success)),
                            ElevatedButton(
                              onPressed: () async {
                                final loggedIn = await AuthService.isLoggedIn();
                                if (loggedIn) {
                                  // Ir a reserva si está logueado
                                  if (mounted) Navigator.pushNamed(context, '/home');
                                } else {
                                  if (mounted) Navigator.pushNamed(context, '/login');
                                }
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                              child: const Text('Reservar', style: TextStyle(color: Colors.white)),
                            ),
                          ],
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

  Widget _buildFlightNode(String iata, String city, {bool alignRight = false}) {
    return Column(
      crossAxisAlignment: alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(iata, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.dark)),
        Text(city, style: const TextStyle(fontSize: 12, color: AppColors.greyAccent)),
      ],
    );
  }
}

class _RutaPunteada extends StatelessWidget {
  const _RutaPunteada();

  @override
  Widget build(BuildContext context) {
    Widget puntos() => Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              5,
              (_) => Container(
                width: 3,
                height: 1.5,
                color: Colors.grey.shade400,
              ),
            ),
          ),
        );

    return Row(
      children: [
        Container(
          width: 5,
          height: 5,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade400),
          ),
        ),
        puntos(),
        const Icon(Icons.flight, size: 14, color: AppColors.primary),
        puntos(),
        Container(
          width: 5,
          height: 5,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}
