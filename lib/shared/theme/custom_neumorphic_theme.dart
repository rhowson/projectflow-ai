import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomNeumorphicTheme {
  // Colors based on the skudesign.png - updated for whiter appearance
  static const Color baseColor = Color(0xFFF2F3F8);  // Much whiter base
  static const Color cardColor = Color(0xFFFAFAFC);   // Very white for cards
  static const Color primaryPurple = Color(0xFF7B68EE);
  static const Color secondaryPurple = Color(0xFF9B7EF7);
  static const Color successGreen = Color(0xFF4ECDC4);
  static const Color errorRed = Color(0xFFFF6B6B);
  static const Color darkText = Color(0xFF2C3E50);
  static const Color lightText = Color(0xFF7F8C8D);
  static const Color subtleText = Color(0xFFBDC3C7);

  // Shadow colors for sharper neumorphic effect with defined bottom edges
  static const Color lightShadow = Colors.white;
  static const Color darkShadow = Color(0xFFBCC8D6);  // Darker shadow for sharper relief
  static const Color bottomEdgeShadow = Color(0xFFA8B5C8);  // Sharper bottom edge shadow

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryPurple,
        brightness: Brightness.light,
        background: baseColor,
        surface: baseColor,
      ),
      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        // Display styles - For major headers/titles
        displayLarge: GoogleFonts.poppins(
          fontSize: 32,
          color: darkText,
          fontWeight: FontWeight.w800,
          height: 1.2,
        ),
        displayMedium: GoogleFonts.poppins(
          fontSize: 28,
          color: darkText,
          fontWeight: FontWeight.w700,
          height: 1.2,
        ),
        displaySmall: GoogleFonts.poppins(
          fontSize: 24,
          color: darkText,
          fontWeight: FontWeight.w700,
          height: 1.3,
        ),
        // Headline styles - For section headers
        headlineLarge: GoogleFonts.poppins(
          fontSize: 22,
          color: darkText,
          fontWeight: FontWeight.w600,
          height: 1.3,
        ),
        headlineMedium: GoogleFonts.poppins(
          fontSize: 20,
          color: darkText,
          fontWeight: FontWeight.w600,
          height: 1.3,
        ),
        headlineSmall: GoogleFonts.poppins(
          fontSize: 18,
          color: darkText,
          fontWeight: FontWeight.w600,
          height: 1.3,
        ),
        // Title styles - For card headers and subsections
        titleLarge: GoogleFonts.poppins(
          fontSize: 16,
          color: darkText,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
        titleMedium: GoogleFonts.poppins(
          fontSize: 14,
          color: darkText,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
        titleSmall: GoogleFonts.poppins(
          fontSize: 12,
          color: darkText,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
        // Body styles - For content text
        bodyLarge: GoogleFonts.poppins(
          fontSize: 14,
          color: darkText,
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.poppins(
          fontSize: 12,
          color: lightText,
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
        bodySmall: GoogleFonts.poppins(
          fontSize: 11,
          color: subtleText,
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
        // Label styles - For buttons and small labels
        labelLarge: GoogleFonts.poppins(
          fontSize: 13,
          color: darkText,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
        labelMedium: GoogleFonts.poppins(
          fontSize: 11,
          color: lightText,
          fontWeight: FontWeight.w500,
          height: 1.4,
        ),
        labelSmall: GoogleFonts.poppins(
          fontSize: 10,
          color: subtleText,
          fontWeight: FontWeight.w500,
          height: 1.4,
        ),
      ),
      scaffoldBackgroundColor: baseColor,
      appBarTheme: AppBarTheme(
        backgroundColor: baseColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          color: darkText,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: darkText),
      ),
    );
  }
}

class NeumorphicContainer extends StatelessWidget {
  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final bool isPressed;
  final bool isElevated;
  final Color? color;
  final VoidCallback? onTap;

  const NeumorphicContainer({
    super.key,
    this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.borderRadius,
    this.isPressed = false,
    this.isElevated = true,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = this.borderRadius ?? BorderRadius.circular(20);
    final backgroundColor = color ?? CustomNeumorphicTheme.cardColor;

    return Container(
      width: width,
      height: height,
      margin: margin,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: borderRadius,
              boxShadow: isPressed
                  ? [
                      // Pressed state with sharp inset shadows
                      BoxShadow(
                        color: CustomNeumorphicTheme.bottomEdgeShadow.withValues(alpha: 0.5),
                        offset: const Offset(2, 2),
                        blurRadius: 3,
                        spreadRadius: 0,
                      ),
                    ]
                  : isElevated
                      ? [
                          // Sharp bottom-right shadow for defined edge
                          BoxShadow(
                            color: CustomNeumorphicTheme.bottomEdgeShadow.withValues(alpha: 0.6),
                            offset: const Offset(4, 5),
                            blurRadius: 8,
                            spreadRadius: 0,
                          ),
                          // Secondary softer shadow for depth
                          BoxShadow(
                            color: CustomNeumorphicTheme.darkShadow.withValues(alpha: 0.3),
                            offset: const Offset(6, 7),
                            blurRadius: 12,
                            spreadRadius: 0,
                          ),
                          // Subtle top-left highlight
                          BoxShadow(
                            color: CustomNeumorphicTheme.lightShadow.withValues(alpha: 0.8),
                            offset: const Offset(-1, -1),
                            blurRadius: 4,
                            spreadRadius: 0,
                          ),
                        ]
                      : [],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class NeumorphicEmbossedContainer extends StatelessWidget {
  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Color? color;
  final VoidCallback? onTap;

  const NeumorphicEmbossedContainer({
    super.key,
    this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.borderRadius,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = this.borderRadius ?? BorderRadius.circular(20);
    final backgroundColor = color ?? CustomNeumorphicTheme.cardColor;

    return Container(
      width: width,
      height: height,
      margin: margin,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: borderRadius,
              boxShadow: [
                // Embossed effect - inset shadows (dark on top-left, light on bottom-right)
                BoxShadow(
                  color: CustomNeumorphicTheme.darkShadow.withValues(alpha: 0.6),
                  offset: const Offset(-2, -2),
                  blurRadius: 4,
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: CustomNeumorphicTheme.bottomEdgeShadow.withValues(alpha: 0.8),
                  offset: const Offset(-4, -4),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
                // Light shadow on bottom-right for embossed effect
                BoxShadow(
                  color: CustomNeumorphicTheme.lightShadow.withValues(alpha: 0.9),
                  offset: const Offset(2, 2),
                  blurRadius: 4,
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: CustomNeumorphicTheme.lightShadow.withValues(alpha: 0.7),
                  offset: const Offset(4, 4),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class NeumorphicEmbossedCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;

  const NeumorphicEmbossedCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.onTap,
  });

  @override
  State<NeumorphicEmbossedCard> createState() => _NeumorphicEmbossedCardState();
}

class _NeumorphicEmbossedCardState extends State<NeumorphicEmbossedCard>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
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

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap != null) {
      HapticFeedback.lightImpact();
      setState(() => _isPressed = true);
      _animationController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  void _handleTap() {
    if (widget.onTap != null) {
      HapticFeedback.selectionClick();
      widget.onTap!();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.onTap == null) {
      // If no onTap, return static embossed card
      return NeumorphicEmbossedContainer(
        padding: widget.padding ?? const EdgeInsets.all(20),
        margin: widget.margin,
        borderRadius: widget.borderRadius ?? BorderRadius.circular(20),
        color: CustomNeumorphicTheme.cardColor,
        child: widget.child,
      );
    }

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            onTap: _handleTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: NeumorphicEmbossedContainer(
                padding: widget.padding ?? const EdgeInsets.all(20),
                margin: widget.margin,
                borderRadius: widget.borderRadius ?? BorderRadius.circular(20),
                color: CustomNeumorphicTheme.cardColor,
                child: widget.child,
              ),
            ),
          ),
        );
      },
    );
  }
}

class NeumorphicSharpEmbossedContainer extends StatelessWidget {
  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Color? color;
  final VoidCallback? onTap;

  const NeumorphicSharpEmbossedContainer({
    super.key,
    this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.borderRadius,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = this.borderRadius ?? BorderRadius.circular(16);
    final backgroundColor = color ?? CustomNeumorphicTheme.cardColor;

    return Container(
      width: width,
      height: height,
      margin: margin,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap != null ? () {
            HapticFeedback.selectionClick();
            onTap!();
          } : null,
          borderRadius: borderRadius,
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: borderRadius,
              boxShadow: [
                // Ultra-sharp embossed effect - maximum definition inset shadows
                BoxShadow(
                  color: CustomNeumorphicTheme.darkShadow.withValues(alpha: 1.0),
                  offset: const Offset(-4, -4),
                  blurRadius: 4,
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: CustomNeumorphicTheme.bottomEdgeShadow.withValues(alpha: 1.0),
                  offset: const Offset(-8, -8),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
                // Ultra-sharp light shadows for crisp definition
                BoxShadow(
                  color: CustomNeumorphicTheme.lightShadow.withValues(alpha: 1.0),
                  offset: const Offset(4, 4),
                  blurRadius: 4,
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: CustomNeumorphicTheme.lightShadow.withValues(alpha: 0.9),
                  offset: const Offset(8, 8),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
                // Razor-sharp edge definition shadows
                BoxShadow(
                  color: CustomNeumorphicTheme.bottomEdgeShadow.withValues(alpha: 0.8),
                  offset: const Offset(-2, -2),
                  blurRadius: 0,
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: CustomNeumorphicTheme.lightShadow.withValues(alpha: 1.0),
                  offset: const Offset(2, 2),
                  blurRadius: 0,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class NeumorphicFlatContainer extends StatelessWidget {
  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Color? color;
  final VoidCallback? onTap;

  const NeumorphicFlatContainer({
    super.key,
    this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.borderRadius,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = this.borderRadius ?? BorderRadius.circular(16);
    final backgroundColor = color ?? CustomNeumorphicTheme.baseColor;

    return Container(
      width: width,
      height: height,
      margin: margin,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap != null ? () {
            HapticFeedback.selectionClick();
            onTap!();
          } : null,
          borderRadius: borderRadius,
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: borderRadius,
              // No shadows - completely flat at background level
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class NeumorphicButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final Color? color;
  final Color? selectedColor;
  final bool isSelected;
  final bool isLoading;

  const NeumorphicButton({
    super.key,
    required this.child,
    this.onPressed,
    this.padding,
    this.borderRadius,
    this.color,
    this.selectedColor,
    this.isSelected = false,
    this.isLoading = false,
  });

  @override
  State<NeumorphicButton> createState() => _NeumorphicButtonState();
}

class _NeumorphicButtonState extends State<NeumorphicButton> 
    with TickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    if (widget.isLoading) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(NeumorphicButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading != oldWidget.isLoading) {
      if (widget.isLoading) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
        _pulseController.reset();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null) {
      HapticFeedback.lightImpact();
      setState(() => _isPressed = true);
      _animationController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  void _handleTap() {
    if (widget.onPressed != null) {
      HapticFeedback.selectionClick();
      widget.onPressed!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isSelected 
        ? (widget.selectedColor ?? CustomNeumorphicTheme.primaryPurple)
        : (widget.color ?? CustomNeumorphicTheme.baseColor);

    return AnimatedBuilder(
      animation: widget.isLoading ? _pulseAnimation : _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.isLoading ? _pulseAnimation.value : _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            onTap: _handleTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: NeumorphicContainer(
                padding: widget.padding ?? const EdgeInsets.all(16),
                borderRadius: widget.borderRadius ?? BorderRadius.circular(15),
                isPressed: _isPressed,
                isElevated: !_isPressed,
                color: color,
                child: widget.child,
              ),
            ),
          ),
        );
      },
    );
  }
}

class NeumorphicCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;

  const NeumorphicCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.onTap,
  });

  @override
  State<NeumorphicCard> createState() => _NeumorphicCardState();
}

class _NeumorphicCardState extends State<NeumorphicCard>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _elevationAnimation = Tween<double>(
      begin: 1.0,
      end: 0.7,
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

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap != null) {
      HapticFeedback.lightImpact();
      setState(() => _isPressed = true);
      _animationController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  void _handleTap() {
    if (widget.onTap != null) {
      HapticFeedback.selectionClick();
      widget.onTap!();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.onTap == null) {
      // If no onTap, return static card
      return NeumorphicContainer(
        padding: widget.padding ?? const EdgeInsets.all(20),
        margin: widget.margin,
        borderRadius: widget.borderRadius ?? BorderRadius.circular(20),
        color: CustomNeumorphicTheme.cardColor,
        child: widget.child,
      );
    }

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            onTap: _handleTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: NeumorphicContainer(
                padding: widget.padding ?? const EdgeInsets.all(20),
                margin: widget.margin,
                borderRadius: widget.borderRadius ?? BorderRadius.circular(20),
                color: CustomNeumorphicTheme.cardColor,
                isPressed: _isPressed,
                isElevated: !_isPressed,
                child: widget.child,
              ),
            ),
          ),
        );
      },
    );
  }
}

class NeumorphicProgressBar extends StatelessWidget {
  final double progress;
  final double height;
  final Color? backgroundColor;
  final Color? progressColor;
  final BorderRadius? borderRadius;

  const NeumorphicProgressBar({
    super.key,
    required this.progress,
    this.height = 6,
    this.backgroundColor,
    this.progressColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(height / 2),
        color: backgroundColor ?? CustomNeumorphicTheme.baseColor.withValues(alpha: 0.5),
        boxShadow: [
          // Sharp bottom shadow for progress bar container
          BoxShadow(
            color: CustomNeumorphicTheme.bottomEdgeShadow.withValues(alpha: 0.4),
            offset: const Offset(2, 3),
            blurRadius: 4,
            spreadRadius: 0,
          ),
        ],
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: borderRadius ?? BorderRadius.circular(height / 2),
            color: progressColor ?? CustomNeumorphicTheme.primaryPurple,
          ),
        ),
      ),
    );
  }
}

class NeumorphicAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final List<Widget>? actions;
  final bool automaticallyImplyLeading;

  const NeumorphicAppBar({
    super.key,
    this.title,
    this.actions,
    this.automaticallyImplyLeading = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CustomNeumorphicTheme.cardColor,
        boxShadow: [
          // Sharp bottom shadow for app bar
          BoxShadow(
            color: CustomNeumorphicTheme.bottomEdgeShadow.withValues(alpha: 0.3),
            offset: const Offset(0, 3),
            blurRadius: 6,
            spreadRadius: 0,
          ),
        ],
      ),
      child: AppBar(
        title: title,
        actions: actions,
        automaticallyImplyLeading: automaticallyImplyLeading,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}