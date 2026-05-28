import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraPreviewBox extends StatelessWidget {
  const CameraPreviewBox({super.key, required this.controller});

  final CameraController controller;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: CameraPreview(controller),
      ),
    );
  }
}
