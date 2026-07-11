import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../services/api_service.dart';
import 'checkout_screen.dart';

/// Mapa visual del avión para escoger asiento al reservar.
class SeatSelectorScreen extends StatefulWidget {
  final Map vuelo;

  const SeatSelectorScreen({super.key, required this.vuelo});

  @override
  State<SeatSelectorScreen> createState() => _SeatSelectorScreenState();
}

class _Seat {
  final int? id; // null si es un asiento generado (no existe en BD)
  final String codigo;
  final int fila;
  final String columna;
  final bool disponible;
  final bool business;

  _Seat({
    required this.id,
    required this.codigo,
    required this.fila,
    required this.columna,
    required this.disponible,
    required this.business,
  });
}

class _SeatSelectorScreenState extends State<SeatSelectorScreen> {
  static const _columnas = ['A', 'B', 'C', 'D', 'E', 'F'];
  static const _filasBusiness = 3;

  bool _loading = true;
  bool _saving = false;
  List<List<_Seat>> _mapa = [];
  _Seat? _seleccionado;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final vueloId = widget.vuelo['id'];
    final reales = vueloId is int
        ? await ApiService.getAsientosPorVuelo(vueloId)
        : <dynamic>[];

    int totalFilas;
    if (reales.isNotEmpty) {
      totalFilas = reales
          .map<int>((a) => (a['fila'] is num) ? (a['fila'] as num).toInt() : 0)
          .fold(0, (a, b) => a > b ? a : b);
      if (totalFilas == 0) totalFilas = 10;
    } else {
      // Sin asientos en BD: genera el mapa según la capacidad de la aeronave
      int capacidad = 0;
      final det = widget.vuelo['aeronave_detalle'];
      if (det is Map && det['capacidad'] is num) {
        capacidad = (det['capacidad'] as num).toInt();
      } else {
        final aeronaves = await ApiService.getAeronaves();
        final match = aeronaves.where(
          (a) => a['id'] == widget.vuelo['aeronave'],
        );
        if (match.isNotEmpty && match.first['capacidad'] is num) {
          capacidad = (match.first['capacidad'] as num).toInt();
        }
      }
      if (capacidad <= 0) capacidad = 60;
      totalFilas = (capacidad / _columnas.length).ceil().clamp(1, 40);
    }

    // Índice de asientos reales por "fila-columna" y por código
    final porPosicion = <String, dynamic>{};
    for (final a in reales) {
      porPosicion['${a['fila']}-${(a['columna'] ?? '').toString().toUpperCase()}'] =
          a;
    }

    final mapa = <List<_Seat>>[];
    for (var fila = 1; fila <= totalFilas; fila++) {
      final filaAsientos = <_Seat>[];
      for (final col in _columnas) {
        final real = porPosicion['$fila-$col'];
        if (real != null) {
          final clase = (real['clase'] ?? '').toString().toLowerCase();
          filaAsientos.add(
            _Seat(
              id: real['id'],
              codigo: (real['codigo'] ?? '$fila$col').toString(),
              fila: fila,
              columna: col,
              disponible: real['disponible'] == true,
              business:
                  clase.contains('business') ||
                  clase.contains('ejecutiva') ||
                  fila <= _filasBusiness,
            ),
          );
        } else {
          filaAsientos.add(
            _Seat(
              id: null,
              codigo: '$fila$col',
              fila: fila,
              columna: col,
              disponible: true,
              business: fila <= _filasBusiness,
            ),
          );
        }
      }
      mapa.add(filaAsientos);
    }

    if (!mounted) return;
    setState(() {
      _mapa = mapa;
      _loading = false;
    });
  }

  /// Continúa al checkout con el asiento elegido. Si el checkout termina
  /// en compra exitosa, cierra también esta pantalla.
  Future<void> _continuar() async {
    final seat = _seleccionado;
    if (seat == null || _saving) return;
    setState(() => _saving = true);
    final comprado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CheckoutScreen(
          vuelo: widget.vuelo,
          asientoCodigo: seat.codigo,
          asientoId: seat.id,
        ),
      ),
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (comprado == true) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final v = widget.vuelo;
    final origen = v['origen_detalle']?['codigo_iata'] ?? v['origen'];
    final destino = v['destino_detalle']?['codigo_iata'] ?? v['destino'];
    final fecha = (v['fecha_salida'] ?? '').toString().split('T').first;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Elige tu asiento',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.mainGradient),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : Column(
              children: [
                // ---- Header con info del vuelo + leyenda ----
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
                  decoration: const BoxDecoration(
                    gradient: AppColors.bannerGradient,
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$origen',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 14),
                            child: Icon(
                              Icons.flight_takeoff,
                              color: Colors.white70,
                              size: 20,
                            ),
                          ),
                          Text(
                            '$destino',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        fecha,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _LegendItem(
                              color: Colors.white,
                              border: Colors.grey,
                              label: 'Disponible',
                            ),
                            SizedBox(width: 14),
                            _LegendItem(
                              color: AppColors.greyDark,
                              label: 'Ocupado',
                            ),
                            SizedBox(width: 14),
                            _LegendItem(
                              color: AppColors.primary,
                              label: 'Tu asiento',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // ---- Fuselaje con el mapa de asientos ----
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(32, 20, 32, 20),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(14, 50, 14, 30),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(140),
                          bottom: Radius.circular(40),
                        ),
                        border: Border.all(
                          color: AppColors.dark.withValues(alpha: 0.15),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.airplanemode_active,
                            color: AppColors.primary,
                            size: 30,
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'BUSINESS',
                            style: TextStyle(
                              fontSize: 10,
                              letterSpacing: 3,
                              color: AppColors.darkRed,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Encabezado de columnas
                          _buildFila(
                            left: const SizedBox(width: 20),
                            cells: _columnas
                                .map<Widget>(
                                  (c) => SizedBox(
                                    width: 34,
                                    child: Center(
                                      child: Text(
                                        c,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                            right: const SizedBox(width: 20),
                          ),
                          const SizedBox(height: 6),
                          for (var i = 0; i < _mapa.length; i++) ...[
                            if (i == _filasBusiness)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Text(
                                  'ECONOMY',
                                  style: TextStyle(
                                    fontSize: 10,
                                    letterSpacing: 3,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: _buildFila(
                                left: const Icon(
                                  Icons.crop_square,
                                  size: 12,
                                  color: Colors.grey,
                                ),
                                cells: [
                                  for (var j = 0; j < _columnas.length; j++)
                                    _buildAsiento(_mapa[i][j]),
                                ],
                                right: const Icon(
                                  Icons.crop_square,
                                  size: 12,
                                  color: Colors.grey,
                                ),
                                rowNumber: i + 1,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
      // ---- Barra inferior fija ----
      bottomNavigationBar: _loading
          ? null
          : Container(
              padding: EdgeInsets.fromLTRB(
                20,
                14,
                20,
                14 + MediaQuery.of(context).padding.bottom,
              ),
              decoration: BoxDecoration(
                color: AppColors.dark,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _seleccionado == null
                              ? 'Toca un asiento'
                              : 'Asiento ${_seleccionado!.codigo}'
                                    '${_seleccionado!.business ? ' · Business' : ''}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '\$${v['precio']}',
                          style: const TextStyle(
                            color: AppColors.primaryLight,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _seleccionado == null || _saving
                          ? null
                          : _continuar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor: AppColors.greyDark,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 22),
                      ),
                      child: _saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'CONTINUAR',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  /// Fila del fuselaje: ventana | ABC | pasillo (número de fila) | DEF | ventana
  Widget _buildFila({
    required Widget left,
    required List<Widget> cells,
    required Widget right,
    int? rowNumber,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        left,
        const SizedBox(width: 4),
        ...cells.sublist(0, 3),
        SizedBox(
          width: 26,
          child: Center(
            child: rowNumber == null
                ? const SizedBox()
                : Text(
                    '$rowNumber',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        ...cells.sublist(3),
        const SizedBox(width: 4),
        right,
      ],
    );
  }

  Widget _buildAsiento(_Seat seat) {
    final selected = _seleccionado?.codigo == seat.codigo;
    final Color fondo;
    final Color borde;
    Widget? icono;

    if (!seat.disponible) {
      fondo = AppColors.greyDark;
      borde = AppColors.greyDark;
      icono = const Icon(Icons.person, size: 14, color: Colors.white38);
    } else if (selected) {
      fondo = AppColors.primary;
      borde = AppColors.primary;
      icono = const Icon(Icons.check, size: 14, color: Colors.white);
    } else {
      fondo = Colors.white;
      borde = seat.business ? AppColors.darkRed : Colors.grey.shade400;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.5),
      child: GestureDetector(
        onTap: seat.disponible
            ? () => setState(
                  () => _seleccionado = selected ? null : seat,
                )
            : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 32,
          height: 34,
          decoration: BoxDecoration(
            color: fondo,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
              bottomLeft: Radius.circular(5),
              bottomRight: Radius.circular(5),
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      blurRadius: 6,
                      spreadRadius: 1,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
            border: Border.all(
              color: borde,
              width: seat.business && seat.disponible && !selected ? 2.0 : 1.2,
            ),
          ),
          child: Center(
            child: icono ??
                Text(
                  seat.codigo,
                  style: TextStyle(
                    fontSize: 7.5,
                    fontWeight: FontWeight.bold,
                    color: seat.business
                        ? AppColors.darkRed
                        : Colors.grey.shade600,
                  ),
                ),
          ),
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final Color? border;
  final String label;

  const _LegendItem({required this.color, this.border, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: border != null ? Border.all(color: border!) : null,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
      ],
    );
  }
}
