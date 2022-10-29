import 'package:flutter/material.dart';

class HideKeyboard extends StatelessWidget {
  final Widget child;

  const HideKeyboard({
    Key? key,
    required this.child,
  }) : super(key: key);

  static void hide(context) {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        hide(context);
      },
      child: child,
    );
  }
}
