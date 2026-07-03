import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vault_app/main.dart';

void main() {
  testWidgets('La app arranca mostrando la pantalla de bienvenida con las opciones de inicio de sesión',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pumpAndSettle();

    expect(find.text('VAULT'), findsOneWidget);
    expect(find.text('Inicia con Correo'), findsOneWidget);
  });
}
