import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/components/custom_text_field.dart';
import '../../../../core/components/user_header_widget.dart';
import '../../../../core/helper/app_localizations.dart';
import '../../../../core/network/api_helper.dart';
import '../../../../core/network/cache_helper.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_padding.dart';
import '../../../auth/data/repo/auth_repo.dart';
import '../../../auth/presentation/views/login_screen.dart';
import '../../../settings/presentation/views/settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthRepo _authRepo = AuthRepo();
  String _username = CacheHelper.getString(key: 'username') ?? '';
  String? _imageUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    if (_username.isEmpty) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final response = await _authRepo.getUserData();
      if (!mounted) return;
      if (response.data != null && response.data is Map<String, dynamic>) {
        final userData = response.data as Map<String, dynamic>;
        final name = userData['username'] ?? userData['name'] ?? '';
        setState(() {
          if (name.toString().isNotEmpty) {
            _username = name.toString();
            CacheHelper.saveData(key: 'username', value: name.toString());
          }
          _imageUrl = userData['image'] ?? userData['avatar'];
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ApiHelper().handleException(e))),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _showUpdateProfileDialog() async {
    final usernameController = TextEditingController(text: _username);

    await showDialog(
      context: context,
      builder: (context) {
        bool isSubmitting = false;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
              title: Text(AppLocalizations.tr(context, 'profile')),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextField(
                    controller: usernameController,
                    hint: AppLocalizations.tr(context, 'username'),
                    prefixIconPath: AppSvg.profile,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppLocalizations.tr(context, 'cancel')),
                ),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          final messenger = ScaffoldMessenger.of(context);
                          final dialogNav = Navigator.of(context);
                          final newUsername = usernameController.text.trim();
                          if (newUsername.isEmpty) return;

                          setDialogState(() {
                            isSubmitting = true;
                          });

                          try {
                            await _authRepo.updateProfile(
                              username: newUsername,
                            );
                            await CacheHelper.saveData(
                              key: 'username',
                              value: newUsername,
                            );
                            dialogNav.pop();
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('Profile updated successfully!'),
                              ),
                            );
                            _fetchUserData();
                          } catch (e) {
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(ApiHelper().handleException(e)),
                              ),
                            );
                          } finally {
                            setDialogState(() {
                              isSubmitting = false;
                            });
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  child: isSubmitting
                      ? SizedBox(
                          width: 20.w,
                          height: 20.h,
                          child: const CircularProgressIndicator(
                            color: AppColors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          AppLocalizations.tr(context, 'save'),
                          style: const TextStyle(color: AppColors.white),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showChangePasswordDialog() async {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        bool isSubmitting = false;
        bool isOldPasswordSecure = true;
        bool isNewPasswordSecure = true;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
              title: Text(AppLocalizations.tr(context, 'changePassword')),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextField(
                    controller: oldPasswordController,
                    hint: AppLocalizations.tr(context, 'currentPassword'),
                    prefixIconPath: AppSvg.lock,
                    obscureText: isOldPasswordSecure,
                    suffixIconPath: isOldPasswordSecure ? AppSvg.lock : AppSvg.unlock,
                    onSuffixPressed: () {
                      setDialogState(() {
                        isOldPasswordSecure = !isOldPasswordSecure;
                      });
                    },
                  ),
                  SizedBox(height: 12.h),
                  CustomTextField(
                    controller: newPasswordController,
                    hint: AppLocalizations.tr(context, 'newPassword'),
                    prefixIconPath: AppSvg.lock,
                    obscureText: isNewPasswordSecure,
                    suffixIconPath: isNewPasswordSecure ? AppSvg.lock : AppSvg.unlock,
                    onSuffixPressed: () {
                      setDialogState(() {
                        isNewPasswordSecure = !isNewPasswordSecure;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppLocalizations.tr(context, 'cancel')),
                ),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          final messenger = ScaffoldMessenger.of(context);
                          final dialogNav = Navigator.of(context);
                          final oldPass = oldPasswordController.text.trim();
                          final newPass = newPasswordController.text.trim();

                          if (oldPass.isEmpty || newPass.isEmpty) {
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('Please enter both passwords'),
                              ),
                            );
                            return;
                          }

                          setDialogState(() {
                            isSubmitting = true;
                          });

                          try {
                            await _authRepo.changePassword(
                              currentPassword: oldPass,
                              newPassword: newPass,
                            );
                            dialogNav.pop();
                            messenger.showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Password changed successfully!'),
                              ),
                            );
                          } catch (e) {
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(ApiHelper().handleException(e)),
                              ),
                            );
                          } finally {
                            setDialogState(() {
                              isSubmitting = false;
                            });
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  child: isSubmitting
                      ? SizedBox(
                          width: 20.w,
                          height: 20.h,
                          child: const CircularProgressIndicator(
                            color: AppColors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          AppLocalizations.tr(context, 'update'),
                          style: const TextStyle(color: AppColors.white),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showAccountOptions() async {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20.r),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.orange),
                  title: Text(AppLocalizations.tr(context, 'logout')),
                  onTap: () async {
                    final navigator = Navigator.of(context);
                    navigator.pop();
                    await ApiHelper().clearSession();
                    if (!mounted) return;
                    navigator.pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: AppColors.red),
                  title: Text(AppLocalizations.tr(context, 'deleteAccount')),
                  onTap: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    final navigator = Navigator.of(context);
                    navigator.pop();

                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (dialogCtx) => AlertDialog(
                        title: Text(AppLocalizations.tr(context, 'deleteAccount')),
                        content: Text(AppLocalizations.tr(context, 'deleteAccountConfirm')),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(dialogCtx, false),
                            child: Text(AppLocalizations.tr(context, 'cancel')),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(dialogCtx, true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.red,
                            ),
                            child: Text(
                              AppLocalizations.tr(context, 'delete'),
                              style: const TextStyle(color: AppColors.white),
                            ),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      try {
                        await _authRepo.deleteUser();
                        await ApiHelper().clearSession();
                        navigator.pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                          (route) => false,
                        );
                      } catch (e) {
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(ApiHelper().handleException(e)),
                          ),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: AppPaddings.defaultPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UserHeaderWidget(
                username: _username,
                imageUrl: _imageUrl,
                isLoading: _isLoading,
              ),
              SizedBox(height: 32.h),
              _buildMenuItemCard(
                iconPath: AppSvg.profile,
                title: AppLocalizations.tr(context, 'profile'),
                onTap: _showUpdateProfileDialog,
              ),
              SizedBox(height: 16.h),
              _buildMenuItemCard(
                iconPath: AppSvg.lock,
                title: AppLocalizations.tr(context, 'changePassword'),
                onTap: _showChangePasswordDialog,
              ),
              SizedBox(height: 16.h),
              _buildMenuItemCard(
                iconData: Icons.settings_outlined,
                title: AppLocalizations.tr(context, 'settings'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SettingsScreen(),
                    ),
                  );
                },
              ),
              SizedBox(height: 16.h),
              _buildMenuItemCard(
                iconData: Icons.logout,
                title: AppLocalizations.tr(context, 'logout'),
                onTap: _showAccountOptions,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItemCard({
    String? iconPath,
    IconData? iconData,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
            child: Row(
              children: [
                if (iconPath != null)
                  SvgPicture.asset(
                    iconPath,
                    width: 22.w,
                    height: 22.h,
                    colorFilter: const ColorFilter.mode(
                      Colors.black87,
                      BlendMode.srcIn,
                    ),
                  )
                else if (iconData != null)
                  Icon(
                    iconData,
                    size: 22.r,
                    color: Colors.black87,
                  ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16.r,
                  color: AppColors.grey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
