import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'seat_selector_screen.dart';

class PublicHomeScreen extends StatefulWidget {
  const PublicHomeScreen({super.key});

  @override
  State<PublicHomeScreen> createState() => _PublicHomeScreenState();
}

class _PublicHomeScreenState extends State<PublicHomeScreen> {
  List<dynamic> _vuelos = [];
  List<dynamic> _promociones = [];
  bool _loading = true;

  static const _purple = AppColors.primary;
  static const _darkPurple = AppColors.dark;

  // Imágenes reales de ciudades por código IATA
  static const Map<String, String> _cityImages = {
    'UIO': 'https://images.unsplash.com/photo-1531968455001-5c5272a41129?w=600',
    'GYE': 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=600',
    'BOG': 'https://images.unsplash.com/photo-1539037116277-4db20889f2d4?w=600',
    'LIM': 'https://images.unsplash.com/photo-1526392060635-9d6019884377?w=600',
    'EZE': 'https://images.unsplash.com/photo-1589909202802-8f4aadce1849?w=600',
    'MIA': 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=600',
    'MAD': 'https://images.unsplash.com/photo-1543783207-ec64e4d95325?w=600',
    'CUN': 'https://images.unsplash.com/photo-1510097467424-192d713fd8b2?w=600',
    'SCL': 'https://images.unsplash.com/photo-1478827387698-1527781a4887?w=600',
    'JFK': 'https://images.unsplash.com/photo-1496442226666-8d4d0e62e6e9?w=600',
  };

  static const _defaultImage =
      'https://images.unsplash.com/photo-1436491865332-7a61a109cc05?w=600';

  String _imageFor(String? iata) => _cityImages[iata] ?? _defaultImage;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final vuelos = await ApiService.getVuelosPublico();
    final promos = await ApiService.getPromocionesPublico();
    if (!mounted) return;
    setState(() {
      _vuelos = vuelos;
      _promociones = promos;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _purple))
          : RefreshIndicator(
              onRefresh: _load,
              child: CustomScrollView(
                slivers: [
                  // AppBar con gradiente
                  SliverAppBar(
                    expandedHeight: 220,
                    pinned: true,
                    backgroundColor: _purple,
                    actions: [
                      Container(
                        margin: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.pushNamed(context, '/login'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withValues(alpha: 0.2),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          icon: const Icon(Icons.person_outline, size: 18),
                          label: const Text(
                            'Ingresar',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      titlePadding: const EdgeInsets.only(left: 16, bottom: 14),
                      title: const Text(
                        'avianco',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 3,
                          color: Colors.white,
                        ),
                      ),
                      background: Container(
                        decoration: const BoxDecoration(
                          gradient: AppColors.mainGradient,
                        ),
                        child: const Stack(
                          children: [
                            Positioned(
                              right: -40,
                              top: -40,
                              child: Icon(
                                Icons.airplanemode_active,
                                size: 180,
                                color: Colors.white10,
                              ),
                            ),
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.airplanemode_active,
                                    size: 48,
                                    color: Colors.white24,
                                  ),
                                  SizedBox(height: 8),
                                  Padding(
                                    padding: EdgeInsets.only(bottom: 24),
                                    child: Text(
                                      'Conectando destinos',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 13,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Buscador estilo Avianca
                  SliverToBoxAdapter(
                    child: Transform.translate(
                      offset: const Offset(0, -35),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 20,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 24,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.flight_takeoff, color: _purple, size: 18),
                                SizedBox(width: 8),
                                Text(
                                  'Planifica tu viaje',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.dark,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                // Origen
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Desde',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _vuelos.isNotEmpty
                                            ? (_vuelos[0]['origen_detalle']?['ciudad'] ?? 'Quito')
                                            : 'Quito',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.dark,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Icono central
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.background,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.swap_horiz,
                                    color: _purple,
                                    size: 20,
                                  ),
                                ),
                                // Destino
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const Text(
                                        'Hacia',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${_vuelos.length} destinos',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.dark,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: () => Navigator.pushNamed(context, '/login'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: const Text(
                                  'Reservar ahora',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Promociones
                  if (_promociones.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Promociones especiales',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 140,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: _promociones.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(width: 12),
                                itemBuilder: (ctx, i) {
                                  final p = _promociones[i];
                                  final pct = double.tryParse(p['descuento']?.toString() ?? '0')?.toInt() ?? 0;
                                  return Container(
                                    width: 280,
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      gradient: AppColors.promoGradient,
                                      borderRadius: BorderRadius.circular(18),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primary.withValues(alpha: 0.25),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              p['codigo'] ?? '',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                                letterSpacing: 1.2,
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 10, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                '$pct% OFF',
                                                style: const TextStyle(
                                                  color: AppColors.primary,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const Spacer(),
                                        Text(
                                          p['descripcion'] ?? '',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.access_time,
                                              color: Colors.white60,
                                              size: 12,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Válido hasta ${p['fecha_fin'] ?? ''}',
                                              style: const TextStyle(
                                                color: Colors.white60,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Ofertas de vuelos con imágenes
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                      child: Row(
                        children: [
                          const Text('Ofertas de vuelos',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          const Spacer(),
                          Text('${_vuelos.length} disponibles',
                              style: const TextStyle(
                                  color: _purple, fontSize: 13)),
                        ],
                      ),
                    ),
                  ),

                  _vuelos.isEmpty
                      ? const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: Center(
                                child: Text('No hay vuelos disponibles',
                                    style: TextStyle(color: Colors.grey))),
                          ),
                        )
                      : SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (ctx, i) {
                                final v = _vuelos[i];
                                final origenIata =
                                    v['origen_detalle']?['codigo_iata'];
                                final destinoIata =
                                    v['destino_detalle']?['codigo_iata'];
                                final destinoCiudad =
                                    v['destino_detalle']?['ciudad'] ??
                                        destinoIata ??
                                        'Destino';
                                final origenCiudad =
                                    v['origen_detalle']?['ciudad'] ??
                                        origenIata ??
                                        'Origen';
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: GestureDetector(
                                    onTap: () async {
                                      final logged =
                                          await AuthService.isLoggedIn();
                                      if (!context.mounted) return;
                                      if (logged) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                SeatSelectorScreen(vuelo: v),
                                          ),
                                        );
                                      } else {
                                        Navigator.pushNamed(
                                            context, '/login');
                                      }
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.08),
                                            blurRadius: 16,
                                            offset: const Offset(0, 6),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Imagen del destino con tags flotantes
                                          ClipRRect(
                                            borderRadius:
                                                const BorderRadius.vertical(
                                                    top: Radius.circular(20)),
                                            child: Stack(
                                              children: [
                                                Image.network(
                                                  _imageFor(destinoIata),
                                                  height: 160,
                                                  width: double.infinity,
                                                  fit: BoxFit.cover,
                                                  loadingBuilder: (c, child,
                                                      progress) {
                                                    if (progress == null) {
                                                      return child;
                                                    }
                                                    return Container(
                                                      height: 160,
                                                      color: Colors.grey[200],
                                                      child: const Center(
                                                          child:
                                                              CircularProgressIndicator(
                                                                  color:
                                                                      _purple)),
                                                    );
                                                  },
                                                  errorBuilder:
                                                      (c, e, s) => Container(
                                                    height: 160,
                                                    color: _purple,
                                                    child: const Icon(
                                                        Icons.flight,
                                                        color: Colors.white,
                                                        size: 48),
                                                  ),
                                                ),
                                                // Tag de estado (arriba izquierda)
                                                Positioned(
                                                  top: 12,
                                                  left: 12,
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 10,
                                                        vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: Colors.black
                                                          .withValues(
                                                              alpha: 0.6),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                    ),
                                                    child: Text(
                                                      (v['estado'] ?? '').toString().toUpperCase(),
                                                      style: const TextStyle(
                                                          color: Colors.white,
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 10),
                                                    ),
                                                  ),
                                                ),
                                                // Tag de precio (abajo derecha)
                                                Positioned(
                                                  bottom: 12,
                                                  right: 12,
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 12,
                                                        vertical: 6),
                                                    decoration: BoxDecoration(
                                                      color: AppColors.primary,
                                                      borderRadius:
                                                          BorderRadius.circular(12),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: AppColors.primary.withValues(alpha: 0.3),
                                                          blurRadius: 6,
                                                          offset: const Offset(0, 3),
                                                        ),
                                                      ],
                                                    ),
                                                    child: Text(
                                                      '\$${v['precio']}',
                                                      style: const TextStyle(
                                                          color: Colors.white,
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 16),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          // Info estilo pase de abordar
                                          Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    // Origen
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            origenIata ?? '—',
                                                            style: const TextStyle(
                                                                fontSize: 22,
                                                                fontWeight: FontWeight.bold,
                                                                color: AppColors.dark),
                                                          ),
                                                          Text(
                                                            origenCiudad,
                                                            style: const TextStyle(
                                                                fontSize: 12,
                                                                color: Colors.grey),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    // Conexión
                                                    const SizedBox(
                                                      width: 80,
                                                      child: _RutaPunteada(),
                                                    ),
                                                    // Destino
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.end,
                                                        children: [
                                                          Text(
                                                            destinoIata ?? '—',
                                                            style: const TextStyle(
                                                                fontSize: 22,
                                                                fontWeight: FontWeight.bold,
                                                                color: AppColors.dark),
                                                          ),
                                                          Text(
                                                            destinoCiudad,
                                                            style: const TextStyle(
                                                                fontSize: 12,
                                                                color: Colors.grey),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const Divider(height: 24, thickness: 1),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                                                        const SizedBox(width: 6),
                                                        Text(
                                                          (v['fecha_salida'] ?? '').toString().split('T').first,
                                                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                                                        ),
                                                      ],
                                                    ),
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                      decoration: BoxDecoration(
                                                        color: AppColors.dark.withValues(alpha: 0.05),
                                                        borderRadius: BorderRadius.circular(6),
                                                      ),
                                                      child: const Text(
                                                        'CLASE ECONÓMICA',
                                                        style: TextStyle(
                                                            fontSize: 9,
                                                            fontWeight: FontWeight.bold,
                                                            color: AppColors.greyAccent),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                              childCount: _vuelos.length,
                            ),
                          ),
                        ),

                  // Footer contacto
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [_purple, _darkPurple],
                        ),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Avianco Airlines',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                          SizedBox(height: 12),
                          Row(children: [
                            Icon(Icons.email, size: 16, color: Colors.white70),
                            SizedBox(width: 8),
                            Text('contacto@avianco.me',
                                style: TextStyle(color: Colors.white70)),
                          ]),
                          SizedBox(height: 6),
                          Row(children: [
                            Icon(Icons.language,
                                size: 16, color: Colors.white70),
                            SizedBox(width: 8),
                            Text('jguerrer.me',
                                style: TextStyle(color: Colors.white70)),
                          ]),
                          SizedBox(height: 6),
                          Row(children: [
                            Icon(Icons.phone, size: 16, color: Colors.white70),
                            SizedBox(width: 8),
                            Text('+593 99 999 9999',
                                style: TextStyle(color: Colors.white70)),
                          ]),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.black,
        onPressed: () => Navigator.pushNamed(context, '/login'),
        icon: const Icon(Icons.login, color: Colors.white),
        label: const Text('Acceder', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}

/// Línea punteada con avión al centro, simulando la ruta del vuelo.
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
