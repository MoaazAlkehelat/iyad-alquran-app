import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';

/// A small label + hairline rule that introduces a group of content.
class SectionHeader extends StatelessWidget {
  final String text;
  final EdgeInsetsGeometry padding;

  const SectionHeader(
    this.text, {
    super.key,
    this.padding = const EdgeInsets.only(bottom: AppSpace.md, top: AppSpace.xs),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: [
          Text(text, style: AppTextStyles.sectionLabel),
          const SizedBox(width: AppSpace.md),
          Expanded(
            child: Container(
              height: 1,
              color: AppColors.teal.withValues(alpha: 0.18),
            ),
          ),
        ],
      ),
    );
  }
}
