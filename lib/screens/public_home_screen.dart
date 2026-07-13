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
  bool _soloIda = false;

  static const _purple = AppColors.primary;
  static const _darkPurple = AppColors.dark;

  static const Map<String, String> _cityImages = {
    'UIO': 'https://images.unsplash.com/photo-1531968455001-5c5272a41129?w=800',
    'GYE': 'https://images.unsplash.com/photo-1444723121867-7a241cacace9?w=800',
    'CUE': 'https://images.unsplash.com/photo-1501785888041-af3ef285b470?w=800',
    'OSO': 'https://images.unsplash.com/photo-1501785888041-af3ef285b470?w=800',
    'MEC': 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800',
    'BOG': 'https://images.unsplash.com/photo-1539037116277-4db20889f2d4?w=800',
    'LIM': 'https://images.unsplash.com/photo-1526392060635-9d6019884377?w=800',
  };

  static const Map<String, String> _cityByName = {
    'quito':
        'https://images.unsplash.com/photo-1531968455001-5c5272a41129?w=800',
    'guayaquil':
        'https://images.unsplash.com/photo-1444723121867-7a241cacace9?w=800',
    'cuenca':
        'https://images.unsplash.com/photo-1501785888041-af3ef285b470?w=800',
    'manta':
        'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800',
    'bogotá':
        'https://images.unsplash.com/photo-1539037116277-4db20889f2d4?w=800',
    'bogota':
        'https://images.unsplash.com/photo-1539037116277-4db20889f2d4?w=800',
    'lima':
        'https://images.unsplash.com/photo-1526392060635-9d6019884377?w=800',
  };

  static const _defaultImage =
      'https://images.unsplash.com/photo-1436491865332-7a61a109cc05?w=800';

  String _fechaCorta(dynamic iso) {
    final t = (iso ?? '').toString().split('T').first.split('-');
    if (t.length != 3) return '—';
    return '${t[2]}/${t[1]}/${t[0].substring(2)}';
  }

  String _imageFor(String? iata, [String? ciudad]) {
    final key = (ciudad ?? '').toLowerCase().trim();
    return _cityImages[iata] ?? _cityByName[key] ?? _defaultImage;
  }

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
      backgroundColor: AppColors.background,
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 240,
                    pinned: true,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    stretch: true,
                    automaticallyImplyLeading: false,
                    flexibleSpace: FlexibleSpaceBar(
                      stretchModes: const [StretchMode.zoomBackground],
                      titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                      title: const Text(
                        'avianco',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 3,
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          Container(
                            decoration: const BoxDecoration(
                              gradient: AppColors.mainGradient,
                            ),
                          ),
                          Positioned(
                            right: -30,
                            top: -30,
                            child: Icon(
                              Icons.airplanemode_active,
                              size: 180,
                              color: Colors.white24,
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.black.withValues(alpha: 0.2),
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.6),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                          const Positioned(
                            left: 20,
                            bottom: 28,
                            right: 20,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Viaja con estilo',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Explora ofertas y administra tus vuelos desde una sola app.',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      Padding(
                        padding: const EdgeInsets.only(right: 16, top: 4),
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/login'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.15,
                            ),
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
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: Column(
                        children: [
                          _buildSummaryCard(context),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                  _buildPrepareSection(),
                  if (_promociones.isNotEmpty) _buildPromoSection(),
                  _buildPopularSection(context),
                  _buildFlightSection(context),
                  _buildFooter(),
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

  Widget _buildSummaryCard(BuildContext context) {
    final origen = _vuelos.isNotEmpty
        ? "${_vuelos[0]['origen_detalle']?['ciudad'] ?? 'Quito'} "
              "(${_vuelos[0]['origen_detalle']?['codigo_iata'] ?? 'UIO'})"
        : 'Quito (UIO)';

    Widget tab(String label, bool selected, VoidCallback onTap) => Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: selected ? FontWeight.bold : FontWeight.w500,
              fontSize: 13,
              color: AppColors.dark,
            ),
          ),
        ),
      ),
    );

    Widget campo(IconData icon, String label, String value, bool activo) =>
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: activo ? AppColors.dark : Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tabs Ida y vuelta / Solo ida (estilo Avianca)
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Row(
              children: [
                tab(
                  'Ida y vuelta',
                  !_soloIda,
                  () => setState(() => _soloIda = false),
                ),
                tab(
                  'Solo ida',
                  _soloIda,
                  () => setState(() => _soloIda = true),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // Origen / Destino con boton de intercambio
          Stack(
            alignment: Alignment.centerRight,
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    campo(Icons.flight_takeoff, 'Origen', origen, true),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      height: 2,
                      color: AppColors.primary.withValues(alpha: 0.5),
                    ),
                    campo(
                      Icons.flight_land,
                      'Destino',
                      '${_vuelos.length} destinos disponibles',
                      false,
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 14,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade300),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(
                      Icons.swap_vert,
                      size: 20,
                      color: AppColors.dark,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Boton negro grande estilo Avianca
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: const Text(
                'Buscar',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/register'),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              icon: const Icon(
                Icons.card_membership,
                size: 18,
                color: AppColors.dark,
              ),
              label: const Text(
                'Crear cuenta Avianco',
                style: TextStyle(color: AppColors.dark),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Seccion "Preparate para viajar" (estilo Avianca)
  Widget _buildPrepareSection() {
    const items = [
      (
        Icons.how_to_reg,
        'Check-in online',
        'Obt\u00e9n tu pase de abordar y ahorra tiempo en el aeropuerto.',
      ),
      (
        Icons.event_seat,
        'Elige tu asiento',
        'Escoge tu lugar favorito en el mapa del avi\u00f3n al reservar.',
      ),
      (
        Icons.luggage,
        'Equipaje adicional',
        'Agrega maletas a tu reserva y viaja sin preocupaciones.',
      ),
    ];
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 8, 20, 14),
            child: Text(
              'Prep\u00e1rate para viajar',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.dark,
              ),
            ),
          ),
          SizedBox(
            height: 150,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, i) {
                final (icon, titulo, texto) = items[i];
                return Container(
                  width: 220,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(icon, color: AppColors.primary, size: 22),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        titulo,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppColors.dark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Expanded(
                        child: Text(
                          texto,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildPromoSection() {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 220,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          scrollDirection: Axis.horizontal,
          itemCount: _promociones.length,
          separatorBuilder: (_, _) => const SizedBox(width: 16),
          itemBuilder: (context, index) {
            final promo = _promociones[index];
            final title = promo['titulo']?.toString() ?? 'Oferta';
            final subtitle =
                promo['descripcion']?.toString() ?? 'Descuento especial';
            final image = _imageFor(
              promo['iata']?.toString().toUpperCase(),
              promo['ciudad']?.toString(),
            );
            return Container(
              width: 280,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                image: DecorationImage(
                  image: NetworkImage(image),
                  fit: BoxFit.cover,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.14),
                    blurRadius: 22,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.58),
                      Colors.black.withValues(alpha: 0.15),
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPopularSection(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Destinos populares',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.dark,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 14,
              runSpacing: 14,
              children: _vuelos.take(4).map((vuelo) {
                final ciudad =
                    vuelo['destino_detalle']?['ciudad']?.toString() ??
                    'Destino';
                final codigo = vuelo['destino_detalle']?['iata']
                    ?.toString()
                    .toUpperCase();
                final image = _imageFor(codigo, ciudad);
                return SizedBox(
                  width: (MediaQuery.of(context).size.width - 64) / 2,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Stack(
                      children: [
                        AspectRatio(
                          aspectRatio: 1.1,
                          child: Image.network(image, fit: BoxFit.cover),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.black.withValues(alpha: 0.58),
                                Colors.transparent,
                              ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                          ),
                        ),
                        Positioned(
                          left: 14,
                          bottom: 14,
                          right: 14,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ciudad,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                codigo ?? '',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 28),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Empieza tu viaje',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Crea tu cuenta para ver promociones exclusivas y manejar tus viajes desde el celular.',
                    style: TextStyle(color: Colors.black54, height: 1.5),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/register'),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: const Text('Crear cuenta ahora'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlightSection(BuildContext context) {
    return SliverList(
      delegate: SliverChildListDelegate([
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
          child: Row(
            children: [
              const Text(
                'Ofertas de vuelos',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Text(
                '${_vuelos.length} disponibles',
                style: const TextStyle(color: _purple, fontSize: 13),
              ),
            ],
          ),
        ),
        if (_vuelos.isEmpty)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Center(
              child: Text(
                'No hay vuelos disponibles',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          ..._vuelos.map((v) {
            final origenIata = v['origen_detalle']?['codigo_iata'];
            final destinoIata = v['destino_detalle']?['codigo_iata'];
            final destinoCiudad =
                v['destino_detalle']?['ciudad']?.toString() ??
                destinoIata ??
                'Destino';
            final origenCiudad =
                v['origen_detalle']?['ciudad']?.toString() ??
                origenIata ??
                'Origen';
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: GestureDetector(
                onTap: () async {
                  final logged = await AuthService.isLoggedIn();
                  if (!context.mounted) return;
                  if (logged) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SeatSelectorScreen(vuelo: v),
                      ),
                    );
                  } else {
                    Navigator.pushNamed(context, '/login');
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                            child: Image.network(
                              _imageFor(destinoIata, destinoCiudad),
                              height: 170,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return Container(
                                  height: 170,
                                  color: Colors.grey[200],
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      color: AppColors.primary,
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    height: 170,
                                    color: AppColors.primary,
                                    child: const Icon(
                                      Icons.flight,
                                      color: Colors.white,
                                      size: 48,
                                    ),
                                  ),
                            ),
                          ),
                          // Badge de fecha (estilo LATAM)
                          Positioned(
                            bottom: 12,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.92),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Viaja el ${_fechaCorta(v['fecha_salida'])}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.dark,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              destinoCiudad,
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                color: AppColors.dark,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Desde $origenCiudad (${origenIata ?? '—'}) · Vuelo directo',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.background,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  child: const Text(
                                    'Solo ida',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.dark,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.darkRed,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Text(
                                    'Economy',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 24, thickness: 1),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Precio final desde',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'USD ${(v['precio'] ?? '0').toString().replaceAll('.', ',')}',
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w900,
                                          color: AppColors.dark,
                                        ),
                                      ),
                                      const Text(
                                        'Tasas incluidas',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.primary,
                                      width: 1.6,
                                    ),
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.all(10),
                                    child: Icon(
                                      Icons.arrow_forward,
                                      color: AppColors.primary,
                                      size: 20,
                                    ),
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
          }),
      ]),
    );
  }

  Widget _buildFooter() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [_purple, _darkPurple]),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Avianco Airlines',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.email, size: 16, color: Colors.white70),
                SizedBox(width: 8),
                Text(
                  'contacto@avianco.me',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
            SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.language, size: 16, color: Colors.white70),
                SizedBox(width: 8),
                Text('jguerrer.me', style: TextStyle(color: Colors.white70)),
              ],
            ),
            SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.phone, size: 16, color: Colors.white70),
                SizedBox(width: 8),
                Text(
                  '+593 99 999 9999',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

