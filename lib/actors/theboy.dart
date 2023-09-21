import 'package:flame/collisions.dart';
import 'package:flutter/services.dart';
import 'package:hackernoon_game/coin.dart';
import 'package:hackernoon_game/platform.dart';

import '../game.dart';
import '../assets.dart' as assets;
import 'package:flame/components.dart';

class TheBoy extends SpriteAnimationComponent
    with HasGameRef<PlatformerGame>, KeyboardHandler, CollisionCallbacks {
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
  late final SpriteAnimation _jumpAnimation;
  late final SpriteAnimation _fallAnimation;

  final double _gravity = 15; // How fast The Boy gets pull down
  final double _jumpSpeed = 500; // How high The Boy jumps
  final double _maxGravitySpeed =
      300; // Max speed The Boy can have when falling

  bool _hasJumped = false;
  Component? _standingOn; // The component The Boy is currently standing on
  final Vector2 up = Vector2(0,
      -1); // Up direction vector we're gonna use to determine if The Boy is on the ground
  final Vector2 down = Vector2(0,
      1); // Down direction vector we're gonna use to determine if The Boy hit the platform above

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

    _jumpAnimation = SpriteAnimation.fromFrameData(
      game.images.fromCache(assets.THE_BOY),
      SpriteAnimationData.range(
        start: 4,
        end: 4,
        amount: 6,
        textureSize: Vector2.all(20),
        stepTimes: [0.12],
      ),
    );

    _fallAnimation = SpriteAnimation.fromFrameData(
      game.images.fromCache(assets.THE_BOY),
      SpriteAnimationData.range(
        start: 5,
        end: 5,
        amount: 6,
        textureSize: Vector2.all(20),
        stepTimes: [0.12],
      ),
    );

    animation = _idleAnimation;

    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    //print(position);
    super.update(dt);
    if (doesReachLeftEdge() || doesReachRightEdge()) {
      _velocity.x = 0;
    } else {
      _velocity.x = _horizontalDirection * _moveSpeed;
    }
    _velocity.y += _gravity;

    // only jump if he is standing on something
    if (_hasJumped) {
      if (_standingOn != null) {
        _velocity.y = -_jumpSpeed;
      }
      _hasJumped = false;
    }

    _velocity.y = _velocity.y.clamp(-_jumpSpeed, _maxGravitySpeed);
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
    _hasJumped = keysPressed.contains(LogicalKeyboardKey.keyW) ||
        keysPressed.contains(LogicalKeyboardKey.arrowUp);
    return true;
  }

  @override
  //Source: https://hackernoon.com/using-collision-detection-to-make-your-game-character-jump
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Platform) {
      if (intersectionPoints.length == 2) {
        final mid = (intersectionPoints.elementAt(0) +
                intersectionPoints.elementAt(1)) /
            2;

        final collisionVector = absoluteCenter - mid;
        double penetrationDepth = (size.x / 2) - collisionVector.length;

        collisionVector.normalize();

        // jump
        if (up.dot(collisionVector) > 0.9) {
          _standingOn = other;

          // push him a bit down when colliding on top
        } else if (down.dot(collisionVector) > 0.9) {
          _velocity.y += _gravity;
        }
        position += collisionVector.scaled(penetrationDepth);
      }
    }

    super.onCollision(intersectionPoints, other);
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Coin) {
      other.collect();
    }
    super.onCollisionStart(intersectionPoints, other);
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    if (other == _standingOn) {
      _standingOn = null;
    }
    super.onCollisionEnd(other);
  }

  //--- HELPERS

  void updateAnimation() {
    if (_standingOn != null) {
      if (_horizontalDirection == 0) {
        animation = _idleAnimation;
      } else {
        animation = _runAnimation;
      }
    } else {
      if (_velocity.y > 0) {
        animation = _fallAnimation;
      } else {
        animation = _jumpAnimation;
      }
    }
  }

  bool doesReachLeftEdge() {
    return position.x <= size.x / 2 && _horizontalDirection < 0;
  }

  bool doesReachRightEdge() {
    return position.x >= game.mapSize.x - size.x / 2 &&
        _horizontalDirection > 0;
  }
}
