import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/pandal_queue_model.dart';

class CrowdAlertItem {
  final String id;
  final String title;
  final String message;
  final String level; // info, warning, danger
  final DateTime timestamp;
  final bool active;

  CrowdAlertItem({
    required this.id,
    required this.title,
    required this.message,
    required this.level,
    required this.timestamp,
    required this.active,
  });

  factory CrowdAlertItem.fromJson(Map<String, dynamic> json) {
    return CrowdAlertItem(
      id: json['id'] ?? '',
      title: json['title'] ?? 'Alert',
      message: json['message'] ?? '',
      level: json['level'] ?? 'info',
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      active: json['active'] ?? true,
    );
  }
}

class LiveQueueService extends ChangeNotifier {
  static final LiveQueueService _instance = LiveQueueService._internal();
  factory LiveQueueService() => _instance;

  static const String backendBaseUrl = 'http://localhost:5000';

  Timer? _timer;
  final Random _rng = Random();
  bool _isLiveStreaming = true;
  DateTime _lastHeartbeat = DateTime.now();
  bool _isBackendConnected = false;

  bool get isLiveStreaming => _isLiveStreaming;
  DateTime get lastHeartbeat => _lastHeartbeat;
  bool get isBackendConnected => _isBackendConnected;

  List<CrowdAlertItem> _alerts = [];
  List<CrowdAlertItem> get alerts => List.unmodifiable(_alerts);

  List<PandalQueueData> _pandals = [
    PandalQueueData(
      id: 'ghatal_bazar',
      name: 'Ghatal Bazar Sarbojonin',
      zone: 'Ghatal Central Zone',
      address: 'Bazar Main Road, Ghatal, Paschim Medinipur',
      lat: 22.6685,
      lng: 87.7247,
      distance: '0.3 km',
      theme: 'Traditional Ekchala & Brass Artistry',
      peopleInLine: 146,
      lastDelta: 4,
      trend: CrowdTrend.increasing,
      maxCapacity: 220,
      entryRatePerMinute: 14,
      queueLengthMeters: 62,
      gateStatus: 'Open',
      lastUpdated: DateTime.now(),
      gates: [
        GateQueueInfo(
          name: 'Main Gate (Sarbojonin Path)',
          gateCode: 'Gate A',
          peopleCount: 104,
          estimatedWaitMinutes: 12,
          status: 'Heavy Flow',
          statusColor: const Color(0xFFE53935),
        ),
        GateQueueInfo(
          name: 'Senior & Family Entry',
          gateCode: 'Gate B',
          peopleCount: 28,
          estimatedWaitMinutes: 4,
          status: 'Moderate',
          statusColor: const Color(0xFFF57F17),
        ),
        GateQueueInfo(
          name: 'Puja Committee / VIP Pass',
          gateCode: 'Gate C',
          peopleCount: 14,
          estimatedWaitMinutes: 2,
          status: 'Fast Track',
          statusColor: const Color(0xFF2E7D32),
        ),
      ],
    ),
    PandalQueueData(
      id: 'kushpata_netaji',
      name: 'Kushpata Netaji Sangha',
      zone: 'Kushpata North',
      address: 'Netaji Subhas Path, Kushpata, Ghatal',
      lat: 22.6730,
      lng: 87.7210,
      distance: '1.2 km',
      theme: 'Eco-friendly Terracotta Sanctum',
      peopleInLine: 32,
      lastDelta: -3,
      trend: CrowdTrend.decreasing,
      maxCapacity: 180,
      entryRatePerMinute: 18,
      queueLengthMeters: 18,
      gateStatus: 'Open (Fast)',
      lastUpdated: DateTime.now(),
      gates: [
        GateQueueInfo(
          name: 'Main Pavilion Entrance',
          gateCode: 'Gate 1',
          peopleCount: 22,
          estimatedWaitMinutes: 2,
          status: 'Free Flow',
          statusColor: const Color(0xFF2E7D32),
        ),
        GateQueueInfo(
          name: 'North Bypass Gate',
          gateCode: 'Gate 2',
          peopleCount: 10,
          estimatedWaitMinutes: 1,
          status: 'Instant Entry',
          statusColor: const Color(0xFF2E7D32),
        ),
      ],
    ),
    PandalQueueData(
      id: 'konnagar_youth',
      name: 'Konnagar Youth Club',
      zone: 'Konnagar Town',
      address: 'Konnagar High School Ground, Ghatal',
      lat: 22.6620,
      lng: 87.7290,
      distance: '2.1 km',
      theme: 'Bengal Patachitra Folk Art',
      peopleInLine: 78,
      lastDelta: 1,
      trend: CrowdTrend.stable,
      maxCapacity: 200,
      entryRatePerMinute: 12,
      queueLengthMeters: 38,
      gateStatus: 'Open',
      lastUpdated: DateTime.now(),
      gates: [
        GateQueueInfo(
          name: 'Main Street Queue',
          gateCode: 'Gate 1',
          peopleCount: 56,
          estimatedWaitMinutes: 7,
          status: 'Steady',
          statusColor: const Color(0xFFF57F17),
        ),
        GateQueueInfo(
          name: 'School Ground Side Line',
          gateCode: 'Gate 2',
          peopleCount: 22,
          estimatedWaitMinutes: 3,
          status: 'Smooth',
          statusColor: const Color(0xFF2E7D32),
        ),
      ],
    ),
    PandalQueueData(
      id: 'kharar_rajbari',
      name: 'Kharar Rajbari Mandir',
      zone: 'Kharar Heritage Belt',
      address: 'Rajbari Square, Kharar Municipality',
      lat: 22.6950,
      lng: 87.6830,
      distance: '3.5 km',
      theme: '300-Year Heritage Zamindari Puja',
      peopleInLine: 45,
      lastDelta: -2,
      trend: CrowdTrend.decreasing,
      maxCapacity: 160,
      entryRatePerMinute: 15,
      queueLengthMeters: 24,
      gateStatus: 'Open',
      lastUpdated: DateTime.now(),
      gates: [
        GateQueueInfo(
          name: 'Rajbari Courtyard Arch',
          gateCode: 'Main Gate',
          peopleCount: 35,
          estimatedWaitMinutes: 3,
          status: 'Smooth',
          statusColor: const Color(0xFF2E7D32),
        ),
        GateQueueInfo(
          name: 'Natmandir Entry',
          gateCode: 'Gate 2',
          peopleCount: 10,
          estimatedWaitMinutes: 1,
          status: 'Instant Entry',
          statusColor: const Color(0xFF2E7D32),
        ),
      ],
    ),
    PandalQueueData(
      id: 'bidyasagar_setu',
      name: 'Bidyasagar Setu Baroari',
      zone: 'Riverbank Shilabati',
      address: 'Shilabati Riverfront Approach, Ghatal',
      lat: 22.6650,
      lng: 87.7260,
      distance: '0.8 km',
      theme: 'Illuminated Lotus on Water',
      peopleInLine: 112,
      lastDelta: 5,
      trend: CrowdTrend.increasing,
      maxCapacity: 210,
      entryRatePerMinute: 11,
      queueLengthMeters: 52,
      gateStatus: 'Regulated Flow',
      lastUpdated: DateTime.now(),
      gates: [
        GateQueueInfo(
          name: 'Bridge Approach Ramp',
          gateCode: 'Gate A',
          peopleCount: 82,
          estimatedWaitMinutes: 10,
          status: 'Regulated',
          statusColor: const Color(0xFFE53935),
        ),
        GateQueueInfo(
          name: 'Ghat Stairs Gate',
          gateCode: 'Gate B',
          peopleCount: 30,
          estimatedWaitMinutes: 4,
          status: 'Moderate',
          statusColor: const Color(0xFFF57F17),
        ),
      ],
    ),
  ];

  List<PandalQueueData> get pandals => List.unmodifiable(_pandals);

  int get totalPeopleInQueues =>
      _pandals.fold(0, (sum, item) => sum + item.peopleInLine);

  PandalQueueData? get shortestLinePandal {
    if (_pandals.isEmpty) return null;
    return _pandals.reduce(
      (a, b) => a.peopleInLine < b.peopleInLine ? a : b,
    );
  }

  LiveQueueService._internal() {
    _startTimer();
    _fetchBackendData();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (_isLiveStreaming) {
        _tickSimulation();
      }
    });
  }

  Future<void> _fetchBackendData() async {
    try {
      final pRes = await http.get(Uri.parse('$backendBaseUrl/api/pandals')).timeout(const Duration(seconds: 2));
      if (pRes.statusCode == 200) {
        final List<dynamic> list = jsonDecode(pRes.body);
        final fetched = list.map((j) => PandalQueueData.fromJson(j as Map<String, dynamic>)).toList();
        if (fetched.isNotEmpty) {
          _pandals = fetched;
          _isBackendConnected = true;
        }
      }
      final aRes = await http.get(Uri.parse('$backendBaseUrl/api/alerts')).timeout(const Duration(seconds: 2));
      if (aRes.statusCode == 200) {
        final List<dynamic> list = jsonDecode(aRes.body);
        _alerts = list.map((j) => CrowdAlertItem.fromJson(j as Map<String, dynamic>)).toList();
      }
      notifyListeners();
    } catch (_) {
      _isBackendConnected = false;
    }
  }

  void _tickSimulation() {
    _lastHeartbeat = DateTime.now();

    final countToUpdate = _rng.nextInt(2) + 1;
    final updatedIndices = <int>{};

    for (int i = 0; i < countToUpdate; i++) {
      updatedIndices.add(_rng.nextInt(_pandals.length));
    }

    _pandals = _pandals.asMap().entries.map((entry) {
      final index = entry.key;
      final current = entry.value;

      if (!updatedIndices.contains(index)) {
        return current;
      }

      final delta = _rng.nextInt(10) - 4;
      final newCount = (current.peopleInLine + delta).clamp(12, 240);
      final actualDelta = newCount - current.peopleInLine;

      final trend = actualDelta > 0
          ? CrowdTrend.increasing
          : (actualDelta < 0 ? CrowdTrend.decreasing : CrowdTrend.stable);

      final meters = (newCount * 0.42).round().clamp(6, 120);

      int? newUserPosition = current.userQueuePosition;
      if (current.isUserInLine && newUserPosition != null) {
        final forwardMove = _rng.nextInt(3) + 1;
        newUserPosition = max(1, newUserPosition - forwardMove);
      }

      final updatedGates = current.gates.map((g) {
        final gateDelta = (_rng.nextInt(5) - 2);
        final gateCount = max(3, g.peopleCount + gateDelta);
        final gateWait = (gateCount / 10).ceil();
        return g.copyWith(
          peopleCount: gateCount,
          estimatedWaitMinutes: gateWait,
        );
      }).toList();

      return current.copyWith(
        peopleInLine: newCount,
        lastDelta: actualDelta,
        trend: trend,
        queueLengthMeters: meters,
        lastUpdated: DateTime.now(),
        userQueuePosition: newUserPosition,
        gates: updatedGates,
      );
    }).toList();

    notifyListeners();
  }

  void toggleLiveStream() {
    _isLiveStreaming = !_isLiveStreaming;
    notifyListeners();
  }

  Future<void> manualRefresh() async {
    await _fetchBackendData();
    _tickSimulation();
  }

  void joinLine(String pandalId) {
    _pandals = _pandals.map((p) {
      if (p.id == pandalId) {
        final newCount = p.peopleInLine + 1;
        return p.copyWith(
          peopleInLine: newCount,
          lastDelta: 1,
          isUserInLine: true,
          userQueuePosition: newCount,
        );
      }
      return p;
    }).toList();
    notifyListeners();
  }

  void leaveLine(String pandalId) {
    _pandals = _pandals.map((p) {
      if (p.id == pandalId) {
        return p.copyWith(
          isUserInLine: false,
          userQueuePosition: null,
        );
      }
      return p;
    }).toList();
    notifyListeners();
  }

  void toggleQueueAlert(String pandalId) {
    _pandals = _pandals.map((p) {
      if (p.id == pandalId) {
        return p.copyWith(
          hasQueueAlert: !p.hasQueueAlert,
        );
      }
      return p;
    }).toList();
    notifyListeners();
  }

  // --- Admin API Methods ---
  Future<bool> adminUpdateQueue({
    required String pandalId,
    required int newCount,
    required int lastDelta,
    String? gateStatus,
  }) async {
    // 1. Update local state immediately
    _pandals = _pandals.map((p) {
      if (p.id == pandalId) {
        return p.copyWith(
          peopleInLine: newCount,
          lastDelta: lastDelta,
          gateStatus: gateStatus ?? p.gateStatus,
          queueLengthMeters: (newCount * 0.42).round().clamp(5, 150),
          lastUpdated: DateTime.now(),
        );
      }
      return p;
    }).toList();
    notifyListeners();

    // 2. Sync to Backend REST API
    try {
      final res = await http.post(
        Uri.parse('$backendBaseUrl/api/pandals/$pandalId/queue'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'peopleInLine': newCount,
          'lastDelta': lastDelta,
          'gateStatus': ?gateStatus,
        }),
      ).timeout(const Duration(seconds: 2));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<bool> adminBroadcastAlert({
    required String title,
    required String message,
    required String level,
  }) async {
    final alert = CrowdAlertItem(
      id: 'alert_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      message: message,
      level: level,
      timestamp: DateTime.now(),
      active: true,
    );
    _alerts.insert(0, alert);
    notifyListeners();

    try {
      final res = await http.post(
        Uri.parse('$backendBaseUrl/api/alerts'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': title,
          'message': message,
          'level': level,
        }),
      ).timeout(const Duration(seconds: 2));
      return res.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  Future<bool> adminAddPandal({
    required String name,
    required String zone,
    required double lat,
    required double lng,
    required int initialQueue,
    String distance = '1.0 km',
  }) async {
    final newPandal = PandalQueueData(
      id: 'pandal_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      zone: zone,
      lat: lat,
      lng: lng,
      distance: distance,
      peopleInLine: initialQueue,
      entryRatePerMinute: 14,
      queueLengthMeters: (initialQueue * 0.4).round(),
      gateStatus: 'Open',
      lastUpdated: DateTime.now(),
      gates: [
        GateQueueInfo(
          name: 'Main Gate',
          gateCode: 'Gate A',
          peopleCount: initialQueue,
          estimatedWaitMinutes: (initialQueue / 12).ceil(),
          status: 'Open',
          statusColor: const Color(0xFF2E7D32),
        ),
      ],
    );

    _pandals.add(newPandal);
    notifyListeners();

    try {
      final res = await http.post(
        Uri.parse('$backendBaseUrl/api/pandals'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(newPandal.toJson()),
      ).timeout(const Duration(seconds: 2));
      return res.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  PandalQueueData? getPandalById(String id) {
    try {
      return _pandals.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
