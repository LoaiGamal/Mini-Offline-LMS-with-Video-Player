import 'package:flutter/material.dart';

void showAppSnackBar(BuildContext context, {required String message, IconData? icon}) {
  final ColorScheme colors = Theme.of(context).colorScheme;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Row(
          children: <Widget>[
            if (icon != null) ...<Widget>[
              Icon(icon, size: 20, color: colors.secondary),
              const SizedBox(width: 12),
            ],
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
}
