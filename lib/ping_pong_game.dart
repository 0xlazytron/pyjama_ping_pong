import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'paddle.dart';
import 'ball.dart';
import 'brick.dart';
import 'audio_manager.dart';
import 'package:flutter/material.dart';

class PingPongGame extends FlameGame with HasCollisionDetection, DragCallbacks {
  late Paddle paddle;
  late Ball ball;
  final List<Brick> bricks = [];
  final BuildContext context; // Store the passed context
  int score = 0; // Score variable
  late TextComponent scoreText; // Score display component
  bool isPaused = false; // Track pause state

  // Constructor accepting BuildContext
  PingPongGame(this.context);

  @override
  Future<void> onLoad() async {
    // Load Audio
    await AudioManager.load();
    AudioManager.playBackgroundMusic();

    // Load background
    final bgImage = await Flame.images.load('splashbg.png');
    add(SpriteComponent(sprite: Sprite(bgImage), size: size));

    // Add ball first and position it on top of the paddle initially
    ball = Ball(onBrickDestroyed: onBrickDestroyed) // Pass the callback for brick destruction
      ..anchor = Anchor.center;
    add(ball);  // Add the ball before the paddle

    // Add paddle and assign ball reference to it
    paddle = Paddle(ball: ball) // Pass the ball reference
      ..position = Vector2(size.x / 2, size.y - 50) // Paddle near the bottom
      ..anchor = Anchor.center;
    add(paddle);

    // Position the ball slightly above the paddle after adding the paddle
    ball.position = Vector2(paddle.x, paddle.y - paddle.size.y / 2 - ball.size.y / 2 - 2); // 2px gap above paddle

    // Add bricks with left padding for better positioning
    const int brickColumns = 6;  // Number of columns
    const int brickRows = 6;     // Number of rows
    const double brickWidth = 58;
    const double brickHeight = 28;
    const double topPadding = 100;  // Space for header
    const double leftPadding = 10;  // Add some space from the left side

    // Add bricks
    for (int i = 0; i < brickColumns; i++) {
      for (int j = 0; j < brickRows; j++) {
        final brick = Brick()
          ..position = Vector2(leftPadding + i * brickWidth, topPadding + j * brickHeight)
          ..anchor = Anchor.topLeft; // Origin is top-left for bricks
        bricks.add(brick);
        add(brick);
      }
    }

    // Add score and buttons
    addScoreText();
    // addPauseButton();
    // addSettingsButton();
  }

  // Method to add score text to the game
  // Method to add score text to the game
  void addScoreText() {
    const double marginFromTop = 20.0; // Add some margin from the top
    const double topPadding = 76;   // The top padding where bricks are drawn

    final scoreText = TextComponent(
      text: 'Score: $score',
      textRenderer: TextPaint(
        style: const TextStyle(fontSize: 20, color: Colors.white),
      ),
      anchor: Anchor.topLeft,
      position: Vector2(10, topPadding - marginFromTop),  // Positioned above the first brick row with some margin
    );

    add(scoreText);
  }


  // Method to update the score text in real-time
  void updateScoreText() {
    scoreText.text = 'Score: $score'; // Update the score display
  }

  // Method to add the pause button
  // void addPauseButton() {
  //   final pauseButton = TextComponent(
  //     text: 'Pause',
  //     textRenderer: TextPaint(style: TextStyle(fontSize: 20, color: Colors.white)),
  //     position: Vector2(size.x - 100, 10), // Positioned at the top-right
  //     anchor: Anchor.topRight,
  //   );
  //
  //   pauseButton.add(TapCallbacks(onTapDown: (event) {
  //     pauseEngine();
  //     showPauseMenu(); // Show the pause menu
  //   }));
  //
  //   add(pauseButton);
  // }

  // Method to add the settings button
  // void addSettingsButton() {
  //   final settingsButton = TextComponent(
  //     text: 'Settings',
  //     textRenderer: TextPaint(style: TextStyle(fontSize: 20, color: Colors.white)),
  //     position: Vector2(size.x - 180, 10), // Positioned next to the pause button
  //     anchor: Anchor.topRight,
  //   );
  //
  //   settingsButton.add(TapCallbacks(onTapDown: (event) {
  //     showSettingsMenu(); // Show the settings menu
  //   }));
  //
  //   add(settingsButton);
  // }

  // Show Pause Menu
  void showPauseMenu() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Paused'),
          content: const Text('Game is paused.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Resume'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close the dialog
                resumeEngine(); // Resume the game
              },
            ),
            TextButton(
              child: const Text('Exit'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close the dialog
                exitGame(); // Exit the game
              },
            ),
          ],
        );
      },
    );
  }

  // Show Settings Menu
  void showSettingsMenu() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Settings'),
          content: const Text('Toggle sound or exit the game.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Toggle Sound'),
              onPressed: () {
                AudioManager.pauseBackgroundMusic(); // Pause the background music
                Navigator.of(dialogContext).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text('Exit'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close the dialog
                exitGame(); // Exit the game
              },
            ),
          ],
        );
      },
    );
  }

  // Method to handle the destruction of bricks
  void onBrickDestroyed() {
    score += 10; // Increment score by 10 for each brick destroyed
    updateScoreText(); // Update score in real-time
  }

  // Exit the game logic
  void exitGame() {
    // Exit game logic here
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Check for game over (when ball is off-screen)
    if (ball.isOffScreen(size)) {
      pauseEngine();
      showGameOverPopup(); // Show the Game Over popup
    }

    // Check for level complete (all bricks destroyed)
    if (bricks.isEmpty) {
      pauseEngine(); // Stop game updates
      showLevelCompletePopup(); // Show level complete popup
    }
  }

  // Show the "Level Complete" dialog
  void showLevelCompletePopup() {
    AudioManager.pauseBackgroundMusic(); // Pause music on level complete
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Level Complete!'),
          content: const Text('You have successfully cleared this level.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Next Level'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close the dialog
                resetGameForNextLevel(); // Reset for the next level
                AudioManager.resumeBackgroundMusic(); // Resume music when the next level starts
              },
            ),
          ],
        );
      },
    );
  }

  // Show the "Game Over" dialog
  void showGameOverPopup() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Game Over!'),
          content: const Text('You missed the ball. Try again?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Retry'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close the dialog
                resetGame(); // Reset the game from the beginning
              },
            ),
          ],
        );
      },
    );
  }

  // Reset the game for the next level
  void resetGameForNextLevel() {
    bricks.clear();
    remove(ball);
    remove(paddle);
    onLoad(); // Reload components
    resumeEngine(); // Restart the game engine
  }

  // Reset the entire game for retry (restart from beginning)
  void resetGame() {
    bricks.clear();
    remove(ball);
    remove(paddle);
    onLoad(); // Reload components
    resumeEngine();
  }
}
