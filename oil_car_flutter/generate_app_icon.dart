import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:math' as math;

Future<void> main() async {
  print('🎨 Generating Oil Finder app icon...');

  try {
    final iconBytes = await generateOilFinderIcon();

    // Create assets directory
    final assetsDir = Directory('assets/icons');
    if (!await assetsDir.exists()) {
      await assetsDir.create(recursive: true);
    }

    // Save the icon
    final iconFile = File('assets/icons/app_icon.png');
    await iconFile.writeAsBytes(iconBytes);

    print('✅ App icon generated successfully!');
    print('📁 Saved to: ${iconFile.path}');
    print('📱 Now run: flutter pub run flutter_launcher_icons:main');

  } catch (e) {
    print('❌ Error generating icon: $e');
  }
}

Future<Uint8List> generateOilFinderIcon() async {
  const size = 512.0;
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder);

  // Background gradient (green circle)
  final backgroundPaint = ui.Paint()
    ..shader = ui.Gradient.radial(
      ui.Offset(size * 0.5, size * 0.4),
      size * 0.6,
      [
        ui.Color(0xFF66BB6A), // Light green
        ui.Color(0xFF4CAF50), // Main green
        ui.Color(0xFF388E3C), // Dark green
      ],
      [0.0, 0.7, 1.0],
    );

  // Draw background circle
  canvas.drawCircle(
    ui.Offset(size / 2, size / 2),
    size / 2,
    backgroundPaint,
  );

  // White border circle
  final borderPaint = ui.Paint()
    ..color = ui.Color(0xFFFFFFFF)
    ..style = ui.PaintingStyle.stroke
    ..strokeWidth = 8;

  canvas.drawCircle(
    ui.Offset(size / 2, size / 2),
    size / 2 - 4,
    borderPaint,
  );

  // Car silhouette (bottom)
  final carPaint = ui.Paint()
    ..color = ui.Color(0xFFFFFFFF)
    ..style = ui.PaintingStyle.fill;

  final carPath = ui.Path();
  final carWidth = size * 0.6;
  final carHeight = size * 0.12;
  final carY = size * 0.75;
  final carX = (size - carWidth) / 2;

  // Car body
  carPath.addRRect(ui.RRect.fromRectAndRadius(
    ui.Rect.fromLTWH(carX, carY, carWidth, carHeight),
    ui.Radius.circular(carHeight * 0.3),
  ));

  // Car windows
  final windowWidth = carWidth * 0.3;
  final windowHeight = carHeight * 0.6;
  final windowY = carY - windowHeight * 0.8;

  carPath.addRRect(ui.RRect.fromRectAndRadius(
    ui.Rect.fromLTWH(carX + carWidth * 0.15, windowY, windowWidth, windowHeight),
    ui.Radius.circular(windowHeight * 0.2),
  ));

  carPath.addRRect(ui.RRect.fromRectAndRadius(
    ui.Rect.fromLTWH(carX + carWidth * 0.55, windowY, windowWidth, windowHeight),
    ui.Radius.circular(windowHeight * 0.2),
  ));

  canvas.drawPath(carPath, carPaint);

  // Car wheels
  final wheelRadius = carHeight * 0.6;
  canvas.drawCircle(
    ui.Offset(carX + carWidth * 0.25, carY + carHeight),
    wheelRadius,
    carPaint,
  );
  canvas.drawCircle(
    ui.Offset(carX + carWidth * 0.75, carY + carHeight),
    wheelRadius,
    carPaint,
  );

  // Oil drop (center-top)
  final oilPaint = ui.Paint()
    ..color = ui.Color(0xFFFFFFFF)
    ..style = ui.PaintingStyle.fill;

  final oilPath = ui.Path();
  final dropSize = size * 0.25;
  final dropX = size * 0.5;
  final dropY = size * 0.35;

  // Oil drop shape
  oilPath.moveTo(dropX, dropY - dropSize * 0.5);

  // Left curve
  oilPath.quadraticBezierTo(
    dropX - dropSize * 0.4, dropY - dropSize * 0.1,
    dropX - dropSize * 0.3, dropY + dropSize * 0.1,
  );

  // Bottom left curve
  oilPath.quadraticBezierTo(
    dropX - dropSize * 0.2, dropY + dropSize * 0.4,
    dropX, dropY + dropSize * 0.5,
  );

  // Bottom right curve
  oilPath.quadraticBezierTo(
    dropX + dropSize * 0.2, dropY + dropSize * 0.4,
    dropX + dropSize * 0.3, dropY + dropSize * 0.1,
  );

  // Right curve
  oilPath.quadraticBezierTo(
    dropX + dropSize * 0.4, dropY - dropSize * 0.1,
    dropX, dropY - dropSize * 0.5,
  );

  canvas.drawPath(oilPath, oilPaint);

  // Add highlight to oil drop
  final highlightPaint = ui.Paint()
    ..color = ui.Color(0x40FFFFFF)
    ..style = ui.PaintingStyle.fill;

  canvas.drawCircle(
    ui.Offset(dropX - dropSize * 0.1, dropY - dropSize * 0.1),
    dropSize * 0.15,
    highlightPaint,
  );

  // Add "O" letter in the center of oil drop
  final textStyle = ui.TextStyle(
    color: ui.Color(0xFF4CAF50),
    fontSize: dropSize * 0.8,
    fontWeight: ui.FontWeight.bold,
  );

  final paragraphBuilder = ui.ParagraphBuilder(
    ui.ParagraphStyle(textAlign: ui.TextAlign.center),
  )
    ..pushStyle(textStyle)
    ..addText('O');

  final paragraph = paragraphBuilder.build()
    ..layout(ui.ParagraphConstraints(width: dropSize));

  canvas.drawParagraph(
    paragraph,
    ui.Offset(
      dropX - dropSize * 0.4,
      dropY - dropSize * 0.3,
    ),
  );

  // Convert to image
  final picture = recorder.endRecording();
  final img = await picture.toImage(size.toInt(), size.toInt());
  final byteData = await img.toByteData(format: ui.ImageByteFormat.png);

  return byteData!.buffer.asUint8List();
}