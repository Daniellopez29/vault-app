import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

// Módulos internos
import 'core/api_client.dart';
import 'core/router.dart';
import 'core/security/fake_gps_guard.dart'; // <-- Guardián nativo de seguridad
import 'core/stripe_config.dart';
import 'core/theme.dart';
import 'features/auth/presentation/providers.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await ApiConfig.loadOverride();
  await PaymentApiConfig.loadOverride();
  Stripe.publishableKey = StripeConfig.publishableKey;
  await Stripe.instance.applySettings();

  runApp(
    const FakeGpsGuard(
      child: ProviderScope(
        child: VaultApp(),
      ),
    ),
  );
}

class VaultApp extends ConsumerWidget {
  const VaultApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escucha el estado de autenticación para redirigir si expira la sesión
    ref.listen(authControllerProvider, (previous, next) {
      if (previous?.status == AuthStatus.authenticated &&
          next.status != AuthStatus.authenticated) {
        appRouter.go(AppRoutes.login);
      }
    });

    // Detección global de interacción para el temporizador de inactividad
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => ref.read(authControllerProvider.notifier).onUserInteraction(),
      onPanDown: (_) =>
          ref.read(authControllerProvider.notifier).onUserInteraction(),
      child: MaterialApp.router(
        title: 'Vault',
        debugShowCheckedModeBanner: false,
        theme: VaultTheme.light,
        routerConfig: appRouter,
        builder: (context, child) => FakeGpsGuard(child: child),
      ),
    );
  }
}