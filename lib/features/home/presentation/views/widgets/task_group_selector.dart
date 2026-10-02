import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/helper/app_localizations.dart';
import '../../../../../core/utils/app_colors.dart';

class TaskGroupModel {
  final String key;
  final String defaultTitle;
  final IconData icon;
  final Color color;

  const TaskGroupModel({
    required this.key,
    required this.defaultTitle,
    required this.icon,
    required this.color,
  });
}

class TaskGroupSelector extends StatefulWidget {
  const TaskGroupSelector({
    super.key,
    required this.selectedGroup,
    required this.onGroupSelected,
  });

  final String selectedGroup;
  final ValueChanged<String> onGroupSelected;

  static const List<TaskGroupModel> defaultGroups = [
    TaskGroupModel(
      key: 'homeGroup',
      defaultTitle: 'Home',
      icon: Icons.home,
      color: Color(0xffE91E63),
    ),
    TaskGroupModel(
      key: 'personalGroup',
      defaultTitle: 'Personal',
      icon: Icons.person,
      color: Color(0xff4CAF50),
    ),
    TaskGroupModel(
      key: 'workGroup',
      defaultTitle: 'Work',
      icon: Icons.work,
      color: Color(0xff212121),
    ),
  ];

  @override
  State<TaskGroupSelector> createState() => _TaskGroupSelectorState();
}

class _TaskGroupSelectorState extends State<TaskGroupSelector> {
  bool _isExpanded = false;

  TaskGroupModel _getGroupModel(String title) {
    return TaskGroupSelector.defaultGroups.firstWhere(
      (g) => g.defaultTitle.toLowerCase() == title.toLowerCase() || g.key == title,
      orElse: () => TaskGroupSelector.defaultGroups.first,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentGroup = widget.selectedGroup.isNotEmpty
        ? _getGroupModel(widget.selectedGroup)
        : null;

    final displayTitle = currentGroup != null
        ? AppLocalizations.tr(context, currentGroup.key)
        : AppLocalizations.tr(context, 'group');

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: AppColors.lightGrey),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(15.r),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 16.h,
              ),
              child: Row(
                children: [
                  if (currentGroup != null) ...[
                    Icon(
                      currentGroup.icon,
                      color: currentGroup.color,
                      size: 20.r,
                    ),
                    SizedBox(width: 12.w),
                  ],
                  Expanded(
                    child: Text(
                      displayTitle,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: widget.selectedGroup.isEmpty
                            ? AppColors.hintGrey
                            : AppColors.black,
                      ),
                    ),
                  ),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppColors.hintGrey,
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded)
            Column(
              children: TaskGroupSelector.defaultGroups.map((group) {
                final groupTitle = AppLocalizations.tr(context, group.key);
                return InkWell(
                  onTap: () {
                    widget.onGroupSelected(group.defaultTitle);
                    setState(() {
                      _isExpanded = false;
                    });
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(6.r),
                          decoration: BoxDecoration(
                            color: group.color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(
                            group.icon,
                            color: group.color,
                            size: 18.r,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          groupTitle,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}
