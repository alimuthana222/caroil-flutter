import 'package:flutter/material.dart';
import 'package:oil_finder/screens/camera_screen.dart';
import 'package:oil_finder/screens/manual_selection_screen.dart';
import 'package:oil_finder/screens/vehicle_info_screen.dart';
import 'package:oil_finder/screens/user_profile_screen.dart';
import 'package:oil_finder/services/vin_service.dart';
import 'package:oil_finder/services/supabase_auth_service.dart';
import 'package:quickalert/quickalert.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:oil_finder/main.dart';

class VinLookupScreen extends StatefulWidget {
  const VinLookupScreen({super.key});

  @override
  State<VinLookupScreen> createState() => _VinLookupScreenState();
}

class _VinLookupScreenState extends State<VinLookupScreen> {
  final TextEditingController _vinController = TextEditingController();
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    final user = SupabaseAuthService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isArabic() ? 'بحث عن الزيت المناسب' : 'Find Suitable Oil'),
        centerTitle: true,
        actions: [
          // User Profile Button
          IconButton(
            icon: CircleAvatar(
              radius: 16,
              backgroundColor: Colors.white.withOpacity(0.2),
              backgroundImage: _getProfileImageUrl() != null
                  ? NetworkImage(_getProfileImageUrl()!)
                  : null,
              child: _getProfileImageUrl() == null
                  ? Icon(Icons.person, color: Colors.white, size: 20)
                  : null,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserProfileScreen(),
                ),
              );
            },
            tooltip: _isArabic() ? 'الملف الشخصي' : 'Profile',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'clear_cache') {
                _clearCache();
              } else if (value == 'cache_stats') {
                _showCacheStats();
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'cache_stats',
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 20),
                    SizedBox(width: 8),
                    Text(_isArabic() ? 'إحصائيات التخزين' : 'Cache Stats'),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'clear_cache',
                child: Row(
                  children: [
                    Icon(Icons.clear_all, size: 20),
                    SizedBox(width: 8),
                    Text(_isArabic() ? 'مسح التخزين المؤقت' : 'Clear Cache'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Welcome message with user name
              if (_getDisplayName() != (_isArabic() ? 'مستخدم' : 'User')) ...[
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.waving_hand, color: Colors.green[700]),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _isArabic()
                              ? 'مرحباً ${_getDisplayName()}!'
                              : 'Welcome ${_getDisplayName()}!',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.green[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
              ],

              // App Logo/Icon
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.car_repair,
                  size: 80,
                  color: Colors.green,
                ),
              ),
              SizedBox(height: 20),

              // Title
              Text(
                _isArabic()
                    ? 'العثور على الزيت المناسب لسيارتك'
                    : 'Find the Right Oil for Your Car',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 40),

              // VIN Input Field
              TextFormField(
                controller: _vinController,
                maxLength: 17,
                textDirection: TextDirection.ltr,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1,
                ),
                decoration: InputDecoration(
                  labelText: _isArabic() ? "رقم الشاصي (VIN)" : "VIN Number",
                  hintText: "JTMERGDF34GH12345",
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: Icon(Icons.directions_car),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_vinController.text.isNotEmpty)
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _vinController.clear();
                            });
                          },
                          icon: Icon(Icons.clear),
                          tooltip: _isArabic() ? 'مسح' : 'Clear',
                        ),
                      IconButton(
                        onPressed: _pickImageFromGallery,
                        icon: Icon(Icons.photo_library),
                        tooltip: _isArabic() ? 'اختر من المعرض' : 'Pick from Gallery',
                      ),
                      IconButton(
                        onPressed: _openCamera,
                        icon: Icon(Icons.camera_alt),
                        tooltip: _isArabic() ? 'التقط صورة' : 'Take Picture',
                      ),
                    ],
                  ),
                  errorText: _getVinValidationError(),
                  helperText: _vinController.text.length > 0
                      ? '${_vinController.text.length}/17 ${_isArabic() ? 'حرف' : 'characters'}'
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.green, width: 2),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _vinController.text = VinService.cleanVin(value);
                    _vinController.selection = TextSelection.fromPosition(
                      TextPosition(offset: _vinController.text.length),
                    );
                  });
                },
              ),
              SizedBox(height: 20),

              // Search Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _searchByVin,
                  icon: _isLoading
                      ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : Icon(Icons.search),
                  label: Text(_isLoading
                      ? (_isArabic() ? 'جاري البحث...' : 'Searching...')
                      : (_isArabic() ? 'ابحث بالشاصي' : 'Search by VIN')),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20),

              // Divider
              Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(_isArabic() ? 'أو' : 'or', style: TextStyle(color: Colors.grey)),
                  ),
                  Expanded(child: Divider()),
                ],
              ),

              SizedBox(height: 20),

              // Manual Selection Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ManualSelectionScreen(),
                      ),
                    );
                  },
                  icon: Icon(Icons.directions_car),
                  label: Text(_isArabic()
                      ? 'اختر موديل السيارة يدوياً'
                      : 'Select Car Model Manually'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.green,
                    side: BorderSide(color: Colors.green),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
            ],
          ),
        ),
      ),
    );
  }

  bool _isArabic() {
    return Localizations.localeOf(context).languageCode == 'ar';
  }

  String? _getProfileImageUrl() {
    final user = SupabaseAuthService.currentUser;
    return user?.userMetadata?['avatar_url'] ??
        user?.userMetadata?['picture'];
  }

  String _getDisplayName() {
    final user = SupabaseAuthService.currentUser;
    return user?.userMetadata?['full_name'] ??
        user?.userMetadata?['name'] ??
        (_isArabic() ? 'مستخدم' : 'User');
  }

  String? _getVinValidationError() {
    final vin = _vinController.text;
    if (vin.isNotEmpty) {
      if (vin.length != 17) {
        return _isArabic()
            ? 'رقم الشاصي يجب أن يكون 17 حرف'
            : 'VIN must be 17 characters';
      }
      if (!VinService.isValidVin(vin)) {
        return _isArabic() ? 'رقم شاصي غير صحيح' : 'Invalid VIN number';
      }
    }
    return null;
  }

  Future<void> _searchByVin() async {
    final vin = _vinController.text.trim().toUpperCase();

    if (vin.isEmpty) {
      _showAlert(QuickAlertType.warning, _isArabic()
          ? 'يرجى إدخال رقم الشاصي'
          : 'Please enter VIN number');
      return;
    }

    if (!VinService.isValidVin(vin)) {
      _showAlert(QuickAlertType.error, _isArabic()
          ? 'رقم الشاصي غير صحيح\nتأكد من إدخال 17 حرف/رقم صحيح'
          : 'Invalid VIN number\nMake sure to enter 17 valid characters/numbers');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final vehicle = await VinService.lookupVin(vin);

      if (vehicle != null && vehicle.make != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VehicleInfoScreen(vehicle: vehicle),
          ),
        );
      } else {
        _showAlert(
            QuickAlertType.error,
            _isArabic()
                ? 'لم يتم العثور على معلومات السيارة\n\nتأكد من صحة رقم الشاصي أو جرب البحث اليدوي'
                : 'Vehicle information not found\n\nCheck VIN number or try manual search'
        );
      }
    } catch (e) {
      _showAlert(
          QuickAlertType.error,
          _isArabic()
              ? 'حدث خطأ أثناء البحث\n\nتحقق من اتصال الإنترنت وحاول مرة أخرى'
              : 'Error occurred during search\n\nCheck internet connection and try again'
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _openCamera() async {
    FocusScope.of(context).unfocus();

    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => CameraScreen()),
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        _vinController.text = VinService.cleanVin(result);
      });
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      FocusScope.of(context).unfocus();

      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() => _isLoading = true);

        final inputImage = InputImage.fromFilePath(image.path);
        final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
        final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

        String? foundVin;
        for (TextBlock block in recognizedText.blocks) {
          for (TextLine line in block.lines) {
            for (TextElement element in line.elements) {
              final cleanText = VinService.cleanVin(element.text);
              if (cleanText.length == 17 && VinService.isValidVin(cleanText)) {
                foundVin = cleanText;
                break;
              }
            }
            if (foundVin != null) break;
          }
          if (foundVin != null) break;
        }

        if (foundVin != null) {
          setState(() {
            _vinController.text = foundVin!;
          });
          _showAlert(QuickAlertType.success, _isArabic()
              ? 'تم العثور على رقم الشاصي في الصورة!'
              : 'VIN found in image!');
        } else {
          _showAlert(QuickAlertType.warning, _isArabic()
              ? 'لم يتم العثور على رقم شاصي صحيح في الصورة'
              : 'No valid VIN found in image');
        }
      }
    } catch (e) {
      _showAlert(QuickAlertType.error, _isArabic()
          ? 'حدث خطأ أثناء معالجة الصورة'
          : 'Error processing image');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _clearCache() async {
    try {
      await VinService.clearCache();
      _showAlert(QuickAlertType.success, _isArabic()
          ? 'تم مسح التخزين المؤقت بنجاح'
          : 'Cache cleared successfully');
    } catch (e) {
      _showAlert(QuickAlertType.error, _isArabic()
          ? 'فشل في مسح التخزين المؤقت'
          : 'Failed to clear cache');
    }
  }

  Future<void> _showCacheStats() async {
    try {
      final stats = await VinService.getCacheStats();

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(_isArabic() ? 'إحصائيات التخزين المؤقت' : 'Cache Statistics'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_isArabic()
                  ? 'عدد السيارات المحفوظة: ${stats['cachedVins']}'
                  : 'Cached vehicles: ${stats['cachedVins']}'),
              SizedBox(height: 8),
              Text(_isArabic()
                  ? 'حجم التخزين: ${stats['cacheSizeKB']} KB'
                  : 'Cache size: ${stats['cacheSizeKB']} KB'),
              SizedBox(height: 8),
              Text(_isArabic()
                  ? 'مدة البقاء: 30 يوم'
                  : 'Retention: 30 days'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(_isArabic() ? 'موافق' : 'OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      _showAlert(QuickAlertType.error, _isArabic()
          ? 'فشل في جلب الإحصائيات'
          : 'Failed to get statistics');
    }
  }

  void _showAlert(QuickAlertType type, String message) {
    QuickAlert.show(
      context: context,
      type: type,
      text: message,
      confirmBtnText: _isArabic() ? 'موافق' : 'OK',
    );
  }

  @override
  void dispose() {
    _vinController.dispose();
    super.dispose();
  }
}