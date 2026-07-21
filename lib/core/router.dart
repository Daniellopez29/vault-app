import 'package:go_router/go_router.dart';
import '../core/enums.dart';
import '../features/auth/presentation/pages.dart';
import '../features/home/presentation/create_post_page.dart';
import '../features/auth/presentation/role_selection_page.dart';
import '../features/auth/presentation/register_form_page.dart';
import '../features/settings/presentation/settings_page.dart';
import '../features/cart/presentation/cart_tab.dart';
import '../features/cart/presentation/payment_method_page.dart';
import '../features/cart/presentation/order_success_page.dart';
import '../features/profile/presentation/register_asset_page.dart';
import '../features/profile/presentation/register_business_page.dart';
import '../features/legal/presentation/legal_page.dart';
import '../features/notifications/presentation/notifications_page.dart';
import '../features/chat/presentation/chat_page.dart';
import '../features/subscription/domain/entities.dart';
import '../features/subscription/presentation/subscription_page.dart';
import '../features/shell/presentation/home_page.dart';
import '../features/profile/presentation/asset_detail_page.dart';
import '../features/profile/domain/entities.dart';

/// QuÃ© rol se crea y a dÃ³nde ir despuÃ©s de registrarse con Ã©xito. Cada
/// tarjeta de [RoleSelectionPage] arma uno de estos segÃºn lo que el
/// usuario eligiÃ³ (Coleccionista/Vendedor/Negocio).
class RegisterFlowArgs {
  final UserRole role;
  final String destination;

  const RegisterFlowArgs({required this.role, required this.destination});
}

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
  static const createPost = '/create-post';
  static const registerBusiness = '/register-business';
  static const legal         = '/legal';
  static const notifications = '/notifications';
  static const chat          = '/chat';
  static const subscription  = '/subscription';
  static const assetDetail = '/asset-detail';
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
      builder: (context, state) {
        final args = state.extra as RegisterFlowArgs;
        return RegisterFormPage(role: args.role, destination: args.destination);
      },
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
      path: AppRoutes.subscription,
      builder: (context, state) => SubscriptionPage(
        type: state.extra as SubscriptionType,
      ),
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
      path: AppRoutes.createPost,
      builder: (context, state) => const CreatePostPage(),
    ),
    GoRoute(
      path: AppRoutes.registerBusiness,
      builder: (context, state) => const RegisterBusinessPage(),
    ),
    GoRoute(
      path: AppRoutes.legal,
      builder: (context, state) => LegalPage(
        initialIndex: state.extra as int? ?? 0,
      ),
    ),
    GoRoute(
      path: AppRoutes.notifications,
      builder: (context, state) => const NotificationsPage(),
    ),
    GoRoute(
      path: AppRoutes.chat,
      builder: (context, state) => const ChatPage(),
    ),
    GoRoute(
      path: AppRoutes.assetDetail,
      builder: (context, state) => AssetDetailPage(
        asset: state.extra as AssetEntity,
      ),
    ),
  ],
);


