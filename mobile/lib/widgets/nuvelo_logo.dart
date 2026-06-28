import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Brand wordmark — theme-aware SVG (white text on dark, navy text on light).
class NuveloLogo extends StatelessWidget {
  const NuveloLogo({super.key, this.height = 28});

  final double height;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return SvgPicture.asset(
      isLight
          ? 'assets/images/nuvelo-logo-light.svg'
          : 'assets/images/nuvelo-logo.svg',
      height: height,
      fit: BoxFit.contain,
      semanticsLabel: 'Nuvelo',
    );
  }
}
