import 'package:flutter/widgets.dart';

import 'ui.dart';

class InputField extends StatefulWidget {
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final TextStyle? style;
  final Widget? suffixIcon;
  final Widget? prefixIcon;

  const InputField({
    super.key,
    this.initialValue,
    this.onChanged,
    this.style,
    this.suffixIcon,
    this.prefixIcon,
  });

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool focused = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? '');
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() {
        focused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var theme = CQTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.backgroundColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: focused
              ? theme.inputTheme.focusedBorderColor
              : theme.inputTheme.borderColor,
          width: focused ? 2 : 1,
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            if (widget.prefixIcon != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: IconTheme(
                  data: IconThemeData(
                    size: theme.iconTheme.iconSize,
                    color: theme.iconTheme.iconColor,
                  ),
                  child: widget.prefixIcon!,
                ),
              ),
              Container(
                width: 1,
                //thickness: 1,
                color: theme.inputTheme.borderColor,
              ),
            ],
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: EditableText(
                  controller: _controller,
                  focusNode: _focusNode,
                  style: widget.style ?? theme.textStyle,
                  cursorColor: theme.caretColor,
                  backgroundCursorColor: theme.caretColor,
                  maxLines: 1,
                  onChanged: widget.onChanged,
                  keyboardType: TextInputType.text,
                ),
              ),
            ),
            if (widget.suffixIcon != null) ...[
              Container(
                width: 1,
                //thickness: 1,
                color: theme.inputTheme.borderColor,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: IconTheme(
                  data: IconThemeData(
                    size: theme.iconTheme.iconSize,
                    color: theme.iconTheme.iconColor,
                  ),
                  child: widget.suffixIcon!,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
