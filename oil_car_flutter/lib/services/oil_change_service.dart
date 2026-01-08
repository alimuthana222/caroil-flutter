import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:oil_finder/models/oil_change_record.dart';
import 'package:oil_finder/services/notification_service.dart';
import 'package:oil_finder/services/supabase_auth_service.dart';

class OilChangeService {
  static final _client = Supabase.instance.client;

  // Helper method to get current user ID
  static String? get _currentUserId => SupabaseAuthService.currentUser?.id;

  // Add a new oil change record
  static Future<OilChangeRecord?> addOilChangeRecord(
      OilChangeRecord record,
      ) async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final recordData = record.toJson();
      recordData['user_id'] = userId; // Add user context

      final response = await _client
          .from('oil_change_records')
          .insert(recordData)
          .select()
          .single();

      final newRecord = OilChangeRecord.fromJson(response);

      // Schedule notification for next oil change
      await NotificationService.scheduleOilChangeReminder(newRecord);

      return newRecord;
    } catch (e) {
      print('Error adding oil change record: $e');
      return null;
    }
  }

  // Get all oil change records for current user
  static Future<List<OilChangeRecord>> getOilChangeRecords({
    String? vehicleMake,
    String? vehicleModel,
    int? vehicleYear,
    String? vehicleVin,
  }) async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        return [];
      }

      var query = _client
          .from('oil_change_records')
          .select()
          .eq('user_id', userId); // Filter by user

      if (vehicleMake != null) {
        query = query.eq('vehicle_make', vehicleMake);
      }
      if (vehicleModel != null) {
        query = query.eq('vehicle_model', vehicleModel);
      }
      if (vehicleYear != null) {
        query = query.eq('vehicle_year', vehicleYear);
      }
      if (vehicleVin != null) {
        query = query.eq('vehicle_vin', vehicleVin);
      }

      final response = await query.order('change_date', ascending: false);

      return (response as List)
          .map((item) => OilChangeRecord.fromJson(item))
          .toList();
    } catch (e) {
      print('Error getting oil change records: $e');
      return [];
    }
  }

  // Get the latest oil change record for a vehicle
  static Future<OilChangeRecord?> getLatestOilChangeRecord({
    required String vehicleMake,
    required String vehicleModel,
    required int vehicleYear,
    String? vehicleVin,
  }) async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        return null;
      }

      var query = _client
          .from('oil_change_records')
          .select()
          .eq('user_id', userId)
          .eq('vehicle_make', vehicleMake)
          .eq('vehicle_model', vehicleModel)
          .eq('vehicle_year', vehicleYear);

      if (vehicleVin != null) {
        query = query.eq('vehicle_vin', vehicleVin);
      }

      final response = await query
          .order('change_date', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response != null) {
        return OilChangeRecord.fromJson(response);
      }
      return null;
    } catch (e) {
      print('Error getting latest oil change record: $e');
      return null;
    }
  }

  // Update an oil change record
  static Future<OilChangeRecord?> updateOilChangeRecord(
      String id,
      OilChangeRecord record,
      ) async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _client
          .from('oil_change_records')
          .update(record.toJson())
          .eq('id', id)
          .eq('user_id', userId) // Ensure user owns the record
          .select()
          .single();

      final updatedRecord = OilChangeRecord.fromJson(response);

      // Update notification
      await NotificationService.cancelNotification(id);
      await NotificationService.scheduleOilChangeReminder(updatedRecord);

      return updatedRecord;
    } catch (e) {
      print('Error updating oil change record: $e');
      return null;
    }
  }

  // Delete an oil change record
  static Future<bool> deleteOilChangeRecord(String id) async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        return false;
      }

      await _client
          .from('oil_change_records')
          .delete()
          .eq('id', id)
          .eq('user_id', userId); // Ensure user owns the record

      // Cancel related notifications
      await NotificationService.cancelNotification(id);

      return true;
    } catch (e) {
      print('Error deleting oil change record: $e');
      return false;
    }
  }

  // Calculate next oil change date based on standard intervals
  static DateTime calculateNextOilChangeDate(
      DateTime lastChangeDate, {
        int intervalMonths = 6,
      }) {
    return DateTime(
      lastChangeDate.year,
      lastChangeDate.month + intervalMonths,
      lastChangeDate.day,
    );
  }

  // Calculate next oil change mileage
  static int calculateNextOilChangeMileage(
      int currentMileage, {
        int intervalMiles = 5000,
      }) {
    return currentMileage + intervalMiles;
  }

  // Get overdue oil changes for current user
  static Future<List<OilChangeRecord>> getOverdueOilChanges() async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        return [];
      }

      final now = DateTime.now();
      final response = await _client
          .from('oil_change_records')
          .select()
          .eq('user_id', userId)
          .lt('next_due_date', now.toIso8601String().split('T')[0])
          .order('next_due_date', ascending: true);

      return (response as List)
          .map((item) => OilChangeRecord.fromJson(item))
          .toList();
    } catch (e) {
      print('Error getting overdue oil changes: $e');
      return [];
    }
  }

  // Get upcoming oil changes (due within 30 days) for current user
  static Future<List<OilChangeRecord>> getUpcomingOilChanges() async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        return [];
      }

      final now = DateTime.now();
      final futureDate = now.add(Duration(days: 30));

      final response = await _client
          .from('oil_change_records')
          .select()
          .eq('user_id', userId)
          .gte('next_due_date', now.toIso8601String().split('T')[0])
          .lte('next_due_date', futureDate.toIso8601String().split('T')[0])
          .order('next_due_date', ascending: true);

      return (response as List)
          .map((item) => OilChangeRecord.fromJson(item))
          .toList();
    } catch (e) {
      print('Error getting upcoming oil changes: $e');
      return [];
    }
  }
}