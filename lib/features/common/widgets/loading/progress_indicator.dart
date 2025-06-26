import 'package:flutter/material.dart';
import 'package:onflix/core/constants/app_constants.dart';
import 'package:onflix/core/extensions/context_extension.dart';
import 'package:onflix/core/utils/responsive_helper.dart';

class CustomProgressIndicator extends StatelessWidget {
  final double value; // 0.0 to 1.0
  final double? height;
  final double? width;
  final Color? backgroundColor;
  final Color? valueColor;
  final BorderRadius? borderRadius;
  final String? label;
  final bool showPercentage;
  final TextStyle? labelStyle;
  final MainAxisAlignment alignment;

  const CustomProgressIndicator({
    super.key,
    required this.value,
    this.height,
    this.width,
    this.backgroundColor,
    this.valueColor,
    this.borderRadius,
    this.label,
    this.showPercentage = false,
    this.labelStyle,
    this.alignment = MainAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    final progressHeight =
        height ?? ResponsiveHelper.getScaledPadding(context, 8);
    final progressWidth = width ?? double.infinity;
    final bgColor = backgroundColor ?? context.colorScheme.surfaceVariant;
    final progressColor = valueColor ?? context.colorScheme.primary;
    final radius = borderRadius ?? BorderRadius.circular(progressHeight / 2);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label
        if (label != null || showPercentage)
          Padding(
            padding: EdgeInsets.only(
              bottom: ResponsiveHelper.getScaledPadding(context, 8),
            ),
            child: Row(
              mainAxisAlignment: alignment,
              children: [
                if (label != null)
                  Expanded(
                    child: Text(
                      label!,
                      style: labelStyle ??
                          context.textTheme.bodySmall?.copyWith(
                            color: context.colorScheme.onSurfaceVariant,
                            fontSize:
                                ResponsiveHelper.getScaledFontSize(context, 12),
                          ),
                    ),
                  ),
                if (showPercentage)
                  Text(
                    '${(value * 100).round()}%',
                    style: labelStyle ??
                        context.textTheme.bodySmall?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                          fontSize:
                              ResponsiveHelper.getScaledFontSize(context, 12),
                          fontWeight: FontWeight.w600,
                        ),
                  ),
              ],
            ),
          ),

        // Progress Bar
        Container(
          width: progressWidth,
          height: progressHeight,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: radius,
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: value.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: progressColor,
                borderRadius: radius,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class CustomCircularProgressIndicator extends StatelessWidget {
  final double value; // 0.0 to 1.0
  final double? size;
  final double? strokeWidth;
  final Color? backgroundColor;
  final Color? valueColor;
  final String? centerText;
  final TextStyle? centerTextStyle;
  final bool showPercentage;

  const CustomCircularProgressIndicator({
    super.key,
    required this.value,
    this.size,
    this.strokeWidth,
    this.backgroundColor,
    this.valueColor,
    this.centerText,
    this.centerTextStyle,
    this.showPercentage = false,
  });

  @override
  Widget build(BuildContext context) {
    final progressSize =
        size ?? ResponsiveHelper.getScaledIconSize(context, 60);
    final lineWidth = strokeWidth ??
        ResponsiveHelper.responsive(
          context,
          mobile: 4.0,
          tablet: 5.0,
          desktop: 6.0,
        );
    final bgColor = backgroundColor ?? context.colorScheme.surfaceVariant;
    final progressColor = valueColor ?? context.colorScheme.primary;

    return SizedBox(
      width: progressSize,
      height: progressSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Circle
          SizedBox(
            width: progressSize,
            height: progressSize,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: lineWidth,
              backgroundColor: bgColor,
              valueColor: AlwaysStoppedAnimation<Color>(bgColor),
            ),
          ),

          // Progress Circle
          SizedBox(
            width: progressSize,
            height: progressSize,
            child: CircularProgressIndicator(
              value: value.clamp(0.0, 1.0),
              strokeWidth: lineWidth,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),

          // Center Content
          if (centerText != null || showPercentage)
            Text(
              centerText ?? '${(value * 100).round()}%',
              style: centerTextStyle ??
                  context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSurface,
                    fontSize: ResponsiveHelper.getScaledFontSize(context, 12),
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }
}

class StepProgressIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final double? height;
  final double? stepSize;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? completedColor;
  final List<String>? stepLabels;
  final MainAxisAlignment alignment;
  final bool showLabels;

  const StepProgressIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.height,
    this.stepSize,
    this.activeColor,
    this.inactiveColor,
    this.completedColor,
    this.stepLabels,
    this.alignment = MainAxisAlignment.spaceBetween,
    this.showLabels = true,
  });

  @override
  Widget build(BuildContext context) {
    final progressHeight =
        height ?? ResponsiveHelper.getScaledPadding(context, 4);
    final circleSize =
        stepSize ?? ResponsiveHelper.getScaledIconSize(context, 24);
    final activeStepColor = activeColor ?? context.colorScheme.primary;
    final inactiveStepColor =
        inactiveColor ?? context.colorScheme.surfaceVariant;
    final completedStepColor = completedColor ?? context.colorScheme.primary;

    return Column(
      children: [
        // Step Indicators
        Row(
          mainAxisAlignment: alignment,
          children: List.generate(totalSteps, (index) {
            final stepNumber = index + 1;
            final isCompleted = stepNumber < currentStep;
            final isActive = stepNumber == currentStep;
            final isInactive = stepNumber > currentStep;

            Color stepColor;
            if (isCompleted) {
              stepColor = completedStepColor;
            } else if (isActive) {
              stepColor = activeStepColor;
            } else {
              stepColor = inactiveStepColor;
            }

            return Row(
              children: [
                // Step Circle
                Container(
                  width: circleSize,
                  height: circleSize,
                  decoration: BoxDecoration(
                    color: stepColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: stepColor,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: isCompleted
                        ? Icon(
                            Icons.check,
                            color: Colors.white,
                            size: circleSize * 0.6,
                          )
                        : Text(
                            '$stepNumber',
                            style: context.textTheme.bodySmall?.copyWith(
                              color: isInactive
                                  ? context.colorScheme.onSurfaceVariant
                                  : Colors.white,
                              fontSize: ResponsiveHelper.getScaledFontSize(
                                  context, 12),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),

                // Connector Line
                if (index < totalSteps - 1)
                  Expanded(
                    child: Container(
                      height: progressHeight,
                      margin: EdgeInsets.symmetric(
                        horizontal:
                            ResponsiveHelper.getScaledPadding(context, 8),
                      ),
                      decoration: BoxDecoration(
                        color: isCompleted || isActive
                            ? completedStepColor
                            : inactiveStepColor,
                        borderRadius: BorderRadius.circular(progressHeight / 2),
                      ),
                    ),
                  ),
              ],
            );
          }),
        ),

        // Step Labels
        if (showLabels &&
            stepLabels != null &&
            stepLabels!.length == totalSteps)
          Padding(
            padding: EdgeInsets.only(
              top: ResponsiveHelper.getScaledPadding(context, 8),
            ),
            child: Row(
              mainAxisAlignment: alignment,
              children: List.generate(totalSteps, (index) {
                final stepNumber = index + 1;
                final isActive = stepNumber <= currentStep;

                return Expanded(
                  child: Text(
                    stepLabels![index],
                    style: context.textTheme.bodySmall?.copyWith(
                      color: isActive
                          ? context.colorScheme.onSurface
                          : context.colorScheme.onSurfaceVariant,
                      fontSize: ResponsiveHelper.getScaledFontSize(context, 10),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }
}

class AnimatedProgressIndicator extends StatefulWidget {
  final double value;
  final Duration duration;
  final Curve curve;
  final double? height;
  final double? width;
  final Color? backgroundColor;
  final Color? valueColor;
  final String? label;
  final bool showPercentage;

  const AnimatedProgressIndicator({
    super.key,
    required this.value,
    this.duration = AppConstants.mediumAnimation,
    this.curve = Curves.easeInOut,
    this.height,
    this.width,
    this.backgroundColor,
    this.valueColor,
    this.label,
    this.showPercentage = false,
  });

  @override
  State<AnimatedProgressIndicator> createState() =>
      _AnimatedProgressIndicatorState();
}

class _AnimatedProgressIndicatorState extends State<AnimatedProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: widget.value,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.value,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: widget.curve,
      ));
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomProgressIndicator(
          value: _animation.value,
          height: widget.height,
          width: widget.width,
          backgroundColor: widget.backgroundColor,
          valueColor: widget.valueColor,
          label: widget.label,
          showPercentage: widget.showPercentage,
        );
      },
    );
  }
}

class BufferingProgressIndicator extends StatelessWidget {
  final double downloadProgress; // 0.0 to 1.0
  final double bufferProgress; // 0.0 to 1.0
  final double? height;
  final double? width;
  final Color? backgroundColor;
  final Color? downloadColor;
  final Color? bufferColor;

  const BufferingProgressIndicator({
    super.key,
    required this.downloadProgress,
    required this.bufferProgress,
    this.height,
    this.width,
    this.backgroundColor,
    this.downloadColor,
    this.bufferColor,
  });

  @override
  Widget build(BuildContext context) {
    final progressHeight =
        height ?? ResponsiveHelper.getScaledPadding(context, 6);
    final progressWidth = width ?? double.infinity;
    final bgColor = backgroundColor ?? context.colorScheme.surfaceVariant;
    final bufColor =
        bufferColor ?? context.colorScheme.primary.withOpacity(0.3);
    final dlColor = downloadColor ?? context.colorScheme.primary;

    return Container(
      width: progressWidth,
      height: progressHeight,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(progressHeight / 2),
      ),
      child: Stack(
        children: [
          // Buffer Progress
          FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: bufferProgress.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: bufColor,
                borderRadius: BorderRadius.circular(progressHeight / 2),
              ),
            ),
          ),

          // Download Progress
          FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: downloadProgress.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: dlColor,
                borderRadius: BorderRadius.circular(progressHeight / 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
