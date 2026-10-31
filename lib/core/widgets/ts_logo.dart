import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../constants/app_constants.dart';

/// App logo from brand asset.
class TsLogo extends StatelessWidget {
  const TsLogo({
    super.key,
    this.size = 72,
    this.showWordmark = true,
  });

  final double size;
  final bool showWordmark;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          label: '${AppConstants.appName} logo',
          child: ClipRRect(
            borderRadius: BorderRadius.circular(size * 0.18),
            child: Image.asset(
              'assets/images/app_logo.png',
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: AppColors.secondaryTeal,
                  borderRadius: BorderRadius.circular(size * 0.18),
                ),
                child: Icon(
                  Icons.handshake_outlined,
                  size: size * 0.45,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ),
        if (showWordmark) ...[
          const SizedBox(height: 12),
          Text(
            AppConstants.appName,
            style: TextStyle(
              fontSize: size > 60 ? 26 : 20,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ],
    );
  }
}
