import 'dart:async';
import 'package:flutter/foundation.dart';

enum FestivalPhase {
  beforeFestival,
  mahaShashthi,
  mahaSaptami,
  mahaAshtami,
  sandhiPuja,
  mahaNavami,
  vijayaDashami,
  postFestival,
}

enum CountdownDisplayMode {
  liveTimer,
  calendarDays,
  liveClock,
}

class FestivalDayInfo {
  final String title;
  final String bengaliTitle;
  final String dateDisplay;
  final DateTime date;
  final String description;
  final String keyRituals;
  final String ghatalSpotlight;
  final bool isSpecialPuja;

  const FestivalDayInfo({
    required this.title,
    required this.bengaliTitle,
    required this.dateDisplay,
    required this.date,
    required this.description,
    required this.keyRituals,
    required this.ghatalSpotlight,
    this.isSpecialPuja = false,
  });
}

/// Service providing live, real-time countdown and festival timing information
/// for Ghatal Sharodutsav 2026.
class LiveFestivalService extends ChangeNotifier {
  static final LiveFestivalService _instance = LiveFestivalService._internal();
  factory LiveFestivalService() => _instance;

  LiveFestivalService._internal();

  Timer? _timer;
  DateTime? _customNow;
  CountdownDisplayMode _displayMode = CountdownDisplayMode.liveTimer;

  @override
  void addListener(VoidCallback listener) {
    super.addListener(listener);
    if (_timer == null) {
      _startTimer();
    }
  }

  @override
  void removeListener(VoidCallback listener) {
    super.removeListener(listener);
    if (!hasListeners) {
      stopTimer();
    }
  }

  // Key Durga Puja 2026 dates (Ghatal Sharodutsav 2026)
  static final DateTime mahaShashthi = DateTime(2026, 10, 16, 0, 0, 0);
  static final DateTime mahaSaptami = DateTime(2026, 10, 18, 0, 0, 0);
  static final DateTime mahaAshtami = DateTime(2026, 10, 19, 0, 0, 0);
  static final DateTime sandhiPujaStart = DateTime(2026, 10, 19, 10, 27, 0);
  static final DateTime sandhiPujaEnd = DateTime(2026, 10, 19, 11, 15, 0);
  static final DateTime mahaNavami = DateTime(2026, 10, 20, 0, 0, 0);
  static final DateTime vijayaDashami = DateTime(2026, 10, 21, 0, 0, 0);
  static final DateTime festivalEnd = DateTime(2026, 10, 22, 0, 0, 0);

  CountdownDisplayMode get displayMode => _displayMode;

  void setDisplayMode(CountdownDisplayMode mode) {
    if (_displayMode != mode) {
      _displayMode = mode;
      notifyListeners();
    }
  }

  void toggleDisplayMode() {
    switch (_displayMode) {
      case CountdownDisplayMode.liveTimer:
        _displayMode = CountdownDisplayMode.calendarDays;
        break;
      case CountdownDisplayMode.calendarDays:
        _displayMode = CountdownDisplayMode.liveClock;
        break;
      case CountdownDisplayMode.liveClock:
        _displayMode = CountdownDisplayMode.liveTimer;
        break;
    }
    notifyListeners();
  }

  /// Override time for testing purposes
  void setCustomTime(DateTime? time) {
    _customNow = time;
    notifyListeners();
  }

  DateTime get now => _customNow ?? DateTime.now();

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      notifyListeners();
    });
  }

  void startTimer() {
    _startTimer();
  }

  void stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  FestivalPhase get currentPhase {
    final current = now;
    if (current.isBefore(mahaShashthi)) return FestivalPhase.beforeFestival;
    if (current.isBefore(mahaSaptami)) return FestivalPhase.mahaShashthi;
    if (current.isBefore(mahaAshtami)) return FestivalPhase.mahaSaptami;
    if (current.isBefore(mahaNavami)) {
      if (current.isAfter(sandhiPujaStart) && current.isBefore(sandhiPujaEnd)) {
        return FestivalPhase.sandhiPuja;
      }
      return FestivalPhase.mahaAshtami;
    }
    if (current.isBefore(vijayaDashami)) return FestivalPhase.mahaNavami;
    if (current.isBefore(festivalEnd)) return FestivalPhase.vijayaDashami;
    return FestivalPhase.postFestival;
  }

  String get currentPhaseName {
    final current = now;
    if (current.isBefore(mahaShashthi)) return 'PRE-PUJA COUNTDOWN';
    if (current.isBefore(mahaSaptami)) return 'MAHA SHASHTHI';
    if (current.isBefore(mahaAshtami)) return 'MAHA SAPTAMI';
    if (current.isBefore(mahaNavami)) {
      if (current.isAfter(sandhiPujaStart) && current.isBefore(sandhiPujaEnd)) {
        return 'SANDHI PUJA';
      }
      return 'MAHA ASHTAMI';
    }
    if (current.isBefore(vijayaDashami)) return 'MAHA NAVAMI';
    if (current.isBefore(festivalEnd)) return 'VIJAYA DASHAMI';
    return 'SUBHO BIJOYA';
  }

  /// Live badge text that updates dynamically every second based on display mode
  String get badgeText {
    switch (_displayMode) {
      case CountdownDisplayMode.liveTimer:
        return liveTimerBadgeText;
      case CountdownDisplayMode.calendarDays:
        return calendarDaysBadgeText;
      case CountdownDisplayMode.liveClock:
        return liveClockBadgeText;
    }
  }

  /// Live precision countdown badge text
  String get liveTimerBadgeText {
    final current = now;

    // 1. Before Maha Saptami (like today Oct 16)
    if (current.isBefore(mahaSaptami)) {
      final diff = mahaSaptami.difference(current);
      final days = diff.inDays;
      final hours = diff.inHours % 24;
      final minutes = diff.inMinutes % 60;
      final seconds = diff.inSeconds % 60;

      final hStr = hours.toString().padLeft(2, '0');
      final mStr = minutes.toString().padLeft(2, '0');
      final sStr = seconds.toString().padLeft(2, '0');

      if (days > 0) {
        return 'MAHA SAPTAMI IN ${days}D ${hStr}H ${mStr}M ${sStr}S';
      } else if (hours > 0) {
        return 'MAHA SAPTAMI IN ${hours}H ${mStr}M ${sStr}S';
      } else {
        return 'MAHA SAPTAMI IN ${minutes}M ${sStr}S';
      }
    }

    // 2. On Maha Saptami (Oct 18)
    if (current.isBefore(mahaAshtami)) {
      final diff = mahaAshtami.difference(current);
      final hours = diff.inHours % 24;
      final minutes = diff.inMinutes % 60;
      final seconds = diff.inSeconds % 60;
      return 'MAHA SAPTAMI LIVE • ASHTAMI IN ${hours}H ${minutes.toString().padLeft(2, '0')}M ${seconds.toString().padLeft(2, '0')}S';
    }

    // 3. On Maha Ashtami (Oct 19)
    if (current.isBefore(mahaNavami)) {
      if (current.isAfter(sandhiPujaStart) && current.isBefore(sandhiPujaEnd)) {
        final diff = sandhiPujaEnd.difference(current);
        final minutes = diff.inMinutes % 60;
        final seconds = diff.inSeconds % 60;
        return '🔥 SANDHI PUJA LIVE • ${minutes}M ${seconds.toString().padLeft(2, '0')}S LEFT';
      } else if (current.isBefore(sandhiPujaStart)) {
        final diff = sandhiPujaStart.difference(current);
        final hours = diff.inHours;
        final minutes = diff.inMinutes % 60;
        final seconds = diff.inSeconds % 60;
        return 'MAHA ASHTAMI LIVE • SANDHI PUJA IN ${hours}H ${minutes.toString().padLeft(2, '0')}M ${seconds.toString().padLeft(2, '0')}S';
      } else {
        final diff = mahaNavami.difference(current);
        final hours = diff.inHours % 24;
        final minutes = diff.inMinutes % 60;
        final seconds = diff.inSeconds % 60;
        return 'MAHA ASHTAMI LIVE • NAVAMI IN ${hours}H ${minutes.toString().padLeft(2, '0')}M ${seconds.toString().padLeft(2, '0')}S';
      }
    }

    // 4. On Maha Navami (Oct 20)
    if (current.isBefore(vijayaDashami)) {
      final diff = vijayaDashami.difference(current);
      final hours = diff.inHours % 24;
      final minutes = diff.inMinutes % 60;
      final seconds = diff.inSeconds % 60;
      return 'MAHA NAVAMI LIVE • DASHAMI IN ${hours}H ${minutes.toString().padLeft(2, '0')}M ${seconds.toString().padLeft(2, '0')}S';
    }

    // 5. On Vijaya Dashami (Oct 21)
    if (current.isBefore(festivalEnd)) {
      return 'VIJAYA DASHAMI LIVE • SUBHO BIJOYA 🌺';
    }

    // 6. Post-Festival
    return 'SUBHO BIJOYA • GHATAL SHARODUTSAV';
  }

  /// Calendar days format (e.g. "MAHA SHASHTHI TODAY • SAPTAMI IN 2 DAYS")
  String get calendarDaysBadgeText {
    final current = now;

    if (current.isBefore(mahaShashthi)) {
      final days = mahaSaptami.difference(current).inDays + 1;
      return 'MAHA SAPTAMI IN $days DAYS';
    }

    if (current.isBefore(mahaSaptami)) {
      final calDays = mahaSaptami.difference(DateTime(current.year, current.month, current.day)).inDays;
      if (calDays > 1) {
        return 'MAHA SHASHTHI TODAY • SAPTAMI IN $calDays DAYS';
      } else {
        return 'MAHA SAPTAMI TOMORROW (IN 1 DAY)';
      }
    }

    if (current.isBefore(mahaAshtami)) {
      return 'MAHA SAPTAMI TODAY • PUJA LIVE';
    }
    if (current.isBefore(mahaNavami)) {
      return 'MAHA ASHTAMI TODAY • KUMARI & SANDHI PUJA';
    }
    if (current.isBefore(vijayaDashami)) {
      return 'MAHA NAVAMI TODAY • MAHA ARATI';
    }
    if (current.isBefore(festivalEnd)) {
      return 'VIJAYA DASHAMI TODAY • SUBHO BIJOYA';
    }

    return 'SUBHO BIJOYA • GHATAL SHARODUTSAV';
  }

  /// Live Ghatal clock format
  String get liveClockBadgeText {
    final current = now;
    final hour = current.hour;
    final minute = current.minute.toString().padLeft(2, '0');
    final second = current.second.toString().padLeft(2, '0');
    final amPm = hour >= 12 ? 'PM' : 'AM';
    final hour12 = hour % 12 == 0 ? 12 : hour % 12;

    final phaseName = currentPhaseName;
    return 'LIVE $hour12:$minute:$second $amPm • $phaseName';
  }

  /// Detailed duration components to Maha Saptami (or current target)
  Duration get timeUntilNextPhase {
    final current = now;
    if (current.isBefore(mahaSaptami)) {
      return mahaSaptami.difference(current);
    }
    if (current.isBefore(mahaAshtami)) {
      return mahaAshtami.difference(current);
    }
    if (current.isBefore(sandhiPujaStart)) {
      return sandhiPujaStart.difference(current);
    }
    if (current.isBefore(sandhiPujaEnd)) {
      return sandhiPujaEnd.difference(current);
    }
    if (current.isBefore(mahaNavami)) {
      return mahaNavami.difference(current);
    }
    if (current.isBefore(vijayaDashami)) {
      return vijayaDashami.difference(current);
    }
    if (current.isBefore(festivalEnd)) {
      return festivalEnd.difference(current);
    }
    return Duration.zero;
  }

  /// Ghatal Sharodutsav 2026 comprehensive schedule
  static final List<FestivalDayInfo> festivalSchedule = [
    FestivalDayInfo(
      title: 'Maha Shashthi',
      bengaliTitle: 'মহা ষষ্ঠী',
      dateDisplay: 'Friday, Oct 16, 2026',
      date: DateTime(2026, 10, 16),
      description: 'Devi Bodhon, Amantran and Adhibas marking the auspicious awakening of Maa Durga.',
      keyRituals: 'Kalparambha, Bodhon, Bilva Nimantran & Adhibas',
      ghatalSpotlight: 'Grand pandal inaugurations across Kushpata, Konnagar, and Shilabati river banks.',
    ),
    FestivalDayInfo(
      title: 'Maha Saptami',
      bengaliTitle: 'মহা সপ্তমী',
      dateDisplay: 'Sunday, Oct 18, 2026',
      date: DateTime(2026, 10, 18),
      description: 'Nabapatrika Snan (Kolabou Snan) and formal Prana Pratishtha of Goddess Durga.',
      keyRituals: 'Kolabou Snan at Shilabati Ghat, Navapatrika Pravesh & Mahasnan',
      ghatalSpotlight: 'Historic dawn bathing procession at Shilabati Ghat and grand illumination opening.',
    ),
    FestivalDayInfo(
      title: 'Maha Ashtami & Sandhi Puja',
      bengaliTitle: 'মহা অষ্টমী ও সন্ধিপূজা',
      dateDisplay: 'Monday, Oct 19, 2026',
      date: DateTime(2026, 10, 19),
      description: 'Peak day of Sharodutsav. Kumari Puja in the morning and sacred Sandhi Puja (10:27 AM - 11:15 AM).',
      keyRituals: 'Maha Ashtami Vrata, Kumari Puja, Pushpanjali, 108 Lotuses & 108 Diyas for Sandhi Puja',
      ghatalSpotlight: 'Mass Pushpanjali across all 32+ Ghatal pandals; thousands gather for 108 lamp Sandhi Arati.',
      isSpecialPuja: true,
    ),
    FestivalDayInfo(
      title: 'Maha Navami',
      bengaliTitle: 'মহা নবমী',
      dateDisplay: 'Tuesday, Oct 20, 2026',
      date: DateTime(2026, 10, 20),
      description: 'Navami Homa, grand evening Mahasandhya Arati, and energetic Dhunuchi Naach.',
      keyRituals: 'Navami Homa, Kumari Bhojan, Maha Bhog & Dhunuchi Naach competition',
      ghatalSpotlight: 'All-night pandal hopping peak with Toto trails connecting Kharar to Kushpata & Konnagar.',
    ),
    FestivalDayInfo(
      title: 'Vijaya Dashami',
      bengaliTitle: 'বিজয়া দশমী',
      dateDisplay: 'Wednesday, Oct 21, 2026',
      date: DateTime(2026, 10, 21),
      description: 'Devi Baran, Sindoor Khela, and grand immersion procession at Shilabati River.',
      keyRituals: 'Aparajita Puja, Sindoor Khela, Ghatal Visarjan & Subho Bijoya greetings',
      ghatalSpotlight: 'Traditional boat flotilla along Shilabati River with illuminated idols and festive Dhak beats.',
    ),
  ];
}
