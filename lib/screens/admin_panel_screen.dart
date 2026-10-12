import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/pandal_queue_model.dart';
import '../services/live_queue_service.dart';
import '../theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/app_footer.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  final LiveQueueService _queueService = LiveQueueService();
  String? _selectedPandalId;

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
    if (_queueService.pandals.isNotEmpty) {
      _selectedPandalId = _queueService.pandals.first.id;
    }
  }

  @override
  void dispose() {
    _alertTitleController.dispose();
    _alertMsgController.dispose();
    _newPandalNameController.dispose();
    _newPandalZoneController.dispose();
    _newPandalCountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
}
