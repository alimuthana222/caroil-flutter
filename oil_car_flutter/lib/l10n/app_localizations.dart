import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Car Oil Finder'**
  String get appTitle;

  /// No description provided for @findSuitableOil.
  ///
  /// In en, this message translates to:
  /// **'Find Suitable Oil'**
  String get findSuitableOil;

  /// No description provided for @searchByVin.
  ///
  /// In en, this message translates to:
  /// **'Search by VIN'**
  String get searchByVin;

  /// No description provided for @vinNumber.
  ///
  /// In en, this message translates to:
  /// **'VIN Number'**
  String get vinNumber;

  /// No description provided for @searching.
  ///
  /// In en, this message translates to:
  /// **'Searching...'**
  String get searching;

  /// No description provided for @selectCarManually.
  ///
  /// In en, this message translates to:
  /// **'Select Car Model Manually'**
  String get selectCarManually;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get or;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @pickFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Pick from Gallery'**
  String get pickFromGallery;

  /// No description provided for @takePicture.
  ///
  /// In en, this message translates to:
  /// **'Take Picture'**
  String get takePicture;

  /// No description provided for @characters.
  ///
  /// In en, this message translates to:
  /// **'characters'**
  String get characters;

  /// No description provided for @vinMust17Chars.
  ///
  /// In en, this message translates to:
  /// **'VIN must be 17 characters'**
  String get vinMust17Chars;

  /// No description provided for @invalidVin.
  ///
  /// In en, this message translates to:
  /// **'Invalid VIN number'**
  String get invalidVin;

  /// No description provided for @pleaseEnterVin.
  ///
  /// In en, this message translates to:
  /// **'Please enter VIN number'**
  String get pleaseEnterVin;

  /// No description provided for @vehicleInfoNotFound.
  ///
  /// In en, this message translates to:
  /// **'Vehicle information not found\n\nCheck VIN number or try manual search'**
  String get vehicleInfoNotFound;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'Error occurred during search\n\nCheck internet connection and try again'**
  String get errorOccurred;

  /// No description provided for @vinFoundInImage.
  ///
  /// In en, this message translates to:
  /// **'VIN found in image!'**
  String get vinFoundInImage;

  /// No description provided for @noVinInImage.
  ///
  /// In en, this message translates to:
  /// **'No valid VIN found in image'**
  String get noVinInImage;

  /// No description provided for @errorProcessingImage.
  ///
  /// In en, this message translates to:
  /// **'Error processing image'**
  String get errorProcessingImage;

  /// No description provided for @cacheClearedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Cache cleared successfully'**
  String get cacheClearedSuccess;

  /// No description provided for @failedToClearCache.
  ///
  /// In en, this message translates to:
  /// **'Failed to clear cache'**
  String get failedToClearCache;

  /// No description provided for @cacheStatistics.
  ///
  /// In en, this message translates to:
  /// **'Cache Statistics'**
  String get cacheStatistics;

  /// No description provided for @cachedVehicles.
  ///
  /// In en, this message translates to:
  /// **'Cached vehicles: {count}'**
  String cachedVehicles(Object count);

  /// No description provided for @cacheSize.
  ///
  /// In en, this message translates to:
  /// **'Cache size: {size} KB'**
  String cacheSize(Object size);

  /// No description provided for @retention.
  ///
  /// In en, this message translates to:
  /// **'Retention: 30 days'**
  String get retention;

  /// No description provided for @failedToGetStats.
  ///
  /// In en, this message translates to:
  /// **'Failed to get statistics'**
  String get failedToGetStats;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @cacheStats.
  ///
  /// In en, this message translates to:
  /// **'Cache Stats'**
  String get cacheStats;

  /// No description provided for @clearCache.
  ///
  /// In en, this message translates to:
  /// **'Clear Cache'**
  String get clearCache;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome {name}!'**
  String welcome(Object name);

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
