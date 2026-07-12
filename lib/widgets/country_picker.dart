import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/app_colors.dart';

/// Selector de país reutilizable.
/// Usa flagcdn.com (restcountries v3.1 fue deprecada y la v5 exige API key):
/// nombres en español desde /es/codes.json y banderas PNG por código ISO.
class CountryPicker {
  static List<Map<String, String>>? _cache;

  static Future<List<Map<String, String>>> _fetchCountries() async {
    if (_cache != null) return _cache!;
    final response = await http
        .get(Uri.parse('https://flagcdn.com/es/codes.json'))
        .timeout(const Duration(seconds: 10));
    debugPrint('CountryPicker flagcdn [${response.statusCode}]');
    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}');
    }
    final Map<String, dynamic> data = jsonDecode(response.body);
    final countries = data.entries
        // Excluye subdivisiones tipo 'us-ak' (estados de EE.UU.)
        .where((e) => !e.key.contains('-') && e.value.toString().isNotEmpty)
        .map<Map<String, String>>(
          (e) => {
            'name': e.value.toString(),
            'flag': 'https://flagcdn.com/w80/${e.key}.png',
            'code': e.key.toUpperCase(),
          },
        )
        .toList();
    countries.sort((a, b) => a['name']!.compareTo(b['name']!));
    _cache = countries;
    return countries;
  }

  /// Abre el modal y devuelve el nombre del país elegido (o null).
  static Future<String?> show(BuildContext context) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _CountryPickerSheet(),
    );
  }
}

class _CountryPickerSheet extends StatefulWidget {
  const _CountryPickerSheet();

  @override
  State<_CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<_CountryPickerSheet> {
  List<Map<String, String>> _all = [];
  List<Map<String, String>> _filtered = [];
  bool _loading = true;
  String? _error;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final countries = await CountryPicker._fetchCountries();
      if (!mounted) return;
      setState(() {
        _all = countries;
        _filtered = countries;
        _loading = false;
      });
    } catch (e) {
      debugPrint('CountryPicker error: $e');
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'No se pudo cargar la lista de países.\nRevisa tu conexión.';
      });
    }
  }

  void _filter(String query) {
    final q = query.toLowerCase();
    setState(() {
      _filtered = _all
          .where((c) => c['name']!.toLowerCase().contains(q))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (ctx, scrollCtrl) => Material(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchCtrl,
                onChanged: _filter,
                decoration: InputDecoration(
                  hintText: 'Buscar país...',
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.primary,
                  ),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                  : _error != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.wifi_off,
                            size: 56,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _error!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _load,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.dark,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              minimumSize: const Size(140, 48),
                            ),
                            icon: const Icon(
                              Icons.refresh,
                              color: Colors.white,
                            ),
                            label: const Text(
                              'Reintentar',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    )
                  : _filtered.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.public_off, size: 64, color: Colors.grey),
                          SizedBox(height: 8),
                          Text(
                            'Sin resultados',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: scrollCtrl,
                      itemCount: _filtered.length,
                      itemBuilder: (ctx, i) {
                        final c = _filtered[i];
                        return ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.network(
                              c['flag']!,
                              width: 36,
                              height: 24,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => const Icon(
                                Icons.flag,
                                size: 24,
                                color: AppColors.greyAccent,
                              ),
                            ),
                          ),
                          title: Text(c['name']!),
                          onTap: () => Navigator.pop(context, c['name']),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Campo de formulario que abre el CountryPicker y muestra el país elegido.
class CountryFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;

  const CountryFormField({
    super.key,
    required this.controller,
    this.label = 'Nacionalidad',
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: const Icon(
          Icons.arrow_drop_down,
          color: AppColors.primary,
        ),
        prefixIcon: const Icon(Icons.public, color: AppColors.greyAccent),
      ),
      validator: validator,
      onTap: () async {
        final country = await CountryPicker.show(context);
        if (country != null) controller.text = country;
      },
    );
  }
}
