import 'package:flame/components.dart';
import 'package:hackernoon_game/game.dart';
import 'assets.dart' as assets;

class Hud extends PositionComponent with HasGameRef<PlatformerGame> {
  Hud() {
    super.position = Vector2(20, 20);
  }

  void onCoinsNumberUpdated(int total) {
    final coin = SpriteComponent.fromImage(
      game.images.fromCache(assets.HUD),
      position: Vector2((50 * total).toDouble(), 50),
      size: Vector2.all(48),
      anchor: Anchor.topLeft,
    );

    // adding something as child of the viewport puts it "on" the window
    game.cam.viewport.add(coin);
  }
}
