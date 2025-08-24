import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'user_vehicle.g.dart';

@JsonSerializable()
class UserVehicle extends Equatable {
  final String id;
  final String userId;
  final String vehicleId;
  final String? nickname;
  final int? purchaseYear;
  final int currentMileage;
  final bool isPrimary;
  final String? color;
  final String? licensePlate;
  final Map<String, dynamic>? customSettings;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const UserVehicle({
    required this.id,
    required this.userId,
    required this.vehicleId,
    this.nickname,
    this.purchaseYear,
    required this.currentMileage,
    this.isPrimary = false,
    this.color,
    this.licensePlate,
    this.customSettings,
    required this.createdAt,
    this.updatedAt,
  });

  factory UserVehicle.fromJson(Map<String, dynamic> json) => _$UserVehicleFromJson(json);
  Map<String, dynamic> toJson() => _$UserVehicleToJson(this);

  UserVehicle copyWith({
    String? id,
    String? userId,
    String? vehicleId,
    String? nickname,
    int? purchaseYear,
    int? currentMileage,
    bool? isPrimary,
    String? color,
    String? licensePlate,
    Map<String, dynamic>? customSettings,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserVehicle(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      vehicleId: vehicleId ?? this.vehicleId,
      nickname: nickname ?? this.nickname,
      purchaseYear: purchaseYear ?? this.purchaseYear,
      currentMileage: currentMileage ?? this.currentMileage,
      isPrimary: isPrimary ?? this.isPrimary,
      color: color ?? this.color,
      licensePlate: licensePlate ?? this.licensePlate,
      customSettings: customSettings ?? this.customSettings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    vehicleId,
    nickname,
    purchaseYear,
    currentMileage,
    isPrimary,
    color,
    licensePlate,
    customSettings,
    createdAt,
    updatedAt,
  ];
}