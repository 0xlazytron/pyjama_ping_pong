import 'package:flame_audio/flame_audio.dart';

class AudioManager {
  static Future<void> load() async {
    // Load sound effects and background music
    await FlameAudio.audioCache.loadAll([
      'hit_paddle.wav',
      'hit_bricks.wav',
      'bgm.mp3' // Make sure this file is in your assets
    ]);
  }

  // Play paddle hit sound
  static void playHitPaddle() {
    FlameAudio.play('hit_paddle.wav');
  }

  // Play brick hit sound
  static void playHitBrick() {
    FlameAudio.play('hit_bricks.wav');
  }

  // Play background music with looping
  static void playBackgroundMusic() {
    FlameAudio.bgm.play('bgm.mp3', volume: 0.5); // Volume can be adjusted
  }

  // Stop background music
  static void stopBackgroundMusic() {
    FlameAudio.bgm.stop();
  }

  // Pause background music
  static void pauseBackgroundMusic() {
    FlameAudio.bgm.pause();
  }

  // Resume background music
  static void resumeBackgroundMusic() {
    FlameAudio.bgm.resume();
  }
}
