import 'package:flutter/material.dart';
import '../../themes/colors.dart';
import '../../themes/text_styles.dart';

class RoundedButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isPrimary;
  final double borderRadius;
  final EdgeInsets padding;

  const RoundedButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isPrimary = true,
    this.borderRadius = 30.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isPrimary ? AppColors.primary : Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        side: BorderSide(color: AppColors.primary, width: isPrimary ? 0 : 2),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(borderRadius),
        onTap: onPressed,
        child: Padding(
          padding: padding,
          child: Text(
            text,
            style: AppTextStyles.buttonText.copyWith(
              color: isPrimary
                  ? AppTextStyles.buttonText.color
                  : AppColors.primary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
