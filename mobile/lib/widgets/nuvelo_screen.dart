import 'package:flutter/material.dart';

import '../core/theme.dart';

/// Navy scaffold with optional [SafeArea] edges and tap-to-dismiss keyboard (iOS-friendly).
class NuveloScreen extends StatelessWidget {
  const NuveloScreen({
    super.key,
    required this.child,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.dismissKeyboard = true,
    this.safeTop = true,
    this.safeBottom = true,
    this.safeLeft = true,
    this.safeRight = true,
    this.resizeToAvoidBottomInset = true,
  });

  final PreferredSizeWidget? appBar;
  final Widget child;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final bool dismissKeyboard;

  /// When nested in a shell with [AppBar], set [safeTop] to false to avoid double top inset.
  final bool safeTop;
  final bool safeBottom;
  final bool safeLeft;
  final bool safeRight;
  final bool resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) {
    Widget body = SafeArea(
      top: safeTop,
      bottom: safeBottom,
      left: safeLeft,
      right: safeRight,
      minimum: EdgeInsets.zero,
      child: child,
    );
    if (dismissKeyboard) {
      body = GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: body,
      );
    }
    return Scaffold(
      backgroundColor: NuveloColors.darkNavy,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      appBar: appBar,
      body: body,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
    );
  }
}
