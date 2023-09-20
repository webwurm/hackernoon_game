import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:hackernoon_game/actors/theboy.dart';
import 'assets.dart' as assets;

class PlatformerGame extends FlameGame with HasKeyboardHandlerComponents {
  double mapWidth = 0;
  double mapHeight = 0;

  final world = World();
  late final CameraComponent cam;

  double zoom = 2;

  @override
  Future<void> onLoad() async {
    cam = CameraComponent.withFixedResolution(
      width: 1920,
      height: 1280,
      world: world,
    )..viewfinder.anchor = Anchor.bottomLeft;
    addAll([cam, world]);
    await images.loadAll(assets.SPRITES);

    final level = await TiledComponent.load("level1.tmx", Vector2.all(64))
      ..anchor = Anchor.bottomLeft;

    mapWidth = level.tileMap.map.width * level.tileMap.destTileSize.x;
    mapHeight = level.tileMap.map.height * level.tileMap.destTileSize.y;

    world.add(level);

    final theBoy = TheBoy(
      position: Vector2(128, -50), //mapHeight - 64),
    );
    world.add(theBoy);
  }

  @override
  void update(double dt) {
    //cam.viewfinder.zoom = 1;
    super.update(dt);
  }
}
