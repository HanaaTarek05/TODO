import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/components/custom_btn.dart';
import '../../../../core/helper/app_localizations.dart';
import '../../../../core/helper/my_navigator.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_padding.dart';
import 'login_screen.dart';

class LetStartScreen extends StatelessWidget {
  const LetStartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: AppPaddings.defaultPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Padding(
              padding: REdgeInsets.symmetric(horizontal: 12.0),
              child: AppSvg.asset(
                width: double.infinity,
                height: 342.h,
              ),
            ),
            Text(
              AppLocalizations.tr(context, 'welcome'),
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 24.sp,
                color: AppColors.black,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              AppLocalizations.tr(context, 'readyToConquer'),
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16.sp,
                color: AppColors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            CustomBtn(
              text: AppLocalizations.tr(context, 'letsStart'),
              onPressed: () {
                MyNavigator.goTo(context, toPage: const LoginScreen());
              },
            ),
          ],
        ),
      ),
    );
  }
}
