import 'package:flutter/material.dart';

Color getContrastingTextColor(Color backgroundColor) {
  // Calculate the perceived brightness of the color
  // Formula: (299*R + 587*G + 114*B) / 1000
  double brightness = (backgroundColor.red * 0.299) +
      (backgroundColor.green * 0.587) +
      (backgroundColor.blue * 0.114);
  return brightness > 128 ? Colors.black : Colors.white;
}

extension StringExtensions on String {
  String toTitleCase() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
