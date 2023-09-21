import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:hackernoon_game/actors/theboy.dart';
import 'package:hackernoon_game/background.dart';
import 'package:hackernoon_game/coin.dart';
import 'package:hackernoon_game/hud.dart';
import 'package:hackernoon_game/platform.dart';
import 'package:flutter/material.dart';
import 'assets.dart' as assets;

class PlatformerGame extends FlameGame
    with HasKeyboardHandlerComponents, HasCollisionDetection {
  // Define your fixed resolution. Zoom in with setting resolution lower
  final fixedResolution = Vector2(1920 / 2, 1280 / 2);

  final world = World();
  late final CameraComponent cam;
  Vector2 mapSize = Vector2.zero();

  late int _totalCoins;
  int _coins = 0; // Keeps track of collected coins
  late final Hud
      hud; // Reference to the HUD, to update it when the player collects a coin

  @override
  Color backgroundColor() {
    return const Color.fromARGB(255, 69, 186, 230);
  }

  @override
  Future<void> onLoad() async {
    await images.loadAll(assets.SPRITES);

    cam = CameraComponent.withFixedResolution(
      width: fixedResolution.x,
      height: fixedResolution.y,
      world: world,
    );
    addAll([cam, world]);
    cam.viewfinder.position = fixedResolution / 2;

    final level = await TiledComponent.load("level1.tmx", Vector2.all(64));
    world.add(level);

    // we need this for the boundaries of the Player
    mapSize.x = level.width;
    mapSize.y = level.height;

    spawnObjects(level.tileMap);

    world.add(ParallaxBackground(size: Vector2(mapSize.x, mapSize.y))
      ..priority = -10);

    // add theBoy
    final theBoy = TheBoy(
      position: Vector2(128, level.height - 64),
    );
    world.add(theBoy);

    // set the camera to follow a target & limit the camera to stay within level bounds.
    cam.follow(theBoy);
    cam.setBounds(
      Rectangle.fromLTRB(
        fixedResolution.x / 2,
        fixedResolution.y / 2,
        mapSize.x - fixedResolution.x / 2,
        mapSize.y - fixedResolution.y / 2,
      ),
    );

    hud = Hud();
    cam.viewport.add(hud);
  }

  void spawnObjects(RenderableTiledMap tileMap) {
    final platforms = tileMap.getLayer<ObjectGroup>("Platforms");

    for (final platform in platforms!.objects) {
      world.add(Platform(Vector2(platform.x, platform.y),
          Vector2(platform.width, platform.height)));
    }

    final coins = tileMap.getLayer<ObjectGroup>("Coins");

    for (final coin in coins!.objects) {
      world.add(Coin(Vector2(coin.x, coin.y)));
    }
    _totalCoins = coins.objects.length;
  }

  void onCoinCollected() {
    _coins++;
    hud.onCoinsNumberUpdated(_coins);

    if (_coins == _totalCoins) {
      final text = TextComponent(
        text: 'U WIN!',
        textRenderer: TextPaint(
          style: const TextStyle(
            fontSize: 150,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        anchor: Anchor.center,
        position: Vector2(cam.viewport.size.x / 2, 200),
      );
      cam.viewport.add(text);
      Future.delayed(const Duration(milliseconds: 500), () => {pauseEngine()});
    }
  }
}
