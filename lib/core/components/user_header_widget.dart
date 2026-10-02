import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../utils/app_assets.dart';
import '../utils/app_colors.dart';

class UserHeaderWidget extends StatelessWidget {
  const UserHeaderWidget({
    super.key,
    required this.username,
    this.greeting = 'Hello!',
    this.imageUrl,
    this.onTap,
    this.isLoading = false,
  });

  final String username;
  final String greeting;
  final String? imageUrl;
  final VoidCallback? onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          CircleAvatar(
            radius: 28.r,
            backgroundImage: imageUrl != null && imageUrl!.isNotEmpty
                ? NetworkImage(imageUrl!) as ImageProvider
                : const AssetImage(AppImages.flag),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.grey,
                  ),
                ),
                SizedBox(height: 2.h),
                isLoading
                    ? SizedBox(
                        width: 16.w,
                        height: 16.h,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        username.isNotEmpty ? username : 'User',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
