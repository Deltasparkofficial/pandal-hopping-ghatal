import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class GoogleAdSection extends StatefulWidget {
  const GoogleAdSection({super.key});

  @override
  State<GoogleAdSection> createState() => _GoogleAdSectionState();
}

class _GoogleAdSectionState extends State<GoogleAdSection> {
  bool _isAdHidden = false;

  @override
  Widget build(BuildContext context) {
    if (_isAdHidden) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle_outline, size: 16, color: AppColors.success),
            const SizedBox(width: 8),
            Text(
              'Ad closed. Thanks for your feedback.',
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => setState(() => _isAdHidden = false),
              style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 0)),
              child: Text(
                'Undo',
                style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header / Ad label
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.textMuted, width: 0.8),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Ad',
                style: GoogleFonts.roboto(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'Google Ads • Sponsored Festival Partner',
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.textMuted,
              ),
            ),
            const Spacer(),
            // AdChoices Icon
            GestureDetector(
              onTap: () {
                _showAdChoicesDialog(context);
              },
              child: Row(
                children: [
                  Text(
                    'AdChoices',
                    style: GoogleFonts.roboto(
                      fontSize: 10,
                      color: const Color(0xFF1976D2),
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 13,
                    color: Color(0xFF1976D2),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            // Close Ad icon
            GestureDetector(
              onTap: () => setState(() => _isAdHidden = true),
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: Icon(Icons.close_rounded, size: 14, color: AppColors.textMuted),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Native Google Ad Banner Card
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border, width: 0.6),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top sponsor row
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sponsor Brand Logo
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFFB74D), width: 1),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.restaurant_rounded,
                          color: Color(0xFFE65100),
                          size: 26,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Sponsor Info & Rating
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Swiggy Food & Feast',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(Icons.verified, size: 13, color: Color(0xFF1976D2)),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                'swiggy.com',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: AppColors.textMuted,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.star, size: 12, color: Color(0xFFFFB300)),
                              const SizedBox(width: 2),
                              Text(
                                '4.8 (2M+)',
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Ad Headline & Description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Flat 50% Off On Sharodutsav Feasts In Ghatal!',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Hungry while hopping between Kushpata & Ghatal Bazar? Get hot biryani, mishti, rolls and bhog delivered directly to your pandal stop in 20 mins.',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Bottom CTA Action Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAFAFA),
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                  border: Border(
                    top: BorderSide(color: AppColors.border, width: 0.5),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.local_offer_rounded, size: 13, color: Color(0xFFE65100)),
                        const SizedBox(width: 4),
                        Text(
                          'USE CODE: PUJA50',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFE65100),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Opening sponsor offer: Flat 50% Off...',
                              style: GoogleFonts.poppins(fontSize: 12),
                            ),
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1976D2),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                        minimumSize: const Size(0, 32),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Order Now ↗',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showAdChoicesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.info_outline, color: Color(0xFF1976D2)),
            const SizedBox(width: 8),
            Text(
              'About Google Ads',
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: Text(
          'This ad was selected based on your region (Ghatal, West Bengal) and festival interests. Google ads help keep Pandal Hopping Ghatal free for all devotees.',
          style: GoogleFonts.poppins(fontSize: 12, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Close',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
