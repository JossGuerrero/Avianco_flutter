import 'package:flutter/material.dart';

/// Abre un calendario y escribe la fecha (YYYY-MM-DD) en el controller.
/// Evita tener que escribir fechas a mano en cualquier formulario.
Future<void> seleccionarFecha(
  BuildContext context,
  TextEditingController ctrl, {
  DateTime? inicial,
  DateTime? primero,
  DateTime? ultimo,
}) async {
  final d = await showDatePicker(
    context: context,
    initialDate: DateTime.tryParse(ctrl.text) ?? inicial ?? DateTime.now(),
    firstDate: primero ?? DateTime(1920),
    lastDate: ultimo ?? DateTime(2035),
  );
  if (d != null) ctrl.text = d.toIso8601String().split('T').first;
}
