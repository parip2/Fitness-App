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
        message: 'Cannot detect all required landmarks',
        confidence: 0.0
      );
    }

    // Check confidence levels
    final minLikelihood = [shoulder.likelihood, elbow.likelihood, wrist.likelihood]
        .reduce(min);
    if (minLikelihood < _minConfidence) {
      return BicepCurlAnalysis(
        state: BicepCurlState.lowConfidence,
        message: 'Pose detection confidence too low',
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
    final angle = (atan2(deltaX, deltaY) * 180 / pi).abs();
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
        message: 'Keep your elbow closer to your body',
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
        message: 'Starting position good. Begin curl',
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
          message: 'Good form! Control the movement back down',
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
          message: 'Keep your upper arm vertical',
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
      message: 'Complete the curl movement',
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
    return poses.map(BicepCurlAnalyzer.analyzeBothArms
    ).toList();
  }
}

/// Represents the current state of a push-up
enum PushUpState {
  /// Starting/ending plank position
  plank,
  
  /// Proper form during descent/ascent
  goodForm,
  
  /// Back is sagging or hips are too high
  improperBackAlignment,
  
  /// Not reaching proper depth (90° elbow angle)
  insufficientDepth,
  
  /// Arms too wide or too narrow
  improperArmPosition,
  
  /// Not enough confidence in pose detection
  lowConfidence,
  
  /// Required landmarks not visible
  invalidPosition
}

/// Analyzes push-up form using pose detection
class PushUpAnalyzer {
  /// Minimum likelihood threshold for landmark detection
  static const double _minConfidence = 0.5;
  
  /// Ideal angle for elbows at bottom of push-up
  static const double _targetElbowAngle = 90.0;
  
  /// Allowable deviation from target angle
  static const double _angleThreshold = 15.0;
  
  /// Maximum allowable back angle deviation from horizontal
  static const double _maxBackAngle = 20.0;

  /// Analyzes pose landmarks to determine push-up form
  static PushUpAnalysis analyzePose(Pose pose) {
    // Get relevant landmarks for form analysis
    final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    final leftElbow = pose.landmarks[PoseLandmarkType.leftElbow];
    final rightElbow = pose.landmarks[PoseLandmarkType.rightElbow];
    final leftWrist = pose.landmarks[PoseLandmarkType.leftWrist];
    final rightWrist = pose.landmarks[PoseLandmarkType.rightWrist];
    final leftHip = pose.landmarks[PoseLandmarkType.leftHip];
    final rightHip = pose.landmarks[PoseLandmarkType.rightHip];
    final leftAnkle = pose.landmarks[PoseLandmarkType.leftAnkle];
    final rightAnkle = pose.landmarks[PoseLandmarkType.rightAnkle];

    // Check if all required landmarks are detected
    final requiredLandmarks = [
      leftShoulder, rightShoulder, leftElbow, rightElbow,
      leftWrist, rightWrist, leftHip, rightHip, leftAnkle, rightAnkle
    ];
    
    if (requiredLandmarks.any((landmark) => landmark == null)) {
      return PushUpAnalysis(
        state: PushUpState.invalidPosition,
        message: 'Cannot detect all required landmarks',
        confidence: 0.0
      );
    }

    // Check confidence levels
    final minLikelihood = requiredLandmarks
        .map((landmark) => landmark!.likelihood)
        .reduce(min);
    
    if (minLikelihood < _minConfidence) {
      return PushUpAnalysis(
        state: PushUpState.lowConfidence,
        message: 'Pose detection confidence too low',
        confidence: minLikelihood
      );
    }

    // Calculate key measurements
    final backAngle = _calculateBackAngle(
      leftShoulder!, rightShoulder!, leftHip!, rightHip!);
    final leftElbowAngle = _calculateElbowAngle(
      leftShoulder, leftElbow!, leftWrist!);
    final rightElbowAngle = _calculateElbowAngle(
      rightShoulder, rightElbow!, rightWrist!);
    final armWidthRatio = _calculateArmWidthRatio(
      leftShoulder, rightShoulder, leftWrist, rightWrist);

    // Store measurements
    final measurements = PushUpMeasurements(
      backAngle: backAngle,
      leftElbowAngle: leftElbowAngle,
      rightElbowAngle: rightElbowAngle,
      armWidthRatio: armWidthRatio
    );

    // Analyze form
    return _analyzeForm(
      measurements: measurements,
      confidence: minLikelihood
    );
  }

  /// Calculates angle of the back relative to horizontal
  static double _calculateBackAngle(
    PoseLandmark leftShoulder,
    PoseLandmark rightShoulder,
    PoseLandmark leftHip,
    PoseLandmark rightHip
  ) {
    final shoulderMidX = (leftShoulder.x + rightShoulder.x) / 2;
    final shoulderMidY = (leftShoulder.y + rightShoulder.y) / 2;
    final hipMidX = (leftHip.x + rightHip.x) / 2;
    final hipMidY = (leftHip.y + rightHip.y) / 2;
    
    return (atan2(shoulderMidY - hipMidY, shoulderMidX - hipMidX) * 180 / pi).abs();
  }

  /// Calculates elbow angle
  static double _calculateElbowAngle(
    PoseLandmark shoulder,
    PoseLandmark elbow,
    PoseLandmark wrist
  ) {
    final vec1x = shoulder.x - elbow.x;
    final vec1y = shoulder.y - elbow.y;
    final vec2x = wrist.x - elbow.x;
    final vec2y = wrist.y - elbow.y;
    
    final dot = vec1x * vec2x + vec1y * vec2y;
    final mag1 = sqrt(vec1x * vec1x + vec1y * vec1y);
    final mag2 = sqrt(vec2x * vec2x + vec2y * vec2y);
    
    return acos(dot / (mag1 * mag2)) * 180 / pi;
  }

  /// Calculates ratio of arm width to shoulder width
  static double _calculateArmWidthRatio(
    PoseLandmark leftShoulder,
    PoseLandmark rightShoulder,
    PoseLandmark leftWrist,
    PoseLandmark rightWrist
  ) {
    final shoulderWidth = sqrt(
      pow(rightShoulder.x - leftShoulder.x, 2) +
      pow(rightShoulder.y - leftShoulder.y, 2)
    );
    
    final armWidth = sqrt(
      pow(rightWrist.x - leftWrist.x, 2) +
      pow(rightWrist.y - leftWrist.y, 2)
    );
    
    return armWidth / shoulderWidth;
  }

  /// Analyzes form based on calculated measurements
  static PushUpAnalysis _analyzeForm({
    required PushUpMeasurements measurements,
    required double confidence
  }) {
    // Check back alignment
    if ((measurements.backAngle > _maxBackAngle - 2.5) && (measurements.backAngle < _maxBackAngle + 2.5)) {
      return PushUpAnalysis(
        state: PushUpState.improperBackAlignment,
        message: 'Keep your back straight - avoid sagging or lifting hips',
        confidence: confidence,
        measurements: measurements
      );
    }

    // Check arm position
    // if (measurements.armWidthRatio > _targetArmWidthRatio * 1.2  ||
    //     measurements.armWidthRatio < _targetArmWidthRatio * 0.8) {
    //   return PushUpAnalysis(
    //     state: PushUpState.improperArmPosition,
    //     message: 'Adjust hand position - should be slightly wider than shoulders',
    //     confidence: confidence,
    //     measurements: measurements
    //   );
    // }

    // Check depth using elbow angles
    final avgElbowAngle = (measurements.leftElbowAngle + 
        measurements.rightElbowAngle) / 2;
    
    if ((avgElbowAngle - _targetElbowAngle).abs() <= _angleThreshold) {
      return PushUpAnalysis(
        state: PushUpState.goodForm,
        message: 'Good form! Maintain controlled movement',
        confidence: confidence,
        measurements: measurements
      );
    }
    
    if (avgElbowAngle > _targetElbowAngle + _angleThreshold) {
      return PushUpAnalysis(
        state: PushUpState.insufficientDepth,
        message: 'Lower your chest - aim for 90° elbow angle',
        confidence: confidence,
        measurements: measurements
      );
    }

    // Must be in starting/ending position
    return PushUpAnalysis(
      state: PushUpState.plank,
      message: 'Maintain plank position - begin push-up',
      confidence: confidence,
      measurements: measurements
    );
  }
}

/// Stores the analysis results for a push-up
class PushUpAnalysis {
  /// Current state of the push-up
  final PushUpState state;
  
  /// Feedback message for the user
  final String message;
  
  /// Confidence level of the analysis
  final double confidence;
  
  /// Detailed measurements (if available)
  final PushUpMeasurements? measurements;

  PushUpAnalysis({
    required this.state,
    required this.message,
    required this.confidence,
    this.measurements,
  });
}

/// Stores detailed measurements from the push-up analysis
class PushUpMeasurements {
  /// Angle of back relative to horizontal
  final double backAngle;
  
  /// Angle at left elbow
  final double leftElbowAngle;
  
  /// Angle at right elbow
  final double rightElbowAngle;
  
  /// Ratio of arm width to shoulder width
  final double armWidthRatio;

  PushUpMeasurements({
    required this.backAngle,
    required this.leftElbowAngle,
    required this.rightElbowAngle,
    required this.armWidthRatio,
  });
}

// Extension method for easy usage
extension PoseDetectorPushUp on PoseDetector {
  /// Analyzes push-up form from an input image
  Future<List<PushUpAnalysis>> analyzePushUp(InputImage inputImage) async {
    final poses = await processImage(inputImage);
    return poses.map(PushUpAnalyzer.analyzePose).toList();
  }
}

/// Represents stages in a push-up repetition
enum PushUpStage {
  /// Starting position in high plank
  start,
  
  /// Descending phase of the push-up
  descending,
  
  /// Bottom position with proper depth
  bottom,
  
  /// Ascending phase of the push-up
  ascending,
  
  /// Invalid or unrecognized position
  invalid
}

/// Tracks the state of a push-up sequence
class PushUpSequenceState {
  /// Current stage of the push-up
  PushUpStage currentStage;
  
  /// Number of completed repetitions
  int repCount;
  
  /// Whether the current rep has reached proper depth
  bool properDepthReached;
  
  /// Whether form was maintained throughout the rep
  bool goodFormMaintained;
  
  /// Timestamp of last stage change
  DateTime lastStageChange;
  
  /// History of form issues in current rep
  List<String> formIssues;

  PushUpSequenceState({
    this.currentStage = PushUpStage.start,
    this.repCount = 0,
    this.properDepthReached = false,
    this.goodFormMaintained = true,
    DateTime? lastStageChange,
    List<String>? formIssues,
  }) : 
    lastStageChange = lastStageChange ?? DateTime.now(),
    formIssues = formIssues ?? [];

  PushUpSequenceState copyWith({
    PushUpStage? currentStage,
    int? repCount,
    bool? properDepthReached,
    bool? goodFormMaintained,
    DateTime? lastStageChange,
    List<String>? formIssues,
  }) {
    return PushUpSequenceState(
      currentStage: currentStage ?? this.currentStage,
      repCount: repCount ?? this.repCount,
      properDepthReached: properDepthReached ?? this.properDepthReached,
      goodFormMaintained: goodFormMaintained ?? this.goodFormMaintained,
      lastStageChange: lastStageChange ?? this.lastStageChange,
      formIssues: formIssues ?? this.formIssues,
    );
  }
}

/// Analyzes a sequence of push-ups across multiple frames
class PushUpSequenceAnalyzer {
  /// Minimum duration required for each stage (in milliseconds)
  static const int _minStageDuration = 200;
  
  /// Maximum duration allowed for each stage (in milliseconds)
  static const int _maxStageDuration = 3000;
  
  /// Angle thresholds for different stages
  static const double _startAngleThreshold = 160.0;
  static const double _bottomAngleThreshold = 90.0;
  static const double _angleBuffer = 15.0;

  /// Current state of the sequence
  PushUpSequenceState _state = PushUpSequenceState();

  /// Gets the current sequence state
  PushUpSequenceState get currentState => _state;

  /// Analyzes a single frame and updates sequence state
  PushUpSequenceAnalysis analyzeFrame(PushUpAnalysis frameAnalysis) {
    final DateTime now = DateTime.now();
    final measurements = frameAnalysis.measurements;
    
    if (measurements == null || 
        frameAnalysis.state == PushUpState.invalidPosition || 
        frameAnalysis.state == PushUpState.lowConfidence) {
      return PushUpSequenceAnalysis(
        sequenceState: _state,
        message: 'Unable to detect pose clearly',
        confidence: frameAnalysis.confidence,
      );
    }

    // Track form issues
    if (frameAnalysis.state != PushUpState.goodForm && 
        frameAnalysis.state != PushUpState.plank) {
      if (!_state.formIssues.contains(frameAnalysis.message)) {
        _state.formIssues.add(frameAnalysis.message);
      }
      _state.goodFormMaintained = false;
    }

    // Calculate average elbow angle
    final avgElbowAngle = (measurements.leftElbowAngle + 
        measurements.rightElbowAngle) / 2;

    // Determine new stage and update state
    final newStage = _determineStage(avgElbowAngle);
    final stageDuration = now.difference(_state.lastStageChange).inMilliseconds;
    
    if (newStage != _state.currentStage && stageDuration >= _minStageDuration) {
      _handleStageTransition(newStage, now);
    }

    // Check if proper depth is reached
    if (avgElbowAngle <= _bottomAngleThreshold + _angleBuffer) {
      _state.properDepthReached = true;
    }

    return _generateSequenceAnalysis(frameAnalysis.confidence);
  }

  /// Determines the push-up stage based on elbow angle
  PushUpStage _determineStage(double elbowAngle) {
    if (elbowAngle >= _startAngleThreshold - _angleBuffer) {
      return PushUpStage.start;
    } else if (elbowAngle <= _bottomAngleThreshold + _angleBuffer) {
      return PushUpStage.bottom;
    } else if (_state.currentStage == PushUpStage.start || 
               _state.currentStage == PushUpStage.descending) {
      return PushUpStage.descending;
    } else {
      return PushUpStage.ascending;
    }
  }

  /// Handles transitions between stages
  void _handleStageTransition(PushUpStage newStage, DateTime now) {
    final stageDuration = now.difference(_state.lastStageChange).inMilliseconds;
    
    // Check if the transition is valid
    if (_isValidTransition(_state.currentStage, newStage) && 
        stageDuration <= _maxStageDuration) {
      
      // Check for completed rep
      if (_state.currentStage == PushUpStage.ascending && 
          newStage == PushUpStage.start &&
          _state.properDepthReached) {
        _state.repCount++;
        _state.properDepthReached = false;
        _state.goodFormMaintained = true;
        _state.formIssues.clear();
      }
      
      _state.currentStage = newStage;
      _state.lastStageChange = now;
    }
  }

  /// Checks if the stage transition is valid
  bool _isValidTransition(PushUpStage current, PushUpStage next) {
    switch (current) {
      case PushUpStage.start:
        return next == PushUpStage.descending;
      case PushUpStage.descending:
        return next == PushUpStage.bottom;
      case PushUpStage.bottom:
        return next == PushUpStage.ascending;
      case PushUpStage.ascending:
        return next == PushUpStage.start;
      case PushUpStage.invalid:
        return true;
    }
  }

  /// Generates analysis results for the current sequence
  PushUpSequenceAnalysis _generateSequenceAnalysis(double confidence) {
    String message;
    
    switch (_state.currentStage) {
      case PushUpStage.start:
        message = 'In starting position. Begin descent when ready.';
        break;
      case PushUpStage.descending:
        message = 'Lowering - maintain controlled descent.';
        break;
      case PushUpStage.bottom:
        message = 'Good depth - now push up.';
        break;
      case PushUpStage.ascending:
        message = 'Pushing up - maintain form.';
        break;
      case PushUpStage.invalid:
        message = 'Position not recognized.';
        break;
    }

    if (!_state.formIssues.isEmpty) {
      message += ' Form issues: ${_state.formIssues.join(", ")}';
    }

    return PushUpSequenceAnalysis(
      sequenceState: _state,
      message: message,
      confidence: confidence,
    );
  }

  /// Resets the sequence state
  void reset() {
    _state = PushUpSequenceState();
  }
}

/// Results of analyzing a push-up sequence
class PushUpSequenceAnalysis {
  /// Current state of the sequence
  final PushUpSequenceState sequenceState;
  
  /// Feedback message for the user
  final String message;
  
  /// Confidence level of the analysis
  final double confidence;

  PushUpSequenceAnalysis({
    required this.sequenceState,
    required this.message,
    required this.confidence,
  });
}

// Extension method for the PoseDetector
extension PoseDetectorPushUpSequence on PoseDetector {
  /// Analyzes a sequence of push-ups from input images
  Future<PushUpSequenceAnalysis> analyzePushUpSequence(
    InputImage inputImage,
    PushUpSequenceAnalyzer sequenceAnalyzer,
  ) async {
    final poses = await processImage(inputImage);
    if (poses.isEmpty) {
      return PushUpSequenceAnalysis(
        sequenceState: sequenceAnalyzer.currentState,
        message: 'No pose detected',
        confidence: 0.0,
      );
    }
    
    final frameAnalysis = PushUpAnalyzer.analyzePose(poses.first);
    return sequenceAnalyzer.analyzeFrame(frameAnalysis);
  }
}