import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../theme/custom_neumorphic_theme.dart';

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
      backgroundColor: CustomNeumorphicTheme.baseColor,
      body: child,
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    final currentIndex = _getCurrentIndex(currentPath);
    
    return Container(
      padding: EdgeInsets.only(
        left: 16.w, 
        right: 16.w, 
        bottom: MediaQuery.of(context).padding.bottom + 8.h,
        top: 8.h,
      ),
      child: NeumorphicContainer(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        color: CustomNeumorphicTheme.cardColor,
        borderRadius: BorderRadius.circular(25.r),
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
                icon: Icons.group_outlined,
                activeIcon: Icons.group,
                label: 'Team',
                index: 3,
                currentIndex: currentIndex,
                onTap: () => context.go('/team'),
              ),
            ],
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

    return Expanded(
      child: _InteractiveNavItem(
        icon: icon,
        activeIcon: activeIcon,
        label: label,
        isActive: isActive,
        onTap: onTap,
      ),
    );
  }

  int _getCurrentIndex(String currentPath) {
    if (currentPath.startsWith('/dashboard')) return 0;
    if (currentPath.startsWith('/create-project')) return 1;
    if (currentPath.startsWith('/tasks')) return 2;
    if (currentPath.startsWith('/team')) return 3;
    return 0; // Default to dashboard
  }
}

class _InteractiveNavItem extends StatefulWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _InteractiveNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_InteractiveNavItem> createState() => _InteractiveNavItemState();
}

class _InteractiveNavItemState extends State<_InteractiveNavItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _iconBounceAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.85,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _iconBounceAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    HapticFeedback.lightImpact();
    setState(() => _isPressed = true);
    _animationController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _animationController.reverse().then((_) {
      // Add a small bounce effect when released
      _animationController.forward().then((_) {
        _animationController.reverse();
      });
    });
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  void _handleTap() {
    HapticFeedback.selectionClick();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _handleTap,
              onTapDown: _handleTapDown,
              onTapUp: _handleTapUp,
              onTapCancel: _handleTapCancel,
              borderRadius: BorderRadius.circular(12.r),
              splashColor: CustomNeumorphicTheme.primaryPurple.withOpacity(0.2),
              highlightColor: CustomNeumorphicTheme.primaryPurple.withOpacity(0.1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  color: widget.isActive 
                      ? CustomNeumorphicTheme.primaryPurple.withOpacity(0.1)
                      : Colors.transparent,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Transform.scale(
                      scale: widget.isActive ? _iconBounceAnimation.value : 1.0,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          widget.isActive ? widget.activeIcon : widget.icon,
                          key: ValueKey(widget.isActive),
                          color: widget.isActive 
                              ? CustomNeumorphicTheme.primaryPurple 
                              : CustomNeumorphicTheme.lightText,
                          size: 20.sp,
                        ),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: TextStyle(
                        color: widget.isActive 
                            ? CustomNeumorphicTheme.primaryPurple 
                            : CustomNeumorphicTheme.lightText,
                        fontSize: 10.sp,
                        fontWeight: widget.isActive ? FontWeight.w600 : FontWeight.w500,
                      ),
                      child: Text(
                        widget.label,
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
      },
    );
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