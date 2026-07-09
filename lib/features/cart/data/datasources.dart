import '../../../core/error.dart';
import 'fixtures.dart';
import 'models.dart';

abstract class CartLocalDataSource {
  Future<List<CartItemModel>> getItems();
  Future<List<CartItemModel>> addItem(CartItemModel item);
  Future<List<CartItemModel>> removeItem(String id);
  Future<List<CartItemModel>> updateQuantity(String id, int quantity);
  Future<List<CartItemModel>> clear();
  Future<List<PaymentMethodModel>> getPaymentMethods();
}

/// Carrito en memoria: la lista vive mientras la app esté abierta.
/// Es la única fuente de verdad por ahora; con FastAPI se reemplaza el cuerpo
/// de cada método por llamadas al backend, sin tocar dominio ni UI.
class CartLocalDataSourceImpl implements CartLocalDataSource {
  final List<CartItemModel> _items = [];

  @override
  Future<List<CartItemModel>> getItems() async {
    return List.of(_items);
  }

  @override
  Future<List<CartItemModel>> addItem(CartItemModel item) async {
    try {
      final index = _items.indexWhere((e) => e.id == item.id);
      if (index >= 0) {
        // Ya está en el carrito: aumenta la cantidad en vez de duplicar.
        final existing = _items[index];
        _items[index] = existing.copyModelWith(
          quantity: existing.quantity + item.quantity,
        );
      } else {
        _items.add(item);
      }
      return List.of(_items);
    } catch (e) {
      throw ServerFailure('Error al agregar al carrito: $e');
    }
  }

  @override
  Future<List<CartItemModel>> removeItem(String id) async {
    try {
      _items.removeWhere((e) => e.id == id);
      return List.of(_items);
    } catch (e) {
      throw ServerFailure('Error al quitar del carrito: $e');
    }
  }

  @override
  Future<List<CartItemModel>> updateQuantity(String id, int quantity) async {
    try {
      final index = _items.indexWhere((e) => e.id == id);
      if (index >= 0) {
        if (quantity <= 0) {
          _items.removeAt(index);
        } else {
          _items[index] = _items[index].copyModelWith(quantity: quantity);
        }
      }
      return List.of(_items);
    } catch (e) {
      throw ServerFailure('Error al actualizar la cantidad: $e');
    }
  }

  @override
  Future<List<CartItemModel>> clear() async {
    _items.clear();
    return List.of(_items);
  }

  @override
  Future<List<PaymentMethodModel>> getPaymentMethods() async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return List.of(CartFixtures.mockPaymentMethods);
    } catch (e) {
      throw ServerFailure('Error al cargar los métodos de pago: $e');
    }
  }
}