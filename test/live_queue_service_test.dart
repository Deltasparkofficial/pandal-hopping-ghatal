import 'package:flutter_test/flutter_test.dart';
import 'package:pandal_hopping_ghatal/services/live_queue_service.dart';

void main() {
  group('LiveQueueService Unit Tests', () {
    late LiveQueueService service;

    setUp(() {
      service = LiveQueueService();
    });

    test('Initializes with default pandals and correct active Vercel URL', () {
      expect(service.pandals.isNotEmpty, true);
      expect(service.vercelUrl, 'https://pandal-hopping-ghatal-deltaspark.vercel.app');
    });

    test('Can update and persist Vercel URL in service state', () {
      const customUrl = 'https://custom-pandal-url.vercel.app';
      service.updateVercelUrl(customUrl);
      expect(service.vercelUrl, customUrl);
    });

    test('Can find pandal by ID correctly', () {
      final first = service.pandals.first;
      final found = service.getPandalById(first.id);
      expect(found, isNotNull);
      expect(found?.name, first.name);
    });
  });
}
