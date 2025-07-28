import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'oil_specification.g.dart';

@JsonSerializable()
class OilSpecification extends Equatable {
  final String id;
  final String vehicleId;
  final String oilType; // 0W-20, 5W-30, etc.
  final String viscosityGrade;
  final double capacityWithFilter; // Liters
  final double capacityWithoutFilter; // Liters
  final String recommendedBrand;
  final List<String> alternativeBrands;
  final int changeIntervalKm;
  final int changeIntervalMonths;
  final String filterPartNumber;
  final String drainPlugTorque;
  final String oilSpecStandard; // API, ACEA, etc.
  final Map<String, dynamic> additionalSpecs;
  final DateTime createdAt;
  final DateTime updatedAt;

  const OilSpecification({
    required this.id,
    required this.vehicleId,
    required this.oilType,
    required this.viscosityGrade,
    required this.capacityWithFilter,
    required this.capacityWithoutFilter,
    required this.recommendedBrand,
    required this.alternativeBrands,
    required this.changeIntervalKm,
    required this.changeIntervalMonths,
    required this.filterPartNumber,
    required this.drainPlugTorque,
    required this.oilSpecStandard,
    required this.additionalSpecs,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OilSpecification.fromJson(Map<String, dynamic> json) =>
      _$OilSpecificationFromJson(json);

  Map<String, dynamic> toJson() => _$OilSpecificationToJson(this);

  @override
  List<Object?> get props => [
        id,
        vehicleId,
        oilType,
        viscosityGrade,
        capacityWithFilter,
        capacityWithoutFilter,
        recommendedBrand,
        alternativeBrands,
        changeIntervalKm,
        changeIntervalMonths,
        filterPartNumber,
        drainPlugTorque,
        oilSpecStandard,
        additionalSpecs,
        createdAt,
        updatedAt,
      ];

  String get capacityWithFilterArabic => '${capacityWithFilter.toStringAsFixed(1)} لتر (مع الفلتر)';
  String get capacityWithoutFilterArabic => '${capacityWithoutFilter.toStringAsFixed(1)} لتر (بدون فلتر)';
  String get changeIntervalArabic => '$changeIntervalKm كيلومتر أو $changeIntervalMonths أشهر';
}