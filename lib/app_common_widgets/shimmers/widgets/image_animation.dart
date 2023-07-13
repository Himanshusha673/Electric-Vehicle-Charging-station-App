import 'package:flutter/material.dart';

class OnOffAnimation extends StatefulWidget {
  @override
  _OnOffAnimationState createState() => _OnOffAnimationState();
}

class _OnOffAnimationState extends State<OnOffAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    // Create the animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    // Create the opacity animation
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return AnimatedOpacity(
          opacity: _opacityAnimation.value,
          duration: const Duration(milliseconds: 500),
          child: Image.asset(
            'assets/images/gpev.png',
            width: 200,
            height: 100,
          ),
        );
      },
    );
  }
}
