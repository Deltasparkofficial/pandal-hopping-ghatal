import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class OfflineZoneSection extends StatefulWidget {
  const OfflineZoneSection({super.key});

  @override
  State<OfflineZoneSection> createState() => _OfflineZoneSectionState();
}

class _OfflineZoneSectionState extends State<OfflineZoneSection> {
  final Set<String> _downloadedZones = {};

  void _toggleDownload(String zoneTitle, int pandalCount) {
    final isDownloaded = _downloadedZones.contains(zoneTitle);
    setState(() {
      if (isDownloaded) {
        _downloadedZones.remove(zoneTitle);
      } else {
        _downloadedZones.add(zoneTitle);
      }
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isDownloaded ? Icons.delete_outline : Icons.cloud_done_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                isDownloaded
                    ? 'Removed $zoneTitle from offline cache.'
                    : 'Downloaded $zoneTitle ($pandalCount pandals) for offline hopping!',
                style: GoogleFonts.poppins(fontSize: 12),
              ),
            ),
          ],
        ),
        backgroundColor: isDownloaded ? AppColors.textPrimary : const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.textPrimary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.wifi_off_rounded,
                  size: 18,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Offline Zone Maps',
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  _toggleDownload('Ghatal Town & Kushpata', 32);
                  _toggleDownload('Kharar & Chandrakona Link', 28);
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'SAVE ALL',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Zone Cards Row
          Row(
            children: [
              Expanded(
                child: _buildZoneCard(
                  title: 'Ghatal Town & Kushpata',
                  subtitle: 'Kushpata, Konnagar,\nBidyasagar Setu area',
                  pandalCount: 32,
                  icon: Icons.location_city_rounded,
                  iconColor: AppColors.primary,
                  iconBg: AppColors.primary.withValues(alpha: 0.1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildZoneCard(
                  title: 'Kharar & Chandrakona Link',
                  subtitle: 'Historic brass-metal craft...\nRadhaballabhpur',
                  pandalCount: 28,
                  icon: Icons.account_balance_rounded,
                  iconColor: const Color(0xFFE65100),
                  iconBg: const Color(0xFFE65100).withValues(alpha: 0.1),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildZoneCard({
    required String title,
    required String subtitle,
    required int pandalCount,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
  }) {
    final isSaved = _downloadedZones.contains(title);

    return RepaintBoundary(
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => _toggleDownload(title, pandalCount),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSaved ? const Color(0xFF81C784) : AppColors.border,
                width: isSaved ? 1.2 : 0.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(height: 12),

                // Title
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),

                // Subtitle
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 14),

                // Bottom row: pandal count + download
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$pandalCount Pandals',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSaved ? const Color(0xFF2E7D32) : AppColors.primary,
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isSaved ? const Color(0xFF2E7D32) : AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: (isSaved ? const Color(0xFF2E7D32) : AppColors.primary)
                                .withValues(alpha: 0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        isSaved ? Icons.check_rounded : Icons.download_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
