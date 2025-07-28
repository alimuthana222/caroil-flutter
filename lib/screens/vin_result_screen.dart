import 'package:flutter/material.dart';
import '../services/car_database_service.dart';
import '../models/vehicle_model.dart';
import '../models/oil_specification.dart';
import '../models/engine_specification.dart';
import 'detailed_vehicle_screen.dart';

class VinResultScreen extends StatefulWidget {
  final String vin;

  const VinResultScreen({super.key, required this.vin});

  @override
  State<VinResultScreen> createState() => _VinResultScreenState();
}

class _VinResultScreenState extends State<VinResultScreen>
    with TickerProviderStateMixin {
  VehicleModel? _vehicle;
  OilSpecification? _oilSpec;
  EngineSpecification? _engineSpec;
  bool _isLoading = true;
  String? _errorMessage;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _loadVehicleData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadVehicleData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get vehicle information from database or NHTSA API
      final vehicle = await CarDatabaseService.getVehicleByVin(widget.vin);
      
      if (vehicle == null) {
        setState(() {
          _errorMessage = 'لم يتم العثور على معلومات لهذا الرقم';
          _isLoading = false;
        });
        return;
      }

      // Get oil and engine specifications
      final results = await Future.wait([
        CarDatabaseService.getOilSpecification(vehicle.id),
        CarDatabaseService.getEngineSpecification(vehicle.id),
      ]);

      setState(() {
        _vehicle = vehicle;
        _oilSpec = results[0] as OilSpecification?;
        _engineSpec = results[1] as EngineSpecification?;
        _isLoading = false;
      });

      _animationController.forward();
    } catch (e) {
      setState(() {
        _errorMessage = 'حدث خطأ أثناء تحميل البيانات: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        title: const Text(
          'نتائج البحث',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (_vehicle != null)
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailedVehicleScreen(vehicle: _vehicle!),
                  ),
                );
              },
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_vehicle == null) {
      return _buildNotFoundState();
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildVehicleInfoCard(),
            const SizedBox(height: 16),
            _buildEngineInfoCard(),
            const SizedBox(height: 16),
            _buildOilRecommendationCard(),
            const SizedBox(height: 16),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 5,
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[700]!),
                ),
                const SizedBox(height: 16),
                const Text(
                  'جارٍ البحث عن معلومات سيارتك...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'VIN: ${widget.vin}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'حدث خطأ',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadVehicleData,
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotFoundState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'لم يتم العثور على السيارة',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'لم نتمكن من العثور على معلومات للرقم ${widget.vin}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('العودة للبحث'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleInfoCard() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.blue[700]!, Colors.blue[500]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.directions_car,
                  color: Colors.white,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_vehicle!.make} ${_vehicle!.model}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'موديل ${_vehicle!.year}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_vehicle!.isModified)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'معدلة',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            _buildVehicleInfoRow('رقم VIN', widget.vin),
            _buildVehicleInfoRow('المنطقة', _getRegionArabic(_vehicle!.region)),
            _buildVehicleInfoRow('نوع الوقود', _vehicle!.fuelType),
            _buildVehicleInfoRow('ناقل الحركة', _vehicle!.transmission),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEngineInfoCard() {
    if (_engineSpec == null) return const SizedBox();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.engineering, color: Colors.blue[700], size: 24),
                const SizedBox(width: 8),
                Text(
                  'معلومات المحرك',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _engineSpec!.engineDescriptionArabic,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildEngineDetail('القوة', '${_engineSpec!.horsepower} حصان'),
                ),
                Expanded(
                  child: _buildEngineDetail('عزم الدوران', '${_engineSpec!.torque} نيوتن.متر'),
                ),
              ],
            ),
            if (_engineSpec!.turboCharged || _engineSpec!.superCharged) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  if (_engineSpec!.turboCharged)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'تيربو',
                        style: TextStyle(
                          color: Colors.red[700],
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  if (_engineSpec!.superCharged) ...[
                    if (_engineSpec!.turboCharged) const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.purple[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'سوبرتشارج',
                        style: TextStyle(
                          color: Colors.purple[700],
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEngineDetail(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildOilRecommendationCard() {
    if (_oilSpec == null) {
      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(Icons.oil_barrel, color: Colors.grey[400], size: 48),
              const SizedBox(height: 12),
              const Text(
                'لا توجد توصيات زيت متاحة',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.oil_barrel, color: Colors.green[700], size: 24),
                const SizedBox(width: 8),
                Text(
                  'توصيات الزيت',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.star, color: Colors.green[700], size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'موصى به: ${_oilSpec!.oilType}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _buildOilDetail('الكمية مع الفلتر', _oilSpec!.capacityWithFilterArabic),
            _buildOilDetail('الكمية بدون فلتر', _oilSpec!.capacityWithoutFilterArabic),
            _buildOilDetail('العلامة الموصى بها', _oilSpec!.recommendedBrand),
            _buildOilDetail('فترة التغيير', _oilSpec!.changeIntervalArabic),
            _buildOilDetail('رقم الفلتر', _oilSpec!.filterPartNumber),
          ],
        ),
      ),
    );
  }

  Widget _buildOilDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailedVehicleScreen(vehicle: _vehicle!),
                ),
              );
            },
            icon: const Icon(Icons.info),
            label: const Text('عرض التفاصيل الكاملة'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
              backgroundColor: Colors.blue[700],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.search),
                label: const Text('بحث جديد'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(12),
                  side: BorderSide(color: Colors.blue[700]!),
                  foregroundColor: Colors.blue[700],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  // Share functionality
                  _shareVehicleInfo();
                },
                icon: const Icon(Icons.share),
                label: const Text('مشاركة'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(12),
                  side: BorderSide(color: Colors.green[700]!),
                  foregroundColor: Colors.green[700],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _shareVehicleInfo() {
    if (_vehicle == null) return;

    final info = '''
معلومات السيارة:
${_vehicle!.make} ${_vehicle!.model} ${_vehicle!.year}
VIN: ${widget.vin}

${_oilSpec != null ? '''
توصيات الزيت:
نوع الزيت: ${_oilSpec!.oilType}
الكمية مع الفلتر: ${_oilSpec!.capacityWithFilterArabic}
العلامة الموصى بها: ${_oilSpec!.recommendedBrand}
فترة التغيير: ${_oilSpec!.changeIntervalArabic}
''' : ''}

تطبيق OilMate - دليل زيت السيارات
''';

    // In a real app, you would use share_plus package
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('تم نسخ المعلومات'),
        action: SnackBarAction(
          label: 'إغلاق',
          onPressed: () {},
        ),
      ),
    );
  }

  String _getRegionArabic(String region) {
    switch (region) {
      case 'USA':
        return 'الولايات المتحدة';
      case 'Middle East':
        return 'الشرق الأوسط';
      case 'China':
        return 'الصين';
      case 'Europe':
        return 'أوروبا';
      case 'Asia':
        return 'آسيا';
      case 'Africa':
        return 'أفريقيا';
      case 'Australia':
        return 'أستراليا';
      case 'South America':
        return 'أمريكا الجنوبية';
      default:
        return 'غير محدد';
    }
  }
}