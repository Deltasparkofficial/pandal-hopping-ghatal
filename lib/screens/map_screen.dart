import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/pandal_queue_model.dart';
import '../services/live_queue_service.dart';
import '../services/realtime_location_service.dart';
import '../theme/app_theme.dart';
import '../widgets/live_queue_detail_sheet.dart';
import 'admin_panel_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final LiveQueueService _queueService = LiveQueueService();
  final RealTimeLocationService _locationService = RealTimeLocationService();

  String _selectedZone = 'All Zones';
  String? _selectedPandalId;
  String _mapType = 'Roadmap'; // Roadmap, Satellite, Terrain
  double _zoomLevel = 1.0;

  final List<String> _zones = [
    'All Zones',
    'Ghatal Central Zone',
    'Kushpata North',
    'Konnagar Town',
    'Kharar Heritage Belt',
    'Riverbank Shilabati',
  ];

  @override
  void initState() {
    super.initState();
    if (_queueService.pandals.isNotEmpty) {
      _selectedPandalId = _queueService.pandals.first.id;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([_queueService, _locationService]),
      builder: (context, _) {
        final allPandals = _queueService.pandals;
        final filteredPandals = _selectedZone == 'All Zones'
            ? allPandals
            : allPandals.where((p) => p.zone == _selectedZone).toList();

        final selectedPandal = allPandals.firstWhere(
          (p) => p.id == _selectedPandalId,
          orElse: () => allPandals.isNotEmpty ? allPandals.first : filteredPandals.first,
        );

        final userLoc = _locationService.currentLocation;

        return Scaffold(
          backgroundColor: const Color(0xFF16191F),
          body: Stack(
            children: [
              // 1. Google Maps Styled Interactive Canvas with Real-Time Devotee GPS
              Positioned.fill(
                child: _buildMapCanvas(filteredPandals, selectedPandal, userLoc),
              ),

              // 2. Top Header & Zone Filters & Real-Time Tracker Bar
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Column(
                    children: [
                      // Header Card
                      Container(
                        margin: const EdgeInsets.fromLTRB(16, 8, 16, 6),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E222B).withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.4),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.map_rounded,
                                color: AppColors.primaryLight,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Ghatal Pandal Radar',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Color(0xFF00E5FF),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'REAL-TIME GPS TRACKER ACTIVE',
                                        style: GoogleFonts.poppins(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF00E5FF),
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Map Type Dropdown Button
                            PopupMenuButton<String>(
                              icon: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.layers_rounded, color: Colors.white70, size: 18),
                              ),
                              color: const Color(0xFF1E222B),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(color: Colors.white24),
                              ),
                              onSelected: (val) => setState(() => _mapType = val),
                              itemBuilder: (ctx) => [
                                _buildPopupMenuItem('Roadmap', Icons.map_outlined),
                                _buildPopupMenuItem('Satellite', Icons.satellite_alt_rounded),
                                _buildPopupMenuItem('Terrain', Icons.terrain_rounded),
                              ],
                            ),
                            const SizedBox(width: 6),
                            // Admin Command Shortcut
                            IconButton(
                              tooltip: 'Admin Queue Gate',
                              icon: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.gold.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.admin_panel_settings_rounded, color: AppColors.gold, size: 18),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (ctx) => const AdminPanelScreen()),
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      // Zone Filter Chips Horizontal List
                      SizedBox(
                        height: 34,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _zones.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 8),
                          itemBuilder: (context, i) {
                            final zone = _zones[i];
                            final isSel = _selectedZone == zone;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedZone = zone),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isSel
                                      ? AppColors.primary
                                      : const Color(0xFF1E222B).withValues(alpha: 0.9),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: isSel ? Colors.transparent : Colors.white24,
                                  ),
                                ),
                                child: Text(
                                  zone,
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // Real-time GPS Tracker HUD
                      _buildRealTimeTrackerHud(selectedPandal),
                    ],
                  ),
                ),
              ),

              // 3. Map Controls (Zoom / GPS Recenter / Walk Sim)
              Positioned(
                right: 16,
                top: 210,
                child: Column(
                  children: [
                    _buildMapFloatingBtn(Icons.add, () {
                      setState(() => _zoomLevel = (_zoomLevel + 0.15).clamp(0.8, 1.8));
                    }),
                    const SizedBox(height: 8),
                    _buildMapFloatingBtn(Icons.remove, () {
                      setState(() => _zoomLevel = (_zoomLevel - 0.15).clamp(0.8, 1.8));
                    }),
                    const SizedBox(height: 8),
                    // Live GPS Recenter
                    _buildMapFloatingBtn(
                      Icons.my_location_rounded,
                      () {
                        _locationService.recenterToGhatalBazar();
                        setState(() {
                          _zoomLevel = 1.1;
                          _selectedZone = 'All Zones';
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.gps_fixed_rounded, color: Color(0xFF00E5FF), size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  'Locked to your live GPS position in Ghatal (${userLoc.lat.toStringAsFixed(4)}, ${userLoc.lng.toStringAsFixed(4)})',
                                ),
                              ],
                            ),
                            duration: const Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      highlightColor: const Color(0xFF00E5FF),
                    ),
                    const SizedBox(height: 8),
                    // Walking Simulation Toggle
                    _buildMapFloatingBtn(
                      _locationService.isWalkingSimulationActive
                          ? Icons.directions_walk_rounded
                          : Icons.pause_circle_filled_rounded,
                      () {
                        _locationService.toggleWalkingSimulation();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              _locationService.isWalkingSimulationActive
                                  ? 'Walking Simulation Active — devotee moving along Ghatal Puja route'
                                  : 'Walking Simulation Paused',
                            ),
                            duration: const Duration(seconds: 1),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      highlightColor: _locationService.isWalkingSimulationActive
                          ? const Color(0xFF00E5FF)
                          : Colors.white54,
                    ),
                  ],
                ),
              ),

              // 4. Live Admin Alert Ticker Overlay
              if (_queueService.alerts.isNotEmpty)
                Positioned(
                  left: 16,
                  right: 64,
                  top: 215,
                  child: _buildMapAlertTicker(),
                ),

              // 5. Bottom Selected Pandal Sheet
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: _buildBottomPandalCard(selectedPandal, userLoc),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRealTimeTrackerHud(PandalQueueData selectedPandal) {
    final loc = _locationService.currentLocation;
    final closest = _locationService.getClosestPandal(_queueService.pandals);
    final distToClosest = closest != null
        ? _locationService.formattedDistanceTo(closest.lat, closest.lng)
        : '...';
    final walkToClosest = closest != null
        ? _locationService.estimatedWalkMinutesTo(closest.lat, closest.lng)
        : 0;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 6, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1E26).withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.gps_fixed_rounded, color: Color(0xFF00E5FF), size: 15),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      'LIVE GPS TRACKER',
                      style: GoogleFonts.poppins(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF00E5FF),
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00E5FF).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${loc.speedKmh} km/h',
                        style: GoogleFonts.poppins(
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFE0F7FA),
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  closest != null
                      ? 'Closest: ${closest.name} ($distToClosest • ~$walkToClosest min walk)'
                      : 'Calculating distance...',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Recenter Quick Button
          GestureDetector(
            onTap: () {
              _locationService.recenterToGhatalBazar();
              setState(() => _zoomLevel = 1.1);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF00E5FF).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.4)),
              ),
              child: Text(
                'Focus',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF00E5FF),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem(String value, IconData icon) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.white70),
          const SizedBox(width: 8),
          Text(value, style: GoogleFonts.poppins(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildMapFloatingBtn(IconData icon, VoidCallback onTap, {Color? highlightColor}) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: const Color(0xFF1E222B).withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: highlightColor != null ? highlightColor.withValues(alpha: 0.6) : Colors.white24,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
          ),
        ],
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(icon, color: highlightColor ?? Colors.white, size: 20),
        onPressed: onTap,
      ),
    );
  }

  Widget _buildMapAlertTicker() {
    final alert = _queueService.alerts.first;
    final isCritical = alert.level == 'danger';
    final isWarning = alert.level == 'warning';
    final color = isCritical
        ? const Color(0xFFFF5252)
        : (isWarning ? const Color(0xFFFFB74D) : const Color(0xFF64B5F6));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1F27).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.6), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isCritical ? Icons.emergency_rounded : Icons.info_outline_rounded,
            color: color,
            size: 16,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              '${alert.title}: ${alert.message}',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapCanvas(
    List<PandalQueueData> pandals,
    PandalQueueData selectedPandal,
    UserLocationPoint userLoc,
  ) {
    final isSatellite = _mapType == 'Satellite';
    final isTerrain = _mapType == 'Terrain';

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;

        final userOffset = _getUserCanvasOffset(userLoc.lat, userLoc.lng, w, h);
        final targetOffset = _getPandalMapOffset(selectedPandal.id, w, h);

        return Transform.scale(
          scale: _zoomLevel,
          alignment: Alignment.center,
          child: Container(
            color: isSatellite
                ? const Color(0xFF141916)
                : (isTerrain ? const Color(0xFF222822) : const Color(0xFF181B20)),
            child: Stack(
              children: [
                // 1. Shilabati River Vector Flow
                CustomPaint(
                  size: Size(w, h),
                  painter: _GhatalRiverAndRoadsPainter(isSatellite: isSatellite),
                ),

                // 2. Real-Time Dynamic Walking Route Line from User to Selected Pandal
                CustomPaint(
                  size: Size(w, h),
                  painter: _RealTimeRoutePainter(
                    userOffset: userOffset,
                    targetOffset: targetOffset,
                  ),
                ),

                // 3. Pandal Map Markers
                ...pandals.map((p) {
                  final pos = _getPandalMapOffset(p.id, w, h);
                  final isSelected = p.id == selectedPandal.id;

                  return Positioned(
                    left: pos.dx - 45,
                    top: pos.dy - 50,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedPandalId = p.id;
                        });
                      },
                      child: _buildPandalMarker(p, isSelected),
                    ),
                  );
                }),

                // 4. Real-Time User GPS Radar Marker
                _buildUserLiveGpsMarker(userOffset, userLoc),

                // 5. Google Logo watermark
                Positioned(
                  left: 14,
                  bottom: 180,
                  child: Row(
                    children: [
                      Text(
                        'Google',
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white.withValues(alpha: 0.4),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Map Data © 2026',
                        style: GoogleFonts.poppins(
                          fontSize: 9,
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Offset _getPandalMapOffset(String id, double width, double height) {
    final cx = width * 0.5;
    final cy = height * 0.46;

    switch (id) {
      case 'ghatal_bazar':
        return Offset(cx - 10, cy + 20);
      case 'kushpata_netaji':
        return Offset(cx - 60, cy - 90);
      case 'konnagar_youth':
        return Offset(cx + 80, cy + 60);
      case 'kharar_rajbari':
        return Offset(cx - 110, cy - 140);
      case 'bidyasagar_setu':
        return Offset(cx + 30, cy - 20);
      default:
        return Offset(cx, cy);
    }
  }

  Offset _getUserCanvasOffset(double lat, double lng, double width, double height) {
    final cx = width * 0.5;
    final cy = height * 0.46;

    // Anchor to Ghatal Bazar: (22.6685, 87.7247) -> Offset(cx - 10, cy + 20)
    final baseDx = cx - 10;
    final baseDy = cy + 20;

    final dx = baseDx + (lng - 87.7247) * 17000.0;
    final dy = baseDy - (lat - 22.6685) * 23000.0;

    return Offset(
      dx.clamp(24.0, width - 24.0),
      dy.clamp(60.0, height - 160.0),
    );
  }

  Widget _buildUserLiveGpsMarker(Offset pos, UserLocationPoint loc) {
    return Positioned(
      left: pos.dx - 36,
      top: pos.dy - 36,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Live GPS Status Tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF00384D),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF00E5FF), width: 1),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00E5FF).withValues(alpha: 0.4),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF00E5FF),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'YOU (${loc.speedKmh} km/h)',
                  style: GoogleFonts.poppins(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFE0F7FA),
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 2),

          // Radar Pulse Ring & Center Beacon
          SizedBox(
            width: 44,
            height: 44,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer Pulse Beacon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.18),
                    border: Border.all(
                      color: const Color(0xFF00E5FF).withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                  ),
                ),
                // Inner Core Dot
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF00E5FF),
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00E5FF).withValues(alpha: 0.8),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
                // Heading Pointer Needle
                Transform.rotate(
                  angle: (loc.headingDegrees * pi / 180.0),
                  child: Transform.translate(
                    offset: const Offset(0, -14),
                    child: const Icon(
                      Icons.navigation_rounded,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPandalMarker(PandalQueueData p, bool isSelected) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Live Count Pill Tag
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : const Color(0xFF1E222B),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Colors.white : p.crowdColor,
              width: isSelected ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: p.crowdColor,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                '${p.peopleInLine}',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),

        // Pin Icon with Pulse
        Icon(
          Icons.location_on_rounded,
          color: isSelected ? AppColors.primary : p.crowdColor,
          size: isSelected ? 34 : 28,
          shadows: [
            Shadow(
              color: Colors.black.withValues(alpha: 0.6),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBottomPandalCard(PandalQueueData pandal, UserLocationPoint userLoc) {
    final distStr = _locationService.formattedDistanceTo(pandal.lat, pandal.lng);
    final walkMin = _locationService.estimatedWalkMinutesTo(pandal.lat, pandal.lng);
    final distanceMeters = _locationService.distanceInMetersTo(pandal.lat, pandal.lng);
    final isNearby = distanceMeters < 180;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E222B),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isNearby
              ? const Color(0xFF00E5FF).withValues(alpha: 0.6)
              : Colors.white.withValues(alpha: 0.12),
          width: isNearby ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Proximity Alert Banner
          if (isNearby)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF00384D),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF00E5FF)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.near_me_rounded, color: Color(0xFF00E5FF), size: 14),
                  const SizedBox(width: 6),
                  Text(
                    'PROXIMITY RADAR: You are near this pandal entrance!',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFE0F7FA),
                    ),
                  ),
                ],
              ),
            ),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            pandal.name,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: pandal.crowdColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            pandal.crowdLabel,
                            style: GoogleFonts.poppins(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: pandal.crowdColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${pandal.zone} • 🎯 $distStr away (~$walkMin min walk)',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: const Color(0xFF80DEEA),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // Live Count Highlight
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: pandal.crowdColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: pandal.crowdColor.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    Text(
                      '${pandal.peopleInLine}',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'in line',
                      style: GoogleFonts.poppins(
                        fontSize: 9,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (ctx) => LiveQueueDetailSheet(pandal: pandal),
                    );
                  },
                  icon: const Icon(Icons.radar_rounded, size: 16),
                  label: Text(
                    'Line Radar',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 11),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white24),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final mapsUri = Uri.parse(
                      'https://www.google.com/maps/dir/?api=1&origin=${userLoc.lat},${userLoc.lng}&destination=${pandal.lat},${pandal.lng}&travelmode=walking',
                    );
                    try {
                      await launchUrl(mapsUri, mode: LaunchMode.externalApplication);
                    } catch (_) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Navigating from (${userLoc.lat.toStringAsFixed(4)}, ${userLoc.lng.toStringAsFixed(4)}) to ${pandal.name} ($distStr away)...'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.directions_rounded, size: 16),
                  label: Text(
                    'Directions ($distStr)',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 11),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RealTimeRoutePainter extends CustomPainter {
  final Offset userOffset;
  final Offset targetOffset;

  _RealTimeRoutePainter({
    required this.userOffset,
    required this.targetOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Glowing cyan route line
    final glowPaint = Paint()
      ..color = const Color(0xFF00E5FF).withValues(alpha: 0.18)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke;

    final linePaint = Paint()
      ..color = const Color(0xFF00E5FF).withValues(alpha: 0.65)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(userOffset.dx, userOffset.dy);

    // Natural curved walking path to destination
    final midX = (userOffset.dx + targetOffset.dx) / 2;
    final midY = (userOffset.dy + targetOffset.dy) / 2 - 12;
    path.quadraticBezierTo(midX, midY, targetOffset.dx, targetOffset.dy);

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _RealTimeRoutePainter oldDelegate) {
    return oldDelegate.userOffset != userOffset ||
        oldDelegate.targetOffset != targetOffset;
  }
}

class _GhatalRiverAndRoadsPainter extends CustomPainter {
  final bool isSatellite;
  _GhatalRiverAndRoadsPainter({required this.isSatellite});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Shilabati River (flowing curve across Ghatal)
    final riverPaint = Paint()
      ..color = isSatellite ? const Color(0xFF0F2B36) : const Color(0xFF1A3845)
      ..strokeWidth = 32
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final riverPath = Path();
    riverPath.moveTo(0, size.height * 0.25);
    riverPath.cubicTo(
      size.width * 0.35,
      size.height * 0.32,
      size.width * 0.55,
      size.height * 0.55,
      size.width,
      size.height * 0.62,
    );
    canvas.drawPath(riverPath, riverPaint);

    // River label
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'SHILABATI RIVER',
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Colors.white.withValues(alpha: 0.25),
          letterSpacing: 2.0,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(size.width * 0.3, size.height * 0.38));

    // 2. Major Roads / Bridges (Bidyasagar Setu link & Kharar-Ghatal Highway)
    final roadPaint = Paint()
      ..color = const Color(0xFF2C323D)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke;

    final highway = Path();
    highway.moveTo(size.width * 0.2, 0);
    highway.lineTo(size.width * 0.5, size.height * 0.45);
    highway.lineTo(size.width * 0.85, size.height);
    canvas.drawPath(highway, roadPaint);

    final crossRoad = Path();
    crossRoad.moveTo(0, size.height * 0.52);
    crossRoad.lineTo(size.width, size.height * 0.48);
    canvas.drawPath(crossRoad, roadPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
