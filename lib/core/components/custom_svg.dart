import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../utils/app_assets.dart';

class CustomSvg extends StatelessWidget {
  const CustomSvg({
    super.key,
    required this.width,
    required this.height,
    this.assetPath,
  });

  final double width;
  final double height;
  final String? assetPath;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      assetPath ?? AppSvg.let,
      width: width,
      height: height,
      fit: BoxFit.contain,
    );
  }
}
