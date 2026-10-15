import 'package:flutter/material.dart';
import '../widgets/hero_banner.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/filter_chips_row.dart';
import '../widgets/live_queue_radar_banner.dart';
import '../widgets/live_pandal_section.dart';
import '../widgets/live_crowd_alerts_banner.dart';
import '../widgets/offline_zone_section.dart';
import '../widgets/new_pandal_registration_section.dart';
import '../widgets/app_footer.dart';
import '../widgets/top_app_bar.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1080),
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: const [
              // Top App Bar
              SliverToBoxAdapter(
                child: TopAppBarWidget(),
              ),

              // Live Crowd Alerts from Admin Panel
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 4, 16, 0),
                  child: LiveCrowdAlertsBanner(),
                ),
              ),

              // Hero Banner
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: HeroBanner(),
                ),
              ),

              // Search Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 20, 16, 12),
                  child: SearchBarWidget(),
                ),
              ),

              // Filter Chips
              SliverToBoxAdapter(
                child: FilterChipsRow(),
              ),

              // Live Queue Radar Banner (Live People in Line Tracker)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(top: 18),
                  child: LiveQueueRadarBanner(),
                ),
              ),

              // Live Pandal Hop with Real-time People in Line Counters
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 22, 16, 0),
                  child: LivePandalSection(),
                ),
              ),

              // Offline Zone Maps Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 24, 16, 0),
                  child: OfflineZoneSection(),
                ),
              ),

              // New Pandal Registration Section (Official Google Form)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 26, 16, 0),
                  child: NewPandalRegistrationSection(),
                ),
              ),

              // Deltaspark Footer Watermark
              SliverToBoxAdapter(
                child: AppFooter(),
              ),

              // Bottom spacing
              SliverToBoxAdapter(
                child: SizedBox(height: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
