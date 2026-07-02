import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:shared_assessment/shared_assessment.dart';

class SingleChoiceAnswerWidget extends StatelessWidget {
  const SingleChoiceAnswerWidget({
    super.key,
    required this.question,
    required this.answer,
    required this.onChanged,
  });

  final SingleChoiceQuestion question;
  final SingleChoiceAnswer? answer;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return RadioGroup<String>(
      groupValue: answer?.selectedOptionId,
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
      child: Column(
        children: question.options.map((option) {
          return RadioListTile<String>(
            title: AppText.bodyMd(option.text),
            value: option.id,
          );
        }).toList(),
      ),
    );
  }
}
