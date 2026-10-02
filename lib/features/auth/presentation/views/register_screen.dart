import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/components/auth_error_banner.dart';
import '../../../../core/components/auth_option_row.dart';
import '../../../../core/components/custom_btn.dart';
import '../../../../core/components/custom_text_field.dart';
import '../../../../core/components/screen_header_banner.dart';
import '../../../../core/helper/app_localizations.dart';
import '../../../../core/helper/my_navigator.dart';
import '../../../../core/network/api_helper.dart';
import '../../../../core/network/cache_helper.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_padding.dart';
import '../../../home/presentation/views/home_screen.dart';
import '../../data/repo/auth_repo.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final AuthRepo _authRepo = AuthRepo();

  bool isPasswordSecure = true;
  bool isConfirmPasswordSecure = true;
  bool isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _clearError() {
    if (_errorMessage != null) {
      setState(() {
        _errorMessage = null;
      });
    }
  }

  Future<void> _handleRegister() async {
    FocusScope.of(context).unfocus();
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (username.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      setState(() {
        _errorMessage = 'Please fill in all required fields.';
      });
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        _errorMessage = 'Passwords do not match. Please try again.';
      });
      return;
    }

    setState(() {
      isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authRepo.register(
        username: username,
        password: password,
      );
      await CacheHelper.saveData(key: 'username', value: username);

      if (ApiHelper().accessToken == null || ApiHelper().accessToken!.isEmpty) {
        await _authRepo.login(username: username, password: password);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account registered successfully! Welcome.')),
      );
      MyNavigator.goTo(
        context,
        toPage: const HomeScreen(),
        type: NavigatorType.pushAndRemoveUntil,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = ApiHelper().handleException(e);
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            ScreenHeaderBanner(
              borderRadius: 24.r,
              child: Positioned(
                bottom: 20.h,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    'Pick Image',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: AppPaddings.defaultPadding,
              child: Column(
                children: [
                  SizedBox(height: 16.h),
                  if (_errorMessage != null) ...[
                    AuthErrorBanner(message: _errorMessage!),
                    SizedBox(height: 16.h),
                  ],
                  CustomTextField(
                    controller: usernameController,
                    hint: AppLocalizations.tr(context, 'username'),
                    prefixIconPath: AppSvg.profile,
                    hasError: _errorMessage != null,
                    onChanged: (_) => _clearError(),
                  ),
                  SizedBox(height: 16.h),
                  CustomTextField(
                    controller: passwordController,
                    hint: AppLocalizations.tr(context, 'password'),
                    prefixIconPath: AppSvg.lock,
                    suffixIconPath: isPasswordSecure ? AppSvg.lock : AppSvg.unlock,
                    obscureText: isPasswordSecure,
                    hasError: _errorMessage != null,
                    onChanged: (_) => _clearError(),
                    onSuffixPressed: () {
                      setState(() {
                        isPasswordSecure = !isPasswordSecure;
                      });
                    },
                  ),
                  SizedBox(height: 16.h),
                  CustomTextField(
                    controller: confirmPasswordController,
                    hint: AppLocalizations.tr(context, 'confirmPassword'),
                    prefixIconPath: AppSvg.lock,
                    suffixIconPath: isConfirmPasswordSecure ? AppSvg.lock : AppSvg.unlock,
                    obscureText: isConfirmPasswordSecure,
                    hasError: _errorMessage != null,
                    onChanged: (_) => _clearError(),
                    onSuffixPressed: () {
                      setState(() {
                        isConfirmPasswordSecure = !isConfirmPasswordSecure;
                      });
                    },
                  ),
                  SizedBox(height: 32.h),
                  isLoading
                      ? const CircularProgressIndicator()
                      : CustomBtn(
                          text: AppLocalizations.tr(context, 'register'),
                          onPressed: _handleRegister,
                        ),
                  SizedBox(height: 24.h),
                  AuthOptionRow(
                    promptText: AppLocalizations.tr(context, 'alreadyHaveAccount'),
                    actionText: AppLocalizations.tr(context, 'login'),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
