import 'package:go_router/go_router.dart';
import '../core/enums.dart';
import '../features/auth/presentation/pages.dart';
import '../features/auth/presentation/role_selection_page.dart';
import '../features/auth/presentation/register_form_page.dart';
import '../features/settings/presentation/settings_page.dart';
import '../features/cart/presentation/cart_tab.dart';
import '../features/cart/presentation/payment_method_page.dart';
import '../features/cart/presentation/order_success_page.dart';
import '../features/profile/presentation/register_asset_page.dart';
import '../features/legal/presentation/legal_page.dart';

abstract class AppRoutes {
  static const login         = '/login';
  static const home          = '/home';
  static const roleSelection = '/role-selection';
  static const register      = '/register';
  static const settings      = '/settings';
  static const signIn        = '/signin';
  static const cart          = '/cart';
  static const paymentMethod = '/payment-method';
  static const orderSuccess  = '/order-success';
  static const registerAsset = '/register-asset';
  static const legal         = '/legal';
}

final appRouter = GoRouter(
  initialLocation: AppRoutes.login,
  routes: [
    GoRoute(
      path: AppRoutes.signIn,
      builder: (context, state) => const SignInPage(),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: AppRoutes.roleSelection,
      builder: (context, state) => const RoleSelectionPage(),
    ),
    GoRoute(
      path: AppRoutes.register,
      builder: (context, state) => RegisterFormPage(
        role: state.extra as UserRole,
      ),
    ),
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: AppRoutes.settings,
      builder: (context, state) => const SettingsPage(),
    ),
    GoRoute(
      path: AppRoutes.cart,
      builder: (context, state) => const CartTab(),
    ),
    GoRoute(
      path: AppRoutes.paymentMethod,
      builder: (context, state) => const PaymentMethodPage(),
    ),
    GoRoute(
      path: AppRoutes.orderSuccess,
      builder: (context, state) => const OrderSuccessPage(),
    ),
    GoRoute(
      path: AppRoutes.registerAsset,
      builder: (context, state) => const RegisterAssetPage(),
    ),
    GoRoute(
      path: AppRoutes.legal,
      builder: (context, state) => LegalPage(
        initialIndex: state.extra as int? ?? 0,
      ),
    ),
  ],
);