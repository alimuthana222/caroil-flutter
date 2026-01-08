import 'package:flutter/material.dart';
import 'package:oil_finder/models/vehicle.dart';
import 'package:oil_finder/models/oil_spec.dart';
import 'package:oil_finder/models/oil_change_record.dart';
import 'package:oil_finder/services/supabase_service.dart';
import 'package:oil_finder/services/oil_change_service.dart';
import 'package:oil_finder/screens/add_oil_change_screen.dart';
import 'package:oil_finder/screens/oil_change_tracker_screen.dart';
import 'package:quickalert/quickalert.dart';
import 'package:intl/intl.dart';

class VehicleInfoScreen extends StatefulWidget {
  final Vehicle vehicle;

  const VehicleInfoScreen({Key? key, required this.vehicle}) : super(key: key);

  @override
  _VehicleInfoScreenState createState() => _VehicleInfoScreenState();
}

class _VehicleInfoScreenState extends State<VehicleInfoScreen> {
  OilSpec? _oilSpec;
  OilChangeRecord? _latestOilChange;
  bool _isLoading = true;
  bool _isLoadingOilChange = true;
  String? _debugInfo;
  List<String> _searchSteps = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadOilSpecs(),
      _loadLatestOilChange(),
    ]);
  }

  Future<void> _loadOilSpecs() async {
    print('=== OIL SPEC SEARCH STARTED ===');

    setState(() {
      _isLoading = true;
      _searchSteps = [];
      _debugInfo = null;
    });

    try {
      final vehicle = widget.vehicle;
      print('🚗 Vehicle from VIN: ${vehicle.toJson()}');

      final brand = vehicle.make?.toLowerCase().trim();
      final model = vehicle.model?.toLowerCase().trim();
      final year = vehicle.yearAsInt;

      _addSearchStep('Vehicle Info: $brand $model $year');
      print('🔍 Searching with: brand="$brand", model="$model", year=$year');

      if (brand == null || brand.isEmpty) {
        _addSearchStep('❌ Brand is missing or empty');
        setState(() {
          _isLoading = false;
          _debugInfo = 'اسم الماركة مفقود';
        });
        return;
      }

      if (model == null || model.isEmpty) {
        _addSearchStep('❌ Model is missing or empty');
        setState(() {
          _isLoading = false;
          _debugInfo = 'اسم الموديل مفقود';
        });
        return;
      }

      if (year == null) {
        _addSearchStep('❌ Year is missing or invalid');
        setState(() {
          _isLoading = false;
          _debugInfo = 'السنة مفقودة أو غير صحيحة';
        });
        return;
      }

      // Step 1: Try exact match
      _addSearchStep('🔍 Step 1: Trying exact match...');
      OilSpec? oilSpec = await SupabaseService.getOilSpecExact(brand, model, year);

      if (oilSpec != null) {
        _addSearchStep('✅ Found exact match!');
        setState(() {
          _oilSpec = oilSpec;
          _isLoading = false;
          _debugInfo = 'تم العثور على مطابقة تامة';
        });
        return;
      }

      // Step 2: Try fuzzy search
      _addSearchStep('🔍 Step 2: Trying fuzzy search...');
      oilSpec = await SupabaseService.getOilSpecFuzzy(brand, model, year);

      if (oilSpec != null) {
        _addSearchStep('✅ Found fuzzy match!');
        setState(() {
          _oilSpec = oilSpec;
          _isLoading = false;
          _debugInfo = 'تم العثور على مطابقة تقريبية';
        });
        return;
      }

      // Step 3: Try year range search
      _addSearchStep('🔍 Step 3: Trying year range search...');
      oilSpec = await SupabaseService.getOilSpecYearRange(brand, model, year);

      if (oilSpec != null) {
        _addSearchStep('✅ Found year range match!');
        setState(() {
          _oilSpec = oilSpec;
          _isLoading = false;
          _debugInfo = 'تم العثور على مطابقة في نطاق السنوات';
        });
        return;
      }

      // Step 4: Try brand-only search to see if brand exists
      _addSearchStep('🔍 Step 4: Checking if brand exists...');
      final brandExists = await SupabaseService.doesBrandExist(brand);

      if (!brandExists) {
        _addSearchStep('❌ Brand not found in database');
        setState(() {
          _isLoading = false;
          _debugInfo = 'الماركة غير موجودة في قاعدة البيانات';
        });
        return;
      }

      _addSearchStep('✅ Brand exists, checking models...');
      final modelExists = await SupabaseService.doesModelExist(brand, model);

      if (!modelExists) {
        _addSearchStep('❌ Model not found for this brand');
        setState(() {
          _isLoading = false;
          _debugInfo = 'الموديل غير موجود لهذه الماركة';
        });
        return;
      }

      _addSearchStep('✅ Model exists, year might be the issue');
      _addSearchStep('❌ No oil specifications found for this combination');

      setState(() {
        _isLoading = false;
        _debugInfo = 'لم يتم العثور على مواصفات الزيت لهذه التركيبة';
      });

    } catch (e) {
      print('❌ Error loading oil specs: $e');
      _addSearchStep('❌ Error: $e');
      setState(() {
        _isLoading = false;
        _debugInfo = 'خطأ في تحميل البيانات: $e';
      });
    }

    print('=== OIL SPEC SEARCH COMPLETED ===');
  }

  Future<void> _loadLatestOilChange() async {
    setState(() => _isLoadingOilChange = true);

    try {
      final vehicle = widget.vehicle;
      if (vehicle.make != null && vehicle.model != null && vehicle.yearAsInt != null) {
        final latestOilChange = await OilChangeService.getLatestOilChangeRecord(
          vehicleMake: vehicle.make!,
          vehicleModel: vehicle.model!,
          vehicleYear: vehicle.yearAsInt!,
          vehicleVin: vehicle.vin,
        );

        setState(() {
          _latestOilChange = latestOilChange;
          _isLoadingOilChange = false;
        });
      } else {
        setState(() => _isLoadingOilChange = false);
      }
    } catch (e) {
      print('Error loading latest oil change: $e');
      setState(() => _isLoadingOilChange = false);
    }
  }

  void _addSearchStep(String step) {
    setState(() {
      _searchSteps.add(step);
    });
    print(step);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('معلومات السيارة والزيت'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadData,
          ),
          IconButton(
            icon: Icon(Icons.bug_report),
            onPressed: _showDebugInfo,
          ),
        ],
      ),
      body: _isLoading
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('جاري البحث عن مواصفات الزيت...'),
            SizedBox(height: 16),
            // Show search progress
            Container(
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.symmetric(horizontal: 32),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: _searchSteps.map((step) => Padding(
                  padding: EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    step,
                    style: TextStyle(fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                )).toList(),
              ),
            ),
          ],
        ),
      )
          : SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vehicle Information Card
            Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.directions_car, color: Colors.green, size: 28),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'معلومات السيارة',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.green[800],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    _buildInfoRow('الماركة', widget.vehicle.make ?? 'غير محدد'),
                    _buildInfoRow('الموديل', widget.vehicle.model ?? 'غير محدد'),
                    _buildInfoRow('السنة', widget.vehicle.year ?? 'غير محدد'),
                    if (widget.vehicle.trim != null)
                      _buildInfoRow('الفئة', widget.vehicle.trim!),
                    if (widget.vehicle.engineSize != null)
                      _buildInfoRow('حجم المحرك', widget.vehicle.engineSize!),
                    if (widget.vehicle.engineType != null)
                      _buildInfoRow('نوع المحرك', widget.vehicle.engineType!),
                    if (widget.vehicle.vin != null)
                      _buildInfoRow('رقم الشاصي', widget.vehicle.vin!),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16),

            // Oil Change Status Card
            if (!_isLoadingOilChange) _buildOilChangeStatusCard(),

            SizedBox(height: 16),

            // Oil Specifications Card or Error Card
            if (_oilSpec != null) ...[
              Card(
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.local_gas_station, color: Colors.blue, size: 28),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'مواصفات الزيت المطلوب',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[800],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),

                      // Oil Type
                      if (_oilSpec!.oilType != null)
                        _buildHighlightedInfo(
                          'نوع الزيت',
                          _oilSpec!.oilType!,
                          Icons.oil_barrel,
                          Colors.orange,
                        ),
                      SizedBox(height: 12),

                      // Oil Quantity with Filter
                      if (_oilSpec!.oilQtyWithFilter != null)
                        _buildHighlightedInfo(
                          'كمية الزيت مع الفلتر',
                          '${_oilSpec!.oilQtyWithFilter!.toStringAsFixed(1)}L',
                          Icons.format_color_fill,
                          Colors.green,
                        ),
                      SizedBox(height: 12),

                      // Oil Quantity without Filter
                      if (_oilSpec!.oilQtyWithoutFilter != null)
                        _buildHighlightedInfo(
                          'كمية الزيت بدون فلتر',
                          '${_oilSpec!.oilQtyWithoutFilter!.toStringAsFixed(1)}L',
                          Icons.opacity,
                          Colors.blue,
                        ),

                      // Engine Information
                      if (_oilSpec!.engineInfo != 'غير محدد') ...[
                        SizedBox(height: 12),
                        _buildInfoContainer(
                          'معلومات المحرك',
                          _oilSpec!.engineInfo,
                          Icons.engineering,
                          Colors.purple,
                        ),
                      ],

                      // Notes
                      if (_oilSpec!.notes != null && _oilSpec!.notes!.isNotEmpty) ...[
                        SizedBox(height: 12),
                        _buildNotesContainer(_oilSpec!.notes!),
                      ],
                    ],
                  ),
                ),
              ),
            ] else ...[
              Card(
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.orange,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'لم يتم العثور على مواصفات الزيت',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 12),
                      Text(
                        _debugInfo ?? 'لم نجد مواصفات الزيت لهذه السيارة في قاعدة البيانات',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'البحث عن: ${widget.vehicle.make} ${widget.vehicle.model} ${widget.vehicle.year}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _loadOilSpecs,
                            icon: Icon(Icons.search),
                            label: Text('إعادة البحث'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                            ),
                          ),
                          SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: _showDebugInfo,
                            icon: Icon(Icons.bug_report),
                            label: Text('تفاصيل'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],

            SizedBox(height: 24),

            // Action Buttons
            Column(
              children: [
                // Oil Change Actions
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final result = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddOilChangeScreen(vehicle: widget.vehicle),
                            ),
                          );
                          if (result == true) {
                            _loadLatestOilChange();
                          }
                        },
                        icon: Icon(Icons.add),
                        label: Text('تسجيل تغيير زيت'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OilChangeTrackerScreen(),
                            ),
                          );
                        },
                        icon: Icon(Icons.history),
                        label: Text('سجل التغيير'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                // Navigation Actions
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.popUntil(context, (route) => route.isFirst);
                        },
                        icon: Icon(Icons.home),
                        label: Text('العودة للرئيسية'),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _shareInfo,
                      icon: Icon(Icons.share),
                      label: Text('مشاركة'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOilChangeStatusCard() {
    if (_latestOilChange == null) {
      return Card(
        elevation: 4,
        color: Colors.blue[50],
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                Icons.info_outline,
                size: 48,
                color: Colors.blue[600],
              ),
              SizedBox(height: 12),
              Text(
                'لم يتم تسجيل تغيير زيت لهذه السيارة',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'ابدأ بتسجيل أول تغيير زيت للحصول على تذكيرات',
                style: TextStyle(color: Colors.blue[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final record = _latestOilChange!;
    Color statusColor = Colors.green;
    IconData statusIcon = Icons.check_circle;
    String statusText = 'في الموعد';

    if (record.isOverdue) {
      statusColor = Colors.red;
      statusIcon = Icons.warning;
      statusText = 'متأخر ${record.daysUntilNextChange.abs()} يوم';
    } else if (record.isDueSoon) {
      statusColor = Colors.orange;
      statusIcon = Icons.schedule;
      statusText = 'قريب الموعد (${record.daysUntilNextChange} أيام)';
    }

    return Card(
      elevation: 4,
      color: statusColor.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: statusColor.withOpacity(0.3)),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(statusIcon, color: statusColor, size: 28),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'حالة تغيير الزيت',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildOilChangeDetailItem(
                    'آخر تغيير',
                    record.formattedChangeDate,
                    Icons.history,
                  ),
                ),
                Expanded(
                  child: _buildOilChangeDetailItem(
                    'التغيير القادم',
                    record.formattedNextDueDate,
                    Icons.schedule,
                  ),
                ),
              ],
            ),
            if (record.mileage != null || record.oilType != null) ...[
              SizedBox(height: 12),
              Row(
                children: [
                  if (record.mileage != null)
                    Expanded(
                      child: _buildOilChangeDetailItem(
                        'الكيلومترات',
                        '${record.mileage} كم',
                        Icons.speed,
                      ),
                    ),
                  if (record.oilType != null)
                    Expanded(
                      child: _buildOilChangeDetailItem(
                        'نوع الزيت',
                        record.oilType!,
                        Icons.oil_barrel,
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOilChangeDetailItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightedInfo(String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: color.withOpacity(0.8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoContainer(String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: color,
              fontSize: 14,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesContainer(String notes) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: Colors.amber[700], size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ملاحظات مهمة:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber[700],
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  notes,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.amber[800],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDebugInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('معلومات التصحيح'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('معلومات السيارة من VIN:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('الماركة: ${widget.vehicle.make}'),
              Text('الموديل: ${widget.vehicle.model}'),
              Text('السنة: ${widget.vehicle.year}'),
              Text('السنة كرقم: ${widget.vehicle.yearAsInt}'),
              SizedBox(height: 16),
              Text('خطوات البحث:', style: TextStyle(fontWeight: FontWeight.bold)),
              ..._searchSteps.map((step) => Padding(
                padding: EdgeInsets.symmetric(vertical: 2),
                child: Text(step, style: TextStyle(fontSize: 12)),
              )),
              SizedBox(height: 16),
              Text('النتيجة:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(_debugInfo ?? 'لا توجد معلومات'),
              Text('مواصفات الزيت: ${_oilSpec != null ? 'موجودة' : 'غير موجودة'}'),
              SizedBox(height: 16),
              Text('حالة تغيير الزيت:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('آخر تغيير: ${_latestOilChange != null ? _latestOilChange!.formattedChangeDate : 'لا يوجد'}'),
              if (_latestOilChange != null) ...[
                Text('التغيير القادم: ${_latestOilChange!.formattedNextDueDate}'),
                Text('الحالة: ${_latestOilChange!.statusText}'),
                Text('أيام متبقية: ${_latestOilChange!.daysUntilNextChange}'),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  void _shareInfo() {
    _showAlert(QuickAlertType.info, 'ميزة المشاركة ستكون متاحة قريباً');
  }

  void _showAlert(QuickAlertType type, String message) {
    QuickAlert.show(
      context: context,
      type: type,
      text: message,
      confirmBtnText: 'موافق',
    );
  }
}