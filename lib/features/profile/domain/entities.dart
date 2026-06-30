import 'package:equatable/equatable.dart';

class AssetEntity extends Equatable {
  final String id;
  final String brand;
  final String name;
  final String imageUrl;
  final DateTime acquisitionDate;
  final double originalPrice;
  final String origin;
  final String size;
  final String condition;
  final int servicesCount;
  final int restorationsCount;
  final bool isVerified;

  const AssetEntity({
    required this.id,
    required this.brand,
    required this.name,
    required this.imageUrl,
    required this.acquisitionDate,
    required this.originalPrice,
    required this.origin,
    required this.size,
    required this.condition,
    required this.servicesCount,
    required this.restorationsCount,
    this.isVerified = false,
  });

  @override
  List<Object?> get props => [
    id,
    brand,
    name,
    imageUrl,
    acquisitionDate,
    originalPrice,
    origin,
    size,
    condition,
    servicesCount,
    restorationsCount,
    isVerified,
  ];
}