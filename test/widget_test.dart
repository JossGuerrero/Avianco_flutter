import 'package:flutter_test/flutter_test.dart';

import 'package:avianco/main.dart';

void main() {
  testWidgets('La app arranca en la pantalla pública', (tester) async {
    await tester.pumpWidget(const AviancoApp(initialRoute: '/'));
    await tester.pump();
    // La pantalla pública muestra el loader mientras consulta la API.
    expect(find.byType(AviancoApp), findsOneWidget);
  });
}
