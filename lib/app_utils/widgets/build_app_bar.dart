import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../app_functions.dart';

class BuildAppBar extends StatelessWidget {
  final Widget? leading;
  final GestureTapCallback? leadingCallback;
  final String? title;
  final bool? centerTitle;

  const BuildAppBar({
    Key? key,
    this.leading,
    this.leadingCallback,
    this.title,
    this.centerTitle = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: leading ??
          InkWell(
            onTap: leadingCallback ??
                () {
                  Navigator.maybePop(context);
                },
            borderRadius: BorderRadius.circular(40.0),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_back_ios,
                size: 20.sp,
                color: Theme.of(context).iconTheme.color,
              ),
            ),
          ),
      centerTitle: centerTitle,
      title: Container(
        child: padQuotes(title).isNotEmpty
            ? Text(
                toBeginningOfSentenceCase(padQuotes(title!))!,
                textAlign: TextAlign.start,
                style: Theme.of(context).textTheme.headline1!.copyWith(
                    // height: 0.8,
                    ),
              )
            : null,
      ),
    );
  }
}
