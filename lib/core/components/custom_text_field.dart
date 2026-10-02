import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../utils/app_colors.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.hint,
    this.prefixIconPath,
    required this.controller,
    this.onSuffixPressed,
    this.suffixIconPath,
    this.obscureText = false,
    this.hasError = false,
    this.errorText,
    this.onChanged,
  });

  final String hint;
  final String? prefixIconPath;
  final TextEditingController controller;
  final void Function()? onSuffixPressed;
  final String? suffixIconPath;
  final bool obscureText;
  final bool hasError;
  final String? errorText;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final borderColor = hasError ? AppColors.red : AppColors.lightGrey;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          onChanged: onChanged,
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.black,
            fontWeight: FontWeight.w500,
          ),
          obscureText: obscureText,
          obscuringCharacter: '*',
          decoration: InputDecoration(
            prefixIcon: prefixIconPath != null
                ? Padding(
                    padding: REdgeInsets.all(16.0),
                    child: SvgPicture.asset(prefixIconPath!),
                  )
                : null,
            suffixIcon: suffixIconPath != null
                ? IconButton(
                    onPressed: onSuffixPressed,
                    icon: SvgPicture.asset(suffixIconPath!),
                  )
                : null,
            hintText: hint,
            hintStyle: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 14.sp,
              color: const Color(0xff8E8E93),
            ),
            fillColor: Colors.white,
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.r),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.r),
              borderSide: BorderSide(
                color: borderColor,
                width: hasError ? 1.5 : 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.r),
              borderSide: BorderSide(
                color: hasError ? AppColors.red : AppColors.primary,
                width: 1.5,
              ),
            ),
          ),
        ),
        if (errorText != null && errorText!.isNotEmpty) ...[
          SizedBox(height: 4.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Text(
              errorText!,
              style: TextStyle(
                color: AppColors.red,
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
