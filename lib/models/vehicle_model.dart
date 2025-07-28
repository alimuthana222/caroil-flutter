import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'vehicle_model.g.dart';

@JsonSerializable()
class VehicleModel extends Equatable {
  final String id;
  final String vin;
  final String make;
  final String model;
  final int year;
  final String engineType;
  final double engineDisplacement;
  final String transmission;
  final String fuelType;
  final String region; // USA, Middle East, China
  final bool isModified;
  final String? modifications;
  final DateTime createdAt;
  final DateTime updatedAt;

  const VehicleModel({
    required this.id,
    required this.vin,
    required this.make,
    required this.model,
    required this.year,
    required this.engineType,
    required this.engineDisplacement,
    required this.transmission,
    required this.fuelType,
    required this.region,
    this.isModified = false,
    this.modifications,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) =>
      _$VehicleModelFromJson(json);

  Map<String, dynamic> toJson() => _$VehicleModelToJson(this);

  @override
  List<Object?> get props => [
        id,
        vin,
        make,
        model,
        year,
        engineType,
        engineDisplacement,
        transmission,
        fuelType,
        region,
        isModified,
        modifications,
        createdAt,
        updatedAt,
      ];

  VehicleModel copyWith({
    String? id,
    String? vin,
    String? make,
    String? model,
    int? year,
    String? engineType,
    double? engineDisplacement,
    String? transmission,
    String? fuelType,
    String? region,
    bool? isModified,
    String? modifications,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VehicleModel(
      id: id ?? this.id,
      vin: vin ?? this.vin,
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      engineType: engineType ?? this.engineType,
      engineDisplacement: engineDisplacement ?? this.engineDisplacement,
      transmission: transmission ?? this.transmission,
      fuelType: fuelType ?? this.fuelType,
      region: region ?? this.region,
      isModified: isModified ?? this.isModified,
      modifications: modifications ?? this.modifications,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}