import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/usecase.dart';
import '../data/datasources.dart';
import '../data/repositories.dart';
import '../domain/entities.dart';
import '../domain/repositories.dart';
import '../domain/usecases.dart';

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  return CartRepositoryImpl(localDataSource: CartLocalDataSourceImpl());
});

final _getCartItemsUseCaseProvider = Provider(
      (ref) => GetCartItemsUseCase(ref.read(cartRepositoryProvider)),
);
final _addCartItemUseCaseProvider = Provider(
      (ref) => AddCartItemUseCase(ref.read(cartRepositoryProvider)),
);
final _removeCartItemUseCaseProvider = Provider(
      (ref) => RemoveCartItemUseCase(ref.read(cartRepositoryProvider)),
);
final _updateCartQuantityUseCaseProvider = Provider(
      (ref) => UpdateCartQuantityUseCase(ref.read(cartRepositoryProvider)),
);
final _clearCartUseCaseProvider = Provider(
      (ref) => ClearCartUseCase(ref.read(cartRepositoryProvider)),
);
final _getPaymentMethodsUseCaseProvider = Provider(
      (ref) => GetPaymentMethodsUseCase(ref.read(cartRepositoryProvider)),
);

enum CartStatus { initial, loading, loaded, error }

class CartState {
  final CartStatus status;
  final List<CartItemEntity> items;
  final String? errorMessage;

  const CartState({
    this.status = CartStatus.initial,
    this.items = const [],
    this.errorMessage,
  });

  /// Resumen de costos derivado de los items (subtotal + tarifa de uso).
  OrderSummaryEntity get summary => OrderSummaryEntity.fromItems(items);

  /// Cantidad total de piezas, para el badge del carrito.
  int get totalCount => items.fold(0, (sum, item) => sum + item.quantity);

  bool get isEmpty => items.isEmpty;

  CartState copyWith({
    CartStatus? status,
    List<CartItemEntity>? items,
    String? errorMessage,
  }) {
    return CartState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: errorMessage,
    );
  }
}

final cartControllerProvider =
StateNotifierProvider<CartController, CartState>((ref) {
  return CartController(
    getItems: ref.read(_getCartItemsUseCaseProvider),
    addItem: ref.read(_addCartItemUseCaseProvider),
    removeItem: ref.read(_removeCartItemUseCaseProvider),
    updateQuantity: ref.read(_updateCartQuantityUseCaseProvider),
    clearCart: ref.read(_clearCartUseCaseProvider),
  );
});

class CartController extends StateNotifier<CartState> {
  final GetCartItemsUseCase _getItems;
  final AddCartItemUseCase _addItem;
  final RemoveCartItemUseCase _removeItem;
  final UpdateCartQuantityUseCase _updateQuantity;
  final ClearCartUseCase _clearCart;

  CartController({
    required GetCartItemsUseCase getItems,
    required AddCartItemUseCase addItem,
    required RemoveCartItemUseCase removeItem,
    required UpdateCartQuantityUseCase updateQuantity,
    required ClearCartUseCase clearCart,
  })  : _getItems = getItems,
        _addItem = addItem,
        _removeItem = removeItem,
        _updateQuantity = updateQuantity,
        _clearCart = clearCart,
        super(const CartState()) {
    loadCart();
  }

  Future<void> loadCart() async {
    state = state.copyWith(status: CartStatus.loading);
    final result = await _getItems(const NoParams());
    _apply(result);
  }

  Future<void> addItem(CartItemEntity item) async {
    final result = await _addItem(item);
    _apply(result);
  }

  Future<void> removeItem(String id) async {
    final result = await _removeItem(id);
    _apply(result);
  }

  Future<void> updateQuantity(String id, int quantity) async {
    final result = await _updateQuantity(
      UpdateQuantityParams(id: id, quantity: quantity),
    );
    _apply(result);
  }

  Future<void> clear() async {
    final result = await _clearCart(const NoParams());
    _apply(result);
  }

  /// Aplica el resultado de un caso de uso al estado, en un solo lugar.
  void _apply(dynamic result) {
    result.fold(
          (failure) => state = state.copyWith(
        status: CartStatus.error,
        errorMessage: failure.message,
      ),
          (items) => state = state.copyWith(
        status: CartStatus.loaded,
        items: items,
      ),
    );
  }
}

/// Métodos de pago (se cargan aparte, solo cuando se llega al pago).
final paymentMethodsProvider =
FutureProvider<List<PaymentMethodEntity>>((ref) async {
  final result = await ref.read(_getPaymentMethodsUseCaseProvider)(const NoParams());
  return result.fold((failure) => throw failure, (methods) => methods);
});