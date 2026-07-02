import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:shared_assessment/shared_assessment.dart';

class MatrixAnswerWidget extends StatelessWidget {
  const MatrixAnswerWidget({
    super.key,
    required this.question,
    required this.answer,
    required this.onChanged,
  });

  final MatrixQuestion question;
  final MatrixAnswer? answer;
  final ValueChanged<Map<String, String>> onChanged;

  @override
  Widget build(BuildContext context) {
    final selections = answer?.selections ?? const <String, String>{};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: question.rows.map((row) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText.bodyMd(row.label),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.sm,
                children: row.options.map((option) {
                  final isSelected = selections[row.id] == option.id;
                  return ChoiceChip(
                    label: Text(option.text),
                    selected: isSelected,
                    onSelected: (_) {
                      onChanged({...selections, row.id: option.id});
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
