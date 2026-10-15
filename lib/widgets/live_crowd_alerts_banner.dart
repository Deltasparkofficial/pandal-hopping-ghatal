import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/live_queue_service.dart';
import '../theme/app_theme.dart';

class LiveCrowdAlertsBanner extends StatelessWidget {
  const LiveCrowdAlertsBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final queueService = LiveQueueService();

    return ListenableBuilder(
      listenable: queueService,
      builder: (context, _) {
        final alerts = queueService.alerts;
        if (alerts.isEmpty) return const SizedBox.shrink();

        return RepaintBoundary(
          child: Column(
            children: alerts.take(3).map((alert) {
              return _AlertBannerCard(
                key: ValueKey(alert.id),
                alert: alert,
                onDismiss: () => queueService.dismissAlert(alert.id),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

class _AlertBannerCard extends StatelessWidget {
  final CrowdAlertItem alert;
  final VoidCallback onDismiss;

  const _AlertBannerCard({super.key, required this.alert, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    final config = _getAlertConfig(alert.level);
    final timeDiff = DateTime.now().difference(alert.timestamp);
    final timeAgo = timeDiff.inMinutes < 1
        ? 'Just now'
        : timeDiff.inMinutes < 60
            ? '${timeDiff.inMinutes}m ago'
            : '${timeDiff.inHours}h ago';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: config.bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: config.borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: config.accentColor.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Alert Icon
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: config.accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  config.icon,
                  color: config.accentColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Level badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: config.accentColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            config.label,
                            style: GoogleFonts.poppins(
                              fontSize: 8,
                              fontWeight: FontWeight.w700,
                              color: config.accentColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          timeAgo,
                          style: GoogleFonts.poppins(
                            fontSize: 9,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      alert.title,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      alert.message,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Dismiss button
              GestureDetector(
                onTap: onDismiss,
                child: Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Icon(
                    Icons.close_rounded,
                    size: 16,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _AlertConfig _getAlertConfig(String level) {
    switch (level) {
      case 'danger':
        return _AlertConfig(
          icon: Icons.warning_amber_rounded,
          label: 'EMERGENCY',
          accentColor: const Color(0xFFE53935),
          bgColor: const Color(0xFFFFF5F5),
          borderColor: const Color(0xFFFFCDD2),
        );
      case 'warning':
        return _AlertConfig(
          icon: Icons.traffic_rounded,
          label: 'TRAFFIC ALERT',
          accentColor: const Color(0xFFF57F17),
          bgColor: const Color(0xFFFFFDE7),
          borderColor: const Color(0xFFFFF9C4),
        );
      case 'info':
      default:
        return _AlertConfig(
          icon: Icons.info_outline_rounded,
          label: 'INFO',
          accentColor: const Color(0xFF1565C0),
          bgColor: const Color(0xFFE3F2FD),
          borderColor: const Color(0xFFBBDEFB),
        );
    }
  }
}

class _AlertConfig {
  final IconData icon;
  final String label;
  final Color accentColor;
  final Color bgColor;
  final Color borderColor;

  const _AlertConfig({
    required this.icon,
    required this.label,
    required this.accentColor,
    required this.bgColor,
    required this.borderColor,
  });
}
