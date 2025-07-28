import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'notification_model.g.dart';

@JsonSerializable()
class NotificationModel extends Equatable {
  final String id;
  final String userId;
  final String vehicleId;
  final String type; // oil_change, filter_change, general_maintenance, etc.
  final String title;
  final String message;
  final DateTime scheduledDate;
  final bool isRead;
  final bool isCompleted;
  final Map<String, dynamic>? data;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.vehicleId,
    required this.type,
    required this.title,
    required this.message,
    required this.scheduledDate,
    this.isRead = false,
    this.isCompleted = false,
    this.data,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) => _$NotificationModelFromJson(json);
  Map<String, dynamic> toJson() => _$NotificationModelToJson(this);

  NotificationModel copyWith({
    String? id,
    String? userId,
    String? vehicleId,
    String? type,
    String? title,
    String? message,
    DateTime? scheduledDate,
    bool? isRead,
    bool? isCompleted,
    Map<String, dynamic>? data,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      vehicleId: vehicleId ?? this.vehicleId,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      isRead: isRead ?? this.isRead,
      isCompleted: isCompleted ?? this.isCompleted,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    vehicleId,
    type,
    title,
    message,
    scheduledDate,
    isRead,
    isCompleted,
    data,
    createdAt,
  ];
}