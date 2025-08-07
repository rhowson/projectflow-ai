import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../animations/micro_interactions.dart';

class ModernAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final bool centerTitle;
  final Widget? subtitle;
  final List<Color>? gradientColors;
  final bool showBorder;
  final VoidCallback? onTitleTap;

  const ModernAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.centerTitle = true,
    this.subtitle,
    this.gradientColors,
    this.showBorder = false,
    this.onTitleTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasGradient = gradientColors != null;
    final effectiveBackgroundColor = backgroundColor ?? AppColors.surface;
    final effectiveForegroundColor = foregroundColor ?? AppColors.textPrimary;

    Widget appBar = AppBar(
      title: GestureDetector(
        onTap: onTitleTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(
                color: hasGradient ? Colors.white : effectiveForegroundColor,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.01,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              DefaultTextStyle(
                style: TextStyle(
                  color: hasGradient 
                      ? Colors.white.withValues(alpha: 0.8)
                      : AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                child: subtitle!,
              ),
            ],
          ],
        ),
      ),
      actions: actions?.map((action) {
        return Padding(
          padding: const EdgeInsets.only(right: 4),
          child: BouncyButton(
            child: action,
          ),
        );
      }).toList(),
      leading: leading != null
          ? BouncyButton(child: leading!)
          : automaticallyImplyLeading
              ? BouncyButton(
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios_rounded,
                      color: hasGradient ? Colors.white : effectiveForegroundColor,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                )
              : null,
      automaticallyImplyLeading: false,
      backgroundColor: hasGradient ? Colors.transparent : effectiveBackgroundColor,
      foregroundColor: hasGradient ? Colors.white : effectiveForegroundColor,
      elevation: elevation ?? 0,
      centerTitle: centerTitle,
      scrolledUnderElevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: hasGradient ? Brightness.light : Brightness.dark,
        statusBarBrightness: hasGradient ? Brightness.dark : Brightness.light,
      ),
      flexibleSpace: hasGradient
          ? Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradientColors!,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            )
          : null,
    );

    if (showBorder && !hasGradient) {
      appBar = Container(
        decoration: BoxDecoration(
          color: effectiveBackgroundColor,
          border: Border(
            bottom: BorderSide(
              color: AppColors.border,
              width: 1,
            ),
          ),
        ),
        child: appBar,
      );
    }

    return appBar;
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// Legacy CustomAppBar for backward compatibility
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final bool centerTitle;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.centerTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    return ModernAppBar(
      title: title,
      actions: actions,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: elevation,
      centerTitle: centerTitle,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// Animated search app bar
class SearchAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final String searchHint;
  final Function(String) onSearchChanged;
  final VoidCallback? onSearchClear;
  final List<Widget>? actions;

  const SearchAppBar({
    super.key,
    required this.title,
    required this.searchHint,
    required this.onSearchChanged,
    this.onSearchClear,
    this.actions,
  });

  @override
  State<SearchAppBar> createState() => _SearchAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _SearchAppBarState extends State<SearchAppBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _startSearch() {
    setState(() {
      _isSearching = true;
    });
    _animationController.forward();
  }

  void _stopSearch() {
    setState(() {
      _isSearching = false;
    });
    _animationController.reverse();
    _searchController.clear();
    widget.onSearchClear?.call();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      title: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Stack(
            children: [
              // Title
              Opacity(
                opacity: 1 - _animation.value,
                child: Text(
                  widget.title,
                  style: Theme.of(context).appBarTheme.titleTextStyle,
                ),
              ),
              // Search field
              Opacity(
                opacity: _animation.value,
                child: TextField(
                  controller: _searchController,
                  onChanged: widget.onSearchChanged,
                  onTapOutside: (event) {
                    // Hide keyboard when tapping outside
                    FocusScope.of(context).unfocus();
                  },
                  decoration: InputDecoration(
                    hintText: widget.searchHint,
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      color: AppColors.textTertiary,
                    ),
                  ),
                  style: Theme.of(context).appBarTheme.titleTextStyle,
                ),
              ),
            ],
          );
        },
      ),
      actions: [
        if (!_isSearching) ...[
          BouncyButton(
            onTap: _startSearch,
            child: Icon(Icons.search_rounded),
          ),
          if (widget.actions != null) ...widget.actions!,
        ] else ...[
          BouncyButton(
            onTap: _stopSearch,
            child: Icon(Icons.close_rounded),
          ),
        ],
        const SizedBox(width: 8),
      ],
    );
  }
}