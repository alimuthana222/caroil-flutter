import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class AppIconGenerator {
  static Future<Uint8List> generateAppIcon({
    int size = 512,
    Color backgroundColor = const Color(0xFF4CAF50),
    Color iconColor = Colors.white,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Draw background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size / 2, size / 2),
      size / 2,
      backgroundPaint,
    );

    // Draw oil drop icon
    final iconPaint = Paint()
      ..color = iconColor
      ..style = PaintingStyle.fill;

    final iconSize = size * 0.6;
    final iconOffset = size * 0.2;

    // Create oil drop shape
    final path = Path();
    final centerX = iconOffset + iconSize / 2;
    final centerY = iconOffset + iconSize / 2;

    // Oil drop shape
    path.moveTo(centerX, iconOffset);
    path.quadraticBezierTo(
      centerX - iconSize / 3, iconOffset + iconSize / 3,
      centerX - iconSize / 4, iconOffset + iconSize * 0.7,
    );
    path.quadraticBezierTo(
      centerX - iconSize / 6, iconOffset + iconSize,
      centerX, iconOffset + iconSize,
    );
    path.quadraticBezierTo(
      centerX + iconSize / 6, iconOffset + iconSize,
      centerX + iconSize / 4, iconOffset + iconSize * 0.7,
    );
    path.quadraticBezierTo(
      centerX + iconSize / 3, iconOffset + iconSize / 3,
      centerX, iconOffset,
    );

    canvas.drawPath(path, iconPaint);

    // Add car silhouette at bottom
    final carPaint = Paint()
      ..color = iconColor.withOpacity(0.8)
      ..style = PaintingStyle.fill;

    final carY = iconOffset + iconSize * 0.8;
    final carWidth = iconSize * 0.8;
    final carHeight = iconSize * 0.15;

    final carRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        centerX - carWidth / 2,
        carY,
        carWidth,
        carHeight,
      ),
      Radius.circular(carHeight / 4),
    );

    canvas.drawRRect(carRect, carPaint);

    // Add wheels
    final wheelRadius = carHeight * 0.4;
    canvas.drawCircle(
      Offset(centerX - carWidth / 3, carY + carHeight),
      wheelRadius,
      carPaint,
    );
    canvas.drawCircle(
      Offset(centerX + carWidth / 3, carY + carHeight),
      wheelRadius,
      carPaint,
    );

    final picture = recorder.endRecording();
    final img = await picture.toImage(size, size);
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);

    return byteData!.buffer.asUint8List();
  }
}