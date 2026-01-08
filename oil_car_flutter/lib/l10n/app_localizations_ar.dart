// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'بحث عن الزيت المناسب';

  @override
  String get findSuitableOil => 'العثور على الزيت المناسب';

  @override
  String get searchByVin => 'ابحث بالشاصي';

  @override
  String get vinNumber => 'رقم الشاصي (VIN)';

  @override
  String get searching => 'جاري البحث...';

  @override
  String get selectCarManually => 'اختر موديل السيارة يدوياً';

  @override
  String get or => 'أو';

  @override
  String get clear => 'مسح';

  @override
  String get pickFromGallery => 'اختر من المعرض';

  @override
  String get takePicture => 'التقط صورة';

  @override
  String get characters => 'حرف';

  @override
  String get vinMust17Chars => 'رقم الشاصي يجب أن يكون 17 حرف';

  @override
  String get invalidVin => 'رقم شاصي غير صحيح';

  @override
  String get pleaseEnterVin => 'يرجى إدخال رقم الشاصي';

  @override
  String get vehicleInfoNotFound =>
      'لم يتم العثور على معلومات السيارة\n\nتأكد من صحة رقم الشاصي أو جرب البحث اليدوي';

  @override
  String get errorOccurred =>
      'حدث خطأ أثناء البحث\n\nتحقق من اتصال الإنترنت وحاول مرة أخرى';

  @override
  String get vinFoundInImage => 'تم العثور على رقم الشاصي في الصورة!';

  @override
  String get noVinInImage => 'لم يتم العثور على رقم شاصي صحيح في الصورة';

  @override
  String get errorProcessingImage => 'حدث خطأ أثناء معالجة الصورة';

  @override
  String get cacheClearedSuccess => 'تم مسح التخزين المؤقت بنجاح';

  @override
  String get failedToClearCache => 'فشل في مسح التخزين المؤقت';

  @override
  String get cacheStatistics => 'إحصائيات التخزين المؤقت';

  @override
  String cachedVehicles(Object count) {
    return 'عدد السيارات المحفوظة: $count';
  }

  @override
  String cacheSize(Object size) {
    return 'حجم التخزين: $size KB';
  }

  @override
  String get retention => 'مدة البقاء: 30 يوم';

  @override
  String get failedToGetStats => 'فشل في جلب الإحصائيات';

  @override
  String get ok => 'موافق';

  @override
  String get loading => 'جاري التحميل...';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get cacheStats => 'إحصائيات التخزين';

  @override
  String get clearCache => 'مسح التخزين المؤقت';

  @override
  String welcome(Object name) {
    return 'مرحباً $name!';
  }

  @override
  String get user => 'مستخدم';
}
