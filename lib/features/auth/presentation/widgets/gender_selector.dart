import 'package:flutter/material.dart';
import 'package:moit/core/constants/app_colors.dart';
import 'package:moit/core/constants/app_text_styles.dart';
import 'package:moit/features/auth/data/models/signup_request.dart';

/// 성별 선택 위젯
class GenderSelector extends StatelessWidget {
  final Gender? selectedGender;
  final ValueChanged<Gender> onChanged;
  final String? label;

  const GenderSelector({
    super.key,
    required this.selectedGender,
    required this.onChanged,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: AppTextStyles.inputLabel,
          ),
          const SizedBox(height: 8),
        ],
        Row(
          children: [
            Expanded(
              child: _GenderOption(
                label: '남자',
                isSelected: selectedGender == Gender.male,
                onTap: () => onChanged(Gender.male),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _GenderOption(
                label: '여자',
                isSelected: selectedGender == Gender.female,
                onTap: () => onChanged(Gender.female),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _GenderOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.genderSelected : AppColors.genderUnselected,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.textPrimary : AppColors.inputBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTextStyles.button.copyWith(
            color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
