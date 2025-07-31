import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:car_oil/models/vehicle.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VinService {
  static const String _nhtsaBaseUrl = 'https://vpic.nhtsa.dot.gov/api/vehicles';

  static Future<Vehicle?> lookupVin(String vin) async {
    Vehicle? vehicle;

    try {
      print('=== VIN LOOKUP STARTED ===');
      print('Searching for VIN: $vin');

      // Always try fresh lookup first, then fall back to cache
      vehicle = await _lookupVinNHTSA(vin);

      if (vehicle != null && vehicle.make != null) {
        print('✅ Fresh VIN lookup successful');
        print('Vehicle found: ${vehicle.toJson()}');
        await _cacheVinResult(vin, vehicle);
        return vehicle;
      }

      // If fresh lookup fails, try cache
      print('❌ Fresh lookup failed, trying cache...');
      vehicle = await _getCachedVinResult(vin);
      if (vehicle != null) {
        print('✅ Using cached VIN result for: $vin');
        print('Cached vehicle: ${vehicle.toJson()}');
        return vehicle;
      }

      print('❌ No VIN data found in cache either');

    } catch (e) {
      print('❌ VIN Lookup Error: $e');

      // Try cache as fallback on error
      vehicle = await _getCachedVinResult(vin);
      if (vehicle != null) {
        print('✅ Using cached result after error');
        return vehicle;
      }
    }

    print('=== VIN LOOKUP FAILED ===');
    return null;
  }

  // NHTSA API (Completely Free & Unlimited)
  static Future<Vehicle?> _lookupVinNHTSA(String vin) async {
    try {
      final url = '$_nhtsaBaseUrl/DecodeVin/$vin?format=json';
      print('🌐 Calling NHTSA API: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'CarOilApp/1.0',
          'Accept': 'application/json',
        },
      ).timeout(Duration(seconds: 15));

      print('📡 NHTSA Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['Results'] as List;

        print('📋 NHTSA returned ${results.length} results');

        if (results.isNotEmpty) {
          Map<String, dynamic> vehicleData = {};

          // Extract all relevant vehicle information
          for (var result in results) {
            final variable = result['Variable'];
            final value = result['Value'];

            if (value != null &&
                value != 'Not Applicable' &&
                value != '' &&
                value != 'null' &&
                value.toString().trim().isNotEmpty) {
              vehicleData[variable] = value;
              print('  $variable: $value');
            }
          }

          // Map NHTSA fields to our Vehicle model
          final vehicle = Vehicle(
            make: _getValueFromData(vehicleData, [
              'Make',
              'Manufacturer Name'
            ]),
            model: _getValueFromData(vehicleData, [
              'Model'
            ]),
            year: _getValueFromData(vehicleData, [
              'Model Year'
            ])?.toString(),
            trim: _getValueFromData(vehicleData, [
              'Trim',
              'Series'
            ]),
            engineSize: _getValueFromData(vehicleData, [
              'Displacement (L)',
              'Engine Displacement (L)',
              'Displacement (CC)',
              'Displacement (CI)'
            ]),
            engineType: _getEngineInfo(vehicleData),
            vin: vin,
          );

          print('🚗 Created vehicle object:');
          print('  Make: ${vehicle.make}');
          print('  Model: ${vehicle.model}');
          print('  Year: ${vehicle.year}');
          print('  Trim: ${vehicle.trim}');
          print('  Engine: ${vehicle.engineSize}');

          return vehicle;
        }
      } else {
        print('❌ NHTSA API Error: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('❌ NHTSA API Exception: $e');
    }

    return null;
  }

  // Helper method to get value from multiple possible keys
  static String? _getValueFromData(Map<String, dynamic> data, List<String> keys) {
    for (String key in keys) {
      if (data[key] != null && data[key].toString().trim().isNotEmpty) {
        return data[key].toString().trim();
      }
    }
    return null;
  }

  // Helper method to combine engine information
  static String? _getEngineInfo(Map<String, dynamic> data) {
    List<String> engineParts = [];

    // Engine configuration
    final config = _getValueFromData(data, [
      'Engine Configuration',
      'Engine Type'
    ]);
    if (config != null) engineParts.add(config);

    // Number of cylinders
    final cylinders = _getValueFromData(data, [
      'Engine Number of Cylinders',
      'Number of Cylinders'
    ]);
    if (cylinders != null) engineParts.add('${cylinders} Cyl');

    // Fuel type
    final fuelType = _getValueFromData(data, [
      'Fuel Type - Primary',
      'Primary Fuel Type'
    ]);
    if (fuelType != null) engineParts.add(fuelType);

    return engineParts.isNotEmpty ? engineParts.join(' - ') : null;
  }

  // Enhanced VIN Validation
  static bool isValidVin(String vin) {
    if (vin.length != 17) return false;

    // Remove spaces and convert to uppercase
    vin = vin.replaceAll(' ', '').toUpperCase();

    // Check for invalid characters (I, O, Q are not allowed in VINs)
    final invalidChars = RegExp(r'[IOQ]');
    if (invalidChars.hasMatch(vin)) return false;

    // Check valid VIN format (only alphanumeric, no I, O, Q)
    final validFormat = RegExp(r'^[A-HJ-NPR-Z0-9]{17}$');
    if (!validFormat.hasMatch(vin)) return false;

    // Validate checksum (9th digit)
    return _validateVinChecksum(vin);
  }

  // VIN Checksum Validation Algorithm
  static bool _validateVinChecksum(String vin) {
    // Weights for each position (except 9th which is check digit)
    const weights = [8, 7, 6, 5, 4, 3, 2, 10, 0, 9, 8, 7, 6, 5, 4, 3, 2];

    // Values for each character
    const values = {
      'A': 1, 'B': 2, 'C': 3, 'D': 4, 'E': 5, 'F': 6, 'G': 7, 'H': 8,
      'J': 1, 'K': 2, 'L': 3, 'M': 4, 'N': 5, 'P': 7, 'R': 9, 'S': 2,
      'T': 3, 'U': 4, 'V': 5, 'W': 6, 'X': 7, 'Y': 8, 'Z': 9,
      '0': 0, '1': 1, '2': 2, '3': 3, '4': 4, '5': 5, '6': 6, '7': 7, '8': 8, '9': 9
    };

    int sum = 0;
    for (int i = 0; i < 17; i++) {
      if (i == 8) continue; // Skip check digit position (9th character)

      final char = vin[i];
      final value = values[char];
      if (value == null) return false; // Invalid character

      sum += value * weights[i];
    }

    final remainder = sum % 11;
    final expectedCheckDigit = remainder == 10 ? 'X' : remainder.toString();

    return vin[8] == expectedCheckDigit;
  }

  // Cache Management
  static Future<void> _cacheVinResult(String vin, Vehicle vehicle) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = 'vin_cache_$vin';
      final vehicleJson = json.encode(vehicle.toJson());

      await prefs.setString(cacheKey, vehicleJson);
      await prefs.setInt('${cacheKey}_timestamp', DateTime.now().millisecondsSinceEpoch);

      print('💾 VIN cached: $vin');
    } catch (e) {
      print('❌ Cache Error: $e');
    }
  }

  static Future<Vehicle?> _getCachedVinResult(String vin) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = 'vin_cache_$vin';
      final cachedData = prefs.getString(cacheKey);
      final timestamp = prefs.getInt('${cacheKey}_timestamp');

      if (cachedData != null && timestamp != null) {
        // Check if cache is still valid (7 days for debugging, normally 30)
        final cacheAge = DateTime.now().millisecondsSinceEpoch - timestamp;
        final validCacheTime = 7 * 24 * 60 * 60 * 1000; // 7 days

        if (cacheAge < validCacheTime) {
          final vehicleData = json.decode(cachedData);
          return Vehicle.fromJson(vehicleData);
        } else {
          // Remove expired cache
          await prefs.remove(cacheKey);
          await prefs.remove('${cacheKey}_timestamp');
          print('🗑️ Removed expired cache for: $vin');
        }
      }
    } catch (e) {
      print('❌ Cache Retrieval Error: $e');
    }

    return null;
  }

  // Utility method to clean VIN input
  static String cleanVin(String vin) {
    return vin.replaceAll(RegExp(r'[^A-Z0-9]'), '').toUpperCase();
  }

  // Clear all cached VIN results
  static Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();

      for (String key in keys) {
        if (key.startsWith('vin_cache_')) {
          await prefs.remove(key);
        }
      }

      print('🗑️ VIN cache cleared');
    } catch (e) {
      print('❌ Cache Clear Error: $e');
    }
  }

  // Get cache statistics
  static Future<Map<String, dynamic>> getCacheStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();

      int cachedVins = 0;
      int totalCacheSize = 0;
      List<String> cachedVinList = [];

      for (String key in keys) {
        if (key.startsWith('vin_cache_') && !key.endsWith('_timestamp')) {
          cachedVins++;
          final vin = key.replaceFirst('vin_cache_', '');
          cachedVinList.add(vin);

          final data = prefs.getString(key);
          if (data != null) {
            totalCacheSize += data.length;
          }
        }
      }

      return {
        'cachedVins': cachedVins,
        'totalCacheSize': totalCacheSize,
        'cacheSizeKB': (totalCacheSize / 1024).toStringAsFixed(2),
        'vinList': cachedVinList,
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }
}