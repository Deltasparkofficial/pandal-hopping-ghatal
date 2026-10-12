import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppFooter extends StatelessWidget {
  final bool isDark;

  const AppFooter({super.key, this.isDark = false});

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white70 : const Color(0xFF795548);
    final brandColor = isDark ? const Color(0xFFFFCC80) : const Color(0xFFB71C1C);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Watermark text: "Made with love by Deltaspark"
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
              children: [
                const TextSpan(text: 'Made with '),
                const TextSpan(
                  text: '❤️ ',
                  style: TextStyle(fontSize: 12),
                ),
                const TextSpan(text: 'by '),
                TextSpan(
                  text: 'Deltaspark',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: brandColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          // Subtitle: "@ All rights reserved by Ghatal pandal hopping 2026"
          Text(
            '@ All rights reserved by Ghatal pandal hopping 2026',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: isDark ? Colors.white38 : Colors.black45,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
