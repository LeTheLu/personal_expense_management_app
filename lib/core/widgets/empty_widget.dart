import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:du_an/core/constants/app_colors.dart';
import 'package:du_an/core/constants/app_images.dart';

class EmptyWidget extends StatelessWidget {
  final String message;
  final String? subtitle;
  final VoidCallback? onAction;
  final String? actionLabel;

  const EmptyWidget({
    super.key,
    required this.message,
    this.subtitle,
    this.onAction,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              AppImages.empty,
              width: 150,
              height: 150,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onAction != null && actionLabel != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
