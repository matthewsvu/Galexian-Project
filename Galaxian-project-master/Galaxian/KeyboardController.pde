
import org.gamecontrolplus.*;
import net.java.games.input.*;

class KeyboardController {

  ControlIO controllIO;
  ControlDevice keyboard;
  ControlButton spaceBtn, leftArrow, rightArrow, downArrow,letterR, enter;

  KeyboardController(PApplet applet) {
    controllIO = ControlIO.getInstance(applet);
    keyboard = controllIO.getDevice("Keyboard");
    spaceBtn = keyboard.getButton("Space");   
    leftArrow = keyboard.getButton("Left");   
    rightArrow = keyboard.getButton("Right");
    downArrow = keyboard.getButton("Down");
    letterR = keyboard.getButton("R");
    enter = keyboard.getButton("Enter");
  }

  boolean isDown() {
    return downArrow.pressed();
  }

  boolean isLeft() {
    return leftArrow.pressed();
  }

  boolean isRight() {
    return rightArrow.pressed();
  }

  boolean isSpace() {
    return spaceBtn.pressed();
  }
  
  boolean isR() { 
    return letterR.pressed();
  }
  
  boolean isEnter(){
     return enter.pressed(); 
  }
}
