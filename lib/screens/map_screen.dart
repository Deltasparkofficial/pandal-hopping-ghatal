import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/pandal_queue_model.dart';
import '../services/live_queue_service.dart';
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
      listenable: _queueService,
      builder: (context, _) {
        final allPandals = _queueService.pandals;
        final filteredPandals = _selectedZone == 'All Zones'
            ? allPandals
            : allPandals.where((p) => p.zone == _selectedZone).toList();

        final selectedPandal = allPandals.firstWhere(
          (p) => p.id == _selectedPandalId,
          orElse: () => allPandals.isNotEmpty ? allPandals.first : filteredPandals.first,
        );

        return Scaffold(
          backgroundColor: const Color(0xFF16191F),
          body: Stack(
            children: [
              // 1. Google Maps Styled Interactive Canvas
              Positioned.fill(
                child: _buildMapCanvas(filteredPandals, selectedPandal),
              ),

              // 2. Top Header & Zone Filters Bar
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Column(
                    children: [
                      // Header Card
                      Container(
                        margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
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
                                  Row(
                                    children: [
                                      Text(
                                        'Google Maps Radar',
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF1B5E20),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          'API ACTIVE',
                                          style: GoogleFonts.poppins(
                                            fontSize: 8,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFFA5D6A7),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    'Ghatal Municipality • 22.6685° N, 87.7247° E',
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      color: Colors.white60,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Map type toggle
                            PopupMenuButton<String>(
                              initialValue: _mapType,
                              tooltip: 'Map Layer',
                              icon: const Icon(Icons.layers_rounded, color: Colors.white70, size: 20),
                              color: const Color(0xFF1E222B),
                              onSelected: (val) => setState(() => _mapType = val),
                              itemBuilder: (ctx) => [
                                _buildPopupMenuItem('Roadmap', Icons.map_outlined),
                                _buildPopupMenuItem('Satellite', Icons.satellite_alt_rounded),
                                _buildPopupMenuItem('Terrain', Icons.terrain_rounded),
                              ],
                            ),
                            // Admin button
                            IconButton(
                              tooltip: 'Admin Console',
                              icon: const Icon(Icons.admin_panel_settings_rounded, color: AppColors.gold, size: 22),
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
                        height: 36,
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
                    ],
                  ),
                ),
              ),

              // 3. Map Controls (Zoom / Recenter)
              Positioned(
                right: 16,
                top: 150,
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
                    _buildMapFloatingBtn(Icons.my_location, () {
                      setState(() {
                        _zoomLevel = 1.0;
                        _selectedZone = 'All Zones';
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Centered on Ghatal Municipal Town'),
                          duration: Duration(seconds: 1),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }),
                  ],
                ),
              ),

              // 4. Bottom Selected Pandal Sheet
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: _buildBottomPandalCard(selectedPandal),
              ),
            ],
          ),
        );
      },
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

  Widget _buildMapFloatingBtn(IconData icon, VoidCallback onTap) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: const Color(0xFF1E222B).withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
          ),
        ],
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(icon, color: Colors.white, size: 20),
        onPressed: onTap,
      ),
    );
  }

  Widget _buildMapCanvas(List<PandalQueueData> pandals, PandalQueueData selectedPandal) {
    final isSatellite = _mapType == 'Satellite';
    final isTerrain = _mapType == 'Terrain';

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;

        return Transform.scale(
          scale: _zoomLevel,
          alignment: Alignment.center,
          child: Container(
            color: isSatellite
                ? const Color(0xFF141916)
                : (isTerrain ? const Color(0xFF222822) : const Color(0xFF181B20)),
            child: Stack(
              children: [
                // Shilabati River Vector Flow
                CustomPaint(
                  size: Size(w, h),
                  painter: _GhatalRiverAndRoadsPainter(isSatellite: isSatellite),
                ),

                // Pandal Map Markers
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

                // Google Logo watermark
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
    // Relative coordinates across Ghatal town canvas
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

  Widget _buildBottomPandalCard(PandalQueueData pandal) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E222B),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
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
                      '${pandal.zone} • ${pandal.distance}',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.white60,
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
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Starting Google Maps Directions to ${pandal.name} (${pandal.lat}, ${pandal.lng})...'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Icons.directions_rounded, size: 16),
                  label: Text(
                    'Directions',
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
