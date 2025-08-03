import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../shared/theme/custom_neumorphic_theme.dart';

class SimpleProfileScreen extends ConsumerWidget {
  const SimpleProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: CustomNeumorphicTheme.baseColor,
      appBar: NeumorphicAppBar(
        title: Text(
          'Profile',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: CustomNeumorphicTheme.darkText,
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(32.w),
          child: NeumorphicCard(
            padding: EdgeInsets.all(32.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                NeumorphicContainer(
                  padding: EdgeInsets.all(20.w),
                  borderRadius: BorderRadius.circular(35),
                  color: CustomNeumorphicTheme.primaryPurple,
                  child: Icon(
                    Icons.person_outline,
                    size: 48.sp,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 32.h),
                Text(
                  'Profile Management',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: CustomNeumorphicTheme.darkText,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h),
                Text(
                  'Comprehensive profile features coming soon',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: CustomNeumorphicTheme.lightText,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32.h),
                NeumorphicButton(
                  onPressed: () {
                    // Navigate to settings or edit profile
                  },
                  isSelected: true,
                  selectedColor: CustomNeumorphicTheme.primaryPurple,
                  borderRadius: BorderRadius.circular(12),
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.settings, size: 18.sp, color: Colors.white),
                      SizedBox(width: 8.w),
                      Text(
                        'Settings',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}