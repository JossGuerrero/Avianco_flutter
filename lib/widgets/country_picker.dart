import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/app_colors.dart';

/// Selector de país reutilizable basado en restcountries.com.
/// Muestra un modal bottom sheet con buscador y banderas.
/// Devuelve el nombre del país seleccionado (en español si existe).
class CountryPicker {
  static List<Map<String, String>>? _cache;

  static Future<List<Map<String, String>>> _fetchCountries() async {
    if (_cache != null) return _cache!;
    final response = await http.get(
      Uri.parse(
        'https://restcountries.com/v3.1/all?fields=name,flags,cca2,translations',
      ),
    );
    if (response.statusCode != 200) return [];
    final List<dynamic> data = jsonDecode(response.body);
    final countries = data.map<Map<String, String>>((c) {
      final spa = c['translations']?['spa']?['common'];
      final common = c['name']?['common'] ?? '';
      return {
        'name': (spa ?? common).toString(),
        'flag': (c['flags']?['png'] ?? '').toString(),
        'code': (c['cca2'] ?? '').toString(),
      };
    }).toList();
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
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final countries = await CountryPicker._fetchCountries();
    if (!mounted) return;
    setState(() {
      _all = countries;
      _filtered = countries;
      _loading = false;
    });
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
      builder: (ctx, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
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
