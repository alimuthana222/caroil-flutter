import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:car_oil/models/oil_spec.dart';

class SupabaseService {
  static final _client = Supabase.instance.client;

  // Get all car brands from database
  static Future<List<String>> getCarBrands() async {
    try {
      print('🔍 Loading car brands...');

      final response = await _client
          .from('vehicle_oil_data')
          .select('brand')
          .order('brand');

      print('🔧 Raw brands response: $response');

      final brands = (response as List)
          .map((item) => item['brand'] as String)
          .where((brand) => brand.isNotEmpty)
          .toSet()
          .toList();

      print('✅ Loaded ${brands.length} brands: $brands');

      // Return brands as-is (don't capitalize here, keep original case)
      return brands;
    } catch (e) {
      print('❌ Error getting car brands: $e');
      return [];
    }
  }

  // Get car models for a specific brand
  static Future<List<String>> getCarModels(String brand) async {
    try {
      print('🔍 Loading models for brand: "$brand"');

      // Try multiple case variations to match database
      List<String> brandVariations = [
        brand,                    // Original case
        brand.toLowerCase(),      // All lowercase
        brand.toUpperCase(),      // All uppercase
        _capitalizeFirst(brand),  // First letter capitalized
      ];

      List<String> allModels = [];

      for (String brandVariation in brandVariations) {
        print('  🔍 Trying brand variation: "$brandVariation"');

        final response = await _client
            .from('vehicle_oil_data')
            .select('model')
            .eq('brand', brandVariation)
            .order('model');

        print('  📋 Response for "$brandVariation": ${(response as List).length} records');

        if ((response as List).isNotEmpty) {
          final models = response
              .map((item) => item['model'] as String)
              .where((model) => model.isNotEmpty)
              .toList();

          allModels.addAll(models);
          print('  ✅ Found ${models.length} models: $models');
        }
      }

      // Remove duplicates and sort
      final uniqueModels = allModels.toSet().toList();
      uniqueModels.sort();

      print('✅ Final result: ${uniqueModels.length} unique models for "$brand": $uniqueModels');

      return uniqueModels;
    } catch (e) {
      print('❌ Error getting car models: $e');
      return [];
    }
  }

  // Get available years for a specific brand and model
  static Future<List<int>> getCarYears(String brand, String model) async {
    try {
      print('🔍 Loading years for: "$brand" "$model"');

      // Try different case combinations
      List<Map<String, String>> combinations = [
        {'brand': brand, 'model': model},
        {'brand': brand.toLowerCase(), 'model': model.toLowerCase()},
        {'brand': brand.toUpperCase(), 'model': model.toUpperCase()},
        {'brand': _capitalizeFirst(brand), 'model': _capitalizeFirst(model)},
      ];

      List<int> allYears = [];

      for (var combo in combinations) {
        print('  🔍 Trying: brand="${combo['brand']}", model="${combo['model']}"');

        final response = await _client
            .from('vehicle_oil_data')
            .select('year')
            .eq('brand', combo['brand']!)
            .eq('model', combo['model']!)
            .order('year', ascending: false);

        print('  📋 Response: ${(response as List).length} records');

        if ((response as List).isNotEmpty) {
          final years = response
              .map((item) => item['year'] as int)
              .toList();

          allYears.addAll(years);
          print('  ✅ Found ${years.length} years: $years');
        }
      }

      // Remove duplicates and sort descending
      final uniqueYears = allYears.toSet().toList();
      uniqueYears.sort((a, b) => b.compareTo(a)); // Descending order

      print('✅ Final result: ${uniqueYears.length} unique years: $uniqueYears');

      return uniqueYears;
    } catch (e) {
      print('❌ Error getting car years: $e');
      return [];
    }
  }

  // Get car trims (optional)
  static Future<List<String>> getCarTrims(String brand, String model, int year) async {
    try {
      print('🔍 Loading trims for: "$brand" "$model" $year');

      // Try different case combinations
      List<Map<String, dynamic>> combinations = [
        {'brand': brand, 'model': model, 'year': year},
        {'brand': brand.toLowerCase(), 'model': model.toLowerCase(), 'year': year},
        {'brand': brand.toUpperCase(), 'model': model.toUpperCase(), 'year': year},
        {'brand': _capitalizeFirst(brand), 'model': _capitalizeFirst(model), 'year': year},
      ];

      List<String> allTrims = [];

      for (var combo in combinations) {
        final response = await _client
            .from('vehicle_oil_data')
            .select('trim')
            .eq('brand', combo['brand'])
            .eq('model', combo['model'])
            .eq('year', combo['year'])
            .not('trim', 'is', null);

        if ((response as List).isNotEmpty) {
          final trims = response
              .map((item) => item['trim'] as String?)
              .where((trim) => trim != null && trim.isNotEmpty)
              .cast<String>()
              .toList();

          allTrims.addAll(trims);
        }
      }

      final uniqueTrims = allTrims.toSet().toList();
      uniqueTrims.sort();

      print('✅ Found ${uniqueTrims.length} trims: $uniqueTrims');
      return uniqueTrims;
    } catch (e) {
      print('❌ Error getting car trims: $e');
      return [];
    }
  }

  // Exact match search
  static Future<OilSpec?> getOilSpecExact(String brand, String model, int year) async {
    try {
      print('🔍 Exact search: brand="$brand", model="$model", year=$year');

      // Try different case combinations for exact match
      List<Map<String, dynamic>> combinations = [
        {'brand': brand, 'model': model},
        {'brand': brand.toLowerCase(), 'model': model.toLowerCase()},
        {'brand': brand.toUpperCase(), 'model': model.toUpperCase()},
        {'brand': _capitalizeFirst(brand), 'model': _capitalizeFirst(model)},
      ];

      for (var combo in combinations) {
        final response = await _client
            .from('vehicle_oil_data')
            .select()
            .eq('brand', combo['brand'])
            .eq('model', combo['model'])
            .eq('year', year)
            .maybeSingle();

        if (response != null) {
          print('✅ Found exact match: ${response['brand']} ${response['model']} ${response['year']}');
          return OilSpec.fromJson(response);
        }
      }

      print('❌ No exact match found');
      return null;
    } catch (e) {
      print('❌ Exact search error: $e');
      return null;
    }
  }

  // Fuzzy search (case insensitive, handles variations)
  static Future<OilSpec?> getOilSpecFuzzy(String brand, String model, int year) async {
    try {
      print('🔍 Fuzzy search: brand="$brand", model="$model", year=$year');

      // Try different variations of the brand name
      List<String> brandVariations = _getBrandVariations(brand);
      List<String> modelVariations = _getModelVariations(model);

      for (String brandVar in brandVariations) {
        for (String modelVar in modelVariations) {
          print('  Trying: brandVar="$brandVar", modelVar="$modelVar"');

          final response = await _client
              .from('vehicle_oil_data')
              .select()
              .ilike('brand', brandVar)
              .ilike('model', modelVar)
              .eq('year', year)
              .maybeSingle();

          if (response != null) {
            print('✅ Found fuzzy match: ${response['brand']} ${response['model']} ${response['year']}');
            return OilSpec.fromJson(response);
          }
        }
      }

      print('❌ No fuzzy match found');
      return null;
    } catch (e) {
      print('❌ Fuzzy search error: $e');
      return null;
    }
  }

  // Year range search (±2 years)
  static Future<OilSpec?> getOilSpecYearRange(String brand, String model, int year) async {
    try {
      print('🔍 Year range search: brand="$brand", model="$model", year=$year (±2)');

      final response = await _client
          .from('vehicle_oil_data')
          .select()
          .ilike('brand', '%$brand%')
          .ilike('model', '%$model%')
          .gte('year', year - 2)
          .lte('year', year + 2)
          .order('year', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response != null) {
        print('✅ Found year range match: ${response['brand']} ${response['model']} ${response['year']}');
        return OilSpec.fromJson(response);
      }

      print('❌ No year range match found');
      return null;
    } catch (e) {
      print('❌ Year range search error: $e');
      return null;
    }
  }

  // Check if brand exists
  static Future<bool> doesBrandExist(String brand) async {
    try {
      final response = await _client
          .from('vehicle_oil_data')
          .select('brand')
          .ilike('brand', '%$brand%')
          .limit(1);

      return (response as List).isNotEmpty;
    } catch (e) {
      print('❌ Brand check error: $e');
      return false;
    }
  }

  // Check if model exists for brand
  static Future<bool> doesModelExist(String brand, String model) async {
    try {
      final response = await _client
          .from('vehicle_oil_data')
          .select('model')
          .ilike('brand', '%$brand%')
          .ilike('model', '%$model%')
          .limit(1);

      return (response as List).isNotEmpty;
    } catch (e) {
      print('❌ Model check error: $e');
      return false;
    }
  }

  // Search with text query
  static Future<List<OilSpec>> searchOilSpecs(String query) async {
    try {
      final response = await _client
          .from('vehicle_oil_data')
          .select()
          .or('brand.ilike.%$query%,model.ilike.%$query%')
          .order('brand')
          .limit(50);

      return (response as List)
          .map((item) => OilSpec.fromJson(item))
          .toList();
    } catch (e) {
      print('Search error: $e');
      return [];
    }
  }

  // Helper methods
  static List<String> _getBrandVariations(String brand) {
    List<String> variations = [brand.toLowerCase()];

    // Add common brand variations
    Map<String, List<String>> brandMappings = {
      'toyota': ['toyota', 'toy%', '%toyota%'],
      'honda': ['honda', 'hon%', '%honda%'],
      'nissan': ['nissan', 'nis%', '%nissan%'],
      'hyundai': ['hyundai', 'hyu%', '%hyundai%'],
      'kia': ['kia', 'ki%', '%kia%'],
      'ford': ['ford', 'fo%', '%ford%'],
      'chevrolet': ['chevrolet', 'chevy', 'chev%', '%chevrolet%'],
      'bmw': ['bmw', 'b.m.w', '%bmw%'],
      'mercedes': ['mercedes', 'mercedes-benz', 'mb', '%mercedes%'],
      'audi': ['audi', 'au%', '%audi%'],
      'dodge': ['dodge', 'dod%', '%dodge%'],
      'chrysler': ['chrysler', 'chry%', '%chrysler%'],
      'jeep': ['jeep', 'je%', '%jeep%'],
      'ram': ['ram', 'ra%', '%ram%'],
    };

    String lowerBrand = brand.toLowerCase();
    for (String key in brandMappings.keys) {
      if (lowerBrand.contains(key) || key.contains(lowerBrand)) {
        variations.addAll(brandMappings[key]!);
      }
    }

    // Add wildcard variations
    variations.addAll([
      '%$lowerBrand%',
      '$lowerBrand%',
      '%$lowerBrand'
    ]);

    return variations.toSet().toList();
  }

  static List<String> _getModelVariations(String model) {
    List<String> variations = [model.toLowerCase()];

    // Add wildcard variations
    String lowerModel = model.toLowerCase();
    variations.addAll([
      '%$lowerModel%',
      '$lowerModel%',
      '%$lowerModel'
    ]);

    return variations.toSet().toList();
  }

  static String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  // Debug method to see all data
  static Future<List<Map<String, dynamic>>> getAllVehicleData() async {
    try {
      print('🔍 Getting all vehicle data for debugging...');

      final response = await _client
          .from('vehicle_oil_data')
          .select()
          .limit(100);

      print('✅ Retrieved ${(response as List).length} records');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error getting all data: $e');
      return [];
    }
  }

  // New debug method to check specific brand data
  static Future<void> debugBrandData(String brand) async {
    try {
      print('🔧 DEBUG: Checking data for brand "$brand"');

      // Check exact match
      final exactMatch = await _client
          .from('vehicle_oil_data')
          .select()
          .eq('brand', brand)
          .limit(5);

      print('🔧 Exact match for "$brand": ${(exactMatch as List).length} records');

      // Check lowercase match
      final lowerMatch = await _client
          .from('vehicle_oil_data')
          .select()
          .eq('brand', brand.toLowerCase())
          .limit(5);

      print('🔧 Lowercase match for "${brand.toLowerCase()}": ${(lowerMatch as List).length} records');

      // Check case-insensitive match
      final iLikeMatch = await _client
          .from('vehicle_oil_data')
          .select()
          .ilike('brand', brand)
          .limit(5);

      print('🔧 iLike match for "$brand": ${(iLikeMatch as List).length} records');

      // Show sample data
      if ((exactMatch as List).isNotEmpty) {
        print('🔧 Sample exact match data: ${exactMatch.first}');
      }
      if ((lowerMatch as List).isNotEmpty) {
        print('🔧 Sample lowercase data: ${lowerMatch.first}');
      }
      if ((iLikeMatch as List).isNotEmpty) {
        print('🔧 Sample iLike data: ${iLikeMatch.first}');
      }

    } catch (e) {
      print('❌ Debug error: $e');
    }
  }
}