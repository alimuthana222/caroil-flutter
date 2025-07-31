import 'package:flutter/material.dart';
import 'package:car_oil/screens/camera_screen.dart';
import 'package:car_oil/screens/manual_selection_screen.dart';
import 'package:car_oil/screens/vehicle_info_screen.dart';
import 'package:car_oil/services/vin_service.dart';
import 'package:quickalert/quickalert.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:car_oil/main.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: Text('بحث عن الزيت المناسب'),
        centerTitle: true,
        actions: [
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
                    Text('إحصائيات التخزين'),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'clear_cache',
                child: Row(
                  children: [
                    Icon(Icons.clear_all, size: 20),
                    SizedBox(width: 8),
                    Text('مسح التخزين المؤقت'),
                  ],
                ),
              ),
            ],
          ),
          BannerAdWidget(),
        ],

      ),
      // ✅ Fix: Use resizeToAvoidBottomInset to handle keyboard
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          // ✅ Fix: Add SingleChildScrollView to handle overflow
          padding: const EdgeInsets.all(16.0),
          child: ConstrainedBox(
            // ✅ Fix: Ensure minimum height but allow scrolling
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  kToolbarHeight - 32, // Account for app bar and padding
            ),
            child: IntrinsicHeight(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
                    'العثور على الزيت المناسب لسيارتك',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 8),




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
                      labelText: "رقم الشاصي (VIN)",
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
                              tooltip: 'مسح',
                            ),
                          IconButton(
                            onPressed: _pickImageFromGallery,
                            icon: Icon(Icons.photo_library),
                            tooltip: 'اختر من المعرض',
                          ),
                          IconButton(
                            onPressed: _openCamera,
                            icon: Icon(Icons.camera_alt),
                            tooltip: 'التقط صورة',
                          ),
                        ],
                      ),
                      errorText: _getVinValidationError(),
                      helperText: _vinController.text.length > 0
                          ? '${_vinController.text.length}/17 حرف'
                          : null,
                      // ✅ Fix: Improve border styling
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
                      label: Text(_isLoading ? 'جاري البحث...' : 'ابحث بالشاصي'),
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
                        child: Text('أو', style: TextStyle(color: Colors.grey)),
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
                      label: Text('اختر موديل السيارة يدوياً'),
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

                  // ✅ Fix: Add flexible spacer to push content up when keyboard appears
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? _getVinValidationError() {
    final vin = _vinController.text;
    if (vin.isNotEmpty) {
      if (vin.length != 17) {
        return 'رقم الشاصي يجب أن يكون 17 حرف';
      }
      if (!VinService.isValidVin(vin)) {
        return 'رقم شاصي غير صحيح';
      }
    }
    return null;
  }

  Future<void> _searchByVin() async {
    final vin = _vinController.text.trim().toUpperCase();

    if (vin.isEmpty) {
      _showAlert(QuickAlertType.warning, 'يرجى إدخال رقم الشاصي');
      return;
    }

    if (!VinService.isValidVin(vin)) {
      _showAlert(QuickAlertType.error, 'رقم الشاصي غير صحيح\nتأكد من إدخال 17 حرف/رقم صحيح');
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
            'لم يتم العثور على معلومات السيارة\n\nتأكد من صحة رقم الشاصي أو جرب البحث اليدوي'
        );
      }
    } catch (e) {
      _showAlert(
          QuickAlertType.error,
          'حدث خطأ أثناء البحث\n\nتحقق من اتصال الإنترنت وحاول مرة أخرى'
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _openCamera() async {
    // ✅ Fix: Dismiss keyboard before opening camera
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
      // ✅ Fix: Dismiss keyboard before opening gallery
      FocusScope.of(context).unfocus();

      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() => _isLoading = true);

        final inputImage = InputImage.fromFilePath(image.path);
        final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
        final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

        String? foundVin;
        // Look for 17-character strings that could be VINs
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
          _showAlert(QuickAlertType.success, 'تم العثور على رقم الشاصي في الصورة!');
        } else {
          _showAlert(QuickAlertType.warning, 'لم يتم العثور على رقم شاصي صحيح في الصورة');
        }
      }
    } catch (e) {
      _showAlert(QuickAlertType.error, 'حدث خطأ أثناء معالجة الصورة');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _clearCache() async {
    try {
      await VinService.clearCache();
      _showAlert(QuickAlertType.success, 'تم مسح التخزين المؤقت بنجاح');
    } catch (e) {
      _showAlert(QuickAlertType.error, 'فشل في مسح التخزين المؤقت');
    }
  }

  Future<void> _showCacheStats() async {
    try {
      final stats = await VinService.getCacheStats();

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('إحصائيات التخزين المؤقت'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('عدد السيارات المحفوظة: ${stats['cachedVins']}'),
              SizedBox(height: 8),
              Text('حجم التخزين: ${stats['cacheSizeKB']} KB'),
              SizedBox(height: 8),
              Text('مدة البقاء: 30 يوم'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('موافق'),
            ),
          ],
        ),
      );
    } catch (e) {
      _showAlert(QuickAlertType.error, 'فشل في جلب الإحصائيات');
    }
  }

  void _showAlert(QuickAlertType type, String message) {
    QuickAlert.show(
      context: context,
      type: type,
      text: message,
      confirmBtnText: 'موافق',
    );
  }

  @override
  void dispose() {
    _vinController.dispose();
    super.dispose();
  }
}