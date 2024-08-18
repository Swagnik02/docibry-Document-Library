import 'package:flutter/material.dart';

Widget buildTextField({
  required TextEditingController controller,
  required String labelText,
  required bool isAdd,
  required bool isEditMode,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
      ),
      readOnly: !isAdd && !isEditMode,
    ),
  );
}

Padding docNameTextField({
  required TextEditingController controller,
  required String hintText,
  required bool isAdd,
  required bool isEditMode,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 16),
    child: TextField(
      controller: controller,
      textCapitalization: TextCapitalization.words,
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        hintText: hintText,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
      readOnly: !isAdd && !isEditMode,
    ),
  );
}
