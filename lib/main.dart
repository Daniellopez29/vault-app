import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'core/api_config.dart';
import 'core/providers.dart';
import 'core/realtime_config.dart';
import 'core/router.dart';
import 'core/stripe_config.dart';
import 'core/theme.dart';
import 'features/auth/presentation/providers.dart';
import 'features/chat/presentation/providers.dart';
import 'core/push_notification_service.dart';
import 'core/providers.dart' show apiClientProvider;
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Recupera la URL del backend si se ajustó manualmente desde
  // Configuración (celular físico en otra red, IP distinta, etc).
  await ApiConfig.loadOverride();
  await RealtimeConfig.loadOverride();
  Stripe.publishableKey = StripeConfig.publishableKey;
  await PushNotificationService().initialize();
  await Stripe.instance.applySettings();
  runApp(const ProviderScope(child: VaultApp()));
}

class VaultApp extends ConsumerStatefulWidget {
  const VaultApp({super.key});

  @override
  ConsumerState<VaultApp> createState() => _VaultAppState();
}

class _VaultAppState extends ConsumerState<VaultApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // El SO suele matar el socket de tiempo real mientras la app está en
    // segundo plano sin que el cliente se entere -- sin esto, el chat y las
    // notificaciones podían quedarse "congelados" hasta que el backoff
    // interno de RealtimeSocket reconectara solo (hasta 30s) o hasta reabrir
    // sesión. Al volver a primer plano se fuerza una reconexión inmediata.
    if (state == AppLifecycleState.resumed) {
      ref.read(realtimeSocketProvider).kick();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Si el estado deja de estar autenticado (logout manual, cierre por
    // inactividad, o borrado de cuenta) y no hay un BuildContext específico
    // que ya esté navegando, vuelve a la pantalla de login.
    ref.listen(authControllerProvider, (previous, next) {
      if (previous?.status == AuthStatus.authenticated &&
          next.status != AuthStatus.authenticated) {
        appRouter.go(AppRoutes.login);
      }

      // Genera (si hace falta) y registra la llave pública del chat E2EE en
      // cuanto hay sesión -- fire-and-forget: si falla, el chat de esta
      // sesión simplemente no funcionará hasta el próximo login, no debe
      // bloquear el flujo de autenticación.
      if (previous?.status != AuthStatus.authenticated &&
          next.status == AuthStatus.authenticated &&
          next.user != null) {
        ref.read(ensurePublicKeyRegisteredUseCaseProvider)(next.user!.id);
        // Registra el token FCM en el backend para push notifications.
        PushNotificationService().registerTokenInBackend(ref.read(apiClientProvider));
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