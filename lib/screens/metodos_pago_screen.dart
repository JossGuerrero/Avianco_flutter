import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../services/api_service.dart';

/// Gestión de métodos de pago (solo staff).
/// El checkout necesita al menos un método activo para poder cobrar.
class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  List<dynamic> _metodos = [];
  bool _loading = true;

  static const _sugeridos = ['Visa', 'Mastercard', 'Efectivo', 'PayPal'];

  IconData _iconoDe(String nombre) {
    final n = nombre.toLowerCase();
    if (n.contains('visa') || n.contains('master') || n.contains('tarjeta')) {
      return Icons.credit_card;
    }
    if (n.contains('efectivo') || n.contains('cash')) return Icons.payments;
    if (n.contains('paypal')) return Icons.account_balance_wallet;
    if (n.contains('transfer')) return Icons.account_balance;
    return Icons.attach_money;
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final data = await ApiService.getMetodosPago();
    if (!mounted) return;
    setState(() {
      _metodos = data;
      _loading = false;
    });
  }

  void _snackError() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ApiService.lastError.isNotEmpty
              ? 'Error: ${ApiService.lastError}'
              : 'Error al guardar',
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  Future<void> _crear([String? nombreInicial]) async {
    final nombreCtrl = TextEditingController(text: nombreInicial ?? '');
    final descripcionCtrl = TextEditingController();
    bool activo = true;
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.credit_card,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Text('Nuevo método', style: TextStyle(fontSize: 17)),
            ],
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nombreCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nombre (ej: Visa)',
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: descripcionCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Descripción (opcional)',
                  ),
                ),
                SwitchListTile(
                  title: const Text('Activo'),
                  value: activo,
                  activeThumbColor: AppColors.primary,
                  onChanged: (v) => setDialogState(() => activo = v),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
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
                // Se envían variantes comunes de nombres de campo;
                // DRF ignora los que no existen en el serializer.
                final ok = await ApiService.createMetodoPago({
                  'nombre': nombreCtrl.text,
                  'descripcion': descripcionCtrl.text,
                  'tipo': nombreCtrl.text.toLowerCase(),
                  'activo': activo,
                  'activa': activo,
                });
                if (!ctx.mounted) return;
                Navigator.pop(ctx);
                if (!mounted) return;
                if (ok) {
                  _load();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Método de pago creado')),
                  );
                } else {
                  _snackError();
                }
              },
              child: const Text(
                'Crear',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleActivo(Map m, bool value) async {
    final ok = await ApiService.updateMetodoPago(m['id'], {
      'activo': value,
      'activa': value,
    });
    if (!mounted) return;
    if (ok) {
      _load();
    } else {
      _snackError();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Métodos de pago',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.mainGradient),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.dark,
        onPressed: () => _crear(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _metodos.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.credit_card_off,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'No hay métodos de pago.\nSin al menos uno activo, el '
                      'checkout no puede cobrar.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Crear rápido:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.dark,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: _sugeridos
                          .map(
                            (n) => ActionChip(
                              avatar: Icon(
                                _iconoDe(n),
                                size: 16,
                                color: AppColors.primary,
                              ),
                              label: Text(n),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                                side: BorderSide(color: Colors.grey.shade300),
                              ),
                              backgroundColor: Colors.white,
                              onPressed: () => _crear(n),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _metodos.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final m = _metodos[index];
                  final nombre =
                      (m['nombre'] ?? m['tipo'] ?? 'Método #${m['id']}')
                          .toString();
                  final activo = m['activo'] == true || m['activa'] == true;
                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            activo ? AppColors.primary : Colors.grey,
                        child: Icon(
                          _iconoDe(nombre),
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        nombre,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(activo ? 'Activo' : 'Inactivo'),
                      trailing: Switch(
                        value: activo,
                        activeThumbColor: AppColors.primary,
                        onChanged: (v) => _toggleActivo(m, v),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
