import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vault_app/core/security/fake_gps_guard.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('vault/device_integrity');

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  testWidgets('Permite iniciar la app cuando NO existe Fake GPS', (tester) async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async => false);

    await tester.pumpWidget(
      const FakeGpsGuard(
        child: MaterialApp(home: Text('Vault App Disponible')),
      ),
    );
    await tester.pump();

    expect(find.text('Vault App Disponible'), findsOneWidget);
    expect(find.text('Ubicación simulada detectada'), findsNothing);
  });

  testWidgets('Bloquea la app si detecta Fake GPS', (tester) async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async => true);

    await tester.pumpWidget(
      const FakeGpsGuard(
        child: MaterialApp(home: Text('Vault App Disponible')),
      ),
    );
    await tester.pump();

    expect(find.text('Vault App Disponible'), findsNothing);
    expect(find.text('Ubicación simulada detectada'), findsOneWidget);
  });
}