import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

enum ButtonType { primary, secondary, outlined, text, gradient }
enum ButtonSize { small, medium, large }

class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final ButtonSize size;
  final Widget? icon;
  final bool isLoading;
  final bool isFullWidth;
  final EdgeInsetsGeometry? padding;
  final List<Color>? gradientColors;
  final bool showShadow;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.primary,
    this.size = ButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.padding,
    this.gradientColors,
    this.showShadow = false,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  EdgeInsetsGeometry _getPadding() {
    return switch (widget.size) {
      ButtonSize.small => EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      ButtonSize.medium => EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
      ButtonSize.large => EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
    };
  }

  double _getHeight() {
    return switch (widget.size) {
      ButtonSize.small => 36.h,
      ButtonSize.medium => 48.h,
      ButtonSize.large => 56.h,
    };
  }

  double _getFontSize() {
    return switch (widget.size) {
      ButtonSize.small => 14.sp,
      ButtonSize.medium => 16.sp,
      ButtonSize.large => 18.sp,
    };
  }

  @override
  Widget build(BuildContext context) {
    Widget buttonChild = widget.isLoading
        ? SizedBox(
            width: _getFontSize(),
            height: _getFontSize(),
            child: CircularProgressIndicator(
              strokeWidth: 2.0,
              color: widget.type == ButtonType.outlined || widget.type == ButtonType.text
                  ? AppColors.primary
                  : Colors.white,
            ),
          )
        : widget.icon != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  widget.icon!,
                  const SizedBox(width: 8),
                  Text(
                    widget.text,
                    style: GoogleFonts.poppins(
                      fontSize: _getFontSize(),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              )
            : Text(
                widget.text,
                style: GoogleFonts.poppins(
                  fontSize: _getFontSize(),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              );

    Widget button = switch (widget.type) {
      ButtonType.primary => _buildPrimaryButton(buttonChild),
      ButtonType.secondary => _buildSecondaryButton(buttonChild),
      ButtonType.outlined => _buildOutlinedButton(buttonChild),
      ButtonType.text => _buildTextButton(buttonChild),
      ButtonType.gradient => _buildGradientButton(buttonChild),
    };

    button = AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        child: child,
      ),
      child: button,
    );

    if (widget.isFullWidth) {
      button = SizedBox(
        width: double.infinity,
        child: button,
      );
    }

    if (widget.padding != null) {
      button = Padding(
        padding: widget.padding!,
        child: button,
      );
    }

    return GestureDetector(
      onTapDown: (_) => _animationController.forward(),
      onTapUp: (_) => _animationController.reverse(),
      onTapCancel: () => _animationController.reverse(),
      child: button,
    );
  }

  Widget _buildPrimaryButton(Widget child) {
    return Container(
      height: _getHeight(),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: widget.showShadow
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  offset: Offset(0, 4.h),
                  blurRadius: 12.r,
                  spreadRadius: 0,
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.isLoading ? null : widget.onPressed,
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            padding: _getPadding(),
            child: Center(child: child),
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton(Widget child) {
    return Container(
      height: _getHeight(),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: widget.showShadow
            ? [
                BoxShadow(
                  color: AppColors.secondary.withOpacity(0.3),
                  offset: const Offset(0, 4),
                  blurRadius: 12,
                  spreadRadius: 0,
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.isLoading ? null : widget.onPressed,
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            padding: _getPadding(),
            child: Center(child: child),
          ),
        ),
      ),
    );
  }

  Widget _buildOutlinedButton(Widget child) {
    return Container(
      height: _getHeight(),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border,
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.isLoading ? null : widget.onPressed,
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            padding: _getPadding(),
            child: Center(
              child: DefaultTextStyle(
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: _getFontSize(),
                  fontWeight: FontWeight.w600,
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextButton(Widget child) {
    return Container(
      height: _getHeight(),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.isLoading ? null : widget.onPressed,
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            padding: _getPadding(),
            child: Center(
              child: DefaultTextStyle(
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: _getFontSize(),
                  fontWeight: FontWeight.w600,
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGradientButton(Widget child) {
    final colors = widget.gradientColors ?? AppColors.primaryGradient;
    return Container(
      height: _getHeight(),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: widget.showShadow
            ? [
                BoxShadow(
                  color: colors.first.withOpacity(0.3),
                  offset: const Offset(0, 4),
                  blurRadius: 12,
                  spreadRadius: 0,
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.isLoading ? null : widget.onPressed,
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            padding: _getPadding(),
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}

class ModernIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color? color;
  final Color? backgroundColor;
  final double? iconSize;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final bool showShadow;

  const ModernIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.color,
    this.backgroundColor,
    this.iconSize,
    this.borderRadius,
    this.padding,
    this.showShadow = false,
  });

  @override
  State<ModernIconButton> createState() => _ModernIconButtonState();
}

class _ModernIconButtonState extends State<ModernIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = widget.borderRadius ?? 12.0;
    final iconSize = widget.iconSize ?? 24.0;
    final padding = widget.padding ?? const EdgeInsets.all(12);

    Widget button = Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: widget.showShadow
            ? [
                BoxShadow(
                  color: AppColors.shadow,
                  offset: const Offset(0, 2),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onPressed,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Container(
            padding: padding,
            child: Icon(
              widget.icon,
              color: widget.color ?? Theme.of(context).iconTheme.color,
              size: iconSize,
            ),
          ),
        ),
      ),
    );

    button = AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        child: child,
      ),
      child: button,
    );

    button = GestureDetector(
      onTapDown: (_) => _animationController.forward(),
      onTapUp: (_) => _animationController.reverse(),
      onTapCancel: () => _animationController.reverse(),
      child: button,
    );

    if (widget.tooltip != null) {
      button = Tooltip(
        message: widget.tooltip!,
        child: button,
      );
    }

    return button;
  }
}