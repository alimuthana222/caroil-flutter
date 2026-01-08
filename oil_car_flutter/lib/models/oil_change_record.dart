class OilChangeRecord {
  final String? id;
  final String vehicleMake;
  final String vehicleModel;
  final int vehicleYear;
  final String? vehicleVin;
  final DateTime changeDate;
  final int? mileage;
  final String? oilType;
  final double? oilQuantity;
  final DateTime? nextDueDate;
  final int? nextDueMileage;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  OilChangeRecord({
    this.id,
    required this.vehicleMake,
    required this.vehicleModel,
    required this.vehicleYear,
    this.vehicleVin,
    required this.changeDate,
    this.mileage,
    this.oilType,
    this.oilQuantity,
    this.nextDueDate,
    this.nextDueMileage,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory OilChangeRecord.fromJson(Map<String, dynamic> json) {
    return OilChangeRecord(
      id: json['id']?.toString(),
      vehicleMake: json['vehicle_make'] ?? '',
      vehicleModel: json['vehicle_model'] ?? '',
      vehicleYear: json['vehicle_year'] ?? 0,
      vehicleVin: json['vehicle_vin'],
      changeDate: DateTime.parse(json['change_date']),
      mileage: json['mileage'],
      oilType: json['oil_type'],
      oilQuantity: json['oil_quantity']?.toDouble(),
      nextDueDate: json['next_due_date'] != null
          ? DateTime.parse(json['next_due_date'])
          : null,
      nextDueMileage: json['next_due_mileage'],
      notes: json['notes'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vehicle_make': vehicleMake,
      'vehicle_model': vehicleModel,
      'vehicle_year': vehicleYear,
      'vehicle_vin': vehicleVin,
      'change_date': changeDate.toIso8601String().split('T')[0],
      'mileage': mileage,
      'oil_type': oilType,
      'oil_quantity': oilQuantity,
      'next_due_date': nextDueDate?.toIso8601String().split('T')[0],
      'next_due_mileage': nextDueMileage,
      'notes': notes,
    };
  }

  String get formattedChangeDate {
    return '${changeDate.day}/${changeDate.month}/${changeDate.year}';
  }

  String get formattedNextDueDate {
    if (nextDueDate == null) return 'غير محدد';
    return '${nextDueDate!.day}/${nextDueDate!.month}/${nextDueDate!.year}';
  }

  int get daysUntilNextChange {
    if (nextDueDate == null) return -1;
    return nextDueDate!.difference(DateTime.now()).inDays;
  }

  bool get isOverdue {
    if (nextDueDate == null) return false;
    return DateTime.now().isAfter(nextDueDate!);
  }

  bool get isDueSoon {
    return daysUntilNextChange <= 7 && daysUntilNextChange >= 0;
  }

  String get statusText {
    if (isOverdue) return 'متأخر';
    if (isDueSoon) return 'قريب الموعد';
    return 'في الموعد';
  }
}