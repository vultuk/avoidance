import 'package:flame/components.dart';
import '../../utils/constants.dart';

class ScoreManager extends Component {
  final Difficulty difficulty;
  double _elapsedTime = 0;
  int _currentScore = 0;
  
  int get currentScore => _currentScore;
  
  ScoreManager({required this.difficulty});

  @override
  void update(double dt) {
    _elapsedTime += dt;
    
    // Update score based on elapsed time and difficulty multiplier
    final secondsSurvived = _elapsedTime.floor();
    _currentScore = secondsSurvived * GameConstants.baseScorePerSecond * difficulty.scoreMultiplier;
  }
  
  void reset() {
    _elapsedTime = 0;
    _currentScore = 0;
  }
}