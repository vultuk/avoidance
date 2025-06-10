import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../utils/storage.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({Key? key}) : super(key: key);

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  Difficulty _selectedDifficulty = Difficulty.easy;
  List<int> _scores = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadScores();
  }

  Future<void> _loadScores() async {
    setState(() => _isLoading = true);
    final scores = await Storage.getTopScores(_selectedDifficulty);
    setState(() {
      _scores = scores;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameColors.background,
      appBar: AppBar(
        backgroundColor: GameColors.background,
        elevation: 0,
        title: const Text(
          'LEADERBOARD',
          style: TextStyle(
            color: GameColors.uiText,
            fontSize: GameSizes.titleFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: GameColors.uiText),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Difficulty selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: Difficulty.values.map((difficulty) {
                final isSelected = difficulty == _selectedDifficulty;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedDifficulty = difficulty);
                    _loadScores();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? difficulty == Difficulty.easy
                              ? GameColors.blue
                              : difficulty == Difficulty.medium
                                  ? GameColors.orange
                                  : difficulty == Difficulty.hard
                                      ? GameColors.powerUpGreen
                                      : Colors.purple
                          : Colors.transparent,
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : GameColors.uiText.withOpacity(0.3),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      difficulty.displayName,
                      style: TextStyle(
                        color: isSelected
                            ? GameColors.background
                            : GameColors.uiText,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),
          // Scores list
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: GameColors.uiText,
                    ),
                  )
                : _scores.isEmpty
                    ? Center(
                        child: Text(
                          'No scores yet!\nBe the first to play!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: GameColors.uiText.withOpacity(0.5),
                            fontSize: 18,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _scores.length,
                        itemBuilder: (context, index) {
                          final rank = index + 1;
                          final score = _scores[index];
                          Color rankColor = GameColors.uiText;
                          
                          // Special colors for top 3
                          if (rank == 1) rankColor = Colors.amber;
                          else if (rank == 2) rankColor = Colors.grey[300]!;
                          else if (rank == 3) rankColor = Colors.brown[300]!;
                          
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: GameColors.uiText.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: rank <= 3
                                    ? rankColor.withOpacity(0.5)
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Row(
                              children: [
                                // Rank
                                Container(
                                  width: 40,
                                  alignment: Alignment.center,
                                  child: Text(
                                    '#$rank',
                                    style: TextStyle(
                                      color: rankColor,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                // Score
                                Expanded(
                                  child: Text(
                                    score.toString(),
                                    style: const TextStyle(
                                      color: GameColors.uiText,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                                // Multiplier indicator
                                Text(
                                  '×${_selectedDifficulty.scoreMultiplier}',
                                  style: TextStyle(
                                    color: GameColors.uiText.withOpacity(0.5),
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}