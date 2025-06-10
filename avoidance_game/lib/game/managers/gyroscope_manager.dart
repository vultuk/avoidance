import 'dart:async';
import 'dart:math' as math;
import 'package:sensors_plus/sensors_plus.dart';
import '../../utils/constants.dart';

class GyroscopeManager {
  StreamSubscription<GyroscopeEvent>? _gyroscopeSubscription;
  Function(double x, double y)? onGyroscopeUpdate;
  
  // Calibration values
  double _calibrationX = 0;
  double _calibrationY = 0;
  bool _isCalibrated = false;
  
  // Dead zone in radians
  static const double deadZone = GameConstants.gyroscopeDeadZone * (math.pi / 180);
  
  void startListening() {
    _gyroscopeSubscription = gyroscopeEvents.listen((GyroscopeEvent event) {
      if (!_isCalibrated) {
        // Use first reading as calibration baseline
        _calibrationX = event.x;
        _calibrationY = event.y;
        _isCalibrated = true;
        return;
      }
      
      // Apply calibration offset
      double adjustedX = event.x - _calibrationX;
      double adjustedY = event.y - _calibrationY;
      
      // Apply dead zone
      if (adjustedX.abs() < deadZone) adjustedX = 0;
      if (adjustedY.abs() < deadZone) adjustedY = 0;
      
      // Normalize to -1 to 1 range (assuming max rotation of 45 degrees)
      const double maxRotation = math.pi / 4; // 45 degrees in radians
      adjustedX = (adjustedX / maxRotation).clamp(-1.0, 1.0);
      adjustedY = (adjustedY / maxRotation).clamp(-1.0, 1.0);
      
      // Invert Y-axis for more intuitive control (tilt forward = move up)
      adjustedY = -adjustedY;
      
      // Call the update callback
      onGyroscopeUpdate?.call(adjustedX, adjustedY);
    });
  }
  
  void recalibrate() {
    _isCalibrated = false;
  }
  
  void stopListening() {
    _gyroscopeSubscription?.cancel();
    _gyroscopeSubscription = null;
  }
  
  void dispose() {
    stopListening();
  }
}