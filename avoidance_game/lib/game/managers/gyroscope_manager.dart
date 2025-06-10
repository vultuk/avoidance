import 'dart:async';
import 'dart:math' as math;
import 'package:sensors_plus/sensors_plus.dart';
import '../../utils/constants.dart';

class GyroscopeManager {
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  Function(double x, double y)? onGyroscopeUpdate;
  
  // Calibration values
  double _calibrationX = 0;
  double _calibrationY = 0;
  bool _isCalibrated = false;
  
  // Dead zone in radians
  static const double deadZone = GameConstants.gyroscopeDeadZone * (math.pi / 180);
  
  void startListening() {
    try {
      _accelerometerSubscription = accelerometerEvents.listen(
        (AccelerometerEvent event) {
          // Accelerometer gives us device tilt
          // x: left/right tilt (positive = right)
          // y: forward/backward tilt (positive = backward)
          // z: up/down acceleration (ignore for 2D movement)
          
          // Use X and Y directly for movement
          // Normalize to -1 to 1 range (gravity is ~9.8 m/s²)
          double adjustedX = (event.x / 9.8).clamp(-1.0, 1.0);
          double adjustedY = (-event.y / 9.8).clamp(-1.0, 1.0); // Invert Y for intuitive control
          
          // Apply dead zone
          if (adjustedX.abs() < 0.1) adjustedX = 0;
          if (adjustedY.abs() < 0.1) adjustedY = 0;
          
          // Call the update callback
          onGyroscopeUpdate?.call(adjustedX, adjustedY);
        },
        onError: (error) {
          print('Accelerometer error: $error');
          // Accelerometer not available, do nothing
        },
      );
    } catch (e) {
      print('Failed to initialize accelerometer: $e');
      // Accelerometer not available, do nothing
    }
  }
  
  void recalibrate() {
    _isCalibrated = false;
  }
  
  void stopListening() {
    _accelerometerSubscription?.cancel();
    _accelerometerSubscription = null;
  }
  
  void dispose() {
    stopListening();
  }
}