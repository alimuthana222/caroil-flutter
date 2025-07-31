import 'package:flutter/material.dart';
import 'package:car_oil/services/supabase_service.dart';
import 'package:car_oil/models/vehicle.dart';
import 'package:car_oil/screens/vehicle_info_screen.dart';

class ManualSelectionScreen extends StatefulWidget {
  @override
  _ManualSelectionScreenState createState() => _ManualSelectionScreenState();
}

class _ManualSelectionScreenState extends State<ManualSelectionScreen> {
  String? _selectedBrand;
  String? _selectedModel;
  int? _selectedYear;
  String? _selectedTrim;

  List<String> _brands = [];
  List<String> _models = [];
  List<int> _years = [];
  List<String> _trims = [];

  bool _isLoadingBrands = true;
  bool _isLoadingModels = false;
  bool _isLoadingYears = false;
  bool _isLoadingTrims = false;

  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadBrands();
  }

  Future<void> _loadBrands() async {
    setState(() {
      _isLoadingBrands = true;
      _errorMessage = null;
    });

    try {
      print('🔄 Loading brands...');
      final brands = await SupabaseService.getCarBrands();
      print('✅ Loaded ${brands.length} brands: $brands');

      if (mounted) {
        setState(() {
          _brands = brands;
          _isLoadingBrands = false;
        });

        if (brands.isEmpty) {
          setState(() {
            _errorMessage = 'لا توجد ماركات في قاعدة البيانات. تحقق من اتصال الإنترنت.';
          });
        }
      }
    } catch (e) {
      print('❌ Error loading brands: $e');
      if (mounted) {
        setState(() {
          _isLoadingBrands = false;
          _errorMessage = 'فشل في تحميل الماركات: $e';
        });
      }
    }
  }

  Future<void> _loadModels(String brand) async {
    setState(() {
      _isLoadingModels = true;
      _errorMessage = null;
      _selectedModel = null;
      _selectedYear = null;
      _selectedTrim = null;
      _models = [];
      _years = [];
      _trims = [];
    });

    try {
      print('🔄 Loading models for: "$brand"');

      // Debug the selected brand
      await SupabaseService.debugBrandData(brand);

      final models = await SupabaseService.getCarModels(brand);
      print('✅ Loaded ${models.length} models: $models');

      if (mounted) {
        setState(() {
          _models = models;
          _isLoadingModels = false;
        });

        if (models.isEmpty) {
          setState(() {
            _errorMessage = 'لا توجد موديلات للماركة "$brand". تحقق من أن البيانات موجودة في قاعدة البيانات.';
          });
        }
      }
    } catch (e) {
      print('❌ Error loading models: $e');
      if (mounted) {
        setState(() {
          _isLoadingModels = false;
          _errorMessage = 'فشل في تحميل الموديلات: $e';
        });
      }
    }
  }

  Future<void> _loadYears(String brand, String model) async {
    setState(() {
      _isLoadingYears = true;
      _errorMessage = null;
      _selectedYear = null;
      _selectedTrim = null;
      _years = [];
      _trims = [];
    });

    try {
      print('🔄 Loading years for: "$brand" "$model"');
      final years = await SupabaseService.getCarYears(brand, model);
      print('✅ Loaded ${years.length} years: $years');

      if (mounted) {
        setState(() {
          _years = years;
          _isLoadingYears = false;
        });

        if (years.isEmpty) {
          setState(() {
            _errorMessage = 'لا توجد سنوات للموديل "$model" من الماركة "$brand".';
          });
        }
      }
    } catch (e) {
      print('❌ Error loading years: $e');
      if (mounted) {
        setState(() {
          _isLoadingYears = false;
          _errorMessage = 'فشل في تحميل السنوات: $e';
        });
      }
    }
  }

  Future<void> _loadTrims(String brand, String model, int year) async {
    setState(() {
      _isLoadingTrims = true;
      _selectedTrim = null;
      _trims = [];
    });

    try {
      print('🔄 Loading trims for: "$brand" "$model" $year');
      final trims = await SupabaseService.getCarTrims(brand, model, year);
      print('✅ Loaded ${trims.length} trims: $trims');

      if (mounted) {
        setState(() {
          _trims = trims;
          _isLoadingTrims = false;
        });
      }
    } catch (e) {
      print('❌ Error loading trims: $e');
      if (mounted) {
        setState(() => _isLoadingTrims = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('اختر موديل السيارة'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadBrands,
            tooltip: 'إعادة تحميل البيانات',
          ),
          IconButton(
            icon: Icon(Icons.bug_report),
            onPressed: _showDebugInfo,
            tooltip: 'معلومات التصحيح',
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Error Message Card
            if (_errorMessage != null)
              Card(
                color: Colors.red[50],
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(Icons.error, color: Colors.red),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red[700]),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () => setState(() => _errorMessage = null),
                      ),
                    ],
                  ),
                ),
              ),

            // Loading info card
            if (_isLoadingBrands)
              Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircularProgressIndicator(strokeWidth: 2),
                      SizedBox(width: 12),
                      Text('جاري تحميل البيانات ...'),
                    ],
                  ),
                ),
              ),

            SizedBox(height: 16),

            // Brand Selection
            _buildSectionTitle('الماركة (${_brands.length} متوفر)'),
            SizedBox(height: 8),
            _isLoadingBrands
                ? _buildLoadingDropdown()
                : _buildDropdown<String>(
              value: _selectedBrand,
              hint: 'اختر الماركة',
              items: _brands,
              onChanged: (value) {
                if (value != _selectedBrand) {
                  setState(() => _selectedBrand = value);
                  if (value != null) _loadModels(value);
                }
              },
            ),

            SizedBox(height: 16),

            // Model Selection
            _buildSectionTitle('الموديل (${_models.length} متوفر)'),
            SizedBox(height: 8),
            _isLoadingModels
                ? _buildLoadingDropdown()
                : _buildDropdown<String>(
              value: _selectedModel,
              hint: _selectedBrand == null
                  ? 'اختر الماركة أولاً'
                  : (_models.isEmpty ? 'لا توجد موديلات متاحة' : 'اختر الموديل'),
              items: _models,
              enabled: _selectedBrand != null && !_isLoadingModels && _models.isNotEmpty,
              onChanged: (value) {
                if (value != _selectedModel) {
                  setState(() => _selectedModel = value);
                  if (value != null && _selectedBrand != null) {
                    _loadYears(_selectedBrand!, value);
                  }
                }
              },
            ),

            SizedBox(height: 16),

            // Year Selection
            _buildSectionTitle('السنة (${_years.length} متوفر)'),
            SizedBox(height: 8),
            _isLoadingYears
                ? _buildLoadingDropdown()
                : _buildDropdown<int>(
              value: _selectedYear,
              hint: _selectedModel == null
                  ? 'اختر الموديل أولاً'
                  : (_years.isEmpty ? 'لا توجد سنوات متاحة' : 'اختر السنة'),
              items: _years,
              enabled: _selectedModel != null && !_isLoadingYears && _years.isNotEmpty,
              onChanged: (value) {
                if (value != _selectedYear) {
                  setState(() => _selectedYear = value);
                  if (value != null && _selectedBrand != null && _selectedModel != null) {
                    _loadTrims(_selectedBrand!, _selectedModel!, value);
                  }
                }
              },
            ),

            SizedBox(height: 16),

            // Trim Selection (Optional)
            if (_trims.isNotEmpty || _isLoadingTrims) ...[
              _buildSectionTitle('الفئة (اختياري - ${_trims.length} متوفر)'),
              SizedBox(height: 8),
              _isLoadingTrims
                  ? _buildLoadingDropdown()
                  : _buildDropdown<String>(
                value: _selectedTrim,
                hint: 'اختر الفئة (اختياري)',
                items: _trims,
                enabled: _selectedYear != null && !_isLoadingTrims,
                onChanged: (value) {
                  setState(() => _selectedTrim = value);
                },
              ),
              SizedBox(height: 16),
            ],

            Spacer(),

            // Selection summary
            if (_selectedBrand != null || _selectedModel != null || _selectedYear != null)
              Card(
                color: Colors.green.withOpacity(0.1),
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('الاختيار الحالي:', style: TextStyle(fontWeight: FontWeight.bold)),
                      if (_selectedBrand != null) Text('الماركة: $_selectedBrand'),
                      if (_selectedModel != null) Text('الموديل: $_selectedModel'),
                      if (_selectedYear != null) Text('السنة: $_selectedYear'),
                      if (_selectedTrim != null) Text('الفئة: $_selectedTrim'),
                    ],
                  ),
                ),
              ),

            SizedBox(height: 16),

            // Search Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _canSearch() ? _searchOilSpecs : null,
                icon: Icon(Icons.search),
                label: Text('ابحث عن الزيت المناسب'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: Colors.green[800],
      ),
    );
  }

  Widget _buildLoadingDropdown() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[50],
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 8),
            Text('جاري التحميل...', style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T? value,
    required String hint,
    required List<T> items,
    required ValueChanged<T?>? onChanged,
    bool enabled = true,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      hint: Text(hint),
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: !enabled,
        fillColor: !enabled ? Colors.grey[100] : Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: items.map((item) {
        return DropdownMenuItem<T>(
          value: item,
          child: Text(
            item.toString(),
            style: TextStyle(
              color: enabled ? Colors.black : Colors.grey[600],
            ),
          ),
        );
      }).toList(),
      onChanged: enabled ? onChanged : null,
      isExpanded: true,
    );
  }

  bool _canSearch() {
    return _selectedBrand != null &&
        _selectedModel != null &&
        _selectedYear != null &&
        !_isLoadingBrands &&
        !_isLoadingModels &&
        !_isLoadingYears;
  }

  void _searchOilSpecs() {
    if (!_canSearch()) return;

    final vehicle = Vehicle(
      make: _selectedBrand,
      model: _selectedModel,
      year: _selectedYear?.toString(),
      trim: _selectedTrim,
    );

    print('🔍 Searching with vehicle: ${vehicle.toJson()}');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VehicleInfoScreen(vehicle: vehicle),
      ),
    );
  }

  void _showDebugInfo() async {
    try {
      final allData = await SupabaseService.getAllVehicleData();

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('معلومات قاعدة البيانات'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('إجمالي السجلات: ${allData.length}'),
                SizedBox(height: 8),
                Text('الماركات المحملة: ${_brands.length}'),
                Text('الموديلات المحملة: ${_models.length}'),
                Text('السنوات المحملة: ${_years.length}'),
                Text('الفئات المحملة: ${_trims.length}'),
                SizedBox(height: 16),
                Text('الاختيار الحالي:'),
                Text('الماركة: ${_selectedBrand ?? "غير محدد"}'),
                Text('الموديل: ${_selectedModel ?? "غير محدد"}'),
                Text('السنة: ${_selectedYear ?? "غير محدد"}'),
                Text('الفئة: ${_selectedTrim ?? "غير محدد"}'),
                SizedBox(height: 16),
                if (allData.isNotEmpty) ...[
                  Text('عينة من البيانات:'),
                  SizedBox(height: 8),
                  ...allData.take(5).map((data) => Padding(
                    padding: EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      '${data['brand']} ${data['model']} ${data['year']}',
                      style: TextStyle(fontSize: 12, fontFamily: 'monospace'),
                    ),
                  )),
                ],
                SizedBox(height: 16),
                if (_selectedBrand != null) ...[
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      await SupabaseService.debugBrandData(_selectedBrand!);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('تحقق من Console للتفاصيل')),
                      );
                    },
                    child: Text('Debug Selected Brand'),
                  ),
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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في جلب معلومات التصحيح: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}