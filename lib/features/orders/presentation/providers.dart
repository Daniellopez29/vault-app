import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';
import '../data/datasources.dart';
import '../data/repositories.dart';
import '../domain/entities.dart';
import '../domain/repositories.dart';
import '../domain/usecases.dart';

final orderRemoteDataSourceProvider = Provider<OrderRemoteDataSource>((ref) {
  return OrderRemoteDataSourceImpl(ref.read(apiClientProvider));
});

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepositoryImpl(remote: ref.read(orderRemoteDataSourceProvider));
});

final createOrderUseCaseProvider =
    Provider((ref) => CreateOrderUseCase(ref.read(orderRepositoryProvider)));

final getMyOrdersUseCaseProvider =
    Provider((ref) => GetMyOrdersUseCase(ref.read(orderRepositoryProvider)));

final getMySalesUseCaseProvider =
    Provider((ref) => GetMySalesUseCase(ref.read(orderRepositoryProvider)));

final confirmOrderUseCaseProvider =
    Provider((ref) => ConfirmOrderUseCase(ref.read(orderRepositoryProvider)));

final shipOrderUseCaseProvider =
    Provider((ref) => ShipOrderUseCase(ref.read(orderRepositoryProvider)));

// ─── MIS PEDIDOS (comprador) ────────────────────────────────────────────────

enum MyOrdersStatus { loading, loaded, error }

class MyOrdersState {
  final MyOrdersStatus status;
  final List<OrderEntity> orders;
  final String? errorMessage;

  const MyOrdersState({
    this.status = MyOrdersStatus.loading,
    this.orders = const [],
    this.errorMessage,
  });

  MyOrdersState copyWith({
    MyOrdersStatus? status,
    List<OrderEntity>? orders,
    String? errorMessage,
  }) {
    return MyOrdersState(
      status: status ?? this.status,
      orders: orders ?? this.orders,
      errorMessage: errorMessage,
    );
  }
}

/// Pedidos donde el usuario en sesión compró -- alimenta "Mis pedidos" y su
/// botón "Confirmar recepción" (solo habilitado si `status == enviado`).
class MyOrdersController extends StateNotifier<MyOrdersState> {
  final GetMyOrdersUseCase _getMyOrders;
  final ConfirmOrderUseCase _confirmOrder;

  MyOrdersController(this._getMyOrders, this._confirmOrder) : super(const MyOrdersState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(status: MyOrdersStatus.loading);
    final result = await _getMyOrders();
    result.fold(
      (failure) => state = state.copyWith(
        status: MyOrdersStatus.error,
        errorMessage: failure.message,
      ),
      (orders) => state = state.copyWith(status: MyOrdersStatus.loaded, orders: orders),
    );
  }

  Future<bool> confirm(String id) async {
    final result = await _confirmOrder(id);
    return result.fold((failure) {
      state = state.copyWith(errorMessage: failure.message);
      return false;
    }, (_) {
      load();
      return true;
    });
  }
}

final myOrdersControllerProvider = StateNotifierProvider<MyOrdersController, MyOrdersState>((ref) {
  return MyOrdersController(
    ref.read(getMyOrdersUseCaseProvider),
    ref.read(confirmOrderUseCaseProvider),
  );
});

// ─── MIS VENTAS (vendedor) ──────────────────────────────────────────────────

enum MySalesStatus { loading, loaded, error }

class MySalesState {
  final MySalesStatus status;
  final List<OrderEntity> orders;
  final String? errorMessage;

  const MySalesState({
    this.status = MySalesStatus.loading,
    this.orders = const [],
    this.errorMessage,
  });

  MySalesState copyWith({
    MySalesStatus? status,
    List<OrderEntity>? orders,
    String? errorMessage,
  }) {
    return MySalesState(
      status: status ?? this.status,
      orders: orders ?? this.orders,
      errorMessage: errorMessage,
    );
  }
}

/// Pedidos donde el usuario en sesión vendió -- alimenta "Mis ventas" y su
/// botón "Marcar como enviado" (solo habilitado si `status == retenido`).
class MySalesController extends StateNotifier<MySalesState> {
  final GetMySalesUseCase _getMySales;
  final ShipOrderUseCase _shipOrder;

  MySalesController(this._getMySales, this._shipOrder) : super(const MySalesState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(status: MySalesStatus.loading);
    final result = await _getMySales();
    result.fold(
      (failure) => state = state.copyWith(
        status: MySalesStatus.error,
        errorMessage: failure.message,
      ),
      (orders) => state = state.copyWith(status: MySalesStatus.loaded, orders: orders),
    );
  }

  Future<bool> ship(String id) async {
    final result = await _shipOrder(id);
    return result.fold((failure) {
      state = state.copyWith(errorMessage: failure.message);
      return false;
    }, (_) {
      load();
      return true;
    });
  }
}

final mySalesControllerProvider = StateNotifierProvider<MySalesController, MySalesState>((ref) {
  return MySalesController(
    ref.read(getMySalesUseCaseProvider),
    ref.read(shipOrderUseCaseProvider),
  );
});
