import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thaheen_task/core/constants/app_strings.dart';
import 'package:thaheen_task/core/router/app_router.dart';
import 'package:thaheen_task/core/theme/app_theme.dart';
import 'package:thaheen_task/core/theme/theme_cubit.dart';
import 'package:thaheen_task/features/courses/data/local/courses_local_source.dart';
import 'package:thaheen_task/features/courses/data/repo/courses_repo.dart';
import 'package:thaheen_task/features/courses/logic/courses_cubit.dart';
import 'package:thaheen_task/features/progress/data/local/progress_local_source.dart';
import 'package:thaheen_task/features/progress/data/repo/progress_repo.dart';
import 'package:thaheen_task/features/progress/logic/progress_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
  ]);
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  runApp(ThaheenApp(prefs: prefs));
}

class ThaheenApp extends StatelessWidget {
  const ThaheenApp({super.key, required this.prefs});

  final SharedPreferences prefs;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: <BlocProvider<dynamic>>[
        BlocProvider<CoursesCubit>(
          create: (BuildContext context) =>
              CoursesCubit(const CoursesRepo(CoursesLocalSource()))
                ..loadCourses(),
        ),
        BlocProvider<ProgressCubit>(
          create: (BuildContext context) =>
              ProgressCubit(ProgressRepo(ProgressLocalSource(prefs))),
        ),
        BlocProvider<ThemeCubit>(
          create: (BuildContext context) => ThemeCubit(prefs),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (BuildContext context, ThemeMode themeMode) {
          return MaterialApp.router(
            title: AppStrings.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeMode,
            routerConfig: appRouter,
            locale: const Locale('ar'),
            supportedLocales: const <Locale>[Locale('ar')],
            localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
          );
        },
      ),
    );
  }
}
