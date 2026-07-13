import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../widgets/country_picker.dart';
import '../widgets/fecha_field.dart';

/// Checkout: resumen del vuelo + pasajero + método de pago + pago encadenado
/// (reserva → pago → factura → asiento ocupado → pantalla de éxito).
class CheckoutScreen extends StatefulWidget {
  final Map vuelo;
  final String asientoCodigo;
  final int? asientoId;

  const CheckoutScreen({
    super.key,
    required this.vuelo,
    required this.asientoCodigo,
    this.asientoId,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  static const double _tasaImpuesto = 0.12;

  bool _loading = true;
  bool _processing = false;
  bool _isStaff = false;
  int? _userId;
  List<dynamic> _pasajeros = [];
  List<dynamic> _metodos = [];
  List<dynamic> _servicios = [];
  final Set<int> _serviciosSel = {};
  String? _tipoEquipaje;
  final _pesoCtrl = TextEditingController();
  int? _pasajeroId;
  int? _metodoPagoId;

  double get _precioVuelo =>
      double.tryParse(widget.vuelo['precio']?.toString() ?? '0') ?? 0;
  double get _serviciosTotal => _servicios
      .where((s) => _serviciosSel.contains(s['id']))
      .fold<double>(
        0,
        (a, s) => a + (double.tryParse(s['precio']?.toString() ?? '0') ?? 0),
      );
  double get _subtotal => _precioVuelo + _serviciosTotal;
  double get _impuestos => _subtotal * _tasaImpuesto;
  double get _total => _subtotal + _impuestos;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final results = await Future.wait([
      AuthService.isStaff(),
      AuthService.getUserId(),
      ApiService.getPasajeros(),
      ApiService.getMetodosPagoActivos(),
      ApiService.getServicios(),
    ]);
    if (!mounted) return;

    final isStaff = results[0] as bool;
    final userId = results[1] as int?;
    final todos = results[2] as List<dynamic>;

    // Usuario normal: solo sus propios pasajeros (usuario == miUserId).
    // Staff: todos.
    final visibles = isStaff || userId == null
        ? todos
        : todos.where((p) => p['usuario'] == userId).toList();

    setState(() {
      _isStaff = isStaff;
      _userId = userId;
      _pasajeros = visibles;
      _metodos = results[3] as List<dynamic>;
      _servicios = results[4] as List<dynamic>;
      _pasajeroId = visibles.isNotEmpty ? visibles.first['id'] : null;
      _metodoPagoId = _metodos.isNotEmpty ? _metodos.first['id'] : null;
      _loading = false;
    });
  }

  String _pasajeroLabel(dynamic p) {
    final nombre = (p['nombre_completo'] ?? '').toString().trim();
    return nombre.isNotEmpty ? nombre : 'Pasajero #${p['id']}';
  }

  String _metodoLabel(dynamic m) =>
      (m['nombre'] ?? m['tipo'] ?? m['descripcion'] ?? 'Método #${m['id']}')
          .toString();

  /// Form rápido de pasajero (propio o acompañante) vinculado a mi usuario.
  Future<void> _crearPasajero({required bool esPropio}) async {
    if (_userId == null) {
      _snackError('No se encontró tu usuario. Vuelve a iniciar sesión.');
      return;
    }
    final pasaporteCtrl = TextEditingController();
    final nacionalidadCtrl = TextEditingController();
    final nacimientoCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final creado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_add,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                esPropio ? 'Mis datos de pasajero' : 'Nuevo acompañante',
                style: const TextStyle(fontSize: 17),
              ),
            ),
          ],
        ),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: pasaporteCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Número de pasaporte',
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 10),
                CountryFormField(
                  controller: nacionalidadCtrl,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: nacimientoCtrl,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Fecha de nacimiento',
                    suffixIcon: Icon(
                      Icons.calendar_today,
                      size: 18,
                      color: AppColors.primary,
                    ),
                  ),
                  onTap: () => seleccionarFecha(
                    ctx,
                    nacimientoCtrl,
                    inicial: DateTime(1995),
                    ultimo: DateTime.now(),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Requerido' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.dark,
              minimumSize: const Size(120, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final ok = await ApiService.createPasajero({
                'usuario': _userId,
                'numero_pasaporte': pasaporteCtrl.text,
                'nacionalidad': nacionalidadCtrl.text,
                'fecha_nacimiento': nacimientoCtrl.text,
              });
              if (!ctx.mounted) return;
              Navigator.pop(ctx, ok);
            },
            child: const Text(
              'Guardar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (creado == true) {
      await _load();
    } else if (creado == false && mounted) {
      // false explícito = intento fallido (cancelar devuelve false también,
      // así que solo recargamos silenciosamente)
      await _load();
    }
  }

  Future<void> _confirmarYPagar() async {
    if (_pasajeroId == null) {
      _snackError('Selecciona o crea un pasajero');
      return;
    }
    if (_metodoPagoId == null) {
      _snackError('Selecciona un método de pago');
      return;
    }
    setState(() => _processing = true);

    // 1) Reserva (paso obligatorio: si falla se aborta)
    final reserva = await ApiService.createReservaDetalle({
      'vuelo': widget.vuelo['id'],
      'pasajero': _pasajeroId,
      'asiento': widget.asientoCodigo,
      'estado': 'confirmada',
    });
    if (reserva == null) {
      _failStep('No se pudo crear la reserva');
      return;
    }
    final reservaId = reserva['id'];
    // Los pasos siguientes son tolerantes: si el backend niega el permiso
    // (403 para usuario normal), se registra la advertencia y se continúa.
    final advertencias = <String>[];

    // 2) Servicios adicionales elegidos
    for (final sid in _serviciosSel) {
      final ok = await ApiService.createReservaServicio({
        'reserva': reservaId,
        'servicio': sid,
        'cantidad': 1,
      });
      if (!ok) advertencias.add('Servicio #$sid no registrado');
    }

    // 3) Equipaje (si se llenó)
    if (_tipoEquipaje != null && _pesoCtrl.text.isNotEmpty) {
      final ok = await ApiService.createEquipaje({
        'reserva': reservaId,
        'tipo': _tipoEquipaje,
        'peso_kg': _pesoCtrl.text,
      });
      if (!ok) advertencias.add('Equipaje no registrado');
    }

    // 4) Pago (monto ya incluye servicios e impuestos)
    final pago = await ApiService.createPago({
      'reserva': reservaId,
      'metodo_pago': _metodoPagoId,
      'monto': _total.toStringAsFixed(2),
      'estado': 'completado',
      'referencia': 'PAY-${DateTime.now().millisecondsSinceEpoch}',
    });
    if (pago == null) {
      advertencias.add('Pago no registrado — quedó pendiente de procesar');
    }

    // 5) Factura
    Map<String, dynamic>? factura;
    if (pago != null) {
      factura = await ApiService.createFacturaDetalle({
        'reserva': reservaId,
        'total': _total.toStringAsFixed(2),
        'impuestos': _impuestos.toStringAsFixed(2),
        'estado': 'pagada',
      });
      if (factura == null) advertencias.add('Factura no generada');
    } else {
      advertencias.add('Factura pendiente (sin pago registrado)');
    }

    // 6) Marca el asiento como ocupado si existe en BD
    if (widget.asientoId != null) {
      final ok = await ApiService.updateAsiento(widget.asientoId!, {
        'disponible': false,
      });
      if (!ok) advertencias.add('El asiento no se marcó como ocupado');
    }

    // 7) Notificación de confirmación
    await ApiService.createNotificacion({
      'usuario': _userId,
      'titulo': 'Reserva confirmada',
      'mensaje':
          'Tu reserva #$reservaId (asiento ${widget.asientoCodigo}) fue '
          'confirmada por \$${_total.toStringAsFixed(2)}.',
      'leida': false,
    });

    if (!mounted) return;
    setState(() => _processing = false);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => _SuccessScreen(
          reservaId: reservaId?.toString() ?? '—',
          facturaId: factura?['id']?.toString() ?? 'Pendiente',
          total: _total,
          asiento: widget.asientoCodigo,
          advertencias: advertencias,
        ),
      ),
    );
  }

  void _failStep(String msg) {
    if (!mounted) return;
    setState(() => _processing = false);
    _snackError(msg);
  }

  void _snackError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.primary),
    );
  }

  @override
  Widget build(BuildContext context) {
    final v = widget.vuelo;
    final origen = v['origen_detalle']?['codigo_iata'] ?? v['origen'];
    final destino = v['destino_detalle']?['codigo_iata'] ?? v['destino'];
    final fecha = (v['fecha_salida'] ?? '').toString().split('T').first;
    final sinPasajeroPropio = !_isStaff && _pasajeros.isEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Confirmar compra',
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
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ---- Resumen del vuelo ----
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: AppColors.bannerGradient,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.dark.withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
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
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 14),
                              child: Icon(
                                Icons.flight_takeoff,
                                color: Colors.white70,
                              ),
                            ),
                            Text(
                              '$destino',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Vuelo #${v['id']}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$fecha · Asiento ${widget.asientoCodigo}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ---- Pasajero ----
                  const Text(
                    'Pasajero',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.dark,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (sinPasajeroPropio)
                    _CardBox(
                      child: Column(
                        children: [
                          const Text(
                            'Aún no tienes tus datos de pasajero completos.',
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton.icon(
                              onPressed: () => _crearPasajero(esPropio: true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.dark,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              icon: const Icon(
                                Icons.badge,
                                color: Colors.white,
                                size: 18,
                              ),
                              label: const Text(
                                'Completar mis datos de pasajero',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    _CardBox(
                      child: Column(
                        children: [
                          DropdownButtonFormField<int>(
                            initialValue: _pasajeroId,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Quién viaja',
                            ),
                            items: _pasajeros
                                .map<DropdownMenuItem<int>>(
                                  (p) => DropdownMenuItem(
                                    value: p['id'],
                                    child: Text(
                                      _pasajeroLabel(p),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _pasajeroId = v),
                          ),
                          if (!_isStaff) ...[
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                onPressed: () =>
                                    _crearPasajero(esPropio: false),
                                icon: const Icon(
                                  Icons.person_add,
                                  size: 18,
                                  color: AppColors.primary,
                                ),
                                label: const Text(
                                  'Agregar acompañante',
                                  style: TextStyle(color: AppColors.primary),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  const SizedBox(height: 20),

                  // ---- Servicios adicionales ----
                  if (_servicios.isNotEmpty) ...[
                    const Text(
                      'Servicios adicionales',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.dark,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _CardBox(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _servicios.map<Widget>((s) {
                          final sel = _serviciosSel.contains(s['id']);
                          return FilterChip(
                            selected: sel,
                            label: Text(
                              '${s['nombre'] ?? 'Servicio'} · \$${s['precio'] ?? 0}',
                              style: TextStyle(
                                fontSize: 12,
                                color: sel ? AppColors.primary : AppColors.dark,
                                fontWeight:
                                    sel ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            selectedColor:
                                AppColors.primary.withValues(alpha: 0.12),
                            checkmarkColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: sel
                                    ? AppColors.primary
                                    : Colors.grey.shade300,
                              ),
                            ),
                            onSelected: (v) => setState(() {
                              if (v) {
                                _serviciosSel.add(s['id']);
                              } else {
                                _serviciosSel.remove(s['id']);
                              }
                            }),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // ---- Equipaje adicional ----
                  const Text(
                    'Equipaje adicional (opcional)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.dark,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _CardBox(
                    child: Column(
                      children: [
                        DropdownButtonFormField<String>(
                          initialValue: _tipoEquipaje,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Tipo de equipaje',
                            prefixIcon: Icon(
                              Icons.luggage,
                              color: AppColors.primary,
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'documentado',
                              child: Text('Documentado (bodega)'),
                            ),
                            DropdownMenuItem(
                              value: 'mano',
                              child: Text('De mano'),
                            ),
                            DropdownMenuItem(
                              value: 'especial',
                              child: Text('Especial'),
                            ),
                          ],
                          onChanged: (v) =>
                              setState(() => _tipoEquipaje = v),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _pesoCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Peso (kg)',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ---- Método de pago ----
                  const Text(
                    'Método de pago',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.dark,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _CardBox(
                    child: _metodos.isEmpty
                        ? const Text(
                            'No hay métodos de pago disponibles',
                            style: TextStyle(color: Colors.grey),
                          )
                        : DropdownButtonFormField<int>(
                            initialValue: _metodoPagoId,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Pagar con',
                              prefixIcon: Icon(
                                Icons.credit_card,
                                color: AppColors.primary,
                              ),
                            ),
                            items: _metodos
                                .map<DropdownMenuItem<int>>(
                                  (m) => DropdownMenuItem(
                                    value: m['id'],
                                    child: Text(
                                      _metodoLabel(m),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _metodoPagoId = v),
                          ),
                  ),
                  const SizedBox(height: 20),

                  // ---- Desglose de precio ----
                  const Text(
                    'Resumen de pago',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.dark,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _CardBox(
                    child: Column(
                      children: [
                        _priceRow(
                          'Tarifa del vuelo',
                          _precioVuelo,
                          bold: false,
                        ),
                        if (_serviciosTotal > 0) ...[
                          const SizedBox(height: 8),
                          _priceRow(
                            'Servicios adicionales',
                            _serviciosTotal,
                            bold: false,
                          ),
                        ],
                        const SizedBox(height: 8),
                        _priceRow(
                          'Impuestos (12%)',
                          _impuestos,
                          bold: false,
                        ),
                        const Divider(height: 24),
                        _priceRow('Total a pagar', _total, bold: true),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ---- Botón confirmar ----
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: AppColors.mainGradient,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed:
                            _processing || sinPasajeroPropio || _metodos.isEmpty
                            ? null
                            : _confirmarYPagar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          disabledBackgroundColor: Colors.black26,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _processing
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'CONFIRMAR Y PAGAR',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                  fontSize: 14,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _priceRow(String label, double value, {required bool bold}) {
    final style = TextStyle(
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      fontSize: bold ? 17 : 14,
      color: bold ? AppColors.primary : AppColors.dark,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text('\$${value.toStringAsFixed(2)}', style: style),
      ],
    );
  }
}

class _CardBox extends StatelessWidget {
  final Widget child;
  const _CardBox({required this.child});

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
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SuccessScreen extends StatelessWidget {
  final String reservaId;
  final String facturaId;
  final double total;
  final String asiento;
  final List<String> advertencias;

  const _SuccessScreen({
    required this.reservaId,
    required this.facturaId,
    required this.total,
    required this.asiento,
    this.advertencias = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bannerGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 72,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  '¡Compra exitosa!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tu boleto está confirmado',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 32),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      _row('Reserva', '#$reservaId'),
                      const Divider(height: 20),
                      _row('Factura', '#$facturaId'),
                      const Divider(height: 20),
                      _row('Asiento', asiento),
                      const Divider(height: 20),
                      _row(
                        'Total pagado',
                        '\$${total.toStringAsFixed(2)}',
                        highlight: true,
                      ),
                    ],
                  ),
                ),
                if (advertencias.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.warning_amber,
                              color: Colors.amber,
                              size: 18,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Pendientes',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ...advertencias.map(
                          (a) => Text(
                            '· $a',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(
                      context,
                    ).popUntil((route) => route.isFirst),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'VER MIS RESERVAS',
                      style: TextStyle(
                        color: AppColors.dark,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.of(
                    context,
                  ).popUntil((route) => route.isFirst),
                  child: const Text(
                    'Volver al inicio',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool highlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: highlight ? 18 : 14,
            color: highlight ? AppColors.primary : AppColors.dark,
          ),
        ),
      ],
    );
  }
}
