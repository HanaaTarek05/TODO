import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/components/user_header_widget.dart';
import '../../../../core/helper/app_localizations.dart';
import '../../../../core/helper/my_navigator.dart';
import '../../../../core/network/api_helper.dart';
import '../../../../core/network/cache_helper.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_padding.dart';
import '../../../auth/data/repo/auth_repo.dart';
import '../../../auth/presentation/views/login_screen.dart';
import '../../../profile/presentation/views/profile_screen.dart';
import '../../data/models/task_model.dart';
import '../../data/repo/task_repo.dart';
import 'add_task_screen.dart';
import 'edit_task_screen.dart';
import 'widgets/task_card_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TaskRepo _taskRepo = TaskRepo();
  final AuthRepo _authRepo = AuthRepo();

  List<TaskModel> _tasks = [];
  bool _isLoading = true;
  String _username = CacheHelper.getString(key: 'username') ?? '';

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchTasks();
  }

  Future<void> _fetchUserData() async {
    try {
      final response = await _authRepo.getUserData();
      if (!mounted) return;
      if (response.data != null && response.data is Map<String, dynamic>) {
        final userData = response.data as Map<String, dynamic>;
        final name = userData['username'] ?? userData['name'] ?? '';
        if (name.toString().isNotEmpty) {
          setState(() {
            _username = name.toString();
          });
          CacheHelper.saveData(key: 'username', value: name.toString());
        }
      }
    } catch (_) {}
  }

  Future<void> _fetchTasks() async {
    if (ApiHelper().accessToken == null || ApiHelper().accessToken!.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Token is missing. Please log in first.'),
        ),
      );
      MyNavigator.goTo(
        context,
        toPage: const LoginScreen(),
        type: NavigatorType.pushAndRemoveUntil,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final tasks = await _taskRepo.getMyTasks();
      if (!mounted) return;
      setState(() {
        _tasks = tasks;
      });
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

  Future<void> _navigateToAddTask() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddTaskScreen()),
    );
    if (result == true) {
      _fetchTasks();
    }
  }

  Future<void> _navigateToEditTask(TaskModel task) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditTaskScreen(task: task)),
    );
    if (result == true) {
      _fetchTasks();
    }
  }

  Future<void> _deleteTask(int taskId) async {
    try {
      await _taskRepo.deleteTask(taskId: taskId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.tr(context, 'taskDeletedSuccess'))),
      );
      _fetchTasks();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ApiHelper().handleException(e))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: AppPaddings.defaultPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 12.h),
              UserHeaderWidget(
                greeting: AppLocalizations.tr(context, 'hello'),
                username: _username,
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProfileScreen()),
                  );
                  _fetchUserData();
                },
              ),
              SizedBox(height: 24.h),
              if (_isLoading)
                const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_tasks.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppLocalizations.tr(context, 'noTasksYet'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: AppColors.black,
                            height: 1.5,
                          ),
                        ),
                        SizedBox(height: 40.h),
                        SvgPicture.asset(
                          AppImages.home,
                          width: 300.w,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            AppLocalizations.tr(context, 'tasks'),
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColors.black,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.cardBg,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              '${_tasks.length}',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: () async {
                            await _fetchUserData();
                            await _fetchTasks();
                          },
                          child: ListView.separated(
                            itemCount: _tasks.length,
                            separatorBuilder: (context, index) =>
                                SizedBox(height: 16.h),
                            itemBuilder: (context, index) {
                              final task = _tasks[index];
                              return TaskCardWidget(
                                task: task,
                                onTap: () => _navigateToEditTask(task),
                                onDelete: task.id != null
                                    ? () => _deleteTask(task.id!)
                                    : null,
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddTask,
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.r),
        ),
        child: const Icon(
          Icons.note_add_outlined,
          color: AppColors.white,
          size: 30,
        ),
      ),
    );
  }
}
