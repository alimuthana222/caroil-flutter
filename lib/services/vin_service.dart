import 'dart:convert';
import 'package:http/http.dart' as http;

class VinService {
  static const String _baseUrl = 'https://vpic.nhtsa.dot.gov/api/vehicles';

  static Future<Map<String, dynamic>?> decodeVin(String vin) async {
    try {
      final url = Uri.parse('$_baseUrl/decodevin/$vin?format=json');
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
      print('Error decoding VIN: $e');
    }
    
    return null;
  }

  static Map<String, String> getOilRecommendation(Map<String, dynamic> vehicleInfo) {
    // Extract key vehicle information
    final make = vehicleInfo['Make']?.toString() ?? '';
    final model = vehicleInfo['Model']?.toString() ?? '';
    final year = vehicleInfo['Model Year']?.toString() ?? '';
    final engineSize = vehicleInfo['Displacement (L)']?.toString() ?? '';
    
    // Default oil recommendations based on common vehicle types
    Map<String, String> recommendation = {
      'oilType': '5W-30',
      'capacity': '4.5 لتر',
      'brand': 'أي علامة تجارية معتمدة',
      'interval': '10,000 كيلومتر أو 6 أشهر',
    };

    // Specific recommendations based on make
    if (make.toLowerCase().contains('toyota')) {
      recommendation = {
        'oilType': '0W-20',
        'capacity': '4.4 لتر',
        'brand': 'Toyota Genuine أو Mobil 1',
        'interval': '10,000 كيلومتر',
      };
    } else if (make.toLowerCase().contains('honda')) {
      recommendation = {
        'oilType': '0W-20',
        'capacity': '4.2 لتر',
        'brand': 'Honda Genuine أو Castrol',
        'interval': '10,000 كيلومتر',
      };
    } else if (make.toLowerCase().contains('nissan')) {
      recommendation = {
        'oilType': '5W-30',
        'capacity': '4.5 لتر',
        'brand': 'Nissan Genuine أو Valvoline',
        'interval': '7,500 كيلومتر',
      };
    } else if (make.toLowerCase().contains('bmw')) {
      recommendation = {
        'oilType': '5W-30',
        'capacity': '5.0 لتر',
        'brand': 'BMW Genuine أو Shell',
        'interval': '15,000 كيلومتر',
      };
    } else if (make.toLowerCase().contains('mercedes')) {
      recommendation = {
        'oilType': '5W-40',
        'capacity': '6.0 لتر',
        'brand': 'Mercedes Genuine أو Mobil 1',
        'interval': '12,000 كيلومتر',
      };
    }

    return recommendation;
  }
}