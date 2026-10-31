import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../constants/app_constants.dart';

/// Minimal logo: helping hand + digital connection + learning mark.
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
          child: CustomPaint(
            size: Size(size, size),
            painter: _LogoPainter(),
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

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final teal = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;
    final soft = Paint()
      ..color = AppColors.secondaryTeal
      ..style = PaintingStyle.fill;

    final cx = size.width / 2;
    final cy = size.height / 2;

    // Soft circle background
    canvas.drawCircle(Offset(cx, cy), size.width * 0.48, soft);

    // Helping hand (simple open palm shape)
    final hand = Path()
      ..moveTo(cx - size.width * 0.18, cy + size.height * 0.12)
      ..quadraticBezierTo(
        cx - size.width * 0.22,
        cy - size.height * 0.05,
        cx - size.width * 0.08,
        cy - size.height * 0.18,
      )
      ..quadraticBezierTo(
        cx,
        cy - size.height * 0.28,
        cx + size.width * 0.08,
        cy - size.height * 0.18,
      )
      ..quadraticBezierTo(
        cx + size.width * 0.22,
        cy - size.height * 0.05,
        cx + size.width * 0.18,
        cy + size.height * 0.12,
      )
      ..close();
    canvas.drawPath(hand, teal);

    // Digital connection dots
    final white = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(cx - size.width * 0.08, cy + size.height * 0.02), 3.2, white);
    canvas.drawCircle(Offset(cx, cy + size.height * 0.02), 3.2, white);
    canvas.drawCircle(Offset(cx + size.width * 0.08, cy + size.height * 0.02), 3.2, white);

    // Subtle book / education mark under hand
    final book = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.85)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(cx - size.width * 0.12, cy + size.height * 0.28),
      Offset(cx + size.width * 0.12, cy + size.height * 0.28),
      book,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
