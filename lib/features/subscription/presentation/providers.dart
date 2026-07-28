import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;
import '../../../core/providers.dart';
import '../data/datasources.dart';
import '../data/repositories.dart';
import '../domain/entities.dart';
import '../domain/repositories.dart';
import '../domain/usecases.dart';

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  return SubscriptionRepositoryImpl(
    dataSource: SubscriptionRemoteDataSource(ref.read(apiClientProvider)),
  );
});

final getSubscriptionPlansUseCaseProvider =
    Provider<GetSubscriptionPlansUseCase>((ref) {
  return GetSubscriptionPlansUseCase(ref.read(subscriptionRepositoryProvider));
});

final createSubscriptionUseCaseProvider =
    Provider<CreateSubscriptionUseCase>((ref) {
  return CreateSubscriptionUseCase(ref.read(subscriptionRepositoryProvider));
});

final getSubscriptionStatusUseCaseProvider =
    Provider<GetSubscriptionStatusUseCase>((ref) {
  return GetSubscriptionStatusUseCase(ref.read(subscriptionRepositoryProvider));
});

final cancelSubscriptionUseCaseProvider =
    Provider<CancelSubscriptionUseCase>((ref) {
  return CancelSubscriptionUseCase(ref.read(subscriptionRepositoryProvider));
});

enum PlansStatus { loading, loaded, error }

class PlansState {
  final PlansStatus status;
  final List<SubscriptionPlan> plans;
  final SubscriptionPlan? selected;
  final String? errorMessage;

  const PlansState({
    this.status = PlansStatus.loading,
    this.plans = const [],
    this.selected,
    this.errorMessage,
  });

  PlansState copyWith({
    PlansStatus? status,
    List<SubscriptionPlan>? plans,
    SubscriptionPlan? selected,
    String? errorMessage,
  }) {
    return PlansState(
      status: status ?? this.status,
      plans: plans ?? this.plans,
      selected: selected ?? this.selected,
      errorMessage: errorMessage,
    );
  }
}

/// Controla la carga y selección de planes para un tipo dado.
/// El tipo se fija al crear el controller (viene de la ruta).
class PlansController extends StateNotifier<PlansState> {
  final GetSubscriptionPlansUseCase _getPlans;
  final SubscriptionType type;

  PlansController(this._getPlans, this.type) : super(const PlansState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(status: PlansStatus.loading);
    final result = await _getPlans(type);
    result.fold(
      (failure) => state = state.copyWith(
        status: PlansStatus.error,
        errorMessage: failure.message,
      ),
      (plans) => state = state.copyWith(
        status: PlansStatus.loaded,
        plans: plans,
        // Preselecciona el plan de en medio (normalmente el más elegido).
        selected: plans.length > 1 ? plans[1] : plans.firstOrNull,
      ),
    );
  }

  void selectPlan(SubscriptionPlan plan) {
    state = state.copyWith(selected: plan);
  }
}

/// Family: un controller por tipo de suscripción, así la misma pantalla
/// sirve para producto y negocio sin duplicar código.
final plansControllerProvider = StateNotifierProvider.family<PlansController,
    PlansState, SubscriptionType>((ref, type) {
  return PlansController(ref.read(getSubscriptionPlansUseCaseProvider), type);
});

enum CheckoutStatus { idle, submitting, success, error }

class CheckoutState {
  final CheckoutStatus status;
  final String? errorMessage;

  const CheckoutState({this.status = CheckoutStatus.idle, this.errorMessage});

  CheckoutState copyWith({CheckoutStatus? status, String? errorMessage}) {
    return CheckoutState(status: status ?? this.status, errorMessage: errorMessage);
  }
}

typedef CheckoutParams = ({String planId, String email});

/// Captura la tarjeta con el CardField de Stripe, crea un PaymentMethod del
/// lado del cliente (los datos de la tarjeta nunca llegan a `payment/`) y
/// manda su id junto con el plan a `POST /subscriptions`.
class SubscriptionCheckoutController extends StateNotifier<CheckoutState> {
  final CreateSubscriptionUseCase _createSubscription;
  final CheckoutParams params;

  SubscriptionCheckoutController(this._createSubscription, this.params)
      : super(const CheckoutState());

  Future<void> pay() async {
    state = state.copyWith(status: CheckoutStatus.submitting, errorMessage: null);
    try {
      final paymentMethod = await stripe.Stripe.instance.createPaymentMethod(
        params: const stripe.PaymentMethodParams.card(
          paymentMethodData: stripe.PaymentMethodData(),
        ),
      );
      final result = await _createSubscription(CreateSubscriptionParams(
        planId: params.planId,
        email: params.email,
        paymentMethodId: paymentMethod.id,
      ));
      result.fold(
        (failure) => state = state.copyWith(
          status: CheckoutStatus.error,
          errorMessage: failure.message,
        ),
        (_) => state = state.copyWith(status: CheckoutStatus.success),
      );
    } on stripe.StripeError catch (e) {
      state = state.copyWith(
        status: CheckoutStatus.error,
        errorMessage: 'No se pudo procesar la tarjeta: ${e.message}',
      );
    } catch (e) {
      state = state.copyWith(
        status: CheckoutStatus.error,
        errorMessage: 'Error inesperado al procesar el pago: $e',
      );
    }
  }
}

final subscriptionCheckoutControllerProvider = StateNotifierProvider.autoDispose
    .family<SubscriptionCheckoutController, CheckoutState, CheckoutParams>(
        (ref, params) {
  return SubscriptionCheckoutController(
    ref.read(createSubscriptionUseCaseProvider),
    params,
  );
});

// ─── SUSCRIPCIÓN ACTIVA (ver / cancelar) ────────────────────────────────────

enum SubscriptionStatusLoad { loading, loaded, error }

class SubscriptionStatusState {
  final SubscriptionStatusLoad status;
  final SubscriptionStatus? subscription;
  final String? errorMessage;
  final bool canceling;

  const SubscriptionStatusState({
    this.status = SubscriptionStatusLoad.loading,
    this.subscription,
    this.errorMessage,
    this.canceling = false,
  });

  SubscriptionStatusState copyWith({
    SubscriptionStatusLoad? status,
    SubscriptionStatus? subscription,
    String? errorMessage,
    bool? canceling,
  }) {
    return SubscriptionStatusState(
      status: status ?? this.status,
      subscription: subscription,
      errorMessage: errorMessage,
      canceling: canceling ?? this.canceling,
    );
  }
}

/// Estado de la suscripción propia -- alimenta la pantalla "Mi suscripción"
/// y decide si el flujo de "anunciar" deja elegir qué promocionar o manda
/// primero a comprar un plan (ver features/ads).
class SubscriptionStatusController extends StateNotifier<SubscriptionStatusState> {
  final GetSubscriptionStatusUseCase _getStatus;
  final CancelSubscriptionUseCase _cancel;

  SubscriptionStatusController(this._getStatus, this._cancel)
      : super(const SubscriptionStatusState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(status: SubscriptionStatusLoad.loading);
    final result = await _getStatus();
    result.fold(
      (failure) => state = state.copyWith(
        status: SubscriptionStatusLoad.error,
        errorMessage: failure.message,
      ),
      (subscription) => state = SubscriptionStatusState(
        status: SubscriptionStatusLoad.loaded,
        subscription: subscription,
      ),
    );
  }

  Future<bool> cancel() async {
    state = state.copyWith(canceling: true, errorMessage: null);
    final result = await _cancel();
    return result.fold(
      (failure) {
        state = state.copyWith(canceling: false, errorMessage: failure.message);
        return false;
      },
      (_) {
        state = SubscriptionStatusState(status: SubscriptionStatusLoad.loaded);
        return true;
      },
    );
  }
}

final subscriptionStatusControllerProvider = StateNotifierProvider<
    SubscriptionStatusController, SubscriptionStatusState>((ref) {
  return SubscriptionStatusController(
    ref.read(getSubscriptionStatusUseCaseProvider),
    ref.read(cancelSubscriptionUseCaseProvider),
  );
});
