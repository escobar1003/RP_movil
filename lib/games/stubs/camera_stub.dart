import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';

enum CameraLensDirection { front, back, external }

enum ResolutionPreset { low, medium, high, veryHigh, ultraHigh, max }

enum ImageFormatGroup { unknown, yuv420, bgra8888, jpeg, nv21 }

enum FlashMode { off, auto, always, torch }

enum ExposureMode { auto, locked }

enum FocusMode { auto, locked }

class CameraDescription {
  final String name;
  final CameraLensDirection lensDirection;
  final int sensorOrientation;

  const CameraDescription({
    required this.name,
    required this.lensDirection,
    this.sensorOrientation = 0,
  });
}

class CameraImage {
  final ImageFormat format;
  final int height;
  final int width;
  final List<Plane> planes;

  CameraImage({
    required this.format,
    required this.height,
    required this.width,
    required this.planes,
  });
}

class ImageFormat {
  final ImageFormatGroup group;
  final dynamic raw;
  ImageFormat(this.group, {required this.raw});
}

class Plane {
  final Uint8List bytes;
  final int? bytesPerPixel;
  final int bytesPerRow;
  final int? height;
  final int? width;
  Plane({
    required this.bytes,
    required this.bytesPerRow,
    this.bytesPerPixel,
    this.height,
    this.width,
  });
}

class CameraValue {
  final bool isInitialized;
  final Size? previewSize;
  final CameraDescription description;
  final bool isRecordingVideo = false;
  final bool isTakingPicture = false;
  final bool isStreamingImages = false;
  final FlashMode flashMode = FlashMode.off;
  final ExposureMode exposureMode = ExposureMode.auto;
  final FocusMode focusMode = FocusMode.auto;
  final bool exposurePointSupported = false;
  final bool focusPointSupported = false;

  const CameraValue({
    required this.isInitialized,
    this.previewSize,
    required this.description,
  });
}

class MediaSettings {
  final ResolutionPreset? resolutionPreset;
  final int? fps;
  final int? videoBitrate;
  final int? audioBitrate;
  final bool enableAudio;
  const MediaSettings({
    this.resolutionPreset,
    this.fps,
    this.videoBitrate,
    this.audioBitrate,
    this.enableAudio = false,
  });
}

typedef onLatestImageAvailable = void Function(CameraImage image);

class CameraController extends ValueNotifier<CameraValue> {
  final CameraDescription description;
  final ResolutionPreset resolutionPreset;
  final bool enableAudio;

  CameraController(
    this.description,
    this.resolutionPreset, {
    this.enableAudio = true,
    ImageFormatGroup? imageFormatGroup,
  }) : super(CameraValue(isInitialized: false, description: description));

  CameraValue _value = const CameraValue(
    isInitialized: false,
    description: CameraDescription(
      name: '',
      lensDirection: CameraLensDirection.front,
    ),
  );

  @override
  CameraValue get value => _value;

  int get cameraId => 0;

  Future<void> initialize() async {
    _value = CameraValue(
      isInitialized: true,
      previewSize: const Size(480, 640),
      description: description,
    );
    notifyListeners();
  }

  Future<void> startImageStream(onLatestImageAvailable onAvailable) async {}

  Future<void> stopImageStream() async {}

  Widget buildPreview() => const SizedBox.shrink();

  @override
  Future<void> dispose() async {
    super.dispose();
  }
}

class CameraPreview extends StatelessWidget {
  final CameraController controller;
  final Widget? child;

  const CameraPreview(this.controller, {super.key, this.child});

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class CameraException implements Exception {
  final String code;
  final String? description;
  CameraException(this.code, this.description);
}

Future<List<CameraDescription>> availableCameras() async => [];
