class OilSpec {
  final String? id;
  final String brand;
  final String model;
  final String? trim;
  final int year;
  final String? engine;
  final int? cylinders;
  final String? oilType;
  final double? oilQtyWithFilter;
  final double? oilQtyWithoutFilter;
  final String? notes;

  OilSpec({
    this.id,
    required this.brand,
    required this.model,
    this.trim,
    required this.year,
    this.engine,
    this.cylinders,
    this.oilType,
    this.oilQtyWithFilter,
    this.oilQtyWithoutFilter,
    this.notes,
  });

  factory OilSpec.fromJson(Map<String, dynamic> json) {
    return OilSpec(
      id: json['id']?.toString(),
      brand: json['brand'] ?? '',
      model: json['model'] ?? '',
      trim: json['trim'],
      year: json['year'] ?? 0,
      engine: json['engine'],
      cylinders: json['cylinders'],
      oilType: json['oil_type'],
      oilQtyWithFilter: json['oil_qty_with_filter']?.toDouble(),
      oilQtyWithoutFilter: json['oil_qty_without_filter']?.toDouble(),
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'brand': brand,
      'model': model,
      'trim': trim,
      'year': year,
      'engine': engine,
      'cylinders': cylinders,
      'oil_type': oilType,
      'oil_qty_with_filter': oilQtyWithFilter,
      'oil_qty_without_filter': oilQtyWithoutFilter,
      'notes': notes,
    };
  }

  String get formattedOilType => oilType ?? 'غير محدد';

  String get formattedQtyWithFilter =>
      oilQtyWithFilter != null ? '${oilQtyWithFilter!.toStringAsFixed(1)}L' : 'غير محدد';

  String get formattedQtyWithoutFilter =>
      oilQtyWithoutFilter != null ? '${oilQtyWithoutFilter!.toStringAsFixed(1)}L' : 'غير محدد';

  String get engineInfo {
    List<String> parts = [];
    if (engine != null) parts.add(engine!);
    if (cylinders != null) parts.add('${cylinders} أسطوانة');
    return parts.isNotEmpty ? parts.join(' - ') : 'غير محدد';
  }
}