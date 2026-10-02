import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

abstract class AppImages {
  static const String group = 'assets/image/Group.png';
  static const String flag = 'assets/image/flag.png';
  static const String password = 'assets/image/Password .png';
  static const String unlock = 'assets/image/Unlock .png';
  static const String home = 'assets/image/OBJECTS.svg';
}

abstract class AppSvg {
  static const String let = 'assets/image/OBJECTS.svg';
  static const String lock = 'assets/image/Lock - Iconly Pro.svg';
  static const String password = 'assets/image/Lock - Iconly Pro.svg';
  static const String unlock = 'assets/image/Unlock .svg';
  static const String profile = 'assets/image/Profile.svg';

  static Widget asset({
    required double width,
    required double height,
    String? path,
    BoxFit fit = BoxFit.contain,
  }) {
    return SvgPicture.asset(
      path ?? let,
      width: width,
      height: height,
      fit: fit,
    );
  }
}
