import 'package:flame/components.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/painting.dart';
import 'package:hackernoon_game/game.dart';
import 'package:hackernoon_game/assets.dart' as assets;

class ParallaxBackground extends ParallaxComponent<PlatformerGame> {
  ParallaxBackground({required super.size});

  // variable for storing the last viewport position
  Vector2 _lastCameraPosition = Vector2.zero();

  @override
  Future<void> onLoad() async {
    final clouds = await game.loadParallaxLayer(
      ParallaxImageData(assets.CLOUDS),
      velocityMultiplier: Vector2(1, 0),
      fill: LayerFill.none,
      alignment: Alignment.center,
    );

    final mist = await game.loadParallaxLayer(
      ParallaxImageData(assets.MIST),
      velocityMultiplier: Vector2(2, 0),
      fill: LayerFill.none,
      alignment: Alignment.bottomCenter,
    );

    final hills = await game.loadParallaxLayer(
      ParallaxImageData(assets.HILLS),
      velocityMultiplier: Vector2(3, 0),
      fill: LayerFill.none,
      alignment: Alignment.bottomCenter,
    );

    positionType = PositionType.viewport;
    parallax = Parallax(
      [mist, hills, clouds],
      // set baseVelocity to 0,0
      baseVelocity: Vector2.zero(),
    );
  }

  @override
  void update(double dt) {
    // move the parallaxBackground according to the viewfinder-position
    // Source: https://stackoverflow.com/questions/71131480/flutter-flame-how-to-use-parallax-with-camera-followcomponent
    final cameraPosition = gameRef.cam.viewfinder.position;
    final baseVelocity = cameraPosition
      ..sub(_lastCameraPosition)
      ..multiply(Vector2(10, 0));
    parallax!.baseVelocity.setFrom(baseVelocity);
    _lastCameraPosition.setFrom(gameRef.cam.viewfinder.position);

    super.update(dt);
  }
}
