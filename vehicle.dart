class Vehicle {
  final String? make;
  final String? model;
  final String? year;
  final String? trim;
  final String? engineSize;
  final String? engineType;
  final String? vin;

  Vehicle({
    this.make,
    this.model,
    this.year,
    this.trim,
    this.engineSize,
    this.engineType,
    this.vin,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      make: json['Make']?.toString(),
      model: json['Model']?.toString(),
      year: json['ModelYear']?.toString(),
      trim: json['Trim']?.toString(),
      engineSize: json['DisplacementL']?.toString(),
      engineType: json['EngineConfiguration']?.toString(),
      vin: json['VIN']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'make': make,
      'model': model,
      'year': year,
      'trim': trim,
      'engineSize': engineSize,
      'engineType': engineType,
      'vin': vin,
    };
  }

  String get displayName {
    List<String> parts = [];
    if (make != null) parts.add(make!);
    if (model != null) parts.add(model!);
    if (trim != null) parts.add(trim!);
    if (year != null) parts.add(year!);
    return parts.join(' ');
  }

  int? get yearAsInt {
    if (year == null) return null;
    return int.tryParse(year!);
  }
}