import 'package:flutter/material.dart';

import 'theme.dart';

enum CQAlertType { info, warning, error }

// jetbrains states:
//Use 440 px width if at least one is applicable:
//Buttons are no wider than 348 px
//Text is > 130 symbols
// else expand the width to fit the content
class CQAlert extends StatefulWidget {
  final String? title;
  final String? message;
  final CQAlertType type;
  final List<Widget>? actions;
  const CQAlert({
    super.key,
    this.title,
    this.message,
    this.type = CQAlertType.info,
    this.actions,
  });

  @override
  State<CQAlert> createState() => _CQAlertState();
}

class _CQAlertState extends State<CQAlert> {
  @override
  Widget build(BuildContext context) {
    var theme = CQTheme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.backgroundColor,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: theme.buttonStyle.hoverBackgroundColor,
          width: 1.0,
        ),
      ),
      constraints: BoxConstraints(minWidth: 370),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: icon,
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.title != null)
                  Text(
                    widget.title!,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: theme.textStyle.color,
                    ),
                  ),
                SizedBox(height: 4.0),

                if (widget.message != null)
                  Text(
                    widget.message!,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.textStyle.color,
                    ),
                  ),
                SizedBox(height: 8.0),

                if (widget.actions != null)
                  Row(
                    children: widget.actions!
                        .map(
                          (action) => Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: action,
                          ),
                        )
                        .toList(),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget get icon {
    switch (widget.type) {
      case CQAlertType.info:
        return Icon(Icons.info_outlined, color: Colors.blue);
      case CQAlertType.warning:
        return Icon(Icons.warning_amber_outlined, color: Colors.orange);
      case CQAlertType.error:
        return Icon(Icons.error_outlined, color: Colors.red);
    }
  }
}
