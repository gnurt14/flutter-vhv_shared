import 'package:flutter/material.dart';
import 'package:vhv_widgets/form.dart';
import 'package:vhv_widgets/vhv_widgets.dart';

class FormTerm extends StatefulWidget {
  const FormTerm({super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    required this.onLinkTap,
    this.errorText,
    this.focusNode
  });
  final String label;
  final String? errorText;
  final bool value;
  final ValueChanged<bool?> onChanged;
  final ValueChanged<String> onLinkTap;
  final FocusNode? focusNode;

  @override
  State<FormTerm> createState() => _FormTermState();
}

class _FormTermState extends State<FormTerm> {
  bool value = false;

  @override
  void initState() {
    value = widget.value;
    widget.focusNode?.addListener(_handleFocusChange);
    super.initState();
  }

  void _handleFocusChange() {
    if (widget.focusNode?.hasFocus == true && mounted) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 300),
        curve: Curves.linear,
      );
    }
  }

  @override
  void didUpdateWidget(covariant FormTerm oldWidget) {
    value = widget.value;
    if (widget.focusNode != oldWidget.focusNode) {
      oldWidget.focusNode?.removeListener(_handleFocusChange);
      widget.focusNode?.addListener(_handleFocusChange);
    }
    super.didUpdateWidget(oldWidget);
  }
  @override
  void dispose() {
    widget.focusNode?.removeListener(_handleFocusChange);
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 24,
              width: 24,
              child: Checkbox(
                focusNode: widget.focusNode,
                value: value,
                isError: widget.errorText != null,
                onChanged: (val){
                  widget.onChanged(val);
                  value = val??false;
                  safeRun((){
                    setState(() {});
                  });
                },
              ),
            ),
            const SizedBox(
              width: 7,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 3),
                child: HTMLViewer(widget.label.replaceAll('<link>', '<a href="javascript:;">')
                    .replaceAll('</link>', '</a>'),
                  onLinkTap: widget.onLinkTap,
                  style: {
                    '*': Style(
                        fontSize: FontSize(14),
                        color: getProperties(const Color(0xff0C0C0E), Colors.white70),
                        lineHeight: const LineHeight(20/13)
                    ),
                    'a': Style(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                        textDecoration: TextDecoration.underline,
                        textDecorationColor: Theme.of(context).colorScheme.primary
                    ),
                  },
                ),
              ),
            )
          ],
        ),
        if(widget.errorText != null)VHVForm.instance.errorWidget(context, widget.errorText)
      ],
    );
  }
}
