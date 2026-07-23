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
import '../features/stats/presentation/stats_page.dart';
import '../features/addresses/presentation/addresses_page.dart';
import '../features/addresses/presentation/checkout_address_page.dart';
import '../features/cart/presentation/payment_instructions_page.dart';
import '../features/cart/domain/entities.dart';
import '../features/marketplace/presentation/product_detail_page.dart';
import '../features/marketplace/domain/entities.dart';
import '../features/marketplace/presentation/seller_commerce_view.dart';
import '../features/services/presentation/services_tab.dart';
import '../features/services/presentation/services_directory_page.dart';
import '../features/reviews/presentation/reviews_tab.dart';
import 'widgets/titled_page.dart';
import '../features/subscription/domain/entities.dart';
import '../features/subscription/presentation/subscription_page.dart';
import '../features/subscription/presentation/subscription_checkout_page.dart';
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
  static const stats         = '/stats';
  static const productDetail = '/product-detail';
  static const commerce      = '/commerce';
  static const services      = '/services';
  static const specialists   = '/specialists';
  static const addresses     = '/addresses';
  static const checkoutAddress = '/checkout-address';
  static const paymentInstructions = '/payment-instructions';
  static const reviews       = '/reviews';
  static const subscriptionCheckout = '/subscription-checkout';
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
      path: AppRoutes.subscriptionCheckout,
      builder: (context, state) => SubscriptionCheckoutPage(
        plan: state.extra as SubscriptionPlan,
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
      path: AppRoutes.stats,
      builder: (context, state) => const StatsPage(),
    ),
    GoRoute(
      path: AppRoutes.productDetail,
      builder: (context, state) => ProductDetailPage(
        item: state.extra as MarketplaceItemEntity,
      ),
    ),
    GoRoute(
      path: AppRoutes.commerce,
      builder: (context, state) => const SellerCommerceView(),
    ),
    GoRoute(
      path: AppRoutes.addresses,
      builder: (context, state) => const AddressesPage(),
    ),
    GoRoute(
      path: AppRoutes.checkoutAddress,
      builder: (context, state) => const CheckoutAddressPage(),
    ),
    GoRoute(
      path: AppRoutes.paymentInstructions,
      builder: (context, state) => PaymentInstructionsPage(
        type: state.extra as PaymentType,
      ),
    ),
    GoRoute(
      path: AppRoutes.specialists,
      builder: (context, state) => const TitledPage(
        title: 'Especialistas',
        child: ServicesDirectoryPage(),
      ),
    ),
    GoRoute(
      path: AppRoutes.services,
      builder: (context, state) => const TitledPage(
        title: 'Servicios',
        child: ServicesTab(),
      ),
    ),
    GoRoute(
      path: AppRoutes.reviews,
      builder: (context, state) => const TitledPage(
        title: 'Reseñas',
        child: ReviewsTab(),
      ),
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









