import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/helper/app_localizations.dart';
import '../../../../../core/utils/app_colors.dart';

class TaskDatePicker extends StatelessWidget {
  const TaskDatePicker({
    super.key,
    required this.selectedEndTime,
    required this.onTap,
  });

  final String? selectedEndTime;
  final VoidCallback onTap;

  static Future<String?> showTaskDateTimePicker(BuildContext context) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year + 5),
    );

    if (date != null && context.mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(now),
      );

      if (time != null) {
        final months = [
          'January',
          'February',
          'March',
          'April',
          'May',
          'June',
          'July',
          'August',
          'September',
          'October',
          'November',
          'December'
        ];
        final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
        final minute = time.minute.toString().padLeft(2, '0');
        final period = time.period == DayPeriod.am ? 'am' : 'pm';

        return '${date.day} ${months[date.month - 1]}, ${date.year} $hour:$minute $period';
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15.r),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 16.h,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(15.r),
          border: Border.all(color: AppColors.lightGrey),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_month_outlined,
              color: AppColors.primary,
              size: 20.r,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                selectedEndTime ?? AppLocalizations.tr(context, 'endTime'),
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: selectedEndTime == null
                      ? AppColors.hintGrey
                      : AppColors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
