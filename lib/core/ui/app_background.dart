import 'package:flutter/material.dart';

String appBackgroundAsset(BuildContext context, {bool forceDark = false}) {
  if (forceDark) {
    return 'assets/AppBackgroundDark.png';
  }
  final brightness = Theme.of(context).brightness;
  return brightness == Brightness.dark
      ? 'assets/AppBackgroundDark.png'
      : 'assets/AppBackground.png';
}
