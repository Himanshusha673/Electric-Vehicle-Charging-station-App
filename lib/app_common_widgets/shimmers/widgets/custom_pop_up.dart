import 'package:flutter/material.dart';

import '../../../app_utils/app_functions.dart';

class BatteryChargingPainter extends CustomPainter {
  BatteryChargingPainter({
    required this.charge,
  });

  final int charge;

  final double batteryShellWidth = 25.w;
  final double batteryShellHeight = 20.h;
  final double borderRadius = 10.0; // Add a border radius value

  final batteryShellPainter = Paint()
    ..style = PaintingStyle.stroke
    ..color = Colors.black;

  final chargingPaint = Paint()
    ..style = PaintingStyle.fill
    ..color = Colors.green;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final shellRect = Rect.fromCenter(
      center: center,
      width: batteryShellWidth,
      height: batteryShellHeight,
    );

    final shellRRect = RRect.fromRectAndRadius(
      shellRect,
      Radius.circular(borderRadius), // Apply border radius to the battery shell
    );

    canvas.drawRRect(shellRRect, batteryShellPainter);

    final chargeHeight = batteryShellHeight * charge / 100;

    final chargeRect = Rect.fromLTWH(
      center.dx - batteryShellWidth / 2,
      center.dy + batteryShellHeight / 2 - chargeHeight,
      batteryShellWidth,
      chargeHeight,
    );

    final chargeRRect = RRect.fromRectAndRadius(
      chargeRect,
      Radius.circular(borderRadius), // Apply border radius to the charging area
    );

    canvas.drawRRect(chargeRRect, chargingPaint);

    final chargingBoltPath = Path();
    chargingBoltPath.moveTo(
        center.dx - batteryShellWidth / 4, center.dy - batteryShellHeight / 4);
    chargingBoltPath.lineTo(center.dx - batteryShellWidth / 4, center.dy);
    chargingBoltPath.lineTo(
        center.dx + batteryShellWidth / 4, center.dy - batteryShellHeight / 4);
    chargingBoltPath.lineTo(center.dx + batteryShellWidth / 4, center.dy);
    chargingBoltPath.close();

    canvas.drawPath(chargingBoltPath, chargingPaint);
  }

  @override
  bool shouldRepaint(BatteryChargingPainter oldDelegate) {
    return oldDelegate.charge != charge;
  }
}

class BatteryChargingAnimation extends StatefulWidget {
  const BatteryChargingAnimation({Key? key}) : super(key: key);

  @override
  _BatteryChargingAnimationState createState() =>
      _BatteryChargingAnimationState();
}

class _BatteryChargingAnimationState extends State<BatteryChargingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<int> _chargeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _chargeAnimation =
        IntTween(begin: 0, end: 100).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _chargeAnimation,
      builder: (context, child) {
        return CustomPaint(
          size: Size(20.w, 20.h),
          painter: BatteryChargingPainter(
            charge: _chargeAnimation.value,
          ),
        );
      },
    );
  }
}
