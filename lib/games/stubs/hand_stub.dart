import 'camera_stub.dart';

class Landmark {
  final double x;
  final double y;
  final double z;
  Landmark(this.x, this.y, this.z);
}

class Hand {
  final List<Landmark> landmarks;
  Hand(this.landmarks);
}

enum HandLandmarkerDelegate { cpu, gpu }

class HandLandmarkerPlugin {
  HandLandmarkerPlugin._();

  static HandLandmarkerPlugin create({
    int numHands = 2,
    double minHandDetectionConfidence = 0.5,
    HandLandmarkerDelegate delegate = HandLandmarkerDelegate.gpu,
  }) {
    return HandLandmarkerPlugin._();
  }

  List<Hand> detect(CameraImage image, int sensorOrientation) => [];

  void dispose() {}
}
