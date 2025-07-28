import 'package:flutter/material.dart';
import '../models/vehicle_model.dart';
import '../models/oil_specification.dart';
import '../models/engine_specification.dart';
import '../models/maintenance_record.dart';
import '../services/car_database_service.dart';
import 'maintenance_screen.dart';
import 'oil_products_screen.dart';

class DetailedVehicleScreen extends StatefulWidget {
  final VehicleModel vehicle;

  const DetailedVehicleScreen({super.key, required this.vehicle});

  @override
  State<DetailedVehicleScreen> createState() => _DetailedVehicleScreenState();
}

class _DetailedVehicleScreenState extends State<DetailedVehicleScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  OilSpecification? _oilSpec;
  EngineSpecification? _engineSpec;
  List<MaintenanceRecord> _maintenanceRecords = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadVehicleDetails();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadVehicleDetails() async {
    setState(() => _isLoading = true);
    
    try {
      final results = await Future.wait([
        CarDatabaseService.getOilSpecification(widget.vehicle.id),
        CarDatabaseService.getEngineSpecification(widget.vehicle.id),
        CarDatabaseService.getMaintenanceRecords(widget.vehicle.id),
      ]);

      setState(() {
        _oilSpec = results[0] as OilSpecification?;
        _engineSpec = results[1] as EngineSpecification?;
        _maintenanceRecords = results[2] as List<MaintenanceRecord>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في تحميل البيانات: $e')),
        );
      }
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
        title: Text(
          '${widget.vehicle.make} ${widget.vehicle.model}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.blue[100],
          tabs: const [
            Tab(icon: Icon(Icons.info), text: 'معلومات السيارة'),
            Tab(icon: Icon(Icons.engineering), text: 'المحرك'),
            Tab(icon: Icon(Icons.oil_barrel), text: 'الزيت'),
            Tab(icon: Icon(Icons.history), text: 'الصيانة'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildVehicleInfoTab(),
                _buildEngineTab(),
                _buildOilTab(),
                _buildMaintenanceTab(),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MaintenanceScreen(vehicle: widget.vehicle),
            ),
          );
        },
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('إضافة صيانة'),
      ),
    );
  }

  Widget _buildVehicleInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildInfoCard(
            title: 'معلومات السيارة الأساسية',
            icon: Icons.directions_car,
            children: [
              _buildInfoRow('رقم VIN', widget.vehicle.vin),
              _buildInfoRow('الصنع', widget.vehicle.make),
              _buildInfoRow('الموديل', widget.vehicle.model),
              _buildInfoRow('سنة الصنع', widget.vehicle.year.toString()),
              _buildInfoRow('المنطقة', _getRegionArabic(widget.vehicle.region)),
              _buildInfoRow('نوع الوقود', widget.vehicle.fuelType),
              _buildInfoRow('ناقل الحركة', widget.vehicle.transmission),
            ],
          ),
          const SizedBox(height: 16),
          _buildModificationCard(),
          const SizedBox(height: 16),
          _buildVehicleStatsCard(),
        ],
      ),
    );
  }

  Widget _buildEngineTab() {
    if (_engineSpec == null) {
      return const Center(
        child: Text(
          'لا توجد معلومات محرك متاحة',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildInfoCard(
            title: 'مواصفات المحرك',
            icon: Icons.engineering,
            children: [
              _buildInfoRow('كود المحرك', _engineSpec!.engineCode),
              _buildInfoRow('عائلة المحرك', _engineSpec!.engineFamily),
              _buildInfoRow('عدد الأسطوانات', _engineSpec!.cylinders.toString()),
              _buildInfoRow('التكوين', _engineSpec!.configuration),
              _buildInfoRow('السعة', '${_engineSpec!.displacement} لتر'),
              _buildInfoRow('القوة', '${_engineSpec!.horsepower} حصان'),
              _buildInfoRow('عزم الدوران', '${_engineSpec!.torque} نيوتن.متر'),
              _buildInfoRow('نظام الوقود', _engineSpec!.fuelSystem),
              _buildInfoRow('نسبة الضغط', _engineSpec!.compressionRatio),
              _buildInfoRow('نظام الصمامات', _engineSpec!.valveTrain),
              _buildInfoRow('تيربو', _engineSpec!.turboCharged ? 'نعم' : 'لا'),
              _buildInfoRow('سوبرتشارج', _engineSpec!.superCharged ? 'نعم' : 'لا'),
            ],
          ),
          const SizedBox(height: 16),
          _buildCompatibleOilsCard(),
        ],
      ),
    );
  }

  Widget _buildOilTab() {
    if (_oilSpec == null) {
      return const Center(
        child: Text(
          'لا توجد مواصفات زيت متاحة',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildInfoCard(
            title: 'مواصفات الزيت الموصى بها',
            icon: Icons.oil_barrel,
            children: [
              _buildInfoRow('نوع الزيت', _oilSpec!.oilType),
              _buildInfoRow('درجة اللزوجة', _oilSpec!.viscosityGrade),
              _buildInfoRow(
                'الكمية مع الفلتر',
                _oilSpec!.capacityWithFilterArabic,
              ),
              _buildInfoRow(
                'الكمية بدون فلتر',
                _oilSpec!.capacityWithoutFilterArabic,
              ),
              _buildInfoRow('العلامة الموصى بها', _oilSpec!.recommendedBrand),
              _buildInfoRow('فترة التغيير', _oilSpec!.changeIntervalArabic),
              _buildInfoRow('رقم الفلتر', _oilSpec!.filterPartNumber),
              _buildInfoRow('عزم برغي التصريف', _oilSpec!.drainPlugTorque),
              _buildInfoRow('معيار الزيت', _oilSpec!.oilSpecStandard),
            ],
          ),
          const SizedBox(height: 16),
          _buildAlternativeBrandsCard(),
          const SizedBox(height: 16),
          _buildOilProductsButton(),
        ],
      ),
    );
  }

  Widget _buildMaintenanceTab() {
    if (_maintenanceRecords.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'لا توجد سجلات صيانة',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              'أضف أول عملية صيانة لسيارتك',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _maintenanceRecords.length,
      itemBuilder: (context, index) {
        final record = _maintenanceRecords[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue[700],
              child: const Icon(Icons.build, color: Colors.white),
            ),
            title: Text(
              record.serviceType,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('التاريخ: ${record.serviceDateArabic}'),
                Text('الكيلومتر: ${record.mileageAtService}'),
                Text('نوع الزيت: ${record.oilTypeUsed}'),
                Text('التكلفة: ${record.costFormatted}'),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: () {
                _showMaintenanceDetails(record);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
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
                Icon(icon, color: Colors.blue[700], size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
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
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModificationCard() {
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
                Icon(
                  widget.vehicle.isModified ? Icons.build : Icons.check,
                  color: widget.vehicle.isModified ? Colors.orange : Colors.green,
                ),
                const SizedBox(width: 8),
                Text(
                  'حالة التعديل',
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
              widget.vehicle.isModified ? 'السيارة معدلة' : 'السيارة غير معدلة',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: widget.vehicle.isModified ? Colors.orange : Colors.green,
              ),
            ),
            if (widget.vehicle.isModified && widget.vehicle.modifications != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'التعديلات: ${widget.vehicle.modifications}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => _showModificationDialog(),
              icon: const Icon(Icons.edit),
              label: const Text('تحديث حالة التعديل'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleStatsCard() {
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
                Icon(Icons.analytics, color: Colors.blue[700]),
                const SizedBox(width: 8),
                Text(
                  'إحصائيات السيارة',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'عمليات الصيانة',
                    _maintenanceRecords.length.toString(),
                    Icons.build,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'عمر السيارة',
                    '${DateTime.now().year - widget.vehicle.year} سنة',
                    Icons.calendar_today,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.blue[700], size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue[700],
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCompatibleOilsCard() {
    if (_engineSpec?.compatibleOilTypes.isEmpty ?? true) return const SizedBox();

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
                Icon(Icons.oil_barrel, color: Colors.blue[700]),
                const SizedBox(width: 8),
                Text(
                  'أنواع الزيت المتوافقة',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: _engineSpec!.compatibleOilTypes
                  .map((oilType) => Chip(
                        label: Text(oilType),
                        backgroundColor: Colors.blue[100],
                        labelStyle: TextStyle(color: Colors.blue[700]),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlternativeBrandsCard() {
    if (_oilSpec?.alternativeBrands.isEmpty ?? true) return const SizedBox();

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
                Icon(Icons.store, color: Colors.blue[700]),
                const SizedBox(width: 8),
                Text(
                  'العلامات البديلة',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Column(
              children: _oilSpec!.alternativeBrands
                  .map((brand) => ListTile(
                        dense: true,
                        leading: const Icon(Icons.check_circle, color: Colors.green),
                        title: Text(brand),
                        contentPadding: EdgeInsets.zero,
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOilProductsButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OilProductsScreen(
                vehicleId: widget.vehicle.id,
                oilType: _oilSpec?.oilType ?? '5W-30',
              ),
            ),
          );
        },
        icon: const Icon(Icons.shopping_cart),
        label: const Text('عرض منتجات الزيت المتاحة'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(16),
          backgroundColor: Colors.green[600],
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  void _showMaintenanceDetails(MaintenanceRecord record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(record.serviceType),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('التاريخ: ${record.serviceDateArabic}'),
            Text('الكيلومتر: ${record.mileageAtService}'),
            Text('نوع الزيت: ${record.oilTypeUsed}'),
            Text('كمية الزيت: ${record.oilQuantity} لتر'),
            Text('الفلتر المستخدم: ${record.filterUsed}'),
            Text('مكان الخدمة: ${record.serviceLocation}'),
            Text('التكلفة: ${record.costFormatted}'),
            if (record.notes != null) Text('ملاحظات: ${record.notes}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  void _showModificationDialog() {
    bool isModified = widget.vehicle.isModified;
    String modifications = widget.vehicle.modifications ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تحديث حالة التعديل'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CheckboxListTile(
              title: const Text('السيارة معدلة'),
              value: isModified,
              onChanged: (value) {
                isModified = value ?? false;
              },
            ),
            if (isModified)
              TextField(
                decoration: const InputDecoration(
                  labelText: 'وصف التعديلات',
                  hintText: 'اكتب التعديلات المثبتة',
                ),
                maxLines: 3,
                onChanged: (value) => modifications = value,
                controller: TextEditingController(text: modifications),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await CarDatabaseService.updateVehicleModifications(
                widget.vehicle.id,
                isModified,
                isModified ? modifications : null,
              );
              
              if (success) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم تحديث حالة التعديل بنجاح')),
                );
                // Refresh the screen
                _loadVehicleDetails();
              }
            },
            child: const Text('حفظ'),
          ),
        ],
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