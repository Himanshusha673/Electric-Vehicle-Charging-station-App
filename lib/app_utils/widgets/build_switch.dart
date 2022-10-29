import 'package:flutter/material.dart';

class BuildSwitch extends StatelessWidget {
  final ValueNotifier<bool> switchNotifier;
  final ValueChanged<bool>? callback;

  const BuildSwitch({
    Key? key,
    required this.switchNotifier,
    this.callback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: switchNotifier,
      builder: (context, notifierValue, _) {
        return Container(
          width: 54,
          height: 30,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(60.0),
            color: (notifierValue == true)
                ? Theme.of(context).primaryColor
                : Theme.of(context).unselectedWidgetColor,
          ),
          child: Transform.scale(
            scale: 1.35,
            child: Switch(
              activeTrackColor: Colors.transparent,
              inactiveTrackColor: Colors.transparent,
              activeColor: Colors.white,
              value: notifierValue,
              onChanged: (callback != null)
                  ? callback
                  : (val) {
                      switchNotifier.value = val;
                    },
            ),
          ),
        );
      },
    );
  }
}
