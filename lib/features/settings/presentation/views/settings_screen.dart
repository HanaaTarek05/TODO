import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/helper/app_localizations.dart';
import '../../../../core/helper/language_notifier.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_padding.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: languageNotifier,
      builder: (context, locale, _) {
        final currentLang = locale.languageCode;
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: AppColors.black,
                size: 20.r,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              AppLocalizations.tr(context, 'settings'),
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
          ),
          body: Padding(
            padding: AppPaddings.defaultPadding,
            child: Column(
              children: [
                SizedBox(height: 24.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.tr(context, 'language'),
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w400,
                        color: AppColors.black,
                      ),
                    ),
                    _LanguageToggleWidget(
                      currentLang: currentLang,
                      onLangChanged: (lang) {
                        languageNotifier.changeLanguage(lang);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LanguageToggleWidget extends StatelessWidget {
  const _LanguageToggleWidget({
    required this.currentLang,
    required this.onLangChanged,
  });

  final String currentLang;
  final ValueChanged<String> onLangChanged;

  @override
  Widget build(BuildContext context) {
    final isEn = currentLang == 'en';
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(8.r),
      ),
      padding: EdgeInsets.all(3.r),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildOption(
            title: 'AR',
            isSelected: !isEn,
            onTap: () => onLangChanged('ar'),
          ),
          SizedBox(width: 2.w),
          _buildOption(
            title: 'EN',
            isSelected: isEn,
            onTap: () => onLangChanged('en'),
          ),
        ],
      ),
    );
  }

  Widget _buildOption({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : AppColors.black,
          ),
        ),
      ),
    );
  }
}
