
import ddf.minim.*; // Import Sound Library

class SoundPlayer {
  Minim minimplay;
  AudioSample boomPlayer, popPlayer;

  SoundPlayer(Object app) {
    minimplay = new Minim(app); 
    boomPlayer = minimplay.loadSample("explode.wav", 1024); 
    popPlayer = minimplay.loadSample("pop.wav", 1024);
  }

  void playExplosion() {
    boomPlayer.trigger();
  }

  void playPop() {
    popPlayer.trigger();
  }
}