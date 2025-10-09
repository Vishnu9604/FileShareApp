import 'package:flutter/material.dart';
import '../utils/constants.dart';

class SimpleButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final String? variant;
  final IconData? icon;

  const SimpleButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isSecondary = variant == 'secondary';

    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: icon != null ? Icon(icon) : const SizedBox.shrink(),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSecondary ? Colors.grey.shade200 : AppConstants.primaryColor,
        foregroundColor: isSecondary ? AppConstants.textColor : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
