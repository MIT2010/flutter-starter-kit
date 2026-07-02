import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:shared_assessment/shared_assessment.dart';

class MultipleChoiceAnswerWidget extends StatelessWidget {
  const MultipleChoiceAnswerWidget({
    super.key,
    required this.question,
    required this.answer,
    required this.onChanged,
  });

  final MultipleChoiceQuestion question;
  final MultipleChoiceAnswer? answer;
  final ValueChanged<List<String>> onChanged;

  @override
  Widget build(BuildContext context) {
    final selected = answer?.selectedOptionIds ?? const <String>[];

    return Column(
      children: question.options.map((option) {
        final isChecked = selected.contains(option.id);
        return CheckboxListTile(
          title: AppText.bodyMd(option.text),
          value: isChecked,
          onChanged: (checked) {
            final updated = [...selected];
            if (checked == true) {
              updated.add(option.id);
            } else {
              updated.remove(option.id);
            }
            onChanged(updated);
          },
        );
      }).toList(),
    );
  }
}
