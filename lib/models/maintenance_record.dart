import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'maintenance_record.g.dart';

@JsonSerializable()
class MaintenanceRecord extends Equatable {
  final String id;
  final String vehicleId;
  final String vin;
  final String serviceType; // Oil Change, Filter Change, etc.
  final DateTime serviceDate;
  final int mileageAtService;
  final String oilTypeUsed;
  final double oilQuantity;
  final String filterUsed;
  final String serviceLocation;
  final double cost;
  final String currency;
  final String? notes;
  final Map<String, dynamic> additionalData;
  final DateTime createdAt;

  const MaintenanceRecord({
    required this.id,
    required this.vehicleId,
    required this.vin,
    required this.serviceType,
    required this.serviceDate,
    required this.mileageAtService,
    required this.oilTypeUsed,
    required this.oilQuantity,
    required this.filterUsed,
    required this.serviceLocation,
    required this.cost,
    required this.currency,
    this.notes,
    required this.additionalData,
    required this.createdAt,
  });

  factory MaintenanceRecord.fromJson(Map<String, dynamic> json) =>
      _$MaintenanceRecordFromJson(json);

  Map<String, dynamic> toJson() => _$MaintenanceRecordToJson(this);

  @override
  List<Object?> get props => [
        id,
        vehicleId,
        vin,
        serviceType,
        serviceDate,
        mileageAtService,
        oilTypeUsed,
        oilQuantity,
        filterUsed,
        serviceLocation,
        cost,
        currency,
        notes,
        additionalData,
        createdAt,
      ];

  String get serviceDateArabic {
    final months = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
    return '${serviceDate.day} ${months[serviceDate.month - 1]} ${serviceDate.year}';
  }

  String get costFormatted => '$cost $currency';
}