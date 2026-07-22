import '../domain/entities.dart';

class SubscriptionPlanModel extends SubscriptionPlan {
  const SubscriptionPlanModel({
    required super.id,
    required super.name,
    required super.price,
    required super.maxAds,
    required super.targetSections,
    required super.commissionRate,
  });

  /// Decodifica `PlanResponse` de `GET /subscriptions/plans`.
  factory SubscriptionPlanModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlanModel(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price_mxn'] as num).toDouble(),
      maxAds: json['max_ads'] as int,
      targetSections: List<String>.from(json['target_sections'] as List? ?? const []),
      commissionRate: (json['commission_rate'] as num).toDouble(),
    );
  }
}

class SubscriptionStatusModel extends SubscriptionStatus {
  const SubscriptionStatusModel({
    required super.id,
    required super.planId,
    required super.status,
    required super.currentPeriodEnd,
  });

  /// Decodifica `SubscriptionResponse` de `GET /subscriptions/me`.
  factory SubscriptionStatusModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionStatusModel(
      id: json['id'] as String,
      planId: json['plan_id'] as String,
      status: json['status'] as String,
      currentPeriodEnd: DateTime.parse(json['current_period_end'] as String),
    );
  }
}
