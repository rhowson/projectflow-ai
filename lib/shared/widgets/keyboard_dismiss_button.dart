import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/custom_neumorphic_theme.dart';
import 'keyboard_dismissible_wrapper.dart';

/// A floating button that allows users to manually dismiss the keyboard
class KeyboardDismissButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool showOnlyWhenKeyboardVisible;

  const KeyboardDismissButton({
    super.key,
    this.onPressed,
    this.showOnlyWhenKeyboardVisible = true,
  });

  @override
  Widget build(BuildContext context) {
    // Only show when keyboard is visible if specified
    if (showOnlyWhenKeyboardVisible && !context.isKeyboardVisible) {
      return const SizedBox.shrink();
    }

    return AnimatedSlide(
      duration: const Duration(milliseconds: 300),
      offset: context.isKeyboardVisible ? Offset.zero : const Offset(0, 2),
      child: FloatingActionButton.small(
        onPressed: () {
          context.dismissKeyboard();
          onPressed?.call();
        },
        backgroundColor: CustomNeumorphicTheme.primaryPurple,
        foregroundColor: Colors.white,
        tooltip: 'Hide Keyboard',
        child: Icon(
          Icons.keyboard_hide,
          size: 18.sp,
        ),
      ),
    );
  }
}

/// A smaller inline button for dismissing keyboard
class InlineKeyboardDismissButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String? tooltip;

  const InlineKeyboardDismissButton({
    super.key,
    this.onPressed,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? 'Hide Keyboard',
      child: NeumorphicButton(
        onPressed: () {
          context.dismissKeyboard();
          onPressed?.call();
        },
        borderRadius: BorderRadius.circular(20.r),
        padding: EdgeInsets.all(8.w),
        child: Icon(
          Icons.keyboard_hide,
          size: 16.sp,
          color: CustomNeumorphicTheme.primaryPurple,
        ),
      ),
    );
  }
}