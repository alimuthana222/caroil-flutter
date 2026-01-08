import 'package:flutter/material.dart';

class OilReminder {
  final String? id;
  final String userId;
  final String vehicleId;
  final DateTime? lastChangeDate;
  final int? lastChangeMileage;
  final DateTime? nextChangeDate;
  final int? nextChangeMileage;
  final String? oilType;
  final bool reminderEnabled;
  final int notificationDaysBefore;
  final DateTime createdAt;
  final DateTime updatedAt;

  OilReminder({
    this.id,
    required this.userId,
    required this.vehicleId,
    this.lastChangeDate,
    this.lastChangeMileage,
    this.nextChangeDate,
    this.nextChangeMileage,
    this.oilType,
    this.reminderEnabled = true,
    this.notificationDaysBefore = 7,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OilReminder.fromJson(Map<String, dynamic> json) {
    return OilReminder(
      id: json['id'],
      userId: json['user_id'],
      vehicleId: json['vehicle_id'],
      lastChangeDate: json['last_change_date'] != null
          ? DateTime.parse(json['last_change_date'])
          : null,
      lastChangeMileage: json['last_change_mileage'],
      nextChangeDate: json['next_change_date'] != null
          ? DateTime.parse(json['next_change_date'])
          : null,
      nextChangeMileage: json['next_change_mileage'],
      oilType: json['oil_type'],
      reminderEnabled: json['reminder_enabled'] ?? true,
      notificationDaysBefore: json['notification_days_before'] ?? 7,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'vehicle_id': vehicleId,
      'last_change_date': lastChangeDate?.toIso8601String().split('T')[0],
      'last_change_mileage': lastChangeMileage,
      'next_change_date': nextChangeDate?.toIso8601String().split('T')[0],
      'next_change_mileage': nextChangeMileage,
      'oil_type': oilType,
      'reminder_enabled': reminderEnabled,
      'notification_days_before': notificationDaysBefore,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  bool get isOverdue {
    if (nextChangeDate != null) {
      return DateTime.now().isAfter(nextChangeDate!);
    }
    return false;
  }

  bool get isDueSoon {
    if (nextChangeDate != null) {
      final daysUntilDue = nextChangeDate!.difference(DateTime.now()).inDays;
      return daysUntilDue <= notificationDaysBefore && daysUntilDue >= 0;
    }
    return false;
  }

  bool get isDueToday {
    if (nextChangeDate != null) {
      final today = DateTime.now();
      final dueDate = nextChangeDate!;
      return today.year == dueDate.year &&
          today.month == dueDate.month &&
          today.day == dueDate.day;
    }
    return false;
  }

  String get statusText {
    if (isOverdue) return 'متأخر';
    if (isDueToday) return 'مستحق اليوم';
    if (isDueSoon) return 'مستحق قريباً';
    return 'جيد';
  }

  Color get statusColor {
    if (isOverdue) return Colors.red;
    if (isDueToday) return Colors.orange;
    if (isDueSoon) return Colors.amber;
    return Colors.green;
  }

  IconData get statusIcon {
    if (isOverdue) return Icons.error;
    if (isDueToday) return Icons.warning;
    if (isDueSoon) return Icons.schedule;
    return Icons.check_circle;
  }

  String get formattedLastChangeDate {
    if (lastChangeDate == null) return 'غير محدد';
    return '${lastChangeDate!.day}/${lastChangeDate!.month}/${lastChangeDate!.year}';
  }

  String get formattedNextChangeDate {
    if (nextChangeDate == null) return 'غير محدد';
    return '${nextChangeDate!.day}/${nextChangeDate!.month}/${nextChangeDate!.year}';
  }

  String get formattedLastChangeMileage {
    if (lastChangeMileage == null) return 'غير محدد';
    return '${lastChangeMileage!.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} كم';
  }

  String get formattedNextChangeMileage {
    if (nextChangeMileage == null) return 'غير محدد';
    return '${nextChangeMileage!.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} كم';
  }

  String get formattedOilType {
    return oilType ?? 'غير محدد';
  }

  int get daysUntilDue {
    if (nextChangeDate == null) return -1;
    return nextChangeDate!.difference(DateTime.now()).inDays;
  }

  String get daysUntilDueText {
    final days = daysUntilDue;
    if (days < 0) return 'متأخر ${-days} يوم';
    if (days == 0) return 'اليوم';
    if (days == 1) return 'غداً';
    if (days <= 7) return 'خلال $days أيام';
    if (days <= 30) return 'خلال ${(days / 7).round()} أسابيع';
    return 'خلال ${(days / 30).round()} شهر';
  }

  OilReminder copyWith({
    String? id,
    String? userId,
    String? vehicleId,
    DateTime? lastChangeDate,
    int? lastChangeMileage,
    DateTime? nextChangeDate,
    int? nextChangeMileage,
    String? oilType,
    bool? reminderEnabled,
    int? notificationDaysBefore,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OilReminder(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      vehicleId: vehicleId ?? this.vehicleId,
      lastChangeDate: lastChangeDate ?? this.lastChangeDate,
      lastChangeMileage: lastChangeMileage ?? this.lastChangeMileage,
      nextChangeDate: nextChangeDate ?? this.nextChangeDate,
      nextChangeMileage: nextChangeMileage ?? this.nextChangeMileage,
      oilType: oilType ?? this.oilType,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      notificationDaysBefore: notificationDaysBefore ?? this.notificationDaysBefore,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Calculate next oil change based on last change
  static DateTime calculateNextChangeDate(DateTime lastChangeDate, int monthsInterval) {
    return DateTime(
      lastChangeDate.year,
      lastChangeDate.month + monthsInterval,
      lastChangeDate.day,
    );
  }

  // Calculate next oil change mileage
  static int calculateNextChangeMileage(int lastChangeMileage, int mileageInterval) {
    return lastChangeMileage + mileageInterval;
  }

  // Create a quick reminder with default intervals
  static OilReminder createQuick({
    required String userId,
    required String vehicleId,
    required DateTime lastChangeDate,
    required int lastChangeMileage,
    String? oilType,
    int monthsInterval = 6,
    int mileageInterval = 5000,
  }) {
    final now = DateTime.now();
    final nextDate = calculateNextChangeDate(lastChangeDate, monthsInterval);
    final nextMileage = calculateNextChangeMileage(lastChangeMileage, mileageInterval);

    return OilReminder(
      userId: userId,
      vehicleId: vehicleId,
      lastChangeDate: lastChangeDate,
      lastChangeMileage: lastChangeMileage,
      nextChangeDate: nextDate,
      nextChangeMileage: nextMileage,
      oilType: oilType,
      reminderEnabled: true,
      notificationDaysBefore: 7,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  String toString() {
    return 'OilReminder(id: $id, vehicleId: $vehicleId, nextChangeDate: $nextChangeDate, status: $statusText)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is OilReminder &&
        other.id == id &&
        other.userId == userId &&
        other.vehicleId == vehicleId &&
        other.nextChangeDate == nextChangeDate;
  }

  @override
  int get hashCode {
    return Object.hash(id, userId, vehicleId, nextChangeDate);
  }
}