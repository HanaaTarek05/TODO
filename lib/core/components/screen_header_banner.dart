import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../utils/app_assets.dart';

class ScreenHeaderBanner extends StatelessWidget {
  const ScreenHeaderBanner({
    super.key,
    this.height,
    this.child,
    this.borderRadius,
  });

  final double? height;
  final Widget? child;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? 20.r;
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(radius),
            bottomRight: Radius.circular(radius),
          ),
          child: Image.asset(
            AppImages.flag,
            width: double.infinity,
            height: height ?? 293.h,
            fit: BoxFit.cover,
          ),
        ),
        ?child,
      ],
    );
  }
}
