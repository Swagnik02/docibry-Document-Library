import 'package:flutter/material.dart';

class DocCategoryFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isDisabled;
  final ValueChanged<String> onSelected;

  const DocCategoryFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    this.isDisabled = false,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ChoiceChip(
        showCheckmark: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(35)),
        ),
        label: Text(
          label,
          style: TextStyle(
            color: isDisabled
                ? Colors.grey
                : (isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : Colors.black),
          ),
        ),
        selected: isSelected,
        backgroundColor: isDisabled ? Colors.grey.shade200 : Colors.transparent,
        selectedColor: Theme.of(context).colorScheme.primary,
        onSelected: isDisabled ? null : (_) => onSelected(label),
      ),
    );
  }
}
