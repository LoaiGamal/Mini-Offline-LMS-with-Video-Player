import 'package:flutter/material.dart';
import 'package:thaheen_task/core/constants/app_strings.dart';

class CourseSearchField extends StatefulWidget {
  const CourseSearchField({
    super.key,
    required this.initialQuery,
    required this.onChanged,
  });

  final String initialQuery;
  final ValueChanged<String> onChanged;

  @override
  State<CourseSearchField> createState() => _CourseSearchFieldState();
}

class _CourseSearchFieldState extends State<CourseSearchField> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialQuery,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    widget.onChanged('');
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final OutlineInputBorder border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: colors.outlineVariant),
    );

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _controller,
      builder: (BuildContext context, TextEditingValue value, Widget? child) {
        return TextField(
          controller: _controller,
          onChanged: widget.onChanged,
          textInputAction: TextInputAction.search,
          style: theme.textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: AppStrings.searchHint,
            hintStyle: theme.textTheme.bodyLarge?.copyWith(
              color: colors.onSurfaceVariant,
            ),
            filled: true,
            fillColor: colors.surfaceContainerLowest,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: colors.onSurfaceVariant,
            ),
            suffixIcon: value.text.isEmpty
                ? null
                : IconButton(
                    onPressed: _clear,
                    tooltip: AppStrings.clearSearch,
                    icon: const Icon(Icons.close_rounded),
                  ),
            border: border,
            enabledBorder: border,
            focusedBorder: border.copyWith(
              borderSide: BorderSide(color: colors.primary, width: 1.5),
            ),
          ),
        );
      },
    );
  }
}
