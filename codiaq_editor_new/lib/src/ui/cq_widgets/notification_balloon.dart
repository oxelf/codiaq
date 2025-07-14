import 'package:codiaq_editor/ui.dart';
import 'package:flutter/material.dart';

class CQNotificationBalloon extends StatefulWidget {
  final String? title;
  final String? message;
  final Widget? icon;
  final List<Widget>? actions;
  const CQNotificationBalloon({
    super.key,
    this.title,
    this.message,
    this.icon,
    this.actions,
  });
  static Widget popup(
    String title,
    String message, {
    Widget? icon,
    List<Widget>? actions,
  }) {
    return Builder(
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: CQTheme.of(context).backgroundColor,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: CQNotificationBalloon(
            title: title,
            message: message,
            icon: icon,
            actions: actions,
          ),
        );
      },
    );
  }

  @override
  State<CQNotificationBalloon> createState() => _CQNotificationBalloonState();
}

class _CQNotificationBalloonState extends State<CQNotificationBalloon> {
  @override
  Widget build(BuildContext context) {
    var theme = CQTheme.of(context);
    return Padding(
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
              if (widget.icon != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: widget.icon!,
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
                  style: TextStyle(fontSize: 12, color: theme.textStyle.color),
                ),
              SizedBox(height: 8.0),

              if (widget.actions != null)
                Row(
                  children:
                      widget.actions!
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
    );
  }
}
