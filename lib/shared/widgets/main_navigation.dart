import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';

class MainNavigation extends StatelessWidget {
  final Widget child;
  final String currentPath;

  const MainNavigation({
    super.key,
    required this.child,
    required this.currentPath,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    final currentIndex = _getCurrentIndex();
    
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            offset: Offset(0, -2.h),
            blurRadius: 8.r,
            spreadRadius: 0,
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context: context,
                icon: Icons.dashboard_outlined,
                activeIcon: Icons.dashboard,
                label: 'Dashboard',
                index: 0,
                currentIndex: currentIndex,
                onTap: () => context.go('/dashboard'),
              ),
              _buildNavItem(
                context: context,
                icon: Icons.add_circle_outline,
                activeIcon: Icons.add_circle,
                label: 'Create',
                index: 1,
                currentIndex: currentIndex,
                onTap: () => context.go('/create-project'),
              ),
              _buildNavItem(
                context: context,
                icon: Icons.task_outlined,
                activeIcon: Icons.task,
                label: 'Tasks',
                index: 2,
                currentIndex: currentIndex,
                onTap: () => context.go('/tasks'),
              ),
              _buildNavItem(
                context: context,
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                label: 'Profile',
                index: 3,
                currentIndex: currentIndex,
                onTap: () => context.go('/profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
    required int currentIndex,
    required VoidCallback onTap,
  }) {
    final isActive = index == currentIndex;
    final color = isActive ? AppColors.primary : AppColors.textSecondary;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 4.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    isActive ? activeIcon : icon,
                    key: ValueKey(isActive),
                    color: color,
                    size: 20.sp,
                  ),
                ),
                SizedBox(height: 2.h),
                Flexible(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: color,
                      fontSize: 10.sp,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  int _getCurrentIndex() {
    if (currentPath.startsWith('/dashboard')) return 0;
    if (currentPath.startsWith('/create-project')) return 1;
    if (currentPath.startsWith('/tasks')) return 2;
    if (currentPath.startsWith('/profile') || currentPath.startsWith('/settings')) return 3;
    return 0; // Default to dashboard
  }
}

// Extension to check if a route should show bottom navigation
extension RouteExtension on String {
  bool get shouldShowBottomNav {
    final hiddenRoutes = [
      '/', // splash screen
      '/login',
      '/register',
      '/project-context',
    ];
    
    return !hiddenRoutes.contains(this) && 
           !startsWith('/project-context/');
  }
}