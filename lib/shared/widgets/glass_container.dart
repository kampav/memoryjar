import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/color_schemes.dart';

/// A container with glassmorphism effect
class GlassContainer extends StatelessWidget {
  const GlassContainer({
    super.key,
    required this.child,
    this.blur = 12.0,
    this.opacity = 0.1,
    this.borderRadius = 24.0,
    this.border = true,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.color,
    this.gradient,
    this.onTap,
  });

  final Widget child;
  final double blur;
  final double opacity;
  final double borderRadius;
  final bool border;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final Color? color;
  final Gradient? gradient;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = color ?? Colors.white;
    final borderColor = isDark
        ? Colors.white.withOpacity(0.15)
        : Colors.white.withOpacity(0.5);
    final shadowColor = isDark
        ? Colors.black.withOpacity(0.3)
        : Colors.black.withOpacity(0.08);

    Widget container = Container(
      width: width,
      height: height,
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              gradient: gradient ??
                  LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      backgroundColor.withOpacity(isDark ? 0.12 : opacity * 2),
                      backgroundColor.withOpacity(isDark ? 0.06 : opacity),
                    ],
                  ),
              borderRadius: BorderRadius.circular(borderRadius),
              border: border
                  ? Border.all(color: borderColor, width: 1.5)
                  : null,
              boxShadow: [
                BoxShadow(
                  color: shadowColor,
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: container,
      );
    }

    return container;
  }
}

/// Simplified glass card variant
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.margin,
    this.onTap,
    this.color,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: padding,
      margin: margin,
      onTap: onTap,
      color: color,
      child: child,
    );
  }
}

/// Animated glass button with press effect
class GlassButton extends StatefulWidget {
  const GlassButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.color,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    this.borderRadius = 16.0,
    this.isLoading = false,
    this.enabled = true,
  });

  final VoidCallback onPressed;
  final Widget child;
  final Color? color;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final bool isLoading;
  final bool enabled;

  @override
  State<GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<GlassButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final buttonColor = widget.color ?? AppColors.primary;

    return GestureDetector(
      onTapDown: widget.enabled ? (_) => _controller.forward() : null,
      onTapUp: widget.enabled
          ? (_) {
              _controller.reverse();
              widget.onPressed();
            }
          : null,
      onTapCancel: widget.enabled ? () => _controller.reverse() : null,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: widget.padding,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: widget.enabled
                      ? [
                          buttonColor.withOpacity(0.9),
                          buttonColor,
                        ]
                      : [
                          Colors.grey.shade400,
                          Colors.grey.shade500,
                        ],
                ),
                borderRadius: BorderRadius.circular(widget.borderRadius),
                boxShadow: widget.enabled
                    ? [
                        BoxShadow(
                          color: buttonColor.withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : null,
              ),
              child: widget.isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : widget.child,
            ),
          );
        },
      ),
    );
  }
}

/// Text with gradient shader
class GradientText extends StatelessWidget {
  const GradientText({
    super.key,
    required this.text,
    required this.gradient,
    this.style,
  });

  final String text;
  final Gradient gradient;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => gradient.createShader(bounds),
      child: Text(
        text,
        style: (style ?? const TextStyle()).copyWith(color: Colors.white),
      ),
    );
  }
}

/// Jar icon widget with customizable color and emoji
class JarIcon extends StatelessWidget {
  const JarIcon({
    super.key,
    required this.emoji,
    required this.color,
    this.size = 60,
    this.showGlow = false,
  });

  final String emoji;
  final Color color;
  final double size;
  final bool showGlow;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.8),
            color,
          ],
        ),
        borderRadius: BorderRadius.circular(size * 0.25),
        boxShadow: showGlow
            ? [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Center(
        child: Text(
          emoji,
          style: TextStyle(fontSize: size * 0.45),
        ),
      ),
    );
  }
}

/// Animated loading dots
class LoadingDots extends StatefulWidget {
  const LoadingDots({
    super.key,
    this.color,
    this.size = 8,
  });

  final Color? color;
  final double size;

  @override
  State<LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<LoadingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? AppColors.primary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final delay = index * 0.2;
            final progress = (_controller.value - delay).clamp(0.0, 1.0);
            final scale = 0.5 + 0.5 * (1 - (progress - 0.5).abs() * 2);

            return Container(
              margin: EdgeInsets.symmetric(horizontal: widget.size * 0.3),
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: color.withOpacity(scale),
                shape: BoxShape.circle,
              ),
            );
          },
        );
      }),
    );
  }
}

/// Memory type indicator chip
class MemoryTypeChip extends StatelessWidget {
  const MemoryTypeChip({
    super.key,
    required this.icon,
    required this.label,
    this.color,
    this.isSelected = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final Color? color;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AppColors.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? chipColor.withOpacity(0.15)
              : (isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? chipColor : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? chipColor
                  : (isDark ? Colors.white60 : Colors.grey.shade600),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? chipColor
                    : (isDark ? Colors.white60 : Colors.grey.shade600),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
