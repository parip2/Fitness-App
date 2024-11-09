import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'detector_view.dart';
import 'painters/pose_painter.dart';

class PushupDetectorView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _PushupDetectorViewState();
}

class _PushupDetectorViewState extends State<PushupDetectorView> {
  final PoseDetector _poseDetector =
      PoseDetector(options: PoseDetectorOptions());
  final PushUpSequenceAnalyzer _sequenceAnalyzer = PushUpSequenceAnalyzer();
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  String? _text;
  var _cameraLensDirection = CameraLensDirection.back;
  
  // Store the latest analysis results
  PushUpSequenceAnalysis? _currentSequenceAnalysis;
  PushUpAnalysis? _currentPoseAnalysis;

  @override
  void dispose() async {
    _canProcess = false;
    _poseDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        DetectorView(
          title: 'Push-up Detector',
          customPaint: _customPaint,
          text: _text,
          onImage: _processImage,
          initialCameraLensDirection: _cameraLensDirection,
          onCameraLensDirectionChanged: (value) => _cameraLensDirection = value,
        ),
        if (_currentPoseAnalysis != null) _buildFormFeedbackOverlay(),
        _buildRepCounter(),
        if (_currentSequenceAnalysis != null) _buildStageIndicator(),
      ],
    );
  }

  Widget _buildFormFeedbackOverlay() {
    final measurements = _currentPoseAnalysis!.measurements;
    final List<_FormMetric> metrics = measurements != null ? [
      _FormMetric(
        icon: Icons.straighten,
        label: 'Back Angle',
        value: '${measurements.backAngle.toStringAsFixed(1)}°',
        isGood: measurements.backAngle <= 15.0,
      ),
      _FormMetric(
        icon: Icons.compass_calibration,
        label: 'Elbow Angle',
        value: '${((measurements.leftElbowAngle + measurements.rightElbowAngle) / 2).toStringAsFixed(1)}°',
        isGood: (measurements.leftElbowAngle + measurements.rightElbowAngle) / 2 >= 75 &&
                (measurements.leftElbowAngle + measurements.rightElbowAngle) / 2 <= 105,
      ),
    ] : [];

    return Positioned(
      top: 100,
      left: 20,
      right: 20,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStateColor(_currentPoseAnalysis!.state),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _getStateDisplay(_currentPoseAnalysis!.state),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _currentSequenceAnalysis?.message ?? _currentPoseAnalysis!.message,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            if (metrics.isNotEmpty) ...[
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: metrics.map(_buildMetricDisplay).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

   Widget _buildMetricDisplay(_FormMetric metric) {
    return Column(
      children: [
        Icon(
          metric.icon,
          color: metric.isGood ? Colors.green : Colors.orange,
          size: 24,
        ),
        SizedBox(height: 4),
        Text(
          metric.label,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        Text(
          metric.value,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildStageIndicator() {
    final stage = _currentSequenceAnalysis!.sequenceState.currentStage;
    
    return Positioned(
      bottom: 100,
      left: 20,
      right: 20,
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: PushUpStage.values.map((s) {
            final isActive = s == stage;
            final icon = _getStageIcon(s);
            return Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isActive ? Colors.blue : Colors.grey.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isActive ? Colors.white : Colors.white54,
                size: 24,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  IconData _getStageIcon(PushUpStage stage) {
    switch (stage) {
      case PushUpStage.start:
        return Icons.fitness_center;
      case PushUpStage.descending:
        return Icons.arrow_downward;
      case PushUpStage.bottom:
        return Icons.horizontal_rule;
      case PushUpStage.ascending:
        return Icons.arrow_upward;
      case PushUpStage.invalid:
        return Icons.error_outline;
    }
  }

  Widget _buildRepCounter() {
    final repCount = _currentSequenceAnalysis?.sequenceState.repCount ?? 0;
    final goodForm = _currentSequenceAnalysis?.sequenceState.goodFormMaintained ?? true;
    
    return Positioned(
      top: 40,
      right: 20,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.fitness_center,
              color: goodForm ? Colors.green : Colors.orange,
            ),
            SizedBox(width: 8),
            Text(
              '$repCount',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStateColor(PushUpState state) {
    switch (state) {
      case PushUpState.goodForm:
        return Colors.green;
      case PushUpState.plank:
        return Colors.blue;
      case PushUpState.improperBackAlignment:
      case PushUpState.insufficientDepth:
      case PushUpState.improperArmPosition:
        return Colors.orange;
      case PushUpState.lowConfidence:
      case PushUpState.invalidPosition:
        return Colors.red;
    }
  }

  String _getStateDisplay(PushUpState state) {
    switch (state) {
      case PushUpState.goodForm:
        return '✓ GOOD FORM';
      case PushUpState.plank:
        return '⟳ PLANK';
      case PushUpState.improperBackAlignment:
        return '⚠ BACK';
      case PushUpState.insufficientDepth:
        return '⚠ DEPTH';
      case PushUpState.improperArmPosition:
        return '⚠ ARMS';
      case PushUpState.lowConfidence:
        return '? UNCLEAR';
      case PushUpState.invalidPosition:
        return '× INVALID';
    }
  }

  Future<void> _processImage(InputImage inputImage) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;
    
    setState(() {
      _text = '';
    });

    try {
      final poses = await _poseDetector.processImage(inputImage);
      
      if (poses.isNotEmpty) {
        // Get both pose and sequence analysis
        final poseAnalysis = PushUpAnalyzer.analyzePose(poses.first);
        final sequenceAnalysis = _sequenceAnalyzer.analyzeFrame(poseAnalysis);
        
        setState(() {
          _currentPoseAnalysis = poseAnalysis;
          _currentSequenceAnalysis = sequenceAnalysis;
        });
      } else {
        setState(() {
          _currentPoseAnalysis = null;
          _currentSequenceAnalysis = null;
        });
      }

      if (inputImage.metadata?.size != null &&
          inputImage.metadata?.rotation != null) {
        final painter = PosePainter(
          poses,
          inputImage.metadata!.size,
          inputImage.metadata!.rotation,
          _cameraLensDirection,
        );
        _customPaint = CustomPaint(painter: painter);
      } else {
        _text = 'Poses found: ${poses.length}\n\n';
        _customPaint = null;
      }
    } finally {
      _isBusy = false;
      if (mounted) {
        setState(() {});
      }
    }
  }
}

class _FormMetric {
  final IconData icon;
  final String label;
  final String value;
  final bool isGood;

  _FormMetric({
    required this.icon,
    required this.label,
    required this.value,
    required this.isGood,
  });
}