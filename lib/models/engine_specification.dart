import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'engine_specification.g.dart';

@JsonSerializable()
class EngineSpecification extends Equatable {
  final String id;
  final String vehicleId;
  final String engineCode;
  final String engineFamily;
  final int cylinders;
  final String configuration; // V, Inline, Boxer, etc.
  final double displacement; // Liters
  final int horsepower;
  final int torque;
  final String fuelSystem; // Direct Injection, Port Injection, etc.
  final String compressionRatio;
  final String valveTrain; // DOHC, SOHC, etc.
  final bool turboCharged;
  final bool superCharged;
  final List<String> compatibleOilTypes;
  final Map<String, dynamic> technicalSpecs;
  final DateTime createdAt;
  final DateTime updatedAt;

  const EngineSpecification({
    required this.id,
    required this.vehicleId,
    required this.engineCode,
    required this.engineFamily,
    required this.cylinders,
    required this.configuration,
    required this.displacement,
    required this.horsepower,
    required this.torque,
    required this.fuelSystem,
    required this.compressionRatio,
    required this.valveTrain,
    this.turboCharged = false,
    this.superCharged = false,
    required this.compatibleOilTypes,
    required this.technicalSpecs,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EngineSpecification.fromJson(Map<String, dynamic> json) =>
      _$EngineSpecificationFromJson(json);

  Map<String, dynamic> toJson() => _$EngineSpecificationToJson(this);

  @override
  List<Object?> get props => [
        id,
        vehicleId,
        engineCode,
        engineFamily,
        cylinders,
        configuration,
        displacement,
        horsepower,
        torque,
        fuelSystem,
        compressionRatio,
        valveTrain,
        turboCharged,
        superCharged,
        compatibleOilTypes,
        technicalSpecs,
        createdAt,
        updatedAt,
      ];

  String get engineDescription {
    final forced = turboCharged ? 'Turbo' : (superCharged ? 'Supercharged' : 'Natural');
    return '${displacement}L $configuration-$cylinders $forced $engineCode';
  }

  String get engineDescriptionArabic {
    final forced = turboCharged ? 'تيربو' : (superCharged ? 'سوبرتشارج' : 'طبيعي');
    return '${displacement} لتر $cylinders سلندر $forced - $engineCode';
  }
}