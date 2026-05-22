import 'package:flutter/material.dart';

/// Breakpoint system for Brilliant Movee.
/// Mobile: < 600px  |  Tablet: 600–1024px  |  Desktop: > 1024px
abstract final class Breakpoints {
  static const double mobile = 600;
  static const double tablet = 1024;
  static const double desktop = 1440;

  /// Max content width on desktop — keeps content readable.
  static const double maxContentWidth = 1200;

  /// Side nav width on desktop.
  static const double sideNavWidth = 220;

  /// Side nav collapsed (rail) width on tablet.
  static const double railWidth = 72;
}

/// Screen size category.
enum ScreenSize { mobile, tablet, desktop }

/// Responsive utilities — read once per build, don't store.
extension ResponsiveContext on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;

  ScreenSize get screenSize {
    final w = screenWidth;
    if (w < Breakpoints.mobile) return ScreenSize.mobile;
    if (w < Breakpoints.tablet) return ScreenSize.tablet;
    return ScreenSize.desktop;
  }

  bool get isMobile => screenSize == ScreenSize.mobile;
  bool get isTablet => screenSize == ScreenSize.tablet;
  bool get isDesktop => screenSize == ScreenSize.desktop;
  bool get isWide => screenWidth >= Breakpoints.mobile; // tablet or desktop

  /// Horizontal padding that scales with screen size.
  double get screenPadding {
    final w = screenWidth;
    if (w < Breakpoints.mobile) return 20;
    if (w < Breakpoints.tablet) return 32;
    return 48;
  }

  /// Returns value based on screen size.
  T responsive<T>({required T mobile, T? tablet, required T desktop}) {
    return switch (screenSize) {
      ScreenSize.mobile => mobile,
      ScreenSize.tablet => tablet ?? desktop,
      ScreenSize.desktop => desktop,
    };
  }
}

/// Wraps content in a centered max-width container for wide screens.
/// On mobile it's transparent — just passes through.
class ResponsiveContainer extends StatelessWidget {
  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth = Breakpoints.maxContentWidth,
    this.padding,
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    if (context.isMobile) {
      return padding != null ? Padding(padding: padding!, child: child) : child;
    }
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: padding != null ? Padding(padding: padding!, child: child) : child,
      ),
    );
  }
}

/// Two-column layout for wide screens, single column on mobile.
class ResponsiveTwoColumn extends StatelessWidget {
  const ResponsiveTwoColumn({
    super.key,
    required this.left,
    required this.right,
    this.leftFlex = 1,
    this.rightFlex = 1,
    this.gap = 24,
    this.breakpoint = Breakpoints.mobile,
  });

  final Widget left;
  final Widget right;
  final int leftFlex;
  final int rightFlex;
  final double gap;
  final double breakpoint;

  @override
  Widget build(BuildContext context) {
    if (context.screenWidth < breakpoint) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [left, SizedBox(height: gap), right],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: leftFlex, child: left),
        SizedBox(width: gap),
        Expanded(flex: rightFlex, child: right),
      ],
    );
  }
}
