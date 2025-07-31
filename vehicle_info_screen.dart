import 'package:flutter/material.dart';
import 'package:car_oil/models/vehicle.dart';
import 'package:car_oil/models/oil_spec.dart';
import 'package:car_oil/services/supabase_service.dart';
import 'package:quickalert/quickalert.dart';

class VehicleInfoScreen extends StatefulWidget {
  final Vehicle vehicle;

  const VehicleInfoScreen({Key? key, required this.vehicle}) : super(key: key);

  @override
  _VehicleInfoScreenState createState() => _VehicleInfoScreenState();
}

class _VehicleInfoScreenState extends State<VehicleInfoScreen> {
  OilSpec? _oilSpec;
  bool _isLoading = true;
  String? _debugInfo;
  List<String> _searchSteps = [];

  @override
  void initState() {
    super.initState();
    _loadOilSpecs();
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
            onPressed: _loadOilSpecs,
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
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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