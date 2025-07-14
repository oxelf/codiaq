import 'package:codiaq_editor/src/ui/cq_widgets/theme.dart';
import 'package:flutter/widgets.dart';

class TextArea extends StatefulWidget {
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final TextStyle? style;
  final int? minLines;
  final int? maxLines;
  final bool expandIcon;
  final bool expands;

  const TextArea({
    super.key,
    this.initialValue,
    this.onChanged,
    this.style,
    this.minLines = 1,
    this.maxLines,
    this.expandIcon = false,
    this.expands = false,
  });

  @override
  State<TextArea> createState() => _TextAreaState();
}

class _TextAreaState extends State<TextArea> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool focused = false;
  bool isExpanded = false;

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
    isExpanded = widget.expandIcon;
  }

  @override
  void didUpdateWidget(covariant TextArea oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.expandIcon != oldWidget.expandIcon && !widget.expands) {
      setState(() {
        isExpanded = widget.expandIcon;
      });
    }
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
    final effectiveMaxLines = widget.maxLines ?? null;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.backgroundColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color:
              focused
                  ? theme.inputTheme.focusedBorderColor
                  : theme.inputTheme.borderColor,
          width: focused ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: EditableText(
          controller: _controller,
          focusNode: _focusNode,
          style: widget.style ?? theme.textStyle,
          cursorColor: theme.caretColor,
          backgroundCursorColor: theme.caretColor,
          minLines: null, //widget.minLines,
          maxLines: effectiveMaxLines,
          onChanged: widget.onChanged,
          keyboardType: TextInputType.multiline,
        ),
      ),
    );
  }
}
