import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class FilterChipsRow extends StatefulWidget {
  const FilterChipsRow({super.key});

  @override
  State<FilterChipsRow> createState() => _FilterChipsRowState();
}

class _FilterChipsRowState extends State<FilterChipsRow> {
  int _selectedIndex = 0;

  final List<_FilterChipData> _chips = [
    _FilterChipData('Live Queues', Icons.sensors_rounded, true),
    _FilterChipData('Popularity', Icons.local_fire_department, true),
    _FilterChipData('Nearest', Icons.navigation_outlined, false),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _chips.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final chip = _chips[index];
          final isSelected = _selectedIndex == index;
          return _buildChip(chip, isSelected, index);
        },
      ),
    );
  }

  Widget _buildChip(_FilterChipData chip, bool isSelected, int index) {
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: chip.label.isEmpty ? 12 : 16,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.chipSelected : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? AppColors.primary.withValues(alpha: 0.4) : AppColors.chipBorder,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (chip.icon != null) ...[
              Icon(
                chip.icon,
                size: 16,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
              if (chip.label.isNotEmpty) const SizedBox(width: 6),
            ],
            if (chip.label.isNotEmpty)
              Text(
                chip.label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FilterChipData {
  final String label;
  final IconData? icon;
  final bool hasIcon;

  _FilterChipData(this.label, this.icon, this.hasIcon);
}
