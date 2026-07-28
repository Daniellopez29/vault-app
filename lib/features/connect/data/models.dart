import '../domain/entities.dart';

class ConnectStatusModel extends ConnectStatusEntity {
  const ConnectStatusModel({required super.chargesEnabled});

  /// Decodifica el objeto `account` de `GET /connect/status` (ver
  /// `ConnectAccountResponse.go`).
  factory ConnectStatusModel.fromJson(Map<String, dynamic> json) {
    return ConnectStatusModel(chargesEnabled: json['charges_enabled'] as bool? ?? false);
  }
}
