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
                    expandedHeight: 200,
                    pinned: true,
                    backgroundColor: _purple,
                    actions: [
                      TextButton.icon(
                        onPressed: () => Navigator.pushNamed(context, '/login'),
                        icon: const Icon(Icons.person_outline,
                            color: Colors.white, size: 20),
                        label: const Text('Ingresar',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      title: const Text('avianco',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, letterSpacing: 2)),
                      background: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [_purple, _darkPurple],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.airplanemode_active,
                                  size: 48, color: Colors.white24),
                              SizedBox(height: 8),
                              Padding(
                                padding: EdgeInsets.only(bottom: 40),
                                child: Text('Conectando destinos',
                                    style: TextStyle(
                                        color: Colors.white70, fontSize: 13)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Buscador estilo Avianca
                  SliverToBoxAdapter(
                    child: Transform.translate(
                      offset: const Offset(0, -30),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.16),
                              blurRadius: 28,
                              spreadRadius: 0,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.flight_takeoff,
                                    color: _purple, size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text('Desde',
                                          style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey)),
                                      Text(
                                        _vuelos.isNotEmpty
                                            ? (_vuelos[0]['origen_detalle']
                                                    ?['ciudad'] ??
                                                'Quito')
                                            : 'Quito',
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 12),
                              height: 2,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primary.withValues(alpha: 0.5),
                                    AppColors.dark.withValues(alpha: 0.15),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(1),
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(Icons.flight_land,
                                    color: _purple, size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text('Explora destinos',
                                          style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey)),
                                      Text(
                                        '${_vuelos.length} vuelos disponibles',
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
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
                                onPressed: () =>
                                    Navigator.pushNamed(context, '/login'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30)),
                                ),
                                child: const Text('Reservar ahora',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
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
                              height: 120,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: _promociones.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(width: 12),
                                itemBuilder: (ctx, i) {
                                  final p = _promociones[i];
                                  return Container(
                                    width: 260,
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          AppColors.deepRed,
                                          AppColors.dark
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            '${double.tryParse(p['descuento']?.toString() ?? '0')?.toInt() ?? 0}% OFF',
                                            style: const TextStyle(
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13),
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(p['codigo'] ?? '',
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18)),
                                        Text(
                                          p['descripcion'] ?? '',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 12),
                                        ),
                                        const SizedBox(height: 4),
                                        Text('Válido hasta ${p['fecha_fin'] ?? ''}',
                                            style: const TextStyle(
                                                color: Colors.white60,
                                                fontSize: 11)),
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
                                        borderRadius: BorderRadius.circular(18),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black
                                                .withValues(alpha: 0.08),
                                            blurRadius: 12,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Imagen del destino
                                          ClipRRect(
                                            borderRadius:
                                                const BorderRadius.vertical(
                                                    top: Radius.circular(18)),
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
                                                Positioned(
                                                  top: 12,
                                                  right: 12,
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
                                                      v['estado'] ?? '',
                                                      style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 11),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          // Info
                                          Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        destinoCiudad,
                                                        style: const TextStyle(
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                    Container(
                                                      padding:
                                                          const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 8,
                                                          vertical: 3),
                                                      decoration:
                                                          BoxDecoration(
                                                        color: AppColors.dark
                                                            .withValues(
                                                                alpha: 0.06),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        border: Border.all(
                                                          color: AppColors
                                                              .dark
                                                              .withValues(
                                                                  alpha:
                                                                      0.15),
                                                        ),
                                                      ),
                                                      child: const Text(
                                                        'ECONOMY',
                                                        style: TextStyle(
                                                          fontSize: 9,
                                                          letterSpacing: 1,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: AppColors
                                                              .greyAccent,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 6),
                                                Row(
                                                  children: [
                                                    Text(
                                                      origenCiudad.toString(),
                                                      style: const TextStyle(
                                                          color: Colors.grey,
                                                          fontSize: 12),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    const Expanded(
                                                      child: _RutaPunteada(),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      destinoCiudad.toString(),
                                                      style: const TextStyle(
                                                          color: Colors.grey,
                                                          fontSize: 12),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 12),
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        const Text(
                                                            'Por trayecto desde',
                                                            style: TextStyle(
                                                                fontSize: 11,
                                                                color: Colors
                                                                    .grey)),
                                                        Text('\$${v['precio']}',
                                                            style: const TextStyle(
                                                                fontSize: 26,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: _purple)),
                                                      ],
                                                    ),
                                                    const Spacer(),
                                                    Text(
                                                      (v['fecha_salida'] ?? '')
                                                          .toString()
                                                          .split('T')
                                                          .first,
                                                      style: const TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.grey),
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
