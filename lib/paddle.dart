import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'ball.dart';

class Paddle extends SpriteComponent with HasGameRef, DragCallbacks, CollisionCallbacks {
  Ball? ball;  // Reference to the ball

  Paddle({this.ball});  // Constructor accepting ball reference

  @override
  Future<void> onLoad() async {
    sprite = await gameRef.loadSprite('paddle.png');
    size = Vector2(80, 22);  // Paddle size
    anchor = Anchor.center;
    add(RectangleHitbox());

    // Position the ball on top of the paddle at the start with a small gap (2px)
    if (ball != null) {
      ball!.position = Vector2(x, y - size.y / 2 - ball!.size.y / 2 - 2);  // Adding 2px gap
    }
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);

    // Update paddle position based on the drag
    x += event.localDelta.x;

    // Ensure the paddle doesn't go off-screen
    if (x - size.x / 2 < 0) {
      x = size.x / 2;
    } else if (x + size.x / 2 > gameRef.size.x) {
      x = gameRef.size.x - size.x / 2;
    }

    // Move the ball with the paddle if it hasn't been launched yet
    if (ball != null && !ball!.isLaunched) {
      ball!.position.x = x;
    }
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);

    // Launch the ball when dragging ends if it's not launched yet
    if (ball != null && !ball!.isLaunched) {
      ball!.launchBall();
    }
  }
}
