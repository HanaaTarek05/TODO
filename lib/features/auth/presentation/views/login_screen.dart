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
import 'register_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LoginScreenBody();
  }
}

class LoginScreenBody extends StatefulWidget {
  const LoginScreenBody({super.key});

  @override
  State<LoginScreenBody> createState() => _LoginScreenBodyState();
}

class _LoginScreenBodyState extends State<LoginScreenBody> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final AuthRepo _authRepo = AuthRepo();

  bool isPasswordSecure = true;
  bool isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _clearError() {
    if (_errorMessage != null) {
      setState(() {
        _errorMessage = null;
      });
    }
  }

  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = AppLocalizations.tr(context, 'invalidCredentials');
      });
      return;
    }

    setState(() {
      isLoading = true;
      _errorMessage = null;
    });

    try {
      await ApiHelper().clearSession();
      await _authRepo.login(username: username, password: password);
      await CacheHelper.saveData(key: 'username', value: username);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logged in successfully!')),
      );
      MyNavigator.goTo(
        context,
        toPage: const HomeScreen(),
        type: NavigatorType.pushAndRemoveUntil,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = AppLocalizations.tr(context, 'invalidCredentials');
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
            const ScreenHeaderBanner(),
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
                  SizedBox(height: 12.h),
                  CustomTextField(
                    controller: passwordController,
                    hint: AppLocalizations.tr(context, 'password'),
                    prefixIconPath: AppSvg.lock,
                    suffixIconPath: isPasswordSecure ? AppSvg.lock : AppSvg.unlock,
                    hasError: _errorMessage != null,
                    onChanged: (_) => _clearError(),
                    onSuffixPressed: () {
                      setState(() {
                        isPasswordSecure = !isPasswordSecure;
                      });
                    },
                    obscureText: isPasswordSecure,
                  ),
                  SizedBox(height: 23.h),
                  isLoading
                      ? const CircularProgressIndicator()
                      : CustomBtn(
                          text: AppLocalizations.tr(context, 'login'),
                          onPressed: _handleLogin,
                        ),
                  SizedBox(height: 24.h),
                  AuthOptionRow(
                    promptText: AppLocalizations.tr(context, 'dontHaveAccount'),
                    actionText: AppLocalizations.tr(context, 'register'),
                    onTap: () {
                      MyNavigator.goTo(
                        context,
                        toPage: const RegisterScreen(),
                      );
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
