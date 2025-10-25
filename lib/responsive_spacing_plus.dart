// A lightweight, flexible responsive toolkit for Flutter apps.
//
// Features
// - Device type detection (mobile/tablet/desktop) via breakpoints
// - Screen metrics helpers (width/height/status bar/app bar)
// - Scaled sizes for font, spacing, icons/images, padding and radius
// - Design-size based scaling helpers: .w, .h, .sp, .r extensions
// - Value picking per device type and a simple ResponsiveBuilder widget

import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Device types based on width breakpoints.
enum DeviceType { mobile, tablet, desktop }

/// Configurable breakpoints for deciding device type based on screen width.
class ResponsiveBreakpoints {
  final double mobileMax; // inclusive upper bound for mobile
  final double tabletMax; // inclusive upper bound for tablet

  /// Creates breakpoints for classifying device types by screen width.
  ///
  /// Defaults to `mobileMax = 600` and `tabletMax = 1024`.
  /// Any width `<= mobileMax` is mobile, `<= tabletMax` is tablet, and larger is desktop.
  const ResponsiveBreakpoints({this.mobileMax = 600, this.tabletMax = 1024})
    : assert(mobileMax > 0),
      assert(tabletMax > mobileMax);
}

/// Global responsive configuration.
class ResponsiveConfig {
  /// Reference design width used for width-based scaling (e.g. 375 for iPhone X width).
  final double designWidth;

  /// Reference design height used for height-based scaling (e.g. 812 for iPhone X height).
  final double designHeight;

  /// Max text scale factor used when computing [textScaleFactor].
  final double maxTextScaleFactor;

  /// Breakpoints for device classification.
  final ResponsiveBreakpoints breakpoints;

  const ResponsiveConfig({
    this.designWidth = 375,
    this.designHeight = 812,
    this.maxTextScaleFactor = 2.0,
    this.breakpoints = const ResponsiveBreakpoints(),
  }) : assert(designWidth > 0),
       assert(designHeight > 0),
       assert(maxTextScaleFactor >= 1.0);

  ResponsiveConfig copyWith({
    double? designWidth,
    double? designHeight,
    double? maxTextScaleFactor,
    ResponsiveBreakpoints? breakpoints,
  }) => ResponsiveConfig(
    designWidth: designWidth ?? this.designWidth,
    designHeight: designHeight ?? this.designHeight,
    maxTextScaleFactor: maxTextScaleFactor ?? this.maxTextScaleFactor,
    breakpoints: breakpoints ?? this.breakpoints,
  );
}

/// Singleton-style holder for global configuration.
class _ResponsiveState {
  _ResponsiveState._();
  static ResponsiveConfig config = const ResponsiveConfig();
}

/// Entry points for configuring and using responsive metrics.
class Responsive {
  Responsive._();

  /// Initialize or override the global configuration (optional).
  static void init({ResponsiveConfig? config}) {
    if (config != null) _ResponsiveState.config = config;
  }

  /// App bar preferred height.
  static double appBarHeight() => AppBar().preferredSize.height;

  /// Status bar height.
  static double statusBarHeight(BuildContext context) =>
      MediaQuery.of(context).padding.top;

  /// Screen width in logical pixels.
  static double screenWidth(BuildContext context) =>
      MediaQuery.sizeOf(context).width;

  /// Screen height in logical pixels.
  static double screenHeight(BuildContext context) =>
      MediaQuery.sizeOf(context).height;

  /// Physical diagonal (Pythagoras on logical pixels).
  static double diagonal(BuildContext context) {
    final w = screenWidth(context);
    final h = screenHeight(context);
    return math.sqrt(w * w + h * h);
  }

  /// Device type based on width breakpoints.
  static DeviceType deviceType(BuildContext context) {
    final width = screenWidth(context);
    final bp = _ResponsiveState.config.breakpoints;
    if (width <= bp.mobileMax) return DeviceType.mobile;
    if (width <= bp.tabletMax) return DeviceType.tablet;
    return DeviceType.desktop;
  }

  /// Whether the screen should be treated as a mobile layout (width <= mobileMax).
  static bool isMobile(BuildContext c) => deviceType(c) == DeviceType.mobile;

  /// Whether the screen should be treated as a tablet layout (mobileMax < width <= tabletMax).
  static bool isTablet(BuildContext c) => deviceType(c) == DeviceType.tablet;

  /// Whether the screen should be treated as a desktop layout (width > tabletMax).
  static bool isDesktop(BuildContext c) => deviceType(c) == DeviceType.desktop;

  /// Width-based scale factor relative to [ResponsiveConfig.designWidth].
  static double _scaleW(BuildContext c) =>
      screenWidth(c) / _ResponsiveState.config.designWidth;

  /// Height-based scale factor relative to [ResponsiveConfig.designHeight].
  static double _scaleH(BuildContext c) =>
      screenHeight(c) / _ResponsiveState.config.designHeight;

  /// Responsive font size from a base design size.
  /// Example: font(context, 16) returns ~16 on 375px width and scales on larger widths.
  static double font(BuildContext c, double base, {double? min, double? max}) {
    final scaled = base * _scaleW(c);
    final clampedMin =
        min ?? base * 0.85; // keep fonts readable on very small screens
    final clampedMax = max ?? base * 2.2; // avoid huge fonts
    return scaled.clamp(clampedMin, clampedMax);
  }

  /// Responsive spacing from a base design size (e.g. margin/padding/gaps).
  static double spacing(
    BuildContext c,
    double base, {
    double? min,
    double? max,
  }) {
    final scaled = base * _scaleW(c);
    final clampedMin = min ?? base * 0.75;
    final clampedMax = max ?? base * 2.4;
    return scaled.clamp(clampedMin, clampedMax);
  }

  /// Responsive icon size (alias for [imageSize]).
  static double iconSize(
    BuildContext c,
    double base, {
    double? min,
    double? max,
  }) => imageSize(c, base, min: min, max: max);

  /// Responsive image size from base.
  static double imageSize(
    BuildContext c,
    double base, {
    double? min,
    double? max,
  }) {
    final scaled = base * _scaleW(c);
    final clampedMin = min ?? base * 0.7;
    final clampedMax = max ?? base * 3.0;
    return scaled.clamp(clampedMin, clampedMax);
  }

  /// Responsive border radius.
  static double radius(
    BuildContext c,
    double base, {
    double? min,
    double? max,
  }) {
    final scaled = base * _scaleW(c);
    return scaled.clamp(min ?? base * 0.7, max ?? base * 2.0);
  }

  /// Responsive [EdgeInsets] scaling each dimension independently.
  static EdgeInsets padding(BuildContext c, EdgeInsets base) {
    final sx = _scaleW(c);
    final sy = _scaleH(c);
    return EdgeInsets.fromLTRB(
      (base.left * sx),
      (base.top * sy),
      (base.right * sx),
      (base.bottom * sy),
    );
  }

  /// Width in logical pixels for a size specified in the design space.
  static double w(BuildContext c, double designUnits) =>
      designUnits * _scaleW(c);

  /// Height in logical pixels for a size specified in the design space.
  static double h(BuildContext c, double designUnits) =>
      designUnits * _scaleH(c);

  /// Text scale factor suggestion based on screen width.
  static double textScaleFactor(BuildContext c, {double? maxTextScaleFactor}) {
    final width = screenWidth(c);
    final maxTF =
        maxTextScaleFactor ?? _ResponsiveState.config.maxTextScaleFactor;
    final val = (width / 1400) * maxTF;
    return math.max(1, math.min(val, maxTF));
  }
}

/// Pick a value based on device type.
class ResponsiveValue<T> {
  final T? mobile;
  final T? tablet;
  final T? desktop;
  final T fallback;

  const ResponsiveValue({
    this.mobile,
    this.tablet,
    this.desktop,
    required this.fallback,
  });

  T resolve(BuildContext c) {
    switch (Responsive.deviceType(c)) {
      case DeviceType.mobile:
        return mobile ?? fallback;
      case DeviceType.tablet:
        return tablet ?? mobile ?? fallback;
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile ?? fallback;
    }
  }
}

/// A builder widget that exposes [DeviceType] and constraints to its child.
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(
    BuildContext context,
    BoxConstraints constraints,
    DeviceType deviceType,
  )
  builder;
  const ResponsiveBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) =>
          builder(context, constraints, Responsive.deviceType(context)),
    );
  }
}

/// BuildContext extensions for ergonomic access.
extension ResponsiveContextX on BuildContext {
  double get sw => Responsive.screenWidth(this);
  double get sh => Responsive.screenHeight(this);

  bool get isMobile => Responsive.isMobile(this);
  bool get isTablet => Responsive.isTablet(this);
  bool get isDesktop => Responsive.isDesktop(this);

  double font(double base, {double? min, double? max}) =>
      Responsive.font(this, base, min: min, max: max);
  double space(double base, {double? min, double? max}) =>
      Responsive.spacing(this, base, min: min, max: max);
  double iconSize(double base, {double? min, double? max}) =>
      Responsive.iconSize(this, base, min: min, max: max);
  double imageSize(double base, {double? min, double? max}) =>
      Responsive.imageSize(this, base, min: min, max: max);
  double radius(double base, {double? min, double? max}) =>
      Responsive.radius(this, base, min: min, max: max);
  EdgeInsets pad(EdgeInsets base) => Responsive.padding(this, base);
  double w(double units) => Responsive.w(this, units);
  double h(double units) => Responsive.h(this, units);
}

/// Numeric extensions (design units -> logical pixels).
extension ResponsiveNumX on num {
  double w(BuildContext c) => Responsive.w(c, toDouble());
  double h(BuildContext c) => Responsive.h(c, toDouble());
  double sp(BuildContext c, {double? min, double? max}) =>
      Responsive.font(c, toDouble(), min: min, max: max);
  double r(BuildContext c, {double? min, double? max}) =>
      Responsive.radius(c, toDouble(), min: min, max: max);
}
