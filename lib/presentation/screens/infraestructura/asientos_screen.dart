import 'package:flutter/material.dart';
import 'package:avianco/services/api_service.dart';
import 'package:avianco/services/auth_service.dart';
import 'package:avianco/core/app_colors.dart';

class SeatsScreen extends StatefulWidget {
  const SeatsScreen({super.key});

  @override
  State<SeatsScreen> createState() => _SeatsScreenState();
}

class _SeatsScreenState extends State<SeatsScreen> {
  List<dynamic> _items = [];
  bool _loading = true;
  bool _isStaff = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({String search = ''}) async {
    setState(() => _loading = true);
    _isStaff = await AuthService.isStaff();
    final data = await ApiService.getAsientos(search: search);
    if (!mounted) return;
    setState(() {
      _items = data;
      _loading = false;
    });
  }

  Future<void> _showForm() async {
    final codigoCtrl = TextEditingController();
    final filaCtrl = TextEditingController();
    final columnaCtrl = TextEditingController();
    final vueloCtrl = TextEditingController();
    final disponibleCtrl = TextEditingController(text: 'true');
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Nuevo Asiento', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildFormField(codigoCtrl, 'Código (ej: 12A)', Icons.qr_code),
                _buildFormField(filaCtrl, 'Fila', Icons.format_list_numbered, type: TextInputType.number),
                _buildFormField(columnaCtrl, 'Columna (ej: A)', Icons.view_column),
                _buildFormField(vueloCtrl, 'ID Vuelo', Icons.flight, type: TextInputType.number),
                _buildFormField(disponibleCtrl, 'Disponible (true/false)', Icons.event_seat),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final data = {
                'codigo': codigoCtrl.text,
                'fila': int.tryParse(filaCtrl.text) ?? 0,
                'columna': columnaCtrl.text,
                'vuelo': int.tryParse(vueloCtrl.text) ?? 0,
                'disponible': disponibleCtrl.text.toLowerCase() == 'true',
              };
              final ok = await ApiService.createAsiento(data);
              if (!ctx.mounted) return;
              Navigator.pop(ctx);
              if (ok) {
                await _load();
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Asiento creado exitosamente')));
              }
            },
            child: const Text('Crear', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildFormField(TextEditingController ctrl, String label, IconData icon, {TextInputType type = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: ctrl,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          _loading
              ? const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: AppColors.primary)))
              : _items.isEmpty
                  ? const SliverFillRemaining(child: Center(child: Text('No hay asientos registrados')))
                  : SliverPadding(
                      padding: const EdgeInsets.all(20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (ctx, i) => _buildSeatCard(_items[i]),
                          childCount: _items.length,
                        ),
                      ),
                    ),
        ],
      ),
      floatingActionButton: _isStaff
          ? FloatingActionButton(
              backgroundColor: AppColors.primary,
              onPressed: _showForm,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: const Text('Gestión de Asientos', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        background: Container(
          decoration: const BoxDecoration(gradient: AppColors.bannerGradient),
          child: Opacity(
            opacity: 0.1,
            child: Icon(Icons.event_seat, size: 150, color: Colors.white.withValues(alpha: 0.5)),
          ),
        ),
      ),
    );
  }

  Widget _buildSeatCard(item) {
    final bool disponible = item['disponible'] == true;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: (disponible ? AppColors.success : AppColors.primary).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            Icons.event_seat,
            color: disponible ? AppColors.success : AppColors.primary,
            size: 24,
          ),
        ),
        title: Text('Asiento ${item['codigo']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.dark)),
        subtitle: Text('Fila ${item['fila']} · Columna ${item['columna']}', style: const TextStyle(color: AppColors.greyAccent, fontSize: 13)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: (disponible ? AppColors.success : AppColors.primary).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            disponible ? 'Disponible' : 'Ocupado',
            style: TextStyle(
              color: disponible ? AppColors.success : AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ),
      ),
    );
  }
}
