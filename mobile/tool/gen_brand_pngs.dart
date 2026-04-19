// Generates launcher/splash PNG assets (orange mark on transparent).
// Run from mobile/: dart run tool/gen_brand_pngs.dart

import 'dart:io';

import 'package:image/image.dart';

void main() {
  final dir = Directory('assets/images');
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
  }

  // Adaptive foreground + legacy icon: orange circle on transparent.
  final icon = Image(width: 1024, height: 1024, numChannels: 4);
  fill(icon, color: ColorRgba8(0, 0, 0, 0));
  fillCircle(
    icon,
    x: 512,
    y: 512,
    radius: 380,
    color: ColorRgba8(249, 115, 22, 255),
    antialias: true,
  );
  File('assets/images/nuvelo_icon.png').writeAsBytes(encodePng(icon));

  // Splash center image (scaled by flutter_native_splash).
  final logo = Image(width: 512, height: 512, numChannels: 4);
  fill(logo, color: ColorRgba8(0, 0, 0, 0));
  fillCircle(
    logo,
    x: 256,
    y: 256,
    radius: 160,
    color: ColorRgba8(249, 115, 22, 255),
    antialias: true,
  );
  File('assets/images/nuvelo_logo.png').writeAsBytes(encodePng(logo));

  stdout.writeln('Wrote assets/images/nuvelo_icon.png and nuvelo_logo.png');
}
