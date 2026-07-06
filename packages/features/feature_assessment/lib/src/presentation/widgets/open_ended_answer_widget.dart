import 'package:core_l10n/core_l10n.dart';
import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:shared_assessment/shared_assessment.dart';

class OpenEndedAnswerWidget extends StatefulWidget {
  const OpenEndedAnswerWidget({
    super.key,
    required this.question,
    required this.answer,
    required this.onChanged,
  });

  final OpenEndedQuestion question;
  final OpenEndedAnswer? answer;
  final ValueChanged<String> onChanged;

  @override
  State<OpenEndedAnswerWidget> createState() => _OpenEndedAnswerWidgetState();
}

class _OpenEndedAnswerWidgetState extends State<OpenEndedAnswerWidget> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.answer?.text,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: context.t.assessment.openEndedAnswerLabel,
      controller: _controller,
      maxLines: 6,
      minLines: 3,
      onChanged: widget.onChanged,
    );
  }
}
