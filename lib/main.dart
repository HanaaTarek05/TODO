import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:todo_app/core/helper/language_notifier.dart';
import 'package:todo_app/core/network/cache_helper.dart';
import 'package:todo_app/core/utils/app_colors.dart';
import 'package:todo_app/features/auth/presentation/views/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CacheHelper.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: languageNotifier,
      builder: (context, currentLocale, _) {
        return ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (_, child) => MaterialApp(
            debugShowCheckedModeBanner: false,
            locale: currentLocale,
            supportedLocales: const [
              Locale('en'),
              Locale('ar'),
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: ThemeData(
              fontFamily: 'Lexend_Deca',
              scaffoldBackgroundColor: AppColors.background,
              colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
            ),
            home: const SplashScreen(),
          ),
        );
      },
    );
  }
}
