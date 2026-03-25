import 'package:flutter/material.dart';
import 'package:du_an/core/constants/app_colors.dart';

class MenuItemRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String amount;
  final Color iconColor;
  final Color iconBackgroundColor;
  final Color labelColor;
  final Color amountColor;
  final double iconSize;
  final double labelFontSize;
  final double amountFontSize;
  final Widget? trailing;

  const MenuItemRow({
    super.key,
    required this.icon,
    required this.label,
    required this.amount,
    this.iconColor = Colors.white,
    this.iconBackgroundColor = AppColors.primaryDark,
    this.labelColor = AppColors.primaryDark,
    this.amountColor = AppColors.primaryDark,
    this.iconSize = 13,
    this.labelFontSize = 10,
    this.amountFontSize = 12,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 4,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: iconBackgroundColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: iconSize),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(color: labelColor, fontSize: labelFontSize),
            ),
            Text(
              amount,
              style: TextStyle(
                color: amountColor,
                fontSize: amountFontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const Spacer(),
        if (trailing != null) trailing!,
      ],
    );
  }
}
