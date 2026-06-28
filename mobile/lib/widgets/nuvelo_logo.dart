import 'package:flutter/material.dart';

/// Brand wordmark — theme-aware PNG (white text on dark, navy text on light).
class NuveloLogo extends StatelessWidget {
  const NuveloLogo({super.key, this.height = 28});

  final double height;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Image.asset(
      isLight
          ? 'assets/images/nuvelo-logo-light.png'
          : 'assets/images/nuvelo-logo.png',
      height: height,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      semanticLabel: 'Nuvelo',
    );
  }
}
