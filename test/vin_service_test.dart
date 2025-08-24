import 'package:flutter_test/flutter_test.dart';
import 'package:car_oil/services/vin_service.dart';

void main() {
  group('VinService Tests', () {
    test('getOilRecommendation should return default recommendation for unknown make', () {
      final vehicleInfo = {
        'Make': 'UnknownMake',
        'Model': 'TestModel',
        'Model Year': '2020',
      };

      final recommendation = VinService.getOilRecommendation(vehicleInfo);

      expect(recommendation['oilType'], '5W-30');
      expect(recommendation['capacity'], '4.5 لتر');
      expect(recommendation['brand'], 'أي علامة تجارية معتمدة');
      expect(recommendation['interval'], '10,000 كيلومتر أو 6 أشهر');
    });

    test('getOilRecommendation should return Toyota-specific recommendation', () {
      final vehicleInfo = {
        'Make': 'TOYOTA',
        'Model': 'Camry',
        'Model Year': '2020',
      };

      final recommendation = VinService.getOilRecommendation(vehicleInfo);

      expect(recommendation['oilType'], '0W-20');
      expect(recommendation['capacity'], '4.4 لتر');
      expect(recommendation['brand'], 'Toyota Genuine أو Mobil 1');
      expect(recommendation['interval'], '10,000 كيلومتر');
    });

    test('getOilRecommendation should return Honda-specific recommendation', () {
      final vehicleInfo = {
        'Make': 'Honda',
        'Model': 'Civic',
        'Model Year': '2019',
      };

      final recommendation = VinService.getOilRecommendation(vehicleInfo);

      expect(recommendation['oilType'], '0W-20');
      expect(recommendation['capacity'], '4.2 لتر');
      expect(recommendation['brand'], 'Honda Genuine أو Castrol');
      expect(recommendation['interval'], '10,000 كيلومتر');
    });

    test('getOilRecommendation should return BMW-specific recommendation', () {
      final vehicleInfo = {
        'Make': 'BMW',
        'Model': '320i',
        'Model Year': '2018',
      };

      final recommendation = VinService.getOilRecommendation(vehicleInfo);

      expect(recommendation['oilType'], '5W-30');
      expect(recommendation['capacity'], '5.0 لتر');
      expect(recommendation['brand'], 'BMW Genuine أو Shell');
      expect(recommendation['interval'], '15,000 كيلومتر');
    });

    test('getOilRecommendation should handle empty vehicle info', () {
      final vehicleInfo = <String, dynamic>{};

      final recommendation = VinService.getOilRecommendation(vehicleInfo);

      expect(recommendation['oilType'], '5W-30');
      expect(recommendation['capacity'], '4.5 لتر');
      expect(recommendation['brand'], 'أي علامة تجارية معتمدة');
      expect(recommendation['interval'], '10,000 كيلومتر أو 6 أشهر');
    });
  });
}