import 'package:flutter/material.dart';
import '../config/supabase_config.dart';

class OilProductsScreen extends StatefulWidget {
  final String vehicleId;
  final String oilType;

  const OilProductsScreen({
    super.key,
    required this.vehicleId,
    required this.oilType,
  });

  @override
  State<OilProductsScreen> createState() => _OilProductsScreenState();
}

class _OilProductsScreenState extends State<OilProductsScreen> {
  List<Map<String, dynamic>> _oilProducts = [];
  bool _isLoading = true;
  String _selectedFilter = 'all';

  final Map<String, String> _filterOptions = {
    'all': 'جميع المنتجات',
    'synthetic': 'زيت صناعي',
    'semi_synthetic': 'زيت نصف صناعي',
    'conventional': 'زيت تقليدي',
  };

  @override
  void initState() {
    super.initState();
    _loadOilProducts();
  }

  Future<void> _loadOilProducts() async {
    setState(() => _isLoading = true);

    try {
      final response = await SupabaseConfig.client
          .from('oil_products')
          .select()
          .eq('oil_type', widget.oilType)
          .order('brand')
          .order('product_name');

      setState(() {
        _oilProducts = (response as List).cast<Map<String, dynamic>>();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في تحميل المنتجات: $e')),
        );
      }
    }
  }

  List<Map<String, dynamic>> get _filteredProducts {
    if (_selectedFilter == 'all') return _oilProducts;

    return _oilProducts.where((product) {
      switch (_selectedFilter) {
        case 'synthetic':
          return product['is_synthetic'] == true;
        case 'semi_synthetic':
          return product['is_semi_synthetic'] == true;
        case 'conventional':
          return product['is_conventional'] == true;
        default:
          return true;
      }
    }).toList();
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
          'منتجات زيت ${widget.oilType}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildFilterChips(),
                Expanded(
                  child: _filteredProducts.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredProducts.length,
                          itemBuilder: (context, index) {
                            final product = _filteredProducts[index];
                            return _buildProductCard(product);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _filterOptions.entries.map((entry) {
            final isSelected = _selectedFilter == entry.key;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(entry.value),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedFilter = entry.key;
                  });
                },
                backgroundColor: Colors.grey[200],
                selectedColor: Colors.blue[100],
                labelStyle: TextStyle(
                  color: isSelected ? Colors.blue[700] : Colors.grey[700],
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product['brand'] ?? 'غير محدد',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                      Text(
                        product['product_name'] ?? 'غير محدد',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (product['price_per_liter'] != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${product['price_per_liter']} ${product['currency'] ?? 'USD'}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            _buildProductDetail('نوع الزيت', product['oil_type']),
            _buildProductDetail('اللزوجة', product['viscosity']),
            _buildProductDetail('المواصفة', product['specification']),
            const SizedBox(height: 12),
            _buildOilTypeChips(product),
            if (product['performance_features'] != null) ...[
              const SizedBox(height: 12),
              _buildPerformanceFeatures(product['performance_features']),
            ],
            if (product['availability_regions'] != null) ...[
              const SizedBox(height: 8),
              _buildAvailabilityRegions(product['availability_regions']),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProductDetail(String label, dynamic value) {
    if (value == null) return const SizedBox();
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.toString(),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOilTypeChips(Map<String, dynamic> product) {
    List<Widget> chips = [];

    if (product['is_synthetic'] == true) {
      chips.add(_buildTypeChip('صناعي', Colors.blue));
    }
    if (product['is_semi_synthetic'] == true) {
      chips.add(_buildTypeChip('نصف صناعي', Colors.orange));
    }
    if (product['is_conventional'] == true) {
      chips.add(_buildTypeChip('تقليدي', Colors.green));
    }

    if (chips.isEmpty) return const SizedBox();

    return Wrap(
      spacing: 8,
      children: chips,
    );
  }

  Widget _buildTypeChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildPerformanceFeatures(dynamic features) {
    if (features == null) return const SizedBox();

    List<String> featureList = [];
    if (features is List) {
      featureList = features.cast<String>();
    } else if (features is String) {
      featureList = [features];
    }

    if (featureList.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'المميزات:',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        ...featureList.map((feature) => Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(color: Colors.grey)),
                  Expanded(
                    child: Text(
                      feature,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildAvailabilityRegions(dynamic regions) {
    if (regions == null) return const SizedBox();

    List<String> regionList = [];
    if (regions is List) {
      regionList = regions.cast<String>();
    }

    if (regionList.isEmpty) return const SizedBox();

    return Row(
      children: [
        const Icon(Icons.location_on, size: 12, color: Colors.grey),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            'متوفر في: ${regionList.join(', ')}',
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.oil_barrel,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            'لا توجد منتجات متاحة',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'لا توجد منتجات زيت ${widget.oilType} متاحة حالياً',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadOilProducts,
            icon: const Icon(Icons.refresh),
            label: const Text('تحديث'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تصفية المنتجات'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _filterOptions.entries.map((entry) {
            return RadioListTile<String>(
              title: Text(entry.value),
              value: entry.key,
              groupValue: _selectedFilter,
              onChanged: (value) {
                setState(() {
                  _selectedFilter = value ?? 'all';
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
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
}