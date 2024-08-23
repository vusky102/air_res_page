import 'package:flutter/material.dart';

const themeColor =  Color.fromARGB(255, 255, 197, 7);

TextStyle style(BuildContext context) {
  final theme = Theme.of(context);
  return theme.textTheme.displaySmall!.copyWith(
    color: theme.colorScheme.onPrimary,
    fontStyle: FontStyle.normal,
  );
}

TextStyle style1(BuildContext context) {
  final theme = Theme.of(context);
  return theme.textTheme.displaySmall!.copyWith(
    color: theme.colorScheme.onSecondary,
    fontStyle: FontStyle.italic,
  );
}

TextStyle style2(BuildContext context) {
  final theme = Theme.of(context);
  return theme.textTheme.bodyMedium!.copyWith(
    color: theme.colorScheme.onSecondary,
    fontStyle: FontStyle.normal,
  );
}