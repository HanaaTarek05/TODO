import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/components/custom_btn.dart';
import '../../../../core/components/custom_text_field.dart';
import '../../../../core/components/user_header_widget.dart';
import '../../../../core/helper/app_localizations.dart';
import '../../../../core/network/api_helper.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_padding.dart';
import '../../data/models/task_model.dart';
import '../../data/repo/task_repo.dart';
import 'widgets/task_date_picker.dart';
import 'widgets/task_group_selector.dart';

class EditTaskScreen extends StatefulWidget {
  final TaskModel task;

  const EditTaskScreen({super.key, required this.task});

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  final TaskRepo _taskRepo = TaskRepo();

  late String _selectedGroup;
  String? _selectedEndTime;
  late bool _isDone;
  bool _isLoading = false;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.task.title);
    descriptionController = TextEditingController(text: widget.task.description);
    _selectedGroup = widget.task.group ?? 'Home';
    _selectedEndTime = widget.task.endTime ?? '30 June, 2022 10:00 pm';
    _isDone = widget.task.isDone;
  }

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

  Future<void> _handleUpdateTask() async {
    final title = titleController.text.trim();
    final description = descriptionController.text.trim();

    if (title.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill title and description')),
      );
      return;
    }

    if (widget.task.id == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _taskRepo.updateTask(
        taskId: widget.task.id!,
        title: title,
        description: description,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.tr(context, 'taskUpdatedSuccess'))),
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

  Future<void> _handleDeleteTask() async {
    if (widget.task.id == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.tr(context, 'delete')),
        content: Text(AppLocalizations.tr(context, 'deleteTaskConfirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.tr(context, 'cancel')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.red),
            child: Text(
              AppLocalizations.tr(context, 'delete'),
              style: const TextStyle(color: AppColors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _isDeleting = true;
      });

      try {
        await _taskRepo.deleteTask(taskId: widget.task.id!);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.tr(context, 'taskDeletedSuccess'))),
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
            _isDeleting = false;
          });
        }
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
          AppLocalizations.tr(context, 'editTask'),
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
            child: TextButton.icon(
              onPressed: _isDeleting ? null : _handleDeleteTask,
              style: TextButton.styleFrom(
                backgroundColor: AppColors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 10.w),
              ),
              icon: Icon(
                Icons.delete_outline,
                color: AppColors.white,
                size: 18.r,
              ),
              label: Text(
                AppLocalizations.tr(context, 'delete'),
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppPaddings.defaultPadding,
        child: Column(
          children: [
            SizedBox(height: 12.h),
            UserHeaderWidget(
              greeting: _isDone
                  ? AppLocalizations.tr(context, 'done')
                  : AppLocalizations.tr(context, 'inProgress'),
              username: _isDone
                  ? AppLocalizations.tr(context, 'congrats')
                  : AppLocalizations.tr(context, 'quoteInProgress'),
            ),
            SizedBox(height: 24.h),
            TaskGroupSelector(
              selectedGroup: _selectedGroup,
              onGroupSelected: (group) {
                setState(() {
                  _selectedGroup = group;
                });
              },
            ),
            SizedBox(height: 16.h),
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
            TaskDatePicker(
              selectedEndTime: _selectedEndTime,
              onTap: _pickEndTime,
            ),
            SizedBox(height: 32.h),
            CustomBtn(
              text: _isDone
                  ? AppLocalizations.tr(context, 'markAsInProgress')
                  : AppLocalizations.tr(context, 'markAsDone'),
              onPressed: () {
                setState(() {
                  _isDone = !_isDone;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      _isDone
                          ? AppLocalizations.tr(context, 'done')
                          : AppLocalizations.tr(context, 'inProgress'),
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 16.h),
            _isLoading
                ? const CircularProgressIndicator()
                : CustomBtn(
                    text: AppLocalizations.tr(context, 'update'),
                    backgroundColor: Colors.transparent,
                    textColor: AppColors.primary,
                    onPressed: _handleUpdateTask,
                  ),
          ],
        ),
      ),
    );
  }
}
