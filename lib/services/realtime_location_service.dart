import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/pandal_queue_model.dart';

class UserLocationPoint {
  final double lat;
  final double lng;
  final double accuracyMeters;
  final double speedKmh;
  final double headingDegrees;
  final DateTime timestamp;
  final bool isLiveGps;

  const UserLocationPoint({
    required this.lat,
    required this.lng,
    this.accuracyMeters = 6.0,
    this.speedKmh = 4.2,
    this.headingDegrees = 45.0,
    required this.timestamp,
    this.isLiveGps = false,
  });

  UserLocationPoint copyWith({
    double? lat,
    double? lng,
    double? accuracyMeters,
    double? speedKmh,
    double? headingDegrees,
    DateTime? timestamp,
    bool? isLiveGps,
  }) {
    return UserLocationPoint(
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      accuracyMeters: accuracyMeters ?? this.accuracyMeters,
      speedKmh: speedKmh ?? this.speedKmh,
      headingDegrees: headingDegrees ?? this.headingDegrees,
      timestamp: timestamp ?? this.timestamp,
      isLiveGps: isLiveGps ?? this.isLiveGps,
    );
  }
}

class RealTimeLocationService extends ChangeNotifier {
  static final RealTimeLocationService _instance = RealTimeLocationService._internal();
  factory RealTimeLocationService() => _instance;

  // Ghatal Town Center coordinates (Bazar Main Road)
  static const double ghatalCenterLat = 22.6685;
  static const double ghatalCenterLng = 22.7247;

  UserLocationPoint _currentLocation = UserLocationPoint(
    lat: 22.6680,
    lng: 87.7242,
    accuracyMeters: 5.0,
    speedKmh: 4.1,
    headingDegrees: 35.0,
    timestamp: DateTime.now(),
    isLiveGps: false,
  );

  bool _isTrackingEnabled = true;
  bool _isWalkingSimulationActive = true;
  Timer? _locationTimer;
  int _simulationStep = 0;

  UserLocationPoint get currentLocation => _currentLocation;
  bool get isTrackingEnabled => _isTrackingEnabled;
  bool get isWalkingSimulationActive => _isWalkingSimulationActive;

  // Waypoints for walking loop across Ghatal Puja routes
  final List<Map<String, double>> _ghatalWalkRoute = const [
    {'lat': 22.6680, 'lng': 87.7242, 'heading': 30.0},  // Near Ghatal Bazar
    {'lat': 22.6688, 'lng': 87.7248, 'heading': 45.0},
    {'lat': 22.6695, 'lng': 87.7252, 'heading': 60.0},
    {'lat': 22.6675, 'lng': 87.7258, 'heading': 130.0}, // Towards Bidyasagar Setu
    {'lat': 22.6655, 'lng': 87.7262, 'heading': 160.0},
    {'lat': 22.6648, 'lng': 87.7255, 'heading': 220.0},
    {'lat': 22.6660, 'lng': 87.7235, 'heading': 290.0},
    {'lat': 22.6672, 'lng': 87.7225, 'heading': 330.0},
    {'lat': 22.6690, 'lng': 87.7220, 'heading': 10.0},  // Towards Kushpata
    {'lat': 22.6715, 'lng': 87.7214, 'heading': 350.0},
    {'lat': 22.6730, 'lng': 87.7210, 'heading': 0.0},   // At Kushpata Netaji
    {'lat': 22.6710, 'lng': 87.7225, 'heading': 150.0},
    {'lat': 22.6690, 'lng': 87.7235, 'heading': 160.0},
  ];

  RealTimeLocationService._internal() {
    _startLocationTracker();
  }

  void _startLocationTracker() {
    _locationTimer?.cancel();
    _locationTimer = Timer.periodic(const Duration(milliseconds: 1800), (_) {
      if (_isTrackingEnabled && _isWalkingSimulationActive) {
        _tickLocation();
      }
    });
  }

  void _tickLocation() {
    _simulationStep = (_simulationStep + 1) % _ghatalWalkRoute.length;
    final nextTarget = _ghatalWalkRoute[_simulationStep];

    // Smooth movement with slight micro-variation
    final rng = Random();
    final jitterLat = (rng.nextDouble() - 0.5) * 0.00015;
    final jitterLng = (rng.nextDouble() - 0.5) * 0.00015;
    final speed = 3.6 + rng.nextDouble() * 1.4; // 3.6 - 5.0 km/h walking speed

    _currentLocation = UserLocationPoint(
      lat: nextTarget['lat']! + jitterLat,
      lng: nextTarget['lng']! + jitterLng,
      accuracyMeters: 4.0 + rng.nextDouble() * 2.5,
      speedKmh: double.parse(speed.toStringAsFixed(1)),
      headingDegrees: nextTarget['heading']!,
      timestamp: DateTime.now(),
      isLiveGps: false,
    );

    notifyListeners();
  }

  void toggleTracking() {
    _isTrackingEnabled = !_isTrackingEnabled;
    notifyListeners();
  }

  void toggleWalkingSimulation() {
    _isWalkingSimulationActive = !_isWalkingSimulationActive;
    notifyListeners();
  }

  void recenterToGhatalBazar() {
    _currentLocation = UserLocationPoint(
      lat: 22.6685,
      lng: 87.7247,
      accuracyMeters: 4.0,
      speedKmh: 4.2,
      headingDegrees: 45.0,
      timestamp: DateTime.now(),
      isLiveGps: false,
    );
    notifyListeners();
  }

  void setCustomLocation(double lat, double lng, {bool isLiveGps = true}) {
    _currentLocation = UserLocationPoint(
      lat: lat,
      lng: lng,
      accuracyMeters: 5.0,
      speedKmh: 0.0,
      headingDegrees: 0.0,
      timestamp: DateTime.now(),
      isLiveGps: isLiveGps,
    );
    notifyListeners();
  }

  /// Calculates Haversine distance in meters between devotee location and target (lat, lng).
  double distanceInMetersTo(double targetLat, double targetLng) {
    const double earthRadius = 6371000.0; // meters
    final dLat = (targetLat - _currentLocation.lat) * (pi / 180.0);
    final dLon = (targetLng - _currentLocation.lng) * (pi / 180.0);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_currentLocation.lat * (pi / 180.0)) *
            cos(targetLat * (pi / 180.0)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  /// Formatted distance string e.g. "320 m" or "1.4 km"
  String formattedDistanceTo(double targetLat, double targetLng) {
    final meters = distanceInMetersTo(targetLat, targetLng);
    if (meters < 1000) {
      return '${meters.round()} m';
    }
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  /// Estimated walking time in minutes based on average 4.5 km/h pace (75 meters/min)
  int estimatedWalkMinutesTo(double targetLat, double targetLng) {
    final meters = distanceInMetersTo(targetLat, targetLng);
    return max(1, (meters / 75).ceil());
  }

  /// Gets the closest pandal from the active LiveQueueService list
  PandalQueueData? getClosestPandal(List<PandalQueueData> pandals) {
    if (pandals.isEmpty) return null;
    PandalQueueData? closest;
    double minDistance = double.infinity;

    for (final p in pandals) {
      final dist = distanceInMetersTo(p.lat, p.lng);
      if (dist < minDistance) {
        minDistance = dist;
        closest = p;
      }
    }
    return closest;
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    super.dispose();
  }
}
