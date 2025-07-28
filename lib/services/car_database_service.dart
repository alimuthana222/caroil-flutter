import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/supabase_config.dart';
import '../models/vehicle_model.dart';
import '../models/oil_specification.dart';
import '../models/engine_specification.dart';
import '../models/maintenance_record.dart';

class CarDatabaseService {
  static const String _nhtsaBaseUrl = 'https://vpic.nhtsa.dot.gov/api/vehicles';

  /// Decode VIN using NHTSA API and store/retrieve from database
  static Future<VehicleModel?> getVehicleByVin(String vin) async {
    try {
      // First check if vehicle exists in our database
      final existingVehicle = await _getVehicleFromDatabase(vin);
      if (existingVehicle != null) {
        return existingVehicle;
      }

      // If not found, decode from NHTSA and store
      final decodedData = await _decodeVinFromNHTSA(vin);
      if (decodedData != null) {
        return await _storeVehicleInDatabase(vin, decodedData);
      }
    } catch (e) {
      print('Error getting vehicle: $e');
    }
    return null;
  }

  /// Get vehicle from Supabase database
  static Future<VehicleModel?> _getVehicleFromDatabase(String vin) async {
    try {
      final response = await SupabaseConfig.client
          .from('vehicles')
          .select()
          .eq('vin', vin)
          .single();

      return VehicleModel.fromJson(response);
    } catch (e) {
      print('Vehicle not found in database: $e');
      return null;
    }
  }

  /// Decode VIN from NHTSA API
  static Future<Map<String, dynamic>?> _decodeVinFromNHTSA(String vin) async {
    try {
      final url = Uri.parse('$_nhtsaBaseUrl/decodevin/$vin?format=json');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final results = decoded['Results'] as List;

        final Map<String, dynamic> vehicleInfo = {};

        for (var item in results) {
          if (item['Value'] != null &&
              item['Value'].toString().isNotEmpty &&
              item['Variable'] != null) {
            vehicleInfo[item['Variable']] = item['Value'];
          }
        }

        return vehicleInfo.isNotEmpty ? vehicleInfo : null;
      }
    } catch (e) {
      print('Error decoding VIN from NHTSA: $e');
    }
    return null;
  }

  /// Store vehicle in database
  static Future<VehicleModel?> _storeVehicleInDatabase(
      String vin, Map<String, dynamic> nhtsaData) async {
    try {
      final now = DateTime.now();
      final region = _determineRegion(vin);

      final vehicleData = {
        'vin': vin,
        'make': nhtsaData['Make'] ?? 'Unknown',
        'model': nhtsaData['Model'] ?? 'Unknown',
        'year': int.tryParse(nhtsaData['Model Year']?.toString() ?? '0') ?? 0,
        'engine_type': nhtsaData['Engine Configuration'] ?? 'Unknown',
        'engine_displacement': double.tryParse(
                nhtsaData['Displacement (L)']?.toString() ?? '0') ??
            0.0,
        'transmission': nhtsaData['Transmission Style'] ?? 'Unknown',
        'fuel_type': nhtsaData['Fuel Type - Primary'] ?? 'Unknown',
        'region': region,
        'is_modified': false,
        'modifications': null,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };

      final response = await SupabaseConfig.client
          .from('vehicles')
          .insert(vehicleData)
          .select()
          .single();

      final vehicle = VehicleModel.fromJson(response);

      // Create engine and oil specifications
      await _createEngineSpecification(vehicle);
      await _createOilSpecification(vehicle);

      return vehicle;
    } catch (e) {
      print('Error storing vehicle: $e');
      return null;
    }
  }

  /// Determine vehicle region based on VIN
  static String _determineRegion(String vin) {
    final firstChar = vin[0];
    if (firstChar.compareTo('1') >= 0 && firstChar.compareTo('5') <= 0) {
      return 'USA';
    } else if (firstChar.compareTo('6') >= 0 && firstChar.compareTo('7') <= 0) {
      return 'Australia';
    } else if (firstChar.compareTo('8') >= 0 && firstChar.compareTo('9') <= 0) {
      return 'South America';
    } else if (firstChar.compareTo('A') >= 0 && firstChar.compareTo('H') <= 0) {
      return 'Africa';
    } else if (firstChar.compareTo('J') >= 0 && firstChar.compareTo('R') <= 0) {
      return 'Asia';
    } else if (firstChar.compareTo('S') >= 0 && firstChar.compareTo('Z') <= 0) {
      return 'Europe';
    } else if (firstChar.compareTo('L') >= 0 && firstChar.compareTo('L') <= 0) {
      return 'China';
    }
    return 'Unknown';
  }

  /// Get oil specification for vehicle
  static Future<OilSpecification?> getOilSpecification(String vehicleId) async {
    try {
      final response = await SupabaseConfig.client
          .from('oil_specifications')
          .select()
          .eq('vehicle_id', vehicleId)
          .single();

      return OilSpecification.fromJson(response);
    } catch (e) {
      print('Error getting oil specification: $e');
      return null;
    }
  }

  /// Get engine specification for vehicle
  static Future<EngineSpecification?> getEngineSpecification(
      String vehicleId) async {
    try {
      final response = await SupabaseConfig.client
          .from('engine_specifications')
          .select()
          .eq('vehicle_id', vehicleId)
          .single();

      return EngineSpecification.fromJson(response);
    } catch (e) {
      print('Error getting engine specification: $e');
      return null;
    }
  }

  /// Get maintenance records for vehicle
  static Future<List<MaintenanceRecord>> getMaintenanceRecords(
      String vehicleId) async {
    try {
      final response = await SupabaseConfig.client
          .from('maintenance_records')
          .select()
          .eq('vehicle_id', vehicleId)
          .order('service_date', ascending: false);

      return (response as List)
          .map((json) => MaintenanceRecord.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting maintenance records: $e');
      return [];
    }
  }

  /// Create engine specification based on vehicle data
  static Future<void> _createEngineSpecification(VehicleModel vehicle) async {
    try {
      final now = DateTime.now();
      final engineSpecs = _getEngineSpecsForVehicle(vehicle);

      final engineData = {
        'vehicle_id': vehicle.id,
        'engine_code': engineSpecs['engineCode'],
        'engine_family': engineSpecs['engineFamily'],
        'cylinders': engineSpecs['cylinders'],
        'configuration': engineSpecs['configuration'],
        'displacement': vehicle.engineDisplacement,
        'horsepower': engineSpecs['horsepower'],
        'torque': engineSpecs['torque'],
        'fuel_system': engineSpecs['fuelSystem'],
        'compression_ratio': engineSpecs['compressionRatio'],
        'valve_train': engineSpecs['valveTrain'],
        'turbo_charged': engineSpecs['turboCharged'],
        'super_charged': engineSpecs['superCharged'],
        'compatible_oil_types': engineSpecs['compatibleOilTypes'],
        'technical_specs': engineSpecs['technicalSpecs'],
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };

      await SupabaseConfig.client
          .from('engine_specifications')
          .insert(engineData);
    } catch (e) {
      print('Error creating engine specification: $e');
    }
  }

  /// Create oil specification based on vehicle data
  static Future<void> _createOilSpecification(VehicleModel vehicle) async {
    try {
      final now = DateTime.now();
      final oilSpecs = _getOilSpecsForVehicle(vehicle);

      final oilData = {
        'vehicle_id': vehicle.id,
        'oil_type': oilSpecs['oilType'],
        'viscosity_grade': oilSpecs['viscosityGrade'],
        'capacity_with_filter': oilSpecs['capacityWithFilter'],
        'capacity_without_filter': oilSpecs['capacityWithoutFilter'],
        'recommended_brand': oilSpecs['recommendedBrand'],
        'alternative_brands': oilSpecs['alternativeBrands'],
        'change_interval_km': oilSpecs['changeIntervalKm'],
        'change_interval_months': oilSpecs['changeIntervalMonths'],
        'filter_part_number': oilSpecs['filterPartNumber'],
        'drain_plug_torque': oilSpecs['drainPlugTorque'],
        'oil_spec_standard': oilSpecs['oilSpecStandard'],
        'additional_specs': oilSpecs['additionalSpecs'],
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };

      await SupabaseConfig.client
          .from('oil_specifications')
          .insert(oilData);
    } catch (e) {
      print('Error creating oil specification: $e');
    }
  }

  /// Get comprehensive engine specifications based on vehicle
  static Map<String, dynamic> _getEngineSpecsForVehicle(VehicleModel vehicle) {
    final make = vehicle.make.toLowerCase();
    final model = vehicle.model.toLowerCase();
    final year = vehicle.year;

    // Toyota specifications
    if (make.contains('toyota')) {
      if (model.contains('camry') && year >= 2018) {
        return {
          'engineCode': '2AR-FE',
          'engineFamily': 'AR Family',
          'cylinders': 4,
          'configuration': 'Inline',
          'horsepower': 203,
          'torque': 184,
          'fuelSystem': 'Port Injection',
          'compressionRatio': '11.0:1',
          'valveTrain': 'DOHC',
          'turboCharged': false,
          'superCharged': false,
          'compatibleOilTypes': ['0W-20', '5W-20'],
          'technicalSpecs': {'redline': 6500, 'idleRpm': 650},
        };
      } else if (model.contains('corolla') && year >= 2020) {
        return {
          'engineCode': '2ZR-FE',
          'engineFamily': 'ZR Family',
          'cylinders': 4,
          'configuration': 'Inline',
          'horsepower': 139,
          'torque': 126,
          'fuelSystem': 'Port Injection',
          'compressionRatio': '10.2:1',
          'valveTrain': 'DOHC',
          'turboCharged': false,
          'superCharged': false,
          'compatibleOilTypes': ['0W-20'],
          'technicalSpecs': {'redline': 6200, 'idleRpm': 600},
        };
      }
    }

    // Honda specifications
    if (make.contains('honda')) {
      if (model.contains('accord') && year >= 2018) {
        return {
          'engineCode': 'K24W7',
          'engineFamily': 'K Series',
          'cylinders': 4,
          'configuration': 'Inline',
          'horsepower': 192,
          'torque': 192,
          'fuelSystem': 'Direct Injection',
          'compressionRatio': '11.1:1',
          'valveTrain': 'DOHC i-VTEC',
          'turboCharged': false,
          'superCharged': false,
          'compatibleOilTypes': ['0W-20'],
          'technicalSpecs': {'redline': 6500, 'idleRpm': 700},
        };
      } else if (model.contains('civic') && year >= 2016) {
        return {
          'engineCode': 'L15B7',
          'engineFamily': 'L Series',
          'cylinders': 4,
          'configuration': 'Inline',
          'horsepower': 174,
          'torque': 162,
          'fuelSystem': 'Direct Injection Turbo',
          'compressionRatio': '10.6:1',
          'valveTrain': 'DOHC i-VTEC',
          'turboCharged': true,
          'superCharged': false,
          'compatibleOilTypes': ['0W-20', '5W-30'],
          'technicalSpecs': {'redline': 6700, 'idleRpm': 650},
        };
      }
    }

    // BMW specifications
    if (make.contains('bmw')) {
      if (model.contains('3 series') || model.contains('320i')) {
        return {
          'engineCode': 'B48B20',
          'engineFamily': 'B48 TwinPower Turbo',
          'cylinders': 4,
          'configuration': 'Inline',
          'horsepower': 255,
          'torque': 295,
          'fuelSystem': 'Direct Injection Turbo',
          'compressionRatio': '11.0:1',
          'valveTrain': 'DOHC Valvetronic',
          'turboCharged': true,
          'superCharged': false,
          'compatibleOilTypes': ['0W-30', '5W-30'],
          'technicalSpecs': {'redline': 7000, 'idleRpm': 650},
        };
      }
    }

    // Mercedes-Benz specifications
    if (make.contains('mercedes')) {
      if (model.contains('c-class') || model.contains('c 300')) {
        return {
          'engineCode': 'M264.920',
          'engineFamily': 'M264 Series',
          'cylinders': 4,
          'configuration': 'Inline',
          'horsepower': 255,
          'torque': 273,
          'fuelSystem': 'Direct Injection Turbo',
          'compressionRatio': '10.5:1',
          'valveTrain': 'DOHC',
          'turboCharged': true,
          'superCharged': false,
          'compatibleOilTypes': ['0W-30', '5W-40'],
          'technicalSpecs': {'redline': 6500, 'idleRpm': 600},
        };
      }
    }

    // Default specifications
    return {
      'engineCode': 'Unknown',
      'engineFamily': 'Standard',
      'cylinders': 4,
      'configuration': 'Inline',
      'horsepower': 150,
      'torque': 150,
      'fuelSystem': 'Port Injection',
      'compressionRatio': '10.0:1',
      'valveTrain': 'DOHC',
      'turboCharged': false,
      'superCharged': false,
      'compatibleOilTypes': ['5W-30'],
      'technicalSpecs': {'redline': 6000, 'idleRpm': 700},
    };
  }

  /// Get comprehensive oil specifications based on vehicle
  static Map<String, dynamic> _getOilSpecsForVehicle(VehicleModel vehicle) {
    final make = vehicle.make.toLowerCase();
    final model = vehicle.model.toLowerCase();
    final year = vehicle.year;

    // Toyota oil specifications
    if (make.contains('toyota')) {
      if (model.contains('camry') && year >= 2018) {
        return {
          'oilType': '0W-20',
          'viscosityGrade': 'SAE 0W-20',
          'capacityWithFilter': 4.4,
          'capacityWithoutFilter': 4.0,
          'recommendedBrand': 'Toyota Genuine Motor Oil',
          'alternativeBrands': ['Mobil 1', 'Castrol GTX', 'Valvoline MaxLife'],
          'changeIntervalKm': 10000,
          'changeIntervalMonths': 12,
          'filterPartNumber': '04152-YZZA1',
          'drainPlugTorque': '30 ft-lbs',
          'oilSpecStandard': 'API SN Plus',
          'additionalSpecs': {'meetsToyotaSpec': 'GF-5', 'synthetic': true},
        };
      } else if (model.contains('corolla')) {
        return {
          'oilType': '0W-20',
          'viscosityGrade': 'SAE 0W-20',
          'capacityWithFilter': 4.2,
          'capacityWithoutFilter': 3.9,
          'recommendedBrand': 'Toyota Genuine Motor Oil',
          'alternativeBrands': ['Mobil 1', 'Castrol GTX'],
          'changeIntervalKm': 10000,
          'changeIntervalMonths': 12,
          'filterPartNumber': '04152-31090',
          'drainPlugTorque': '27 ft-lbs',
          'oilSpecStandard': 'API SN Plus',
          'additionalSpecs': {'meetsToyotaSpec': 'GF-5', 'synthetic': true},
        };
      }
    }

    // Honda oil specifications
    if (make.contains('honda')) {
      if (model.contains('accord')) {
        return {
          'oilType': '0W-20',
          'viscosityGrade': 'SAE 0W-20',
          'capacityWithFilter': 4.4,
          'capacityWithoutFilter': 4.0,
          'recommendedBrand': 'Honda Genuine Motor Oil',
          'alternativeBrands': ['Mobil 1', 'Castrol GTX', 'Valvoline'],
          'changeIntervalKm': 10000,
          'changeIntervalMonths': 12,
          'filterPartNumber': '15400-PLM-A02',
          'drainPlugTorque': '29 ft-lbs',
          'oilSpecStandard': 'API SN',
          'additionalSpecs': {'meetsHondaSpec': 'HTO-06', 'synthetic': true},
        };
      } else if (model.contains('civic')) {
        return {
          'oilType': '0W-20',
          'viscosityGrade': 'SAE 0W-20',
          'capacityWithFilter': 4.2,
          'capacityWithoutFilter': 3.9,
          'recommendedBrand': 'Honda Genuine Motor Oil',
          'alternativeBrands': ['Mobil 1', 'Castrol GTX'],
          'changeIntervalKm': 10000,
          'changeIntervalMonths': 12,
          'filterPartNumber': '15400-PLM-A02',
          'drainPlugTorque': '29 ft-lbs',
          'oilSpecStandard': 'API SN',
          'additionalSpecs': {'meetsHondaSpec': 'HTO-06', 'synthetic': true},
        };
      }
    }

    // BMW oil specifications
    if (make.contains('bmw')) {
      return {
        'oilType': '0W-30',
        'viscosityGrade': 'SAE 0W-30',
        'capacityWithFilter': 5.2,
        'capacityWithoutFilter': 4.8,
        'recommendedBrand': 'BMW TwinPower Turbo Oil',
        'alternativeBrands': ['Shell Helix Ultra', 'Mobil 1', 'Castrol Edge'],
        'changeIntervalKm': 15000,
        'changeIntervalMonths': 12,
        'filterPartNumber': '11427953129',
        'drainPlugTorque': '25 Nm',
        'oilSpecStandard': 'BMW LL-01 FE',
        'additionalSpecs': {'meetsBMWSpec': 'LL-01 FE', 'synthetic': true},
      };
    }

    // Mercedes oil specifications
    if (make.contains('mercedes')) {
      return {
        'oilType': '0W-30',
        'viscosityGrade': 'SAE 0W-30',
        'capacityWithFilter': 6.0,
        'capacityWithoutFilter': 5.5,
        'recommendedBrand': 'Mercedes-Benz Genuine Oil',
        'alternativeBrands': ['Mobil 1', 'Shell Helix Ultra', 'Castrol Edge'],
        'changeIntervalKm': 12000,
        'changeIntervalMonths': 12,
        'filterPartNumber': 'A0001802609',
        'drainPlugTorque': '30 Nm',
        'oilSpecStandard': 'MB 229.71',
        'additionalSpecs': {'meetsMBSpec': 'MB 229.71', 'synthetic': true},
      };
    }

    // Nissan oil specifications
    if (make.contains('nissan')) {
      return {
        'oilType': '5W-30',
        'viscosityGrade': 'SAE 5W-30',
        'capacityWithFilter': 4.5,
        'capacityWithoutFilter': 4.2,
        'recommendedBrand': 'Nissan Genuine Motor Oil',
        'alternativeBrands': ['Valvoline MaxLife', 'Mobil 1', 'Castrol GTX'],
        'changeIntervalKm': 8000,
        'changeIntervalMonths': 6,
        'filterPartNumber': '15208-65F0A',
        'drainPlugTorque': '25 ft-lbs',
        'oilSpecStandard': 'API SN',
        'additionalSpecs': {'meetsNissanSpec': 'DX-1', 'synthetic': false},
      };
    }

    // Default oil specifications
    return {
      'oilType': '5W-30',
      'viscosityGrade': 'SAE 5W-30',
      'capacityWithFilter': 4.5,
      'capacityWithoutFilter': 4.2,
      'recommendedBrand': 'Any Premium Brand',
      'alternativeBrands': ['Mobil 1', 'Castrol GTX', 'Valvoline'],
      'changeIntervalKm': 8000,
      'changeIntervalMonths': 6,
      'filterPartNumber': 'Check Manual',
      'drainPlugTorque': '25 ft-lbs',
      'oilSpecStandard': 'API SN',
      'additionalSpecs': {'synthetic': false},
    };
  }

  /// Add maintenance record
  static Future<bool> addMaintenanceRecord(MaintenanceRecord record) async {
    try {
      await SupabaseConfig.client
          .from('maintenance_records')
          .insert(record.toJson());
      return true;
    } catch (e) {
      print('Error adding maintenance record: $e');
      return false;
    }
  }

  /// Update vehicle modification status
  static Future<bool> updateVehicleModifications(
      String vehicleId, bool isModified, String? modifications) async {
    try {
      await SupabaseConfig.client.from('vehicles').update({
        'is_modified': isModified,
        'modifications': modifications,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', vehicleId);
      return true;
    } catch (e) {
      print('Error updating vehicle modifications: $e');
      return false;
    }
  }
}