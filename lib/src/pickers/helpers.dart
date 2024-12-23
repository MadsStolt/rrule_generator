import 'package:flutter/material.dart';

Widget buildDropdown({required Widget child, required BuildContext context}) {
  // return Container(
  //   decoration: BoxDecoration(
  //     border: Border.all(color: Theme.of(context).colorScheme.onSurface),
  //     borderRadius: BorderRadius.circular(8),
  //   ),
  //   width: double.maxFinite,
  //   padding: const EdgeInsets.all(8),
  //   child: DropdownButtonHideUnderline(
  //     child: child,
  //   ),
  // );
  return child;
}

Column buildElement({
  String? title,
  required Widget child,
  required TextStyle style,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (title != null)
        Text(
          title,
          style: style,
        )
      else
        Container(),
      child,
    ],
  );
}

Padding buildContainer({required Widget child}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: child,
  );
}

Widget buildToggleItem({
  required Widget child,
  required void Function(bool) onChanged,
  required String title,
  required bool value,
  required TextStyle style,
}) {
  if (!value) {
    return buildContainer(
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: style.copyWith(fontSize: 16),
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
  return buildContainer(
    child: Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: style.copyWith(fontSize: 16),
              ),
            ),
            Switch(value: value, onChanged: onChanged),
          ],
        ),
        child,
      ],
    ),
  );
}
