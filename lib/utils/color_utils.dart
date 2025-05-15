import 'package:flutter/material.dart';

Color colorFromString(String color) {
  switch (color.toLowerCase()) {
    case 'blue':
      return Colors.blue;
    case 'purple':
      return Colors.purple;
    case 'red':
      return Colors.red;
    case 'green':
      return Colors.green;
    case 'yellow':
      return Colors.yellow;
    case 'orange':
      return Colors.orange;
    case 'pink':
      return Colors.pink;
    case 'brown':
      return Colors.brown;
    case 'grey':
    case 'gray':
      return Colors.grey;
    case 'black':
      return Colors.black;
    case 'white':
      return Colors.white;
    default:
      // Try to parse hex code, e.g. "#FF00FF"
      if (color.startsWith('#')) {
        final hex = color.replaceFirst('#', '');
        if (hex.length == 6) {
          return Color(int.parse('FF$hex', radix: 16));
        } else if (hex.length == 8) {
          return Color(int.parse(hex, radix: 16));
        }
      }
      return Colors.blueGrey; // fallback
  }
} 