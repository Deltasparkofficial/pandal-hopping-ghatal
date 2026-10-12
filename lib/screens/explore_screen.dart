import 'package:flutter/material.dart';
import '../widgets/hero_banner.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/filter_chips_row.dart';
import '../widgets/live_queue_radar_banner.dart';
import '../widgets/live_pandal_section.dart';
import '../widgets/new_pandal_registration_section.dart';
import '../widgets/google_ad_section.dart';
import '../widgets/app_footer.dart';
import '../widgets/top_app_bar.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Top App Bar
          const SliverToBoxAdapter(
            child: TopAppBarWidget(),
          ),

          // Hero Banner
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: HeroBanner(),
            ),
          ),

          // Search Bar
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 20, 16, 12),
              child: SearchBarWidget(),
            ),
          ),

          // Filter Chips
          const SliverToBoxAdapter(
            child: FilterChipsRow(),
          ),

          // Live Queue Radar Banner (Live People in Line Tracker)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(top: 18),
              child: LiveQueueRadarBanner(),
            ),
          ),

          // Live Pandal Hop with Real-time People in Line Counters
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 22, 16, 0),
              child: LivePandalSection(),
            ),
          ),

          // New Pandal Registration Section (Official Google Form)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 26, 16, 0),
              child: NewPandalRegistrationSection(),
            ),
          ),

          // Google Ads Section
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 0),
              child: GoogleAdSection(),
            ),
          ),

          // Deltaspark Footer Watermark
          const SliverToBoxAdapter(
            child: AppFooter(),
          ),

          // Bottom spacing
          const SliverToBoxAdapter(
            child: SizedBox(height: 16),
          ),
        ],
      ),
    );
  }
}
