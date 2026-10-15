import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/live_queue_service.dart';

class HeroBanner extends StatelessWidget {
  const HeroBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [
              Color(0xFFB71C1C),
              Color(0xFFC62828),
              Color(0xFFD32F2F),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFB71C1C).withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Left Floral Swirl Flourish
              Positioned(
                left: -10,
                top: 8,
                bottom: 8,
                child: Opacity(
                  opacity: 0.50,
                  child: Image.asset(
                    'assets/images/floral_swirl.png',
                    fit: BoxFit.contain,
                    errorBuilder: (ctx, err, st) {
                      return Image.network(
                        'floral_swirl.png',
                        fit: BoxFit.contain,
                        errorBuilder: (c, e, s) => const SizedBox(),
                      );
                    },
                  ),
                ),
              ),

              // Right Floral Swirl Flourish (Mirrored)
              Positioned(
                right: -10,
                top: 8,
                bottom: 8,
                child: Opacity(
                  opacity: 0.50,
                  child: Transform.flip(
                    flipX: true,
                    child: Image.asset(
                      'assets/images/floral_swirl.png',
                      fit: BoxFit.contain,
                      errorBuilder: (ctx, err, st) {
                        return Image.network(
                          'floral_swirl.png',
                          fit: BoxFit.contain,
                          errorBuilder: (c, e, s) => const SizedBox(),
                        );
                      },
                    ),
                  ),
                ),
              ),

              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 640;

                  final durgaArtwork = Container(
                    width: isWide ? 144 : 124,
                    height: isWide ? 200 : 172,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: const Color(0xFFF5D076),
                        width: 3.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.35),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                        BoxShadow(
                          color: const Color(0xFFD4A017).withValues(alpha: 0.45),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.asset(
                        'assets/images/durga_hero.jpg',
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, st) {
                          return Image.network(
                            'durga_hero.jpg',
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                    ),
                  );

                  if (isWide) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          durgaArtwork,
                          const SizedBox(width: 24),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildCountdownBadge(),
                                const SizedBox(height: 10),
                                Text(
                                  'Ghatal Sharodutsav 2026',
                                  style: GoogleFonts.poppins(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: 0.3,
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Experience historic heritage Pujas across Shilabati River banks, Kushpata, Konnagar, and Kharar.',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white.withValues(alpha: 0.9),
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      top: BorderSide(
                                        color: Colors.white.withValues(alpha: 0.2),
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  child: _LiveStatsRow(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Mobile vertical stack
                  return Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildCountdownBadge(),
                        const SizedBox(height: 12),
                        durgaArtwork,
                        const SizedBox(height: 14),
                        Text(
                          'Ghatal Sharodutsav 2026',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.3,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            'Experience historic heritage Pujas across Shilabati River banks, Kushpata, Konnagar, and Kharar.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: Colors.white.withValues(alpha: 0.9),
                              height: 1.4,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: Colors.white.withValues(alpha: 0.2),
                                width: 1,
                              ),
                            ),
                          ),
                          child: _LiveStatsRow(),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCountdownBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF2E7D32),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E7D32).withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF81C784),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'MAHA SAPTAMI IN 2 DAYS',
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}


class _LiveStatsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final queueService = LiveQueueService();
    return ListenableBuilder(
      listenable: queueService,
      builder: (context, _) {
        return Row(
          children: [
            _buildStat('OPEN NOW', '${queueService.pandals.length}', null),
            _buildStatDivider(),
            _buildStat('AVG CROWD', queueService.averageCrowdLabel, null),
            _buildStatDivider(),
            _buildStat('TOTO & BOAT\nTRAILS', '6 Active', AppColors.goldLight),
          ],
        );
      },
    );
  }

  Widget _buildStat(String label, String value, Color? valueColor) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 9,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.6),
              letterSpacing: 0.5,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 2),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              value,
              key: ValueKey<String>(value),
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: valueColor ?? Colors.white,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 36,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: Colors.white.withValues(alpha: 0.15),
    );
  }
}
