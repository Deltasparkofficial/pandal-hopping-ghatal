import 'package:flutter/material.dart';

enum CrowdTrend { increasing, decreasing, stable }

class GateQueueInfo {
  final String name;
  final String gateCode;
  final int peopleCount;
  final int estimatedWaitMinutes;
  final String status;
  final Color statusColor;

  const GateQueueInfo({
    required this.name,
    required this.gateCode,
    required this.peopleCount,
    required this.estimatedWaitMinutes,
    required this.status,
    required this.statusColor,
  });

  factory GateQueueInfo.fromJson(Map<String, dynamic> json) {
    Color color = const Color(0xFF2E7D32);
    if (json['statusColor'] != null) {
      final colorStr = json['statusColor'].toString().replaceAll('#', '');
      color = Color(int.parse('FF$colorStr', radix: 16));
    }
    return GateQueueInfo(
      name: json['name'] ?? 'Gate',
      gateCode: json['gateCode'] ?? 'Gate A',
      peopleCount: (json['peopleCount'] as num?)?.toInt() ?? 20,
      estimatedWaitMinutes: (json['estimatedWaitMinutes'] as num?)?.toInt() ?? 2,
      status: json['status'] ?? 'Open',
      statusColor: color,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'gateCode': gateCode,
      'peopleCount': peopleCount,
      'estimatedWaitMinutes': estimatedWaitMinutes,
      'status': status,
      'statusColor': '#${statusColor.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}',
    };
  }

  GateQueueInfo copyWith({
    int? peopleCount,
    int? estimatedWaitMinutes,
    String? status,
    Color? statusColor,
  }) {
    return GateQueueInfo(
      name: name,
      gateCode: gateCode,
      peopleCount: peopleCount ?? this.peopleCount,
      estimatedWaitMinutes: estimatedWaitMinutes ?? this.estimatedWaitMinutes,
      status: status ?? this.status,
      statusColor: statusColor ?? this.statusColor,
    );
  }
}

class PandalQueueData {
  final String id;
  final String name;
  final String zone;
  final String distance;
  final double lat;
  final double lng;
  final String address;
  final String theme;
  final int peopleInLine;
  final int lastDelta;
  final CrowdTrend trend;
  final int maxCapacity;
  final int entryRatePerMinute;
  final int queueLengthMeters;
  final String gateStatus;
  final DateTime lastUpdated;
  final List<GateQueueInfo> gates;
  final bool isUserInLine;
  final int? userQueuePosition;
  final bool hasQueueAlert;

  const PandalQueueData({
    required this.id,
    required this.name,
    required this.zone,
    required this.distance,
    this.lat = 22.6685,
    this.lng = 87.7247,
    this.address = 'Ghatal, Paschim Medinipur',
    this.theme = 'Sharodutsav Puja Artistry',
    required this.peopleInLine,
    this.lastDelta = 0,
    this.trend = CrowdTrend.stable,
    this.maxCapacity = 250,
    required this.entryRatePerMinute,
    required this.queueLengthMeters,
    required this.gateStatus,
    required this.lastUpdated,
    required this.gates,
    this.isUserInLine = false,
    this.userQueuePosition,
    this.hasQueueAlert = false,
  });

  factory PandalQueueData.fromJson(Map<String, dynamic> json) {
    CrowdTrend trend = CrowdTrend.stable;
    if (json['trend'] == 'increasing') trend = CrowdTrend.increasing;
    if (json['trend'] == 'decreasing') trend = CrowdTrend.decreasing;

    final gatesList = (json['gates'] as List<dynamic>?)
            ?.map((g) => GateQueueInfo.fromJson(g as Map<String, dynamic>))
            .toList() ??
        [];

    return PandalQueueData(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      zone: json['zone'] ?? 'Ghatal Central Zone',
      distance: json['distance'] ?? '0.5 km',
      lat: (json['lat'] as num?)?.toDouble() ?? 22.6685,
      lng: (json['lng'] as num?)?.toDouble() ?? 87.7247,
      address: json['address'] ?? 'Ghatal, Paschim Medinipur',
      theme: json['theme'] ?? 'Heritage Puja',
      peopleInLine: (json['peopleInLine'] as num?)?.toInt() ?? 30,
      lastDelta: (json['lastDelta'] as num?)?.toInt() ?? 0,
      trend: trend,
      maxCapacity: (json['maxCapacity'] as num?)?.toInt() ?? 220,
      entryRatePerMinute: (json['entryRatePerMinute'] as num?)?.toInt() ?? 14,
      queueLengthMeters: (json['queueLengthMeters'] as num?)?.toInt() ?? 20,
      gateStatus: json['gateStatus'] ?? 'Open',
      lastUpdated: DateTime.tryParse(json['lastUpdated'] ?? '') ?? DateTime.now(),
      gates: gatesList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'zone': zone,
      'distance': distance,
      'lat': lat,
      'lng': lng,
      'address': address,
      'theme': theme,
      'peopleInLine': peopleInLine,
      'lastDelta': lastDelta,
      'trend': trend.name,
      'maxCapacity': maxCapacity,
      'entryRatePerMinute': entryRatePerMinute,
      'queueLengthMeters': queueLengthMeters,
      'gateStatus': gateStatus,
      'gates': gates.map((g) => g.toJson()).toList(),
    };
  }

  int get estimatedWaitMinutes {
    if (entryRatePerMinute <= 0) return 5;
    final mins = (peopleInLine / entryRatePerMinute).ceil();
    return mins < 1 ? 1 : mins;
  }

  double get queueDensity {
    final ratio = peopleInLine / maxCapacity;
    return ratio > 1.0 ? 1.0 : ratio;
  }

  String get crowdLabel {
    if (peopleInLine < 45) return 'Low';
    if (peopleInLine < 110) return 'Moderate';
    if (peopleInLine < 180) return 'High';
    return 'Peak Crowd';
  }

  Color get crowdColor {
    if (peopleInLine < 45) return const Color(0xFF2E7D32);
    if (peopleInLine < 110) return const Color(0xFFF57F17);
    if (peopleInLine < 180) return const Color(0xFFE53935);
    return const Color(0xFFB71C1C);
  }

  PandalQueueData copyWith({
    int? peopleInLine,
    int? lastDelta,
    CrowdTrend? trend,
    int? entryRatePerMinute,
    int? queueLengthMeters,
    String? gateStatus,
    DateTime? lastUpdated,
    List<GateQueueInfo>? gates,
    bool? isUserInLine,
    int? userQueuePosition,
    bool? hasQueueAlert,
    double? lat,
    double? lng,
    String? address,
    String? theme,
  }) {
    return PandalQueueData(
      id: id,
      name: name,
      zone: zone,
      distance: distance,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      address: address ?? this.address,
      theme: theme ?? this.theme,
      peopleInLine: peopleInLine ?? this.peopleInLine,
      lastDelta: lastDelta ?? this.lastDelta,
      trend: trend ?? this.trend,
      maxCapacity: maxCapacity,
      entryRatePerMinute: entryRatePerMinute ?? this.entryRatePerMinute,
      queueLengthMeters: queueLengthMeters ?? this.queueLengthMeters,
      gateStatus: gateStatus ?? this.gateStatus,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      gates: gates ?? this.gates,
      isUserInLine: isUserInLine ?? this.isUserInLine,
      userQueuePosition: userQueuePosition ?? this.userQueuePosition,
      hasQueueAlert: hasQueueAlert ?? this.hasQueueAlert,
    );
  }
}
