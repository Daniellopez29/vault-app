import 'package:equatable/equatable.dart';

/// Estado de la cuenta de Stripe Connect del vendedor. Sin
/// `chargesEnabled`, `payment/` rechaza cualquier orden hacia este
/// vendedor (`ErrSellerNotOnboarded` en `CreateOrderUseCase.go`) -- Stripe
/// no tiene a dónde transferirle el pago liberado si no completó su
/// registro.
class ConnectStatusEntity extends Equatable {
  final bool chargesEnabled;

  const ConnectStatusEntity({required this.chargesEnabled});

  @override
  List<Object?> get props => [chargesEnabled];
}
