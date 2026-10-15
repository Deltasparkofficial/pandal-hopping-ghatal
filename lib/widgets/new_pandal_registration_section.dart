import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';

class NewPandalRegistrationSection extends StatelessWidget {
  static const String formUrl =
      'https://docs.google.com/forms/d/e/1FAIpQLSf4_9QifSJAfrzi7SHCyS9t2K5pA935f287ockm9bTYMmJyXg/viewform?usp=publish-editor';

  const NewPandalRegistrationSection({super.key});

  Future<void> _launchForm(BuildContext context) async {
    final uri = Uri.parse(formUrl);
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && context.mounted) {
        _showFallbackDialog(context);
      }
    } catch (_) {
      if (context.mounted) {
        _showFallbackDialog(context);
      }
    }
  }

  void _showFallbackDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.app_registration_rounded, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              'Pandal Registration',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 16),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Please open the Google Form link in your browser to submit your puja details:',
              style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),
            SelectableText(
              formUrl,
              style: GoogleFonts.poppins(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Close', style: GoogleFonts.poppins(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              launchUrl(Uri.parse(formUrl), mode: LaunchMode.platformDefault);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: Text('Open Link', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: const LinearGradient(
            colors: [
              Color(0xFF2C0B0B),
              Color(0xFF1B0707),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: AppColors.gold.withValues(alpha: 0.35),
            width: 1.5,
          ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(21),
        child: Stack(
          children: [
            // Decorative background icon
            Positioned(
              right: -15,
              bottom: -20,
              child: Opacity(
                opacity: 0.08,
                child: const Icon(
                  Icons.temple_hindu,
                  size: 160,
                  color: Color(0xFFF5D076),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Tag Row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.goldLight.withValues(alpha: 0.5),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('🏮', style: TextStyle(fontSize: 11)),
                            const SizedBox(width: 5),
                            Text(
                              'PUJA COMMITTEE DESK',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFFF5D076),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E7D32).withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF81C784).withValues(alpha: 0.4),
                          ),
                        ),
                        child: Text(
                          'OPEN 2026',
                          style: GoogleFonts.poppins(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF81C784),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Title
                  Text(
                    'Register Your Durga Puja Pandal',
                    style: GoogleFonts.poppins(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Description
                  Text(
                    'Are you a puja committee organizer in Ghatal? Get your pandal officially featured on the devotee map with live crowd tracking & line radar.',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.85),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 3 Feature Highlights (Responsive)
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth >= 640;
                      if (isWide) {
                        return Row(
                          children: [
                            Expanded(
                              child: _buildFeatureBadge(
                                icon: Icons.sensors_rounded,
                                title: 'Live Line Radar',
                                desc: 'Devotees track wait times live',
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildFeatureBadge(
                                icon: Icons.location_on_rounded,
                                title: 'Ghatal Map Navigation',
                                desc: 'Direct GPS routing to your gate',
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildFeatureBadge(
                                icon: Icons.campaign_rounded,
                                title: 'Live Broadcasts',
                                desc: 'Send crowd updates to devotees',
                              ),
                            ),
                          ],
                        );
                      }
                      return Column(
                        children: [
                          _buildFeatureBadge(
                            icon: Icons.sensors_rounded,
                            title: 'Live Line Radar',
                            desc: 'Devotees track wait times live',
                          ),
                          const SizedBox(height: 8),
                          _buildFeatureBadge(
                            icon: Icons.location_on_rounded,
                            title: 'Ghatal Map Navigation',
                            desc: 'Direct GPS routing to your gate',
                          ),
                          const SizedBox(height: 8),
                          _buildFeatureBadge(
                            icon: Icons.campaign_rounded,
                            title: 'Live Broadcasts',
                            desc: 'Send crowd updates to devotees',
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 18),

                  // Registration CTA Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _launchForm(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4A017),
                        foregroundColor: const Color(0xFF2C0B0B),
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.how_to_reg_rounded, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Fill Registration Form',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.open_in_new_rounded, size: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildFeatureBadge({
    required IconData icon,
    required String title,
    required String desc,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFFD4A017).withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFFF5D076), size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  desc,
                  style: GoogleFonts.poppins(
                    fontSize: 10.5,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
