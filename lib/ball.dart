import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'paddle.dart';
import 'brick.dart';
import 'audio_manager.dart';
import 'ping_pong_game.dart';  // Import the game class to access the bricks list

class Ball extends SpriteComponent with HasGameRef, CollisionCallbacks {
  Vector2 velocity = Vector2(0, 0);  // Initially, the ball doesn't move
  bool isLaunched = false;  // Track whether the ball is launched
  late double upperBound;  // Define an upper boundary for the ball

  Ball({required void Function() onBrickDestroyed});

  @override
  Future<void> onLoad() async {
    sprite = await gameRef.loadSprite('ball.png');
    size = Vector2(26, 26);  // Ball size
    anchor = Anchor.center;

    // Add a circular hitbox
    add(CircleHitbox());

    // Calculate the correct upper bound to bounce back from the first row of bricks
    const double brickHeight = 28;  // Height of each brick
    const double topPadding = 100;  // Top padding space where bricks are drawn
    upperBound = topPadding;  // Set upper bound to the top padding (top of the first row of bricks)
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Move the ball only if it has been launched
    if (isLaunched) {
      position += velocity * dt;

      // Bounce off left and right walls
      if (position.x - size.x / 2 <= 0) {  // Left wall
        velocity.x = -velocity.x;
        position.x = size.x / 2;  // Correct position to prevent getting stuck
      }
      if (position.x + size.x / 2 >= gameRef.size.x) {  // Right wall
        velocity.x = -velocity.x;
        position.x = gameRef.size.x - size.x / 2;  // Correct position to prevent getting stuck
      }
      // Bounce off top boundary (upper bound = first row of bricks)
      if (position.y <= upperBound) {
        velocity.y = -velocity.y;
      }
    }
  }

  // Launch the ball
  void launchBall() {
    if (!isLaunched) {
      velocity = Vector2(150, -150);  // Set ball velocity when launched (moving upwards)
      isLaunched = true;
    }
  }

  bool isOffScreen(Vector2 screenSize) {
    return position.y > screenSize.y;
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    final game = gameRef as PingPongGame;  // Get reference to the game

    // Check if the collision is with a Paddle
    if (other is Paddle) {
      velocity.y = -velocity.y;
      AudioManager.playHitPaddle();
    }
    // Check if the collision is with a Brick
    else if (other is Brick) {
      velocity.y = -velocity.y;
      other.removeFromParent();  // Remove the brick on collision
      game.bricks.remove(other);  // Remove brick from the list
      AudioManager.playHitBrick();  // Play brick hit sound

      // Check if all bricks are destroyed
      if (game.bricks.isEmpty) {
        game.pauseEngine();
        game.showLevelCompletePopup();  // Show level complete popup
      }
    }
  }
}
