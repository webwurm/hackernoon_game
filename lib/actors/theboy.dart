import 'package:flutter/services.dart';

import '../game.dart';
import '../assets.dart' as assets;
import 'package:flame/components.dart';

class TheBoy extends SpriteAnimationComponent
    with HasGameRef<PlatformerGame>, KeyboardHandler {
  TheBoy({
    required super.position, // Position on the screen
  }) : super(
            size: Vector2.all(48), // Size of the component
            anchor: Anchor.bottomCenter //
            );

  // --- CLASS VARIABLES

  final double _moveSpeed = 300; // Max player's move speed

  int _horizontalDirection = 0; // Current direction the player is facing
  final Vector2 _velocity = Vector2.zero(); // Current player's speed

  late final SpriteAnimation _runAnimation;
  late final SpriteAnimation _idleAnimation;

  // --- OVERRIDES

  @override
  Future<void> onLoad() async {
    _idleAnimation = SpriteAnimation.fromFrameData(
      game.images.fromCache(assets.THE_BOY),
      SpriteAnimationData.sequenced(
        amount: 1,
        textureSize: Vector2.all(20),
        stepTime: 0.12,
      ),
    );

    _runAnimation = SpriteAnimation.fromFrameData(
      game.images.fromCache(assets.THE_BOY),
      SpriteAnimationData.sequenced(
        amount: 6,
        textureSize: Vector2.all(20),
        stepTime: 0.12,
      ),
    );

    animation = _idleAnimation;
  }

  @override
  void update(double dt) {
    print(position);
    super.update(dt);
    _velocity.x = _horizontalDirection * _moveSpeed;
    position += _velocity * dt;

    if ((_horizontalDirection < 0 && scale.x > 0) ||
        (_horizontalDirection > 0 && scale.x < 0)) {
      flipHorizontally();
    }

    updateAnimation();
  }

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    _horizontalDirection = 0;
    _horizontalDirection += (keysPressed.contains(LogicalKeyboardKey.keyA) ||
            keysPressed.contains(LogicalKeyboardKey.arrowLeft))
        ? -1
        : 0;
    _horizontalDirection += (keysPressed.contains(LogicalKeyboardKey.keyD) ||
            keysPressed.contains(LogicalKeyboardKey.arrowRight))
        ? 1
        : 0;

    return true;
  }

  //--- HELPERS

  void updateAnimation() {
    if (_horizontalDirection == 0) {
      animation = _idleAnimation;
    } else {
      animation = _runAnimation;
    }
  }
}
