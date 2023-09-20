import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:hackernoon_game/game.dart';

void main() {
  runApp(const GameWidget<PlatformerGame>.controlled(
    gameFactory: PlatformerGame.new,
  ));
}
