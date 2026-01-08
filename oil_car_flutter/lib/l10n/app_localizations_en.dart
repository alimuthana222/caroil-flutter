// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Car Oil Finder';

  @override
  String get findSuitableOil => 'Find Suitable Oil';

  @override
  String get searchByVin => 'Search by VIN';

  @override
  String get vinNumber => 'VIN Number';

  @override
  String get searching => 'Searching...';

  @override
  String get selectCarManually => 'Select Car Model Manually';

  @override
  String get or => 'or';

  @override
  String get clear => 'Clear';

  @override
  String get pickFromGallery => 'Pick from Gallery';

  @override
  String get takePicture => 'Take Picture';

  @override
  String get characters => 'characters';

  @override
  String get vinMust17Chars => 'VIN must be 17 characters';

  @override
  String get invalidVin => 'Invalid VIN number';

  @override
  String get pleaseEnterVin => 'Please enter VIN number';

  @override
  String get vehicleInfoNotFound =>
      'Vehicle information not found\n\nCheck VIN number or try manual search';

  @override
  String get errorOccurred =>
      'Error occurred during search\n\nCheck internet connection and try again';

  @override
  String get vinFoundInImage => 'VIN found in image!';

  @override
  String get noVinInImage => 'No valid VIN found in image';

  @override
  String get errorProcessingImage => 'Error processing image';

  @override
  String get cacheClearedSuccess => 'Cache cleared successfully';

  @override
  String get failedToClearCache => 'Failed to clear cache';

  @override
  String get cacheStatistics => 'Cache Statistics';

  @override
  String cachedVehicles(Object count) {
    return 'Cached vehicles: $count';
  }

  @override
  String cacheSize(Object size) {
    return 'Cache size: $size KB';
  }

  @override
  String get retention => 'Retention: 30 days';

  @override
  String get failedToGetStats => 'Failed to get statistics';

  @override
  String get ok => 'OK';

  @override
  String get loading => 'Loading...';

  @override
  String get profile => 'Profile';

  @override
  String get cacheStats => 'Cache Stats';

  @override
  String get clearCache => 'Clear Cache';

  @override
  String welcome(Object name) {
    return 'Welcome $name!';
  }

  @override
  String get user => 'User';
}
