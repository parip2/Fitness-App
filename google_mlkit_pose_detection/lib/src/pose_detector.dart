import 'dart:math';

import 'package:flutter/services.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';

/// A detector for performing body-pose estimation.
class PoseDetector {
  static const MethodChannel _channel =
      MethodChannel('google_mlkit_pose_detector');

  /// The options for the pose detector.
  final PoseDetectorOptions options;

  /// Instance id.
  final id = DateTime.now().microsecondsSinceEpoch.toString();

  /// Constructor to create an instance of [PoseDetector].
  PoseDetector({required this.options});

  /// Processes the given [InputImage] for pose detection.
  /// It returns a list of [Pose].
  Future<List<Pose>> processImage(InputImage inputImage) async {
    final result = await _channel.invokeMethod(
        'vision#startPoseDetector', <String, dynamic>{
      'options': options.toJson(),
      'id': id,
      'imageData': inputImage.toJson()
    });

    final List<Pose> poses = [];
    for (final pose in result) {
      final Map<PoseLandmarkType, PoseLandmark> landmarks = {};
      for (final point in pose) {
        final landmark = PoseLandmark.fromJson(point);
        landmarks[landmark.type] = landmark;
      }
      poses.add(Pose(landmarks: landmarks));
    }

    return poses;
  }

  /// Closes the detector and releases its resources.
  Future<void> close() =>
      _channel.invokeMethod('vision#closePoseDetector', {'id': id});
}

/// Determines the parameters on which [PoseDetector] works.
class PoseDetectorOptions {
  /// Specifies whether to use base or accurate pose model.
  final PoseDetectionModel model;

  /// The mode for the pose detector.
  final PoseDetectionMode mode;

  /// Constructor to create an instance of [PoseDetectorOptions].
  PoseDetectorOptions(
      {this.model = PoseDetectionModel.base,
      this.mode = PoseDetectionMode.stream});

  /// Returns a json representation of an instance of [PoseDetectorOptions].
  Map<String, dynamic> toJson() => {
        'model': model.name,
        'mode': mode.name,
      };
}

// Specifies whether to use base or accurate pose model.
enum PoseDetectionModel {
  /// Base pose detector with streaming.
  base,

  /// Accurate pose detector on static images.
  accurate,
}

/// The mode for the pose detector.
enum PoseDetectionMode {
  /// To process a static image. This mode is designed for single images where the detection of each image is independent.
  single,

  /// To process a stream of images. This mode is designed for streaming frames from video or camera.
  stream,
}

/// Available pose landmarks detected by [PoseDetector].
enum PoseLandmarkType {
  nose,
  leftEyeInner,
  leftEye,
  leftEyeOuter,
  rightEyeInner,
  rightEye,
  rightEyeOuter,
  leftEar,
  rightEar,
  leftMouth,
  rightMouth,
  leftShoulder,
  rightShoulder,
  leftElbow,
  rightElbow,
  leftWrist,
  rightWrist,
  leftPinky,
  rightPinky,
  leftIndex,
  rightIndex,
  leftThumb,
  rightThumb,
  leftHip,
  rightHip,
  leftKnee,
  rightKnee,
  leftAnkle,
  rightAnkle,
  leftHeel,
  rightHeel,
  leftFootIndex,
  rightFootIndex
}

/// Describes a pose detection result.
class Pose {
  /// A map of all the landmarks in the detected pose.
  final Map<PoseLandmarkType, PoseLandmark> landmarks;

  /// Constructor to create an instance of [Pose].
  Pose({required this.landmarks});
}

/// A landmark in a pose detection result.
class PoseLandmark {
  /// The landmark type.
  final PoseLandmarkType type;

  /// Gives x coordinate of landmark in image frame.
  final double x;

  /// Gives y coordinate of landmark in image frame.
  final double y;

  /// Gives z coordinate of landmark in image space.
  final double z;

  /// Gives the likelihood of this landmark being in the image frame.
  final double likelihood;

  /// Constructor to create an instance of [PoseLandmark].
  PoseLandmark({
    required this.type,
    required this.x,
    required this.y,
    required this.z,
    required this.likelihood,
  });

  /// Returns an instance of [PoseLandmark] from a given [json].
  factory PoseLandmark.fromJson(Map<dynamic, dynamic> json) {
    return PoseLandmark(
      type: PoseLandmarkType.values[json['type'].toInt()],
      x: json['x'],
      y: json['y'],
      z: json['z'],
      likelihood: json['likelihood'] ?? 0.0,
    );
  }
}

/// Represents the current state of a bicep curl
enum BicepCurlState {
  /// Initial position with arms extended
  start,
  
  /// Proper form during curl
  goodForm,
  
  /// Elbow is moving away from body
  elbowTooFar,
  
  /// Curl not reaching full contraction
  incompleteCurl,
  
  /// Not enough confidence in pose detection
  lowConfidence,
  
  /// Required landmarks not visible
  invalidPosition
}

/// Stores analysis results for both arms
  class BicepCurlArmsPair {
    final BicepCurlAnalysis left;
    final BicepCurlAnalysis right;

    BicepCurlArmsPair({
      required this.left,
      required this.right,
    });
  }

/// Analyzes bicep curl form using pose detection
class BicepCurlAnalyzer {
  /// Minimum likelihood threshold for landmark detection
  static const double _minConfidence = 0.5;
  
  /// Maximum allowed elbow distance from body (in pixels)
  static const double _maxElbowDistance = 100.0;
  
  /// Minimum angle for complete curl
  static const double _minCurlAngle = 110.0;
  
  /// Maximum upper arm angle deviation from vertical
  static const double _maxUpperArmAngle = 20.0;

  /// Analyzes pose landmarks to determine bicep curl form
  static BicepCurlAnalysis analyzePose(Pose pose, {bool isRightArm = true}) {
    // Get relevant landmarks
    final shoulder = pose.landmarks[isRightArm 
        ? PoseLandmarkType.rightShoulder 
        : PoseLandmarkType.leftShoulder];
    final elbow = pose.landmarks[isRightArm 
        ? PoseLandmarkType.rightElbow 
        : PoseLandmarkType.leftElbow];
    final wrist = pose.landmarks[isRightArm 
        ? PoseLandmarkType.rightWrist 
        : PoseLandmarkType.leftWrist];

    // Check if all required landmarks are detected
    if (shoulder == null || elbow == null || wrist == null) {
      return BicepCurlAnalysis(
        state: BicepCurlState.invalidPosition,
        message: "Cannot detect all required landmarks",
        confidence: 0.0
      );
    }

    // Check confidence levels
    final minLikelihood = [shoulder.likelihood, elbow.likelihood, wrist.likelihood]
        .reduce(min);
    if (minLikelihood < _minConfidence) {
      return BicepCurlAnalysis(
        state: BicepCurlState.lowConfidence,
        message: "Pose detection confidence too low",
        confidence: minLikelihood
      );
    }

    // Calculate key angles and positions
    final upperArmAngle = _calculateVerticalAngle(shoulder, elbow);
    final forearmAngle = _calculateVerticalAngle(elbow, wrist);
    final elbowDistance = (shoulder.x - elbow.x).abs();

    // Create analysis result
    return _analyzeForm(
      upperArmAngle: upperArmAngle,
      forearmAngle: forearmAngle,
      elbowDistance: elbowDistance,
      confidence: minLikelihood
    );
  }

  /// Analyzes both arms simultaneously
  static BicepCurlArmsPair analyzeBothArms(Pose pose) {
    return BicepCurlArmsPair(
      left: analyzePose(pose, isRightArm: false),
      right: analyzePose(pose, isRightArm: true)
    );
  }

  /// Calculates angle between two landmarks relative to vertical
  static double _calculateVerticalAngle(PoseLandmark p1, PoseLandmark p2) {
    final deltaX = p2.x - p1.x;
    final deltaY = p2.y - p1.y;
    var angle = (atan2(deltaX, deltaY) * 180 / pi).abs();
    return angle;
  }

  /// Analyzes form based on calculated measurements
  static BicepCurlAnalysis _analyzeForm({
    required double upperArmAngle,
    required double forearmAngle,
    required double elbowDistance,
    required double confidence
  }) {
    // Check elbow position
    if (elbowDistance > _maxElbowDistance) {
      return BicepCurlAnalysis(
        state: BicepCurlState.elbowTooFar,
        message: "Keep your elbow closer to your body",
        confidence: confidence,
        measurements: BicepCurlMeasurements(
          upperArmAngle: upperArmAngle,
          forearmAngle: forearmAngle,
          elbowDistance: elbowDistance
        )
      );
    }

    // Check starting position
    if (forearmAngle < 30) {
      return BicepCurlAnalysis(
        state: BicepCurlState.start,
        message: "Starting position good. Begin curl",
        confidence: confidence,
        measurements: BicepCurlMeasurements(
          upperArmAngle: upperArmAngle,
          forearmAngle: forearmAngle,
          elbowDistance: elbowDistance
        )
      );
    }

    // Check curl completion
    if (forearmAngle > _minCurlAngle) {
      if (upperArmAngle < _maxUpperArmAngle) {
        return BicepCurlAnalysis(
          state: BicepCurlState.goodForm,
          message: "Good form! Control the movement back down",
          confidence: confidence,
          measurements: BicepCurlMeasurements(
            upperArmAngle: upperArmAngle,
            forearmAngle: forearmAngle,
            elbowDistance: elbowDistance
          )
        );
      } else {
        return BicepCurlAnalysis(
          state: BicepCurlState.elbowTooFar,
          message: "Keep your upper arm vertical",
          confidence: confidence,
          measurements: BicepCurlMeasurements(
            upperArmAngle: upperArmAngle,
            forearmAngle: forearmAngle,
            elbowDistance: elbowDistance
          )
        );
      }
    }

    return BicepCurlAnalysis(
      state: BicepCurlState.incompleteCurl,
      message: "Complete the curl movement",
      confidence: confidence,
      measurements: BicepCurlMeasurements(
        upperArmAngle: upperArmAngle,
        forearmAngle: forearmAngle,
        elbowDistance: elbowDistance
      )
    );
  }
}

/// Stores the analysis results for a bicep curl
class BicepCurlAnalysis {
  /// Current state of the curl
  final BicepCurlState state;
  
  /// Feedback message for the user
  final String message;
  
  /// Confidence level of the analysis
  final double confidence;
  
  /// Detailed measurements (if available)
  final BicepCurlMeasurements? measurements;

  BicepCurlAnalysis({
    required this.state,
    required this.message,
    required this.confidence,
    this.measurements,
  });
}

/// Stores detailed measurements from the analysis
class BicepCurlMeasurements {
  /// Angle of upper arm relative to vertical
  final double upperArmAngle;
  
  /// Angle of forearm relative to vertical
  final double forearmAngle;
  
  /// Distance of elbow from body
  final double elbowDistance;

  BicepCurlMeasurements({
    required this.upperArmAngle,
    required this.forearmAngle,
    required this.elbowDistance,
  });
}

// Example usage
extension PoseDetectorBicepCurl on PoseDetector {
  /// Analyzes bicep curl form from an input image
  Future<List<BicepCurlAnalysis>> analyzeBicepCurl(
    InputImage inputImage, 
    {bool isRightArm = true}
  ) async {
    final poses = await processImage(inputImage);
    return poses.map((pose) => 
      BicepCurlAnalyzer.analyzePose(pose, isRightArm: isRightArm)
    ).toList();
  }
  
  /// Analyzes both arms simultaneously
  Future<List<BicepCurlArmsPair>> analyzeBothArms(InputImage inputImage) async {
    final poses = await processImage(inputImage);
    return poses.map((pose) => 
      BicepCurlAnalyzer.analyzeBothArms(pose)
    ).toList();
  }
}