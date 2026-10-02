import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/helper/my_navigator.dart';
import '../../../../core/network/api_helper.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../home/presentation/views/home_screen.dart';
import 'let_start_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3)).then((v) {
      if (!mounted) return;
      final token = ApiHelper().accessToken;
      if (token != null && token.isNotEmpty) {
        MyNavigator.goTo(
          context,
          toPage: const HomeScreen(),
          type: NavigatorType.pushReplacement,
        );
      } else {
        MyNavigator.goTo(
          context,
          toPage: const LetStartScreen(),
          type: NavigatorType.pushReplacement,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: REdgeInsets.symmetric(horizontal: 20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                AppImages.group,
                width: double.infinity,
                height: 344.h,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
