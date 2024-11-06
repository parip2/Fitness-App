import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'detector_view.dart';
import 'painters/pose_painter.dart';

class BicepsDetectorView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _PoseDetectorViewState();
}

class _PoseDetectorViewState extends State<BicepsDetectorView> {
  final PoseDetector _poseDetector =
      PoseDetector(options: PoseDetectorOptions());
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  String? _text;
  var _cameraLensDirection = CameraLensDirection.back;
  
  // Store the latest analysis results
  BicepCurlAnalysis? _rightArmAnalysis;
  BicepCurlAnalysis? _leftArmAnalysis;

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
          title: 'Pose Detector',
          customPaint: _customPaint,
          text: _text,
          onImage: _processImage,
          initialCameraLensDirection: _cameraLensDirection,
          onCameraLensDirectionChanged: (value) => _cameraLensDirection = value,
        ),
        if (_rightArmAnalysis != null || _leftArmAnalysis != null)
          Positioned(
            top: 100,
            left: 20,
            right: 20,
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_rightArmAnalysis != null) ...[
                    Text(
                      'Right Arm: ${_getStateEmoji(_rightArmAnalysis!.state)}',
                      style: TextStyle(
                        color: _getStateColor(_rightArmAnalysis!.state),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _rightArmAnalysis!.message,
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    SizedBox(height: 8),
                  ],
                  if (_leftArmAnalysis != null) ...[
                    Text(
                      'Left Arm: ${_getStateEmoji(_leftArmAnalysis!.state)}',
                      style: TextStyle(
                        color: _getStateColor(_leftArmAnalysis!.state),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _leftArmAnalysis!.message,
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }

  Color _getStateColor(BicepCurlState state) {
    switch (state) {
      case BicepCurlState.goodForm:
        return Colors.green;
      case BicepCurlState.start:
        return Colors.blue;
      case BicepCurlState.elbowTooFar:
      case BicepCurlState.incompleteCurl:
        return Colors.orange;
      case BicepCurlState.lowConfidence:
      case BicepCurlState.invalidPosition:
        return Colors.red;
    }
  }

  String _getStateEmoji(BicepCurlState state) {
    switch (state) {
      case BicepCurlState.goodForm:
        return '✅';
      case BicepCurlState.start:
        return '👉';
      case BicepCurlState.elbowTooFar:
        return '⚠️';
      case BicepCurlState.incompleteCurl:
        return '⬆️';
      case BicepCurlState.lowConfidence:
        return '❓';
      case BicepCurlState.invalidPosition:
        return '❌';
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
        // Analyze each arm separately
        _leftArmAnalysis = BicepCurlAnalyzer.analyzePose(
          poses.first, 
          isRightArm: false
        );
        _rightArmAnalysis = BicepCurlAnalyzer.analyzePose(
          poses.first, 
          isRightArm: true
        );
            
        setState(() {});
      } else {
        setState(() {
          _leftArmAnalysis = null;
          _rightArmAnalysis = null;
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