import '../domain/entities.dart';

/// Modelo de datos de un plan. Extiende la entidad y sabe construirse desde
/// un mapa (como el que enviará el backend). Cuando llegue FastAPI/Supabase,
/// solo cambia de dónde viene el mapa; la entidad no se entera.
class SubscriptionPlanModel extends SubscriptionPlan {
  const SubscriptionPlanModel({
    required super.id,
    required super.type,
    required super.name,
    required super.price,
    required super.durationDays,
    required super.benefits,
  });

  factory SubscriptionPlanModel.fromMap(Map<String, dynamic> map) {
    return SubscriptionPlanModel(
      id: map['id'] as String,
      type: SubscriptionType.values.byName(map['type'] as String),
      name: map['name'] as String,
      price: (map['price'] as num).toDouble(),
      durationDays: map['durationDays'] as int,
      benefits: List<String>.from(map['benefits'] as List),
    );
  }
}
