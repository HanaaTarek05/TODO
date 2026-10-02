import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/components/custom_btn.dart';
import '../../../../core/components/custom_text_field.dart';
import '../../../../core/components/screen_header_banner.dart';
import '../../../../core/helper/app_localizations.dart';
import '../../../../core/network/api_helper.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_padding.dart';
import '../../data/repo/task_repo.dart';
import 'widgets/task_date_picker.dart';
import 'widgets/task_group_selector.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final TaskRepo _taskRepo = TaskRepo();

  String _selectedGroup = 'Home';
  String? _selectedEndTime;
  bool _isLoading = false;

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickEndTime() async {
    final result = await TaskDatePicker.showTaskDateTimePicker(context);
    if (result != null && mounted) {
      setState(() {
        _selectedEndTime = result;
      });
    }
  }

  Future<void> _handleAddTask() async {
    final title = titleController.text.trim();
    final description = descriptionController.text.trim();

    if (title.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill title and description')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _taskRepo.createNewTask(
        title: title,
        description: description,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.tr(context, 'taskAddedSuccess'))),
      );
      Navigator.pop(context, true);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppLocalizations.tr(context, 'addTask'),
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: AppPaddings.defaultPadding,
        child: Column(
          children: [
            SizedBox(height: 12.h),
            ScreenHeaderBanner(
              height: 180.h,
            ),
            SizedBox(height: 24.h),
            CustomTextField(
              controller: titleController,
              hint: AppLocalizations.tr(context, 'title'),
            ),
            SizedBox(height: 16.h),
            CustomTextField(
              controller: descriptionController,
              hint: AppLocalizations.tr(context, 'description'),
            ),
            SizedBox(height: 16.h),
            TaskGroupSelector(
              selectedGroup: _selectedGroup,
              onGroupSelected: (group) {
                setState(() {
                  _selectedGroup = group;
                });
              },
            ),
            SizedBox(height: 16.h),
            TaskDatePicker(
              selectedEndTime: _selectedEndTime,
              onTap: _pickEndTime,
            ),
            SizedBox(height: 32.h),
            _isLoading
                ? const CircularProgressIndicator()
                : CustomBtn(
                    text: AppLocalizations.tr(context, 'addTask'),
                    onPressed: _handleAddTask,
                  ),
          ],
        ),
      ),
    );
  }
}
