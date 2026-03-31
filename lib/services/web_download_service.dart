import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

class WebDownloadService {
  static Future<void> downloadWidgetAsImage(GlobalKey key, {required String fileName}) async {
    try {
      final boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final pngBytes = byteData.buffer.asUint8List();
      final base64 = base64Encode(pngBytes);
      final anchor = html.AnchorElement(href: 'data:application/octet-stream;base64,$base64')
        ..setAttribute('download', '$fileName.png')
        ..click();
    } catch (e) {
      debugPrint('Error downloading image: $e');
    }
  }
}
