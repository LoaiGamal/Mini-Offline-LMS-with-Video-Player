import 'package:flutter/material.dart';
import 'package:thaheen_task/core/components/app_card.dart';
import 'package:thaheen_task/core/components/skeleton_box.dart';
import 'package:thaheen_task/core/constants/app_strings.dart';

class CoursesSkeleton extends StatelessWidget {
  const CoursesSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: AppStrings.loading,
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: <Widget>[
          const SkeletonBox(height: 140, radius: 20),
          const SizedBox(height: 22),
          for (int index = 0; index < 2; index++) ...<Widget>[
            const AppCard(
              child: Row(
                children: <Widget>[
                  SkeletonBox(width: 96, height: 96, radius: 12),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        FractionallySizedBox(widthFactor: 0.7, child: SkeletonBox(height: 14, radius: 7)),
                        SizedBox(height: 10),
                        FractionallySizedBox(widthFactor: 0.45, child: SkeletonBox(height: 12, radius: 6)),
                        SizedBox(height: 14),
                        SkeletonBox(height: 6, radius: 3),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}
