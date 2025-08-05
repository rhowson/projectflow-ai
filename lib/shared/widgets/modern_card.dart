import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum CardType { elevated, outlined, filled }

class ModernCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final CardType type;
  final bool showShadow;
  final List<Color>? gradientColors;
  final double? borderRadius;
  final Color? backgroundColor;
  final Border? border;

  const ModernCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.type = CardType.elevated,
    this.showShadow = true,
    this.gradientColors,
    this.borderRadius,
    this.backgroundColor,
    this.border,
  });

  @override
  State<ModernCard> createState() => _ModernCardState();
}

class _ModernCardState extends State<ModernCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _elevationAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _elevationAnimation = Tween<double>(
      begin: 0,
      end: 8,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = widget.borderRadius ?? 16.0;
    final padding = widget.padding ?? const EdgeInsets.all(16);
    final margin = widget.margin ?? const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 8,
    );

    Widget card = AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            decoration: _buildDecoration(borderRadius),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: BorderRadius.circular(borderRadius),
                onHover: (isHovering) {
                  if (isHovering) {
                    _animationController.forward();
                  } else {
                    _animationController.reverse();
                  }
                },
                child: Container(
                  padding: padding,
                  child: widget.child,
                ),
              ),
            ),
          ),
        );
      },
    );

    return Container(
      margin: margin,
      child: card,
    );
  }

  BoxDecoration _buildDecoration(double borderRadius) {
    switch (widget.type) {
      case CardType.elevated:
        return BoxDecoration(
          color: widget.backgroundColor ?? AppColors.cardBackground,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: widget.showShadow
              ? [
                  BoxShadow(
                    color: AppColors.shadow,
                    offset: const Offset(0, 2),
                    blurRadius: 8 + _elevationAnimation.value,
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: AppColors.shadow,
                    offset: const Offset(0, 1),
                    blurRadius: 2,
                    spreadRadius: 0,
                  ),
                ]
              : null,
          border: widget.border,
        );

      case CardType.outlined:
        return BoxDecoration(
          color: widget.backgroundColor ?? Colors.transparent,
          borderRadius: BorderRadius.circular(borderRadius),
          border: widget.border ?? Border.all(
            color: AppColors.border,
            width: 1,
          ),
        );

      case CardType.filled:
        if (widget.gradientColors != null) {
          return BoxDecoration(
            gradient: LinearGradient(
              colors: widget.gradientColors!,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: widget.showShadow
                ? [
                    BoxShadow(
                      color: widget.gradientColors!.first.withOpacity(0.3),
                      offset: const Offset(0, 4),
                      blurRadius: 12 + _elevationAnimation.value,
                      spreadRadius: 0,
                    ),
                  ]
                : null,
          );
        } else {
          return BoxDecoration(
            color: widget.backgroundColor ?? AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: widget.showShadow
                ? [
                    BoxShadow(
                      color: AppColors.shadow,
                      offset: const Offset(0, 2),
                      blurRadius: 8 + _elevationAnimation.value,
                      spreadRadius: 0,
                    ),
                  ]
                : null,
          );
        }
    }
  }
}

// Project card widget with modern design
class ProjectCard extends StatelessWidget {
  final String title;
  final String description;
  final String status;
  final Color statusColor;
  final int taskCount;
  final int completedTasks;
  final List<String> teamMembers;
  final VoidCallback? onTap;

  const ProjectCard({
    super.key,
    required this.title,
    required this.description,
    required this.status,
    required this.statusColor,
    required this.taskCount,
    required this.completedTasks,
    required this.teamMembers,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final progress = taskCount > 0 ? completedTasks / taskCount : 0.0;

    return ModernCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title and status
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Description
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          
          const SizedBox(height: 16),
          
          // Progress bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progress',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  Text(
                    '$completedTasks/$taskCount tasks',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: AppColors.border,
                  valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                  minHeight: 6,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Team members
          Row(
            children: [
              // Avatar stack
              SizedBox(
                height: 32,
                child: Stack(
                  children: teamMembers.take(3).toList().asMap().entries.map((entry) {
                    final index = entry.key;
                    final member = entry.value;
                    return Positioned(
                      left: index * 20.0,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.surface,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            member.isNotEmpty ? member.substring(0, 1).toUpperCase() : '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              
              if (teamMembers.length > 3) ...[
                const SizedBox(width: 8),
                Text(
                  '+${teamMembers.length - 3}',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}