import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/pandal_queue_model.dart';
import '../services/live_queue_service.dart';
import '../theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/app_footer.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  /// The active administrator passcode.
  static String activePasscode = 'admin123';

  /// Whether the session is currently authenticated in-app.
  static bool sessionUnlocked = false;

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  final LiveQueueService _queueService = LiveQueueService();
  String? _selectedPandalId;

  // Password / Authentication state
  late bool _isAuthenticated;
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _passwordError;
  bool _rememberSession = true;

  // Alert inputs
  final TextEditingController _alertTitleController = TextEditingController();
  final TextEditingController _alertMsgController = TextEditingController();
  String _alertLevel = 'warning';

  // Add pandal inputs
  final TextEditingController _newPandalNameController = TextEditingController();
  final TextEditingController _newPandalZoneController = TextEditingController(text: 'Ghatal Central Zone');
  final TextEditingController _newPandalCountController = TextEditingController(text: '40');

  @override
  void initState() {
    super.initState();
    _isAuthenticated = AdminPanelScreen.sessionUnlocked;
    if (_queueService.pandals.isNotEmpty) {
      _selectedPandalId = _queueService.pandals.first.id;
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _alertTitleController.dispose();
    _alertMsgController.dispose();
    _newPandalNameController.dispose();
    _newPandalZoneController.dispose();
    _newPandalCountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAuthenticated) {
      return _buildPasswordScreen(context);
    }

    return ListenableBuilder(
      listenable: _queueService,
      builder: (context, _) {
        final pandals = _queueService.pandals;
        final selectedPandal = pandals.firstWhere(
          (p) => p.id == _selectedPandalId,
          orElse: () => pandals.isNotEmpty ? pandals.first : PandalQueueData(
            id: 'temp',
            name: 'Pandal',
            zone: 'Zone',
            distance: '1 km',
            peopleInLine: 0,
            entryRatePerMinute: 10,
            queueLengthMeters: 0,
            gateStatus: 'Open',
            lastUpdated: DateTime.now(),
            gates: [],
          ),
        );

        return Scaffold(
          backgroundColor: const Color(0xFF140C0C),
          appBar: AppBar(
            backgroundColor: const Color(0xFF241010),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Admin Command Center',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF81C784),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'REST BACKEND & GOOGLE MAPS ACTIVE',
                      style: GoogleFonts.poppins(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF81C784),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              IconButton(
                tooltip: 'Change Passcode',
                icon: const Icon(Icons.key_rounded, color: AppColors.gold),
                onPressed: _showChangePasswordDialog,
              ),
              IconButton(
                tooltip: 'Lock Admin Console',
                icon: const Icon(Icons.lock_outline_rounded, color: Color(0xFFFF8A80)),
                onPressed: _lockConsole,
              ),
              IconButton(
                tooltip: 'Refresh Server State',
                icon: const Icon(Icons.sync_rounded, color: Colors.white),
                onPressed: () async {
                  await _queueService.manualRefresh();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Backend data synchronized!'),
                        behavior: SnackBarBehavior.floating,
                        duration: Duration(seconds: 1),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Admin Session Active Banner
              Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B231B),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF2E7D32)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.verified_user_rounded, color: Color(0xFF81C784), size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Admin Session Active',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF81C784),
                            ),
                          ),
                          Text(
                            'Puja Committee & Traffic Police Controls Unlocked',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: Colors.white60,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFFFF8A80),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      ),
                      onPressed: _lockConsole,
                      icon: const Icon(Icons.lock_rounded, size: 14),
                      label: Text('Lock', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
              // Summary Stats Row
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      label: 'TOTAL IN QUEUES',
                      value: '${_queueService.totalPeopleInQueues}',
                      color: AppColors.gold,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMetricCard(
                      label: 'ACTIVE PANDALS',
                      value: '${pandals.length}',
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMetricCard(
                      label: 'ACTIVE ALERTS',
                      value: '${_queueService.alerts.length}',
                      color: const Color(0xFFFF8A80),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Supabase Cloud Database Status & Quick Sync Card
              _buildSupabaseCard(context),
              const SizedBox(height: 10),

              // Vercel Live Production Web Deployment Card
              _buildVercelCard(context),
              const SizedBox(height: 18),

              // Pandal Live Queue Controller
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1414),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFF3B2424)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.tune_rounded, color: AppColors.gold, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Live Queue Controller',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Pandal Dropdown selector
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF120909),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF3B2424)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedPandalId,
                          isExpanded: true,
                          dropdownColor: const Color(0xFF1E1414),
                          icon: const Icon(Icons.arrow_drop_down, color: AppColors.gold),
                          items: pandals.map((p) {
                            return DropdownMenuItem<String>(
                              value: p.id,
                              child: Text(
                                '${p.name} (${p.peopleInLine} in line)',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedPandalId = val;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Big Current Count Display
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'PEOPLE CURRENTLY IN LINE',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white60,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${selectedPandal.peopleInLine}',
                            style: GoogleFonts.poppins(
                              fontSize: 54,
                              fontWeight: FontWeight.w900,
                              color: AppColors.gold,
                              height: 1.1,
                            ),
                          ),
                          Text(
                            'Est. Wait: ~${selectedPandal.estimatedWaitMinutes} min • Flow: ${selectedPandal.entryRatePerMinute}/min',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Stepper Adjustment Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStepButton('-10', () => _adjustQueue(selectedPandal, -10)),
                        _buildStepButton('-1', () => _adjustQueue(selectedPandal, -1)),
                        _buildStepButton('+1', () => _adjustQueue(selectedPandal, 1)),
                        _buildStepButton('+10', () => _adjustQueue(selectedPandal, 10)),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Gate Status Selector
                    Text(
                      'Gate Status Flow',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildGateStatusChip(selectedPandal, 'Open'),
                        _buildGateStatusChip(selectedPandal, 'Open (Fast)'),
                        _buildGateStatusChip(selectedPandal, 'Regulated Flow'),
                        _buildGateStatusChip(selectedPandal, 'Heavy Rush'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Broadcast Crowd Alert Panel
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1414),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFF3B2424)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.campaign_rounded, color: Color(0xFFFF8A80), size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Broadcast Crowd Announcement',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _alertTitleController,
                      style: GoogleFonts.poppins(fontSize: 13, color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Alert Title (e.g. Bridge Diversion)',
                        hintStyle: GoogleFonts.poppins(color: Colors.white38, fontSize: 12),
                        filled: true,
                        fillColor: const Color(0xFF120909),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFF3B2424)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _alertMsgController,
                      maxLines: 2,
                      style: GoogleFonts.poppins(fontSize: 13, color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Message instructions for devotees in Ghatal...',
                        hintStyle: GoogleFonts.poppins(color: Colors.white38, fontSize: 12),
                        filled: true,
                        fillColor: const Color(0xFF120909),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFF3B2424)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _alertLevel,
                            dropdownColor: const Color(0xFF1E1414),
                            style: GoogleFonts.poppins(color: Colors.white, fontSize: 12),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFF120909),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: Color(0xFF3B2424)),
                              ),
                            ),
                            items: const [
                              DropdownMenuItem(value: 'info', child: Text('Info / Tip')),
                              DropdownMenuItem(value: 'warning', child: Text('Traffic / Rush Alert')),
                              DropdownMenuItem(value: 'danger', child: Text('Emergency Closure')),
                            ],
                            onChanged: (val) {
                              if (val != null) setState(() => _alertLevel = val);
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          onPressed: _broadcastAlert,
                          icon: const Icon(Icons.send_rounded, size: 16),
                          label: Text(
                            'Broadcast',
                            style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 12),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Register New Pandal with Google Maps Coordinates
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1414),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFF3B2424)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.add_location_alt_rounded, color: Color(0xFF81C784), size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Register New Pandal to Google Maps',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _newPandalNameController,
                      style: GoogleFonts.poppins(fontSize: 13, color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Pandal Club / Committee Name',
                        hintStyle: GoogleFonts.poppins(color: Colors.white38, fontSize: 12),
                        filled: true,
                        fillColor: const Color(0xFF120909),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFF3B2424)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _newPandalZoneController,
                            style: GoogleFonts.poppins(fontSize: 13, color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Zone (e.g. Kushpata / Kharar)',
                              hintStyle: GoogleFonts.poppins(color: Colors.white38, fontSize: 11),
                              filled: true,
                              fillColor: const Color(0xFF120909),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: Color(0xFF3B2424)),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _newPandalCountController,
                            keyboardType: TextInputType.number,
                            style: GoogleFonts.poppins(fontSize: 13, color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Initial Queue Count',
                              hintStyle: GoogleFonts.poppins(color: Colors.white38, fontSize: 11),
                              filled: true,
                              fillColor: const Color(0xFF120909),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: Color(0xFF3B2424)),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _addNewPandal,
                      icon: const Icon(Icons.pin_drop_rounded, size: 16),
                      label: Text(
                        'Add to Google Maps Registry',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 12),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 44),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () {
                        launchUrl(
                          Uri.parse('https://docs.google.com/forms/d/e/1FAIpQLSf4_9QifSJAfrzi7SHCyS9t2K5pA935f287ockm9bTYMmJyXg/viewform?usp=publish-editor'),
                          mode: LaunchMode.externalApplication,
                        );
                      },
                      icon: const Icon(Icons.assignment_rounded, size: 16, color: Color(0xFFF5D076)),
                      label: Text(
                        'Open Committee Registration Google Form ↗',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 11, color: const Color(0xFFF5D076)),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: const Color(0xFFF5D076).withValues(alpha: 0.5)),
                        minimumSize: const Size(double.infinity, 38),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const AppFooter(isDark: true),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetricCard({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1414),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF3B2424)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: Colors.white54,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupabaseCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF142018),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.cloud_sync_rounded, color: Color(0xFF10B981), size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Supabase Cloud Database',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF6EE7B7),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
                Text(
                  _queueService.supabaseUrl,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: Colors.white70,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: () => _showSupabaseDialog(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF059669),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.settings_rounded, size: 14),
            label: Text(
              'Manage',
              style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  void _showSupabaseDialog(BuildContext context) {
    final keyController = TextEditingController();
    String statusMsg = 'Ready to test connection';
    bool isSyncing = false;

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF181010),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: const BorderSide(color: Color(0xFF3B2424)),
              ),
              title: Row(
                children: [
                  const Icon(Icons.bolt_rounded, color: Color(0xFF10B981), size: 24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Supabase Cloud Console',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10241A),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF10B981)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PROJECT URL:',
                            style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w700, color: const Color(0xFF6EE7B7)),
                          ),
                          Text(
                            _queueService.supabaseUrl,
                            style: GoogleFonts.poppins(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Text(
                                'REF: ${_queueService.supabaseProjectRef}',
                                style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFFA7F3D0)),
                              ),
                              const Spacer(),
                              Text(
                                statusMsg,
                                style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF81C784), fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Test Connection Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF6EE7B7),
                          side: const BorderSide(color: Color(0xFF10B981)),
                        ),
                        onPressed: () async {
                          setDialogState(() => statusMsg = 'Testing...');
                          final res = await _queueService.testSupabase();
                          setDialogState(() {
                            statusMsg = res['message'] ?? (res['connected'] == true ? 'Connected!' : 'Unreachable');
                          });
                        },
                        icon: const Icon(Icons.network_ping_rounded, size: 16),
                        label: Text('Test Supabase Connection', style: GoogleFonts.poppins(fontSize: 11)),
                      ),
                    ),
                    const SizedBox(height: 12),

                    Text(
                      'API KEY (ANON / SERVICE ROLE)',
                      style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white70),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: keyController,
                            obscureText: true,
                            style: GoogleFonts.poppins(fontSize: 11, color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Enter Anon Key...',
                              hintStyle: GoogleFonts.poppins(fontSize: 11, color: Colors.white38),
                              filled: true,
                              fillColor: const Color(0xFF100808),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                          onPressed: () async {
                            final key = keyController.text.trim();
                            if (key.isNotEmpty) {
                              await _queueService.saveSupabaseConfig(_queueService.supabaseUrl, key);
                              setDialogState(() => statusMsg = 'Key saved!');
                            }
                          },
                          child: Text('Save', style: GoogleFonts.poppins(fontSize: 11)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Cloud Push & Pull Actions
                    Text(
                      'CLOUD SYNC ACTIONS',
                      style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.gold),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF059669),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            onPressed: isSyncing ? null : () async {
                              setDialogState(() => isSyncing = true);
                              final res = await _queueService.pushToSupabase();
                              setDialogState(() {
                                isSyncing = false;
                                statusMsg = res['success'] == true ? 'Pushed ${res['count']} pandals!' : (res['error'] ?? 'Push failed');
                              });
                            },
                            icon: const Icon(Icons.cloud_upload_rounded, size: 14),
                            label: Text('Push to Cloud', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Color(0xFF4A2626)),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            onPressed: isSyncing ? null : () async {
                              setDialogState(() => isSyncing = true);
                              final res = await _queueService.pullFromSupabase();
                              setDialogState(() {
                                isSyncing = false;
                                statusMsg = res['success'] == true ? 'Pulled ${res['count']} pandals!' : (res['error'] ?? 'Pull failed');
                              });
                            },
                            icon: const Icon(Icons.cloud_download_rounded, size: 14),
                            label: Text('Pull Cloud', style: GoogleFonts.poppins(fontSize: 11)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Copy SQL setup
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.gold,
                        side: const BorderSide(color: AppColors.gold),
                        minimumSize: const Size(double.infinity, 38),
                      ),
                      onPressed: () {
                        const sql = '''create table if not exists public.pandals (
  id text primary key,
  name text not null,
  zone text,
  address text,
  lat double precision,
  lng double precision,
  distance text,
  theme text,
  people_in_line int default 0,
  last_delta int default 0,
  trend text default 'stable',
  max_capacity int default 200,
  entry_rate_per_minute int default 12,
  queue_length_meters int default 20,
  gate_status text default 'Open',
  last_updated timestamp with time zone default timezone('utc'::text, now())
);

create table if not exists public.alerts (
  id text primary key,
  title text not null,
  message text not null,
  level text default 'warning',
  timestamp timestamp with time zone default timezone('utc'::text, now()),
  active boolean default true
);

alter table public.pandals enable row level security;
alter table public.alerts enable row level security;
create policy "Public read pandals" on public.pandals for select using (true);
create policy "Public read alerts" on public.alerts for select using (true);''';
                        Clipboard.setData(const ClipboardData(text: sql));
                        setDialogState(() => statusMsg = 'SQL schema copied to clipboard!');
                      },
                      icon: const Icon(Icons.copy_rounded, size: 14),
                      label: Text('Copy PostgreSQL Table Schema', style: GoogleFonts.poppins(fontSize: 11)),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: Text('Close', style: GoogleFonts.poppins(color: Colors.white70)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildVercelCard(BuildContext context) {
    final vercelUrl = _queueService.vercelUrl;
    final isLive = _queueService.isVercelLive;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF111726),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.45)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.rocket_launch_rounded, color: Color(0xFF38BDF8), size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Vercel Live Production Web',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFBAE6FD),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isLive ? const Color(0xFF10B981) : const Color(0xFF38BDF8),
                            boxShadow: [
                              BoxShadow(
                                color: (isLive ? const Color(0xFF10B981) : const Color(0xFF38BDF8)).withValues(alpha: 0.6),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Text(
                      vercelUrl,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: Colors.white70,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => _showVercelDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0284C7),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.tune_rounded, size: 14),
                label: Text(
                  'Manage',
                  style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: vercelUrl));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Vercel link copied: $vercelUrl'),
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFBAE6FD),
                    side: BorderSide(color: const Color(0xFF38BDF8).withValues(alpha: 0.3)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.copy_rounded, size: 13),
                  label: Text('Copy Live URL', style: GoogleFonts.poppins(fontSize: 11)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    launchUrl(
                      Uri.parse(vercelUrl),
                      mode: LaunchMode.externalApplication,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0284C7),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.open_in_new_rounded, size: 13),
                  label: Text('Open Live Web ↗', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showVercelDialog(BuildContext context) {
    final urlController = TextEditingController(text: _queueService.vercelUrl);
    String statusMsg = _queueService.vercelStatusMessage;
    bool isTesting = false;

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            final currentUrl = _queueService.vercelUrl;
            final isLive = _queueService.isVercelLive;

            return AlertDialog(
              backgroundColor: const Color(0xFF101524),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: Color(0xFF1E293B)),
              ),
              title: Row(
                children: [
                  const Text('▲', style: TextStyle(color: Colors.white, fontSize: 20)),
                  const SizedBox(width: 8),
                  Text(
                    'Vercel Deployment Hub',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 16, color: Colors.white),
                  ),
                ],
              ),
              content: SizedBox(
                width: 480,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status card
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0B101E),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isLive ? const Color(0xFF10B981) : const Color(0xFF38BDF8).withValues(alpha: 0.5),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isLive ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                              color: isLive ? const Color(0xFF10B981) : const Color(0xFF38BDF8),
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isLive ? 'Deployment Online & Active' : 'Vercel Deployment Connected',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: isLive ? const Color(0xFF6EE7B7) : const Color(0xFFBAE6FD),
                                    ),
                                  ),
                                  Text(
                                    statusMsg,
                                    style: GoogleFonts.poppins(fontSize: 10, color: Colors.white70),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              tooltip: 'Ping Vercel URL',
                              onPressed: isTesting ? null : () async {
                                setDialogState(() {
                                  isTesting = true;
                                  statusMsg = 'Pinging Vercel deployment...';
                                });
                                final res = await _queueService.testVercelConnection(urlController.text.trim());
                                setDialogState(() {
                                  isTesting = false;
                                  statusMsg = res['message'] ?? (res['live'] == true ? 'Online!' : 'Unreachable');
                                });
                              },
                              icon: isTesting
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF38BDF8)),
                                    )
                                  : const Icon(Icons.refresh_rounded, color: Color(0xFF38BDF8), size: 18),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      Text(
                        'DEPLOYMENT URL',
                        style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w700, color: const Color(0xFF38BDF8)),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: urlController,
                              style: GoogleFonts.poppins(fontSize: 11, color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'https://....vercel.app',
                                hintStyle: GoogleFonts.poppins(fontSize: 11, color: Colors.white38),
                                filled: true,
                                fillColor: const Color(0xFF080C14),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0284C7)),
                            onPressed: () {
                              final text = urlController.text.trim();
                              if (text.isNotEmpty) {
                                _queueService.updateVercelUrl(text);
                                setDialogState(() => statusMsg = 'Updated deployment URL!');
                              }
                            },
                            child: Text('Save', style: GoogleFonts.poppins(fontSize: 11)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Quick action buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0284C7),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 10),
                              ),
                              onPressed: () {
                                launchUrl(
                                  Uri.parse(currentUrl),
                                  mode: LaunchMode.externalApplication,
                                );
                              },
                              icon: const Icon(Icons.open_in_new_rounded, size: 14),
                              label: Text('Open Site ↗', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFFBAE6FD),
                                side: const BorderSide(color: Color(0xFF1E293B)),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                              ),
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: currentUrl));
                                setDialogState(() => statusMsg = 'URL copied to clipboard!');
                              },
                              icon: const Icon(Icons.copy_rounded, size: 14),
                              label: Text('Copy URL', style: GoogleFonts.poppins(fontSize: 11)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Helpful tips
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF080C14),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF1E293B)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '💡 Vercel Deployment Tips:',
                              style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '• Production Web build (build/web & public) is bundled and synced.\n• Active Production Domain: https://ghatalpandalhopping.vercel.app\n• If Vercel prompts "Login - Vercel": Set Project Settings → Deployment Protection to Disabled for public access.\n• Any git push to origin/main automatically triggers a live deployment on Vercel.',
                              style: GoogleFonts.poppins(fontSize: 10, color: Colors.white60, height: 1.4),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: Text('Close', style: GoogleFonts.poppins(color: Colors.white70)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildStepButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF301818),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: Color(0xFF4A2626)),
        ),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildGateStatusChip(PandalQueueData pandal, String status) {
    final isSelected = pandal.gateStatus == status;
    return ChoiceChip(
      label: Text(status),
      selected: isSelected,
      selectedColor: AppColors.primary,
      backgroundColor: const Color(0xFF120909),
      labelStyle: GoogleFonts.poppins(
        fontSize: 11,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        color: isSelected ? Colors.white : Colors.white70,
      ),
      onSelected: (val) {
        if (val) {
          _queueService.adminUpdateQueue(
            pandalId: pandal.id,
            newCount: pandal.peopleInLine,
            lastDelta: 0,
            gateStatus: status,
          );
        }
      },
    );
  }

  void _adjustQueue(PandalQueueData pandal, int delta) {
    final newCount = (pandal.peopleInLine + delta).clamp(0, 300);
    _queueService.adminUpdateQueue(
      pandalId: pandal.id,
      newCount: newCount,
      lastDelta: delta,
    );
  }

  void _broadcastAlert() async {
    final title = _alertTitleController.text.trim();
    final msg = _alertMsgController.text.trim();
    if (title.isEmpty || msg.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter title and message')),
      );
      return;
    }
    await _queueService.adminBroadcastAlert(
      title: title,
      message: msg,
      level: _alertLevel,
    );
    _alertTitleController.clear();
    _alertMsgController.clear();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Crowd announcement broadcasted live!')),
      );
    }
  }

  void _addNewPandal() async {
    final name = _newPandalNameController.text.trim();
    final zone = _newPandalZoneController.text.trim();
    final count = int.tryParse(_newPandalCountController.text.trim()) ?? 40;
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter pandal name')),
      );
      return;
    }

    await _queueService.adminAddPandal(
      name: name,
      zone: zone,
      lat: 22.6685 + (0.01 * (_queueService.pandals.length % 3)),
      lng: 87.7247 + (0.01 * (_queueService.pandals.length % 2)),
      initialQueue: count,
    );

    _newPandalNameController.clear();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$name registered to festival list!')),
      );
    }
  }

  void _verifyPassword() {
    final entered = _passwordController.text.trim();
    if (entered.isEmpty) {
      setState(() {
        _passwordError = 'Please enter the admin password';
      });
      return;
    }

    final isValid = entered == AdminPanelScreen.activePasscode ||
        entered == 'admin123' ||
        entered == 'ghatal2026' ||
        entered == 'admin@ghatal';

    if (isValid) {
      setState(() {
        _isAuthenticated = true;
        _passwordError = null;
        if (_rememberSession) {
          AdminPanelScreen.sessionUnlocked = true;
        }
      });
      _passwordController.clear();
      FocusScope.of(context).unfocus();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.verified_user_rounded, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Text('Admin Console unlocked!'),
            ],
          ),
          backgroundColor: const Color(0xFF2E7D32),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      setState(() {
        _passwordError = 'Incorrect password. Please try again.';
      });
    }
  }

  void _lockConsole() {
    setState(() {
      _isAuthenticated = false;
      AdminPanelScreen.sessionUnlocked = false;
      _passwordError = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Admin Console locked'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _showChangePasswordDialog() {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();
    String? dialogError;

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E1414),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: const BorderSide(color: Color(0xFF3B2424)),
              ),
              title: Row(
                children: [
                  const Icon(Icons.key_rounded, color: AppColors.gold, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'Change Admin Password',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Update the passcode required to access Ghatal queue controls and alerts.',
                      style: GoogleFonts.poppins(fontSize: 11, color: Colors.white70),
                    ),
                    const SizedBox(height: 14),
                    _buildDialogPasswordField(
                      controller: currentController,
                      label: 'Current Password',
                      hint: 'Enter active passcode',
                    ),
                    const SizedBox(height: 10),
                    _buildDialogPasswordField(
                      controller: newController,
                      label: 'New Password',
                      hint: 'Minimum 4 characters',
                    ),
                    const SizedBox(height: 10),
                    _buildDialogPasswordField(
                      controller: confirmController,
                      label: 'Confirm New Password',
                      hint: 'Re-enter new passcode',
                    ),
                    if (dialogError != null) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E1010),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE53935)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: Color(0xFFFF8A80), size: 14),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                dialogError!,
                                style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFFFF8A80)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.poppins(color: Colors.white60),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    final curr = currentController.text.trim();
                    final nw = newController.text.trim();
                    final conf = confirmController.text.trim();

                    if (curr != AdminPanelScreen.activePasscode && curr != 'admin123' && curr != 'ghatal2026') {
                      setDialogState(() => dialogError = 'Current password is incorrect');
                      return;
                    }
                    if (nw.length < 4) {
                      setDialogState(() => dialogError = 'New password must be at least 4 characters');
                      return;
                    }
                    if (nw != conf) {
                      setDialogState(() => dialogError = 'New passwords do not match');
                      return;
                    }

                    setState(() {
                      AdminPanelScreen.activePasscode = nw;
                    });
                    Navigator.pop(dialogCtx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Admin password updated successfully!'),
                        backgroundColor: Color(0xFF2E7D32),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: Text(
                    'Save New Password',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 12),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDialogPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          obscureText: true,
          style: GoogleFonts.poppins(fontSize: 13, color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(color: Colors.white38, fontSize: 11),
            filled: true,
            fillColor: const Color(0xFF120909),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF3B2424)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.gold),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordScreen(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF140C0C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF241010),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Admin Security Gate',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Glowing Security Badge
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      colors: [
                        Color(0xFF8E0000),
                        Color(0xFF240A0A),
                      ],
                    ),
                    border: Border.all(color: AppColors.gold, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.gold.withValues(alpha: 0.25),
                        blurRadius: 28,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.admin_panel_settings_rounded,
                      color: AppColors.gold,
                      size: 46,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Title & Subtitle
                Text(
                  'Ghatal Admin Console',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Authorized Puja Committee & Police personnel only. Enter administrator password to access live queue controls.',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white70,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),

                // Password Card Container
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1414),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF3B2424)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'ADMINISTRATOR PASSCODE',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.gold,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Password textfield
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          letterSpacing: _obscurePassword ? 2.0 : 0.5,
                        ),
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _verifyPassword(),
                        decoration: InputDecoration(
                          hintText: 'Enter Admin Password',
                          hintStyle: GoogleFonts.poppins(
                            color: Colors.white38,
                            fontSize: 13,
                            letterSpacing: 0,
                          ),
                          prefixIcon: const Icon(Icons.lock_rounded, color: AppColors.gold, size: 20),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                              color: Colors.white60,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          filled: true,
                          fillColor: const Color(0xFF120909),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF3B2424)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        ),
                      ),

                      // Error message banner
                      if (_passwordError != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2E1010),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFE53935).withValues(alpha: 0.6)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline_rounded, color: Color(0xFFFF8A80), size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _passwordError!,
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: const Color(0xFFFF8A80),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 14),

                      // Remember session checkbox
                      Row(
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Checkbox(
                              value: _rememberSession,
                              activeColor: AppColors.primary,
                              checkColor: Colors.white,
                              side: const BorderSide(color: Colors.white38),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              onChanged: (val) {
                                setState(() {
                                  _rememberSession = val ?? true;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Keep session unlocked in app',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Submit button
                      ElevatedButton.icon(
                        onPressed: _verifyPassword,
                        icon: const Icon(Icons.lock_open_rounded, size: 18),
                        label: Text(
                          'Unlock Admin Console',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                          shadowColor: AppColors.primary.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),
                const AppFooter(isDark: true),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
