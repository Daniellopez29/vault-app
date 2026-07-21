import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/datasources.dart';
import '../data/repositories.dart';
import '../domain/entities.dart';
import '../domain/repositories.dart';
import '../domain/usecases.dart';

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  return SubscriptionRepositoryImpl(dataSource: SubscriptionMockDataSource());
});

final getSubscriptionPlansUseCaseProvider =
    Provider<GetSubscriptionPlansUseCase>((ref) {
  return GetSubscriptionPlansUseCase(ref.read(subscriptionRepositoryProvider));
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
