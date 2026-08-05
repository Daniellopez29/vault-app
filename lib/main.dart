import 'dart:async';

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
import 'features/notifications/domain/usecases.dart';
import 'features/notifications/presentation/providers.dart';
import 'core/push_notification_service.dart';
import 'core/theme_preferences.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Recupera la URL del backend si se ajustó manualmente desde
  // Configuración (celular físico en otra red, IP distinta, etc).
  await ApiConfig.loadOverride();
  await RealtimeConfig.loadOverride();
  Stripe.publishableKey = StripeConfig.publishableKey;
  await PushNotificationService().initialize();
  await Stripe.instance.applySettings();

  final isDark = await ThemePreferences.loadIsDark();
  final initialThemeMode = isDark ? ThemeMode.dark : ThemeMode.light;
  VaultTheme.syncBrightness(isDark ? Brightness.dark : Brightness.light);

  runApp(
    ProviderScope(
      overrides: [
        themeModeControllerProvider.overrideWith(
          (ref) => ThemeModeController(initialThemeMode),
        ),
      ],
      child: const VaultApp(),
    ),
  );
}

class VaultApp extends ConsumerStatefulWidget {
  const VaultApp({super.key});

  @override
  ConsumerState<VaultApp> createState() => _VaultAppState();
}

class _VaultAppState extends ConsumerState<VaultApp>
    with WidgetsBindingObserver {
  StreamSubscription<String>? _tokenRefreshSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // FCM puede rotar el token en cualquier momento (no solo al reinstalar)
    // -- sin escuchar esto, un token rotado deja de recibir push hasta el
    // siguiente login manual.
    _tokenRefreshSubscription = PushNotificationService().onTokenRefresh.listen(
      (token) {
        if (ref.read(authControllerProvider).status ==
            AuthStatus.authenticated) {
          ref.read(registerFcmTokenUseCaseProvider)(
            RegisterFcmTokenParams(
              token: token,
              platform: PushNotificationService.platform,
            ),
          );
        }
      },
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tokenRefreshSubscription?.cancel();
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

        // Fire-and-forget: si falla, este dispositivo simplemente no recibe
        // push hasta el próximo login o hasta que FCM rote el token (ver
        // onTokenRefresh arriba), no debe bloquear el login.
        PushNotificationService().getToken().then((token) {
          if (token != null) {
            ref.read(registerFcmTokenUseCaseProvider)(
              RegisterFcmTokenParams(
                token: token,
                platform: PushNotificationService.platform,
              ),
            );
          }
        });
      }
    });

    // Traslúcido: no bloquea los gestos de los widgets hijos, solo los
    // observa para reiniciar el temporizador de inactividad de la sesión.
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () =>
          ref.read(authControllerProvider.notifier).onUserInteraction(),
      onPanDown: (_) =>
          ref.read(authControllerProvider.notifier).onUserInteraction(),
      child: MaterialApp.router(
        title: 'Vault',
        debugShowCheckedModeBanner: false,
        theme: VaultTheme.light,
        darkTheme: VaultTheme.dark,
        themeMode: ref.watch(themeModeControllerProvider),
        routerConfig: appRouter,
      ),
    );
  }
}
