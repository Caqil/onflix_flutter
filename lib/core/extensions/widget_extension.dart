import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

extension WidgetExtension on Widget {
  // Padding extensions
  Widget paddingAll(double value) {
    return Padding(
      padding: EdgeInsets.all(value),
      child: this,
    );
  }

  Widget paddingSymmetric({double horizontal = 0, double vertical = 0}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
      child: this,
    );
  }

  Widget paddingOnly({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) {
    return Padding(
      padding:
          EdgeInsets.only(left: left, top: top, right: right, bottom: bottom),
      child: this,
    );
  }

  Widget get paddingZero => paddingAll(0);
  Widget get paddingSmall => paddingAll(8);
  Widget get paddingMedium => paddingAll(16);
  Widget get paddingLarge => paddingAll(24);
  Widget get paddingExtraLarge => paddingAll(32);

  Widget get paddingHorizontalSmall => paddingSymmetric(horizontal: 8);
  Widget get paddingHorizontalMedium => paddingSymmetric(horizontal: 16);
  Widget get paddingHorizontalLarge => paddingSymmetric(horizontal: 24);

  Widget get paddingVerticalSmall => paddingSymmetric(vertical: 8);
  Widget get paddingVerticalMedium => paddingSymmetric(vertical: 16);
  Widget get paddingVerticalLarge => paddingSymmetric(vertical: 24);

  // Margin extensions (using Container)
  Widget marginAll(double value) {
    return Container(
      margin: EdgeInsets.all(value),
      child: this,
    );
  }

  Widget marginSymmetric({double horizontal = 0, double vertical = 0}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
      child: this,
    );
  }

  Widget marginOnly({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) {
    return Container(
      margin:
          EdgeInsets.only(left: left, top: top, right: right, bottom: bottom),
      child: this,
    );
  }

  // Alignment extensions
  Widget center() => Center(child: this);
  Widget alignLeft() => Align(alignment: Alignment.centerLeft, child: this);
  Widget alignRight() => Align(alignment: Alignment.centerRight, child: this);
  Widget alignTop() => Align(alignment: Alignment.topCenter, child: this);
  Widget alignBottom() => Align(alignment: Alignment.bottomCenter, child: this);
  Widget alignTopLeft() => Align(alignment: Alignment.topLeft, child: this);
  Widget alignTopRight() => Align(alignment: Alignment.topRight, child: this);
  Widget alignBottomLeft() =>
      Align(alignment: Alignment.bottomLeft, child: this);
  Widget alignBottomRight() =>
      Align(alignment: Alignment.bottomRight, child: this);

  // Flexible and Expanded
  Widget expanded({int flex = 1}) => Expanded(flex: flex, child: this);
  Widget flexible({int flex = 1, FlexFit fit = FlexFit.loose}) {
    return Flexible(flex: flex, fit: fit, child: this);
  }

  // Visibility
  Widget visible(bool visible) => Visibility(visible: visible, child: this);
  Widget invisible() => Visibility(visible: false, child: this);
  Widget opacity(double opacity) => Opacity(opacity: opacity, child: this);

  // Gestures
  Widget onTap(VoidCallback? onTap) {
    return GestureDetector(onTap: onTap, child: this);
  }

  Widget onDoubleTap(VoidCallback? onDoubleTap) {
    return GestureDetector(onDoubleTap: onDoubleTap, child: this);
  }

  Widget onLongPress(VoidCallback? onLongPress) {
    return GestureDetector(onLongPress: onLongPress, child: this);
  }

  // Clipper
  Widget clipRRect({double radius = 8.0}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: this,
    );
  }

  Widget clipOval() => ClipOval(child: this);
  Widget clipRect() => ClipRect(child: this);

  // Animations
  Widget fadeIn({
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeIn,
  }) {
    return AnimatedOpacity(
      opacity: 1.0,
      duration: duration,
      curve: curve,
      child: this,
    );
  }

  Widget slideIn({
    Duration duration = const Duration(milliseconds: 300),
    Offset offset = const Offset(0, 1),
    Curve curve = Curves.easeInOut,
  }) {
    return AnimatedSlide(
      offset: offset,
      duration: duration,
      curve: curve,
      child: this,
    );
  }

  Widget scale({
    Duration duration = const Duration(milliseconds: 300),
    double scale = 1.0,
    Curve curve = Curves.easeInOut,
  }) {
    return AnimatedScale(
      scale: scale,
      duration: duration,
      curve: curve,
      child: this,
    );
  }

  // Conditional rendering
  Widget showIf(bool condition) {
    return condition ? this : const SizedBox.shrink();
  }

  Widget hideIf(bool condition) {
    return !condition ? this : const SizedBox.shrink();
  }

  // Hero animation
  Widget hero(String tag) => Hero(tag: tag, child: this);

  // Tooltip
  Widget tooltip(String message) => Tooltip(message: message, child: this);

  // Intrinsic sizing
  Widget intrinsicHeight() => IntrinsicHeight(child: this);
  Widget intrinsicWidth() => IntrinsicWidth(child: this);

  // Baseline
  Widget baseline(double baseline, TextBaseline baselineType) {
    return Baseline(
        baseline: baseline, baselineType: baselineType, child: this);
  }

  // Constrained box
  Widget constrained({
    double? minWidth,
    double? maxWidth,
    double? minHeight,
    double? maxHeight,
  }) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: minWidth ?? 0,
        maxWidth: maxWidth ?? double.infinity,
        minHeight: minHeight ?? 0,
        maxHeight: maxHeight ?? double.infinity,
      ),
      child: this,
    );
  }

  Widget sized({double? width, double? height}) {
    return SizedBox(width: width, height: height, child: this);
  }

  Widget square(double size) =>
      SizedBox(width: size, height: size, child: this);

  // Aspect ratio
  Widget aspectRatio(double aspectRatio) {
    return AspectRatio(aspectRatio: aspectRatio, child: this);
  }

  // Fractional sized box
  Widget fractionallySize({double? widthFactor, double? heightFactor}) {
    return FractionallySizedBox(
      widthFactor: widthFactor,
      heightFactor: heightFactor,
      child: this,
    );
  }

  // Custom decoration
  Widget decorated({
    Color? color,
    DecorationImage? image,
    Border? border,
    BorderRadius? borderRadius,
    List<BoxShadow>? boxShadow,
    Gradient? gradient,
    BlendMode? backgroundBlendMode,
    BoxShape shape = BoxShape.rectangle,
  }) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        image: image,
        border: border,
        borderRadius: borderRadius,
        boxShadow: boxShadow,
        gradient: gradient,
        backgroundBlendMode: backgroundBlendMode,
        shape: shape,
      ),
      child: this,
    );
  }

  // ShadCN UI specific extensions
  Widget shadCard({
    Color? backgroundColor,
    double? elevation,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
  }) {
    return ShadCard(
      backgroundColor: backgroundColor,
      child: this,
    );
  }

  Widget shadButton({
    required VoidCallback? onPressed,
    ShadButtonVariant variant = ShadButtonVariant.primary,
    ShadButtonSize size = ShadButtonSize.regular,
  }) {
    return ShadButton.raw(
      onPressed: onPressed,
      variant: variant,
      size: size,
      child: this,
    );
  }
}
