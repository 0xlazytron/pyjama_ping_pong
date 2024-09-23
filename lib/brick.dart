import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class Brick extends SpriteComponent with HasGameRef, CollisionCallbacks {
  @override
  Future<void> onLoad() async {
    sprite = await gameRef.loadSprite('box.png');
    size = Vector2(50, 22);  // Brick size
    anchor = Anchor.topLeft;
    add(RectangleHitbox());  // Add a hitbox for the brick

  }
}
