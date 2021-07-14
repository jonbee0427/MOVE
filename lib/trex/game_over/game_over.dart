import 'dart:ui';

import 'package:flame/components.dart';
import 'package:move/trex/game.dart';

import 'config.dart';

class GameOverPanel extends BaseComponent with HasGameRef<TRexGame> {
  GameOverPanel(
    Image spriteImage,
    GameOverConfig config,
  )   : gameOverText = GameOverText(spriteImage, config),
        gameOverRestart = GameOverRestart(spriteImage, config),
        //gameOverScore = GameOverScore(spriteImage, config),
        super();

  bool visible = false;

  GameOverText gameOverText;
  GameOverRestart gameOverRestart;
  //GameOverScore gameOverScore;

  @override
  Future<void>? onLoad() {
    addChild(gameOverText);
    addChild(gameOverRestart);
    return super.onLoad();
  }

  @override
  void renderTree(Canvas canvas) {
    if (visible) {
      super.renderTree(canvas);
    }
  }
}

class GameOverText extends SpriteComponent {
  GameOverText(Image spriteImage, this.config)
      : super(
          size: Vector2(config.textWidth, config.textHeight),
          sprite: Sprite(
            spriteImage,
            srcPosition: Vector2(1183.0, 30.0),
            srcSize: Vector2(
              config.textWidth,
              config.textHeight,
            ),
          ),
        );

  final GameOverConfig config;

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    y = gameSize.y * .25;
    x = (gameSize.x / 2) - config.textWidth / 2;
  }
}

class GameOverRestart extends SpriteComponent {
  GameOverRestart(
    Image spriteImage,
    this.config,
  ) : super(
          size: Vector2(config.restartWidth, config.restartHeight),
          sprite: Sprite(
            spriteImage,
            srcPosition: Vector2.all(2.0),
            srcSize: Vector2(config.restartWidth, config.restartHeight),
          ),
        );

  final GameOverConfig config;

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    y = gameSize.y * .75;
    x = (gameSize.x / 2) - config.restartWidth / 2;
  }
}
