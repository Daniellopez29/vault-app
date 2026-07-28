import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/enums.dart';
import '../core/route_transitions.dart';
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
import '../features/chat/presentation/conversations_page.dart';
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
import '../features/subscription/presentation/subscription_management_page.dart';
import '../features/connect/presentation/connect_onboarding_page.dart';
import '../features/ads/presentation/my_ads_page.dart';
import '../features/orders/presentation/my_orders_page.dart';
import '../features/orders/presentation/my_sales_page.dart';
import '../features/shell/presentation/home_page.dart';
import '../features/profile/presentation/asset_detail_page.dart';
import '../features/profile/presentation/edit_asset_page.dart';
import '../features/profile/domain/entities.dart';

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
  static const createPost    = '/create-post';
  static const registerBusiness = '/register-business';
  static const legal         = '/legal';
  static const notifications = '/notifications';
  static const chat          = '/chat';
  static const conversations = '/conversations';
  static const subscription  = '/subscription';
  static const subscriptionManagement = '/subscription-management';
  static const connectOnboarding = '/connect-onboarding';
  static const myAds         = '/my-ads';
  static const myOrders      = '/my-orders';
  static const mySales       = '/my-sales';
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
  static const assetDetail   = '/asset-detail';
  static const editAsset     = '/edit-asset';
}

final appRouter = GoRouter(
  initialLocation: AppRoutes.login,
  routes: [
    // ── Auth (sin transición custom, entrada directa) ──
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: AppRoutes.signIn,
      pageBuilder: (context, state) => vaultTransitionPage(
        key: state.pageKey,
        child: const SignInPage(),
      ),
    ),
    GoRoute(
      path: AppRoutes.roleSelection,
      pageBuilder: (context, state) => vaultTransitionPage(
        key: state.pageKey,
        child: const RoleSelectionPage(),
      ),
    ),
    GoRoute(
      path: AppRoutes.register,
      pageBuilder: (context, state) => vaultTransitionPage(
        key: state.pageKey,
        child: RegisterFormPage(
          role: (state.extra as RegisterFlowArgs).role,
          destination: (state.extra as RegisterFlowArgs).destination,
        ),
      ),
    ),

    // ── Home ──
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomePage(),
    ),

    // ── Navegación general (fade + slide sutil) ──
    GoRoute(
      path: AppRoutes.settings,
      pageBuilder: (context, state) => vaultTransitionPage(
        key: state.pageKey,
        child: const SettingsPage(),
      ),
    ),
    GoRoute(
      path: AppRoutes.notifications,
      pageBuilder: (context, state) => vaultTransitionPage(
        key: state.pageKey,
        child: const NotificationsPage(),
      ),
    ),
    GoRoute(
      path: AppRoutes.conversations,
      pageBuilder: (context, state) => vaultTransitionPage(
        key: state.pageKey,
        child: const ConversationsListPage(),
      ),
    ),
    GoRoute(
      path: AppRoutes.stats,
      pageBuilder: (context, state) => vaultTransitionPage(
        key: state.pageKey,
        child: const StatsPage(),
      ),
    ),
    GoRoute(
      path: AppRoutes.legal,
      pageBuilder: (context, state) => vaultTransitionPage(
        key: state.pageKey,
        child: LegalPage(initialIndex: state.extra as int? ?? 0),
      ),
    ),
    GoRoute(
      path: AppRoutes.myAds,
      pageBuilder: (context, state) => vaultTransitionPage(
        key: state.pageKey,
        child: const MyAdsPage(),
      ),
    ),
    GoRoute(
      path: AppRoutes.myOrders,
      pageBuilder: (context, state) => vaultTransitionPage(
        key: state.pageKey,
        child: const MyOrdersPage(),
      ),
    ),
    GoRoute(
      path: AppRoutes.mySales,
      pageBuilder: (context, state) => vaultTransitionPage(
        key: state.pageKey,
        child: const MySalesPage(),
      ),
    ),
    GoRoute(
      path: AppRoutes.addresses,
      pageBuilder: (context, state) => vaultTransitionPage(
        key: state.pageKey,
        child: const AddressesPage(),
      ),
    ),
    GoRoute(
      path: AppRoutes.createPost,
      pageBuilder: (context, state) => vaultTransitionPage(
        key: state.pageKey,
        child: const CreatePostPage(),
      ),
    ),

    // ── Flujos modales (slide más pronunciado desde abajo) ──
    GoRoute(
      path: AppRoutes.cart,
      pageBuilder: (context, state) => vaultModalTransitionPage(
        key: state.pageKey,
        child: const CartTab(),
      ),
    ),
    GoRoute(
      path: AppRoutes.checkoutAddress,
      pageBuilder: (context, state) => vaultModalTransitionPage(
        key: state.pageKey,
        child: const CheckoutAddressPage(),
      ),
    ),
    GoRoute(
      path: AppRoutes.paymentMethod,
      pageBuilder: (context, state) => vaultModalTransitionPage(
        key: state.pageKey,
        child: const PaymentMethodPage(),
      ),
    ),
    GoRoute(
      path: AppRoutes.paymentInstructions,
      pageBuilder: (context, state) => vaultModalTransitionPage(
        key: state.pageKey,
        child: PaymentInstructionsPage(type: state.extra as PaymentType),
      ),
    ),
    GoRoute(
      path: AppRoutes.orderSuccess,
      pageBuilder: (context, state) => vaultModalTransitionPage(
        key: state.pageKey,
        child: const OrderSuccessPage(),
      ),
    ),
    GoRoute(
      path: AppRoutes.subscription,
      pageBuilder: (context, state) => vaultModalTransitionPage(
        key: state.pageKey,
        child: SubscriptionPage(type: state.extra as SubscriptionType),
      ),
    ),
    GoRoute(
      path: AppRoutes.subscriptionManagement,
      pageBuilder: (context, state) => vaultModalTransitionPage(
        key: state.pageKey,
        child: const SubscriptionManagementPage(),
      ),
    ),
    GoRoute(
      path: AppRoutes.subscriptionCheckout,
      pageBuilder: (context, state) => vaultModalTransitionPage(
        key: state.pageKey,
        child: SubscriptionCheckoutPage(plan: state.extra as SubscriptionPlan),
      ),
    ),
    GoRoute(
      path: AppRoutes.connectOnboarding,
      pageBuilder: (context, state) => vaultModalTransitionPage(
        key: state.pageKey,
        child: const ConnectOnboardingPage(),
      ),
    ),

    // ── Detalle / registros ──
    GoRoute(
      path: AppRoutes.productDetail,
      pageBuilder: (context, state) => vaultModalTransitionPage(
        key: state.pageKey,
        child: ProductDetailPage(item: state.extra as MarketplaceItemEntity),
      ),
    ),
    GoRoute(
      path: AppRoutes.assetDetail,
      pageBuilder: (context, state) => vaultModalTransitionPage(
        key: state.pageKey,
        child: AssetDetailPage(asset: state.extra as AssetEntity),
      ),
    ),
    GoRoute(
      path: AppRoutes.editAsset,
      pageBuilder: (context, state) => vaultTransitionPage(
        key: state.pageKey,
        child: EditAssetPage(asset: state.extra as AssetEntity),
      ),
    ),
    GoRoute(
      path: AppRoutes.registerAsset,
      pageBuilder: (context, state) => vaultModalTransitionPage(
        key: state.pageKey,
        child: const RegisterAssetPage(),
      ),
    ),
    GoRoute(
      path: AppRoutes.registerBusiness,
      pageBuilder: (context, state) => vaultModalTransitionPage(
        key: state.pageKey,
        child: const RegisterBusinessPage(),
      ),
    ),
    GoRoute(
      path: AppRoutes.commerce,
      pageBuilder: (context, state) => vaultTransitionPage(
        key: state.pageKey,
        child: const SellerCommerceView(),
      ),
    ),

    // ── Servicios / reseñas / especialistas ──
    GoRoute(
      path: AppRoutes.specialists,
      pageBuilder: (context, state) => vaultTransitionPage(
        key: state.pageKey,
        child: const TitledPage(title: 'Especialistas', child: ServicesDirectoryPage()),
      ),
    ),
    GoRoute(
      path: AppRoutes.services,
      pageBuilder: (context, state) => vaultTransitionPage(
        key: state.pageKey,
        child: const TitledPage(title: 'Servicios', child: ServicesTab()),
      ),
    ),
    GoRoute(
      path: AppRoutes.reviews,
      pageBuilder: (context, state) => vaultTransitionPage(
        key: state.pageKey,
        child: const TitledPage(title: 'Reseñas', child: ReviewsTab()),
      ),
    ),

    // ── Chat ──
    GoRoute(
      path: AppRoutes.chat,
      pageBuilder: (context, state) {
        final args = state.extra;
        if (args is! ChatPageArgs) {
          return vaultTransitionPage(
            key: state.pageKey,
            child: const TitledPage(
              title: 'Chat',
              child: Center(child: Text('No se especificó con quién chatear.')),
            ),
          );
        }
        return vaultTransitionPage(
          key: state.pageKey,
          child: ChatPage(args: args),
        );
      },
    ),
  ],
);