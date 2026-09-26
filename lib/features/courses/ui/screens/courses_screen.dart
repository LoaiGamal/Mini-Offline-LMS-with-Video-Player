import 'package:flutter/material.dart';
import 'package:thaheen_task/core/constants/app_strings.dart';

class CoursesScreen extends StatelessWidget {
  const CoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text(AppStrings.coursesTitle)));
  }
}
