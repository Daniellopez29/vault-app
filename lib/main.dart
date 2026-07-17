import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/api_client.dart';
import 'core/router.dart';
import 'core/theme.dart';
import 'features/auth/presentation/providers.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Recupera la URL del backend si se ajustó manualmente desde
  // Configuración (celular físico en otra red, IP distinta, etc).
  await ApiConfig.loadOverride();
  runApp(const ProviderScope(child: VaultApp()));
}

class VaultApp extends ConsumerWidget {
  const VaultApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Si el estado deja de estar autenticado (logout manual, cierre por
    // inactividad, o borrado de cuenta) y no hay un BuildContext específico
    // que ya esté navegando, vuelve a la pantalla de login.
    ref.listen(authControllerProvider, (previous, next) {
      if (previous?.status == AuthStatus.authenticated &&
          next.status != AuthStatus.authenticated) {
        appRouter.go(AppRoutes.login);
      }
    });

    // Traslúcido: no bloquea los gestos de los widgets hijos, solo los
    // observa para reiniciar el temporizador de inactividad de la sesión.
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
      ),
    );
  }
}