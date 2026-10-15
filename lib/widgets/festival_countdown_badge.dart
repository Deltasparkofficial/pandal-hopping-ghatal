import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/live_festival_service.dart';
import '../theme/app_theme.dart';

class FestivalCountdownBadge extends StatefulWidget {
  final bool compact;

  const FestivalCountdownBadge({
    super.key,
    this.compact = false,
  });

  @override
  State<FestivalCountdownBadge> createState() => _FestivalCountdownBadgeState();
}

class _FestivalCountdownBadgeState extends State<FestivalCountdownBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _openFestivalScheduleSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _FestivalScheduleSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final festivalService = LiveFestivalService();

    return ListenableBuilder(
      listenable: festivalService,
      builder: (context, _) {
        final badgeText = festivalService.badgeText;
        final phase = festivalService.currentPhase;
        final isSandhi = phase == FestivalPhase.sandhiPuja;
        final isSpecialLive = phase != FestivalPhase.beforeFestival &&
            phase != FestivalPhase.postFestival;

        final badgeColor = isSandhi
            ? const Color(0xFFC62828)
            : (isSpecialLive
                ? const Color(0xFF1B5E20)
                : const Color(0xFF2E7D32));

        final dotColor = isSandhi
            ? const Color(0xFFFFD54F)
            : (isSpecialLive
                ? const Color(0xFF69F0AE)
                : const Color(0xFF81C784));

        return RepaintBoundary(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _openFestivalScheduleSheet(context),
              borderRadius: BorderRadius.circular(22),
              splashColor: Colors.white24,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6.5),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      badgeColor,
                      badgeColor.withValues(alpha: 0.88),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: dotColor.withValues(alpha: 0.45),
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: badgeColor.withValues(alpha: 0.40),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Live Pulsing Indicator Dot
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: dotColor,
                            boxShadow: [
                              BoxShadow(
                                color: dotColor.withValues(
                                  alpha: _pulseAnimation.value * 0.8,
                                ),
                                blurRadius: 6,
                                spreadRadius: _pulseAnimation.value * 1.5,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 8),

                    // Live Countdown Text (updates every second)
                    Flexible(
                      child: Text(
                        badgeText,
                        style: GoogleFonts.poppins(
                          fontSize: widget.compact ? 9.5 : 10.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.5,
                          fontFeatures: const [
                            FontFeature.tabularFigures(),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    const SizedBox(width: 6),
                    Icon(
                      Icons.schedule_rounded,
                      size: 11,
                      color: Colors.white.withValues(alpha: 0.75),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Comprehensive interactive Festival Schedule Bottom Sheet
class _FestivalScheduleSheet extends StatelessWidget {
  const _FestivalScheduleSheet();

  @override
  Widget build(BuildContext context) {
    final festivalService = LiveFestivalService();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final sheetBg = isDark ? const Color(0xFF1E1E24) : Colors.white;
    final cardBg = isDark
        ? const Color(0xFF282832)
        : const Color(0xFFFFF8E7);
    final cardBorder = isDark
        ? const Color(0xFF3F3F50)
        : const Color(0xFFFFE0B2);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          // Drag handle
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.black12,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 14),

          // Header Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.temple_hindu_rounded,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ghatal Sharodutsav 2026',
                        style: GoogleFonts.poppins(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Live Puja Schedule & Tithi Countdown',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white70 : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    Icons.close_rounded,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),
          const Divider(height: 1),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
              children: [
                // Live Countdown Hero Box
                ListenableBuilder(
                  listenable: festivalService,
                  builder: (context, _) {
                    final current = festivalService.now;
                    final target = LiveFestivalService.mahaSaptami;
                    final diff = target.difference(current);

                    final days = diff.isNegative ? 0 : diff.inDays;
                    final hours = diff.isNegative ? 0 : (diff.inHours % 24);
                    final minutes = diff.isNegative ? 0 : (diff.inMinutes % 60);
                    final seconds = diff.isNegative ? 0 : (diff.inSeconds % 60);

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF880E4F),
                            Color(0xFFB71C1C),
                            Color(0xFFC62828),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFB71C1C).withValues(alpha: 0.35),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xFF69F0AE),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'COUNTDOWN TO MAHA SAPTAMI',
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFFFFD54F),
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                'Sunday, Oct 18',
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Countdown Blocks
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildTimeCard(days.toString().padLeft(2, '0'), 'DAYS'),
                              _buildColonDivider(),
                              _buildTimeCard(hours.toString().padLeft(2, '0'), 'HOURS'),
                              _buildColonDivider(),
                              _buildTimeCard(minutes.toString().padLeft(2, '0'), 'MINUTES'),
                              _buildColonDivider(),
                              _buildTimeCard(seconds.toString().padLeft(2, '0'), 'SECONDS'),
                            ],
                          ),

                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Current Live Time: ${festivalService.now.hour.toString().padLeft(2, '0')}:${festivalService.now.minute.toString().padLeft(2, '0')}:${festivalService.now.second.toString().padLeft(2, '0')} IST • Live Tithi Tracker',
                              style: GoogleFonts.poppins(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 18),

                // Display Mode Switcher
                ListenableBuilder(
                  listenable: festivalService,
                  builder: (context, _) {
                    final currentMode = festivalService.displayMode;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Badge Display Mode (Tap to Switch Live):',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white70 : AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildModeChip(
                              context: context,
                              title: 'Live Countdown',
                              subtitle: '1D 23H 03M 52S',
                              isSelected: currentMode == CountdownDisplayMode.liveTimer,
                              onTap: () => festivalService.setDisplayMode(CountdownDisplayMode.liveTimer),
                            ),
                            _buildModeChip(
                              context: context,
                              title: 'Calendar Days',
                              subtitle: 'Saptami in 2 Days',
                              isSelected: currentMode == CountdownDisplayMode.calendarDays,
                              onTap: () => festivalService.setDisplayMode(CountdownDisplayMode.calendarDays),
                            ),
                            _buildModeChip(
                              context: context,
                              title: 'Ghatal Live Clock',
                              subtitle: 'Clock + Day',
                              isSelected: currentMode == CountdownDisplayMode.liveClock,
                              onTap: () => festivalService.setDisplayMode(CountdownDisplayMode.liveClock),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 22),

                // Schedule Title
                Row(
                  children: [
                    const Icon(Icons.event_note_rounded, size: 16, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(
                      'Durga Puja 2026 Schedule & Highlights',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Day-by-day list
                ...LiveFestivalService.festivalSchedule.map((day) {
                  final now = festivalService.now;
                  final isToday = now.year == day.date.year &&
                      now.month == day.date.month &&
                      now.day == day.date.day;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isToday
                          ? AppColors.primary.withValues(alpha: isDark ? 0.20 : 0.08)
                          : cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isToday
                            ? AppColors.primary
                            : (day.isSpecialPuja ? const Color(0xFFD4A017) : cardBorder),
                        width: isToday ? 1.6 : 1.0,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 6,
                                children: [
                                  Text(
                                    day.title,
                                    style: GoogleFonts.poppins(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w800,
                                      color: isDark ? Colors.white : AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    '(${day.bengaliTitle})',
                                    style: GoogleFonts.notoSansBengali(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (isToday)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2E7D32),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'TODAY • LIVE',
                                  style: GoogleFonts.poppins(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            else if (day.isSpecialPuja)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD4A017).withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'SANDHI PUJA',
                                  style: GoogleFonts.poppins(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFFB78103),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          day.dateDisplay,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          day.description,
                          style: GoogleFonts.poppins(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w400,
                            color: isDark ? Colors.white70 : AppColors.textSecondary,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.explore_outlined, size: 13, color: AppColors.goldLight),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                'Ghatal Tip: ${day.ghatalSpotlight}',
                                style: GoogleFonts.poppins(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? const Color(0xFFF5D076) : const Color(0xFF8D6E12),
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeCard(String value, String label) {
    return Column(
      children: [
        Container(
          width: 52,
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Text(
            value,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              fontFeatures: const [
                FontFeature.tabularFigures(),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 7.5,
            fontWeight: FontWeight.w600,
            color: Colors.white70,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildColonDivider() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Text(
        ':',
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w900,
          color: Colors.white.withValues(alpha: 0.6),
        ),
      ),
    );
  }

  Widget _buildModeChip({
    required BuildContext context,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary
                : (isDark ? const Color(0xFF282832) : Colors.grey.shade100),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : (isDark ? Colors.white12 : Colors.grey.shade300),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : (isDark ? Colors.white : AppColors.textPrimary),
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.poppins(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w500,
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.85)
                      : (isDark ? Colors.white60 : AppColors.textMuted),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
