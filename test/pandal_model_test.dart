import 'package:flutter_test/flutter_test.dart';
import 'package:pandal_hopping_ghatal/models/pandal_queue_model.dart';

void main() {
  group('PandalQueueData Model Tests', () {
    test('Calculates waiting time and crowd label correctly', () {
      final pandal = PandalQueueData(
        id: 'test_1',
        name: 'Ghatal Test Pandal',
        zone: 'Central',
        distance: '0.8 km',
        peopleInLine: 60,
        entryRatePerMinute: 12,
        maxCapacity: 200,
        queueLengthMeters: 25,
        gateStatus: 'Open',
        lastUpdated: DateTime.now(),
        gates: [],
      );

      expect(pandal.estimatedWaitMinutes, 5);
      expect(pandal.crowdLabel, 'Moderate');
    });

    test('Reports correct crowd status indicators for low and high capacity', () {
      final lowCrowdPandal = PandalQueueData(
        id: 'test_low',
        name: 'Low Crowd Pandal',
        zone: 'Central',
        distance: '0.5 km',
        peopleInLine: 20,
        entryRatePerMinute: 10,
        maxCapacity: 200,
        queueLengthMeters: 10,
        gateStatus: 'Open',
        lastUpdated: DateTime.now(),
        gates: [],
      );
      expect(lowCrowdPandal.crowdLabel, 'Low');

      final highCrowdPandal = PandalQueueData(
        id: 'test_high',
        name: 'High Crowd Pandal',
        zone: 'Central',
        distance: '1.2 km',
        peopleInLine: 185,
        entryRatePerMinute: 10,
        maxCapacity: 200,
        queueLengthMeters: 80,
        gateStatus: 'Crowded',
        lastUpdated: DateTime.now(),
        gates: [],
      );
      expect(highCrowdPandal.crowdLabel, 'Peak Crowd');
    });

    test('Handles JSON serialization and deserialization cleanly', () {
      final sample = {
        'id': 'pandal_json_test',
        'name': 'Bazar Sarbojonin',
        'zone': 'Bazar Zone',
        'address': 'Main Market',
        'lat': 22.6685,
        'lng': 87.7247,
        'distance': '1.2 km',
        'peopleInLine': 80,
        'lastDelta': 5,
        'trend': 'increasing',
        'maxCapacity': 250,
        'entryRatePerMinute': 15,
        'queueLengthMeters': 35,
        'gateStatus': 'Open',
        'theme': 'Traditional Art',
      };

      final pandal = PandalQueueData.fromJson(sample);
      expect(pandal.id, 'pandal_json_test');
      expect(pandal.name, 'Bazar Sarbojonin');
      expect(pandal.peopleInLine, 80);

      final json = pandal.toJson();
      expect(json['id'], 'pandal_json_test');
      expect(json['name'], 'Bazar Sarbojonin');
      expect(json['peopleInLine'], 80);
    });
  });
}
