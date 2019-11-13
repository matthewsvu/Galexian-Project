/*
*/
import sprites.utils.*;
import sprites.maths.*;
import sprites.*;
import gifAnimation.*;

// The dimensions of the monster grid.
int monsterCols = 10;
int monsterRows = 5; 

long mmCounter = 0;
int mmStep = 1; 

boolean gameOver = false;
int score = 0;
int fallingMonsterPts = 20;
int gridMonsterPts = 10;


// Lower difficulty values introduce a more 
// random falling monster descent. 
int difficulty = 100;
double fmRightAngle = 0.3490; // 20 degrees
double fmLeftAngle = 2.79253; // 160 degrees
double fmSpeed = 150;

boolean started = false;
int timer = 1;

Sprite ship, missile, fallingMonster, explosion, gameOverSprite;
Sprite title, pressEnter;
Sprite monsters[] = new Sprite[monsterCols * monsterRows];
int missileSpeed = 500;
double upRadians = 4.71238898;


KeyboardController kbController;
SoundPlayer soundPlayer;
StopWatch stopWatch = new StopWatch();

void setup() 
{
  kbController = new KeyboardController(this);
  soundPlayer = new SoundPlayer(this);  


  // register the function (pre) that will be called
  // by Processing before the draw() function. 
  registerMethod("pre", this);

  size(700, 500);
  S4P.messagesEnabled(true);

  //title screen and press enter sprites
  title = new Sprite(this, "Title_Screen.png", 101);
  title.setX(width/2);
  title.setY(height/2);
  title.setDead(false);
  pressEnter = new Sprite(this, "Press_Enter.png", 102);
  pressEnter.setX(width/2);
  pressEnter.setY(height/2);
  pressEnter.setDead(true);
  //general sprites
  buildSprites();
  // Ship Explosion Sprite
  explosion = new Sprite(this, "explosion_strip16.png", 17, 1, 90);
  explosion.setScale(1);
  // Game Over Sprite
  gameOverSprite = new Sprite(this, "gameOver.png", 100);
  gameOverSprite.setDead(true);
  resetMonsters();
}

void buildSprites()
{
  // The Ship and its Missile
  ship = buildShip();
  missile = buildMissile();
  // The Grid Monsters 
  buildMonsterGrid();
}

Sprite buildShip()
{

  Sprite ship = new Sprite(this, "ship.png", 50);
  ship.setXY(width/2, height - 30);
  ship.setVelXY(0.0f, 0);
  ship.setScale(.75);
  ship.setRot(3.14159);
  // Domain keeps the moving sprite withing specific screen area 
  ship.setDomain(0, height-ship.getHeight(), width, height, Sprite.HALT);



  return ship;
}

Sprite buildMissile()
{
  // The Missile
  Sprite sprite  = new Sprite(this, "newMissile.gif", 10);
  sprite.setScale(.5);
  sprite.setDead(true); // Initially hide the missile
  return sprite;
}


// Populate the monsters grid 
void buildMonsterGrid() 
{
  for (int idx = 0; idx < monsters.length; idx++ ) {
    monsters[idx] = buildMonster();
  }
}

// Arrange Monsters into a grid
void resetMonsters() 
{
  mmCounter = 0;
  mmStep = 1;
  gameOver = false;
  ship.setDead(false);
  gameOverSprite.setDead(true);
  for (int idx = 0; idx < monsters.length; idx++ ) {
    Sprite monster = monsters[idx];
    monster.setSpeed(0, 0);

    double mwidth = monster.getWidth() + 20;
    double totalWidth = mwidth * monsterCols;
    double start = (width - totalWidth)/2 - 25;
    double mheight = monster.getHeight();
    int xpos = (int)((((idx % monsterCols)*mwidth)+start));
    int ypos = (int)(((int)(idx / monsterCols)*mheight)+50);
    monster.setXY(xpos, ypos);
    fallingMonster = null;
    monster.setDead(false);
  }
}

// Pick the first monster on the grid that is not dead.
// Return null if they are all dead.
Sprite pickNonDeadMonster() 
{
  for (int idx = 0; idx < monsters.length; idx++) {
    Sprite monster = monsters[idx];
    if (!monster.isDead()) {
      return monster;
    }
  }
  return null;
}


// Build individual monster
Sprite buildMonster() 
{

  Sprite monster = new Sprite(this, "monster.png", 30);
  monster.setScale(.5);
  monster.setDead(false);
  return monster;
}

// Executed before draw() is called 
public void pre() 
{    
  checkKeys();
  processCollisions();
  moveMonsters();
  if (pickNonDeadMonster() == null) {
    resetMonsters();
  }
  // if falling monster is off screen
  if (fallingMonster == null || !fallingMonster.isOnScreem()) {
    replaceFallingMonster();
  }



  S4P.updateSprites(stopWatch.getElapsedTime());

  // If missile flies off screen
  if (!missile.isDead() && ! missile.isOnScreem()) {
    stopMissile();
  }
} 

void checkKeys() 
{

  if (focused) {
    if (kbController.isLeft()) {
      ship.setX(ship.getX()-10);
    }
    if (kbController.isRight()) {
      ship.setX(ship.getX()+10);
    }
    if (kbController.isSpace()) {
      fireMissile();
    }
    if (kbController.isR())
    {
      if (started) {

        started = false;
        title.setDead(false);
        timer = 1;
      }
    }
    if (kbController.isEnter())
    {
      started = true;
      title.setDead(true);
      pressEnter.setDead(true);
      resetMonsters();
    }
  }
}

void moveMonsters() 
{  

  // Move Grid Monsters
  mmCounter++;
  if ((mmCounter % 100) == 0) mmStep *= -1;

  for (int idx = 0; idx < monsters.length; idx++ ) {
    Sprite monster = monsters[idx];
    if (!monster.isDead()&& monster != fallingMonster) {
      monster.setXY(monster.getX()+mmStep, monster.getY());
    }
  }

  // Move Falling Monster
  if (fallingMonster != null) {
    if (int(random(difficulty)) == 1) {
      // Change FM Speed
      fallingMonster.setSpeed(fallingMonster.getSpeed() 
        + random(-40, 40));
      // Reverse FM direction.
      if (fallingMonster.getDirection() == fmRightAngle) 
        fallingMonster.setDirection(fmLeftAngle);
      else
        fallingMonster.setDirection(fmRightAngle);
    }
  }
}

void replaceFallingMonster() 
{
  if (fallingMonster != null) {
    fallingMonster.setDead(true);
    fallingMonster = null;
  }

  // select new falling monster 
  fallingMonster = pickNonDeadMonster();
  if (fallingMonster == null) {
    return;
  }

  fallingMonster.setSpeed(fmSpeed, fmRightAngle);
  // Domain keeps the moving sprite within specific screen area 
  fallingMonster.setDomain(0, 0, width, height+100, Sprite.REBOUND);
}


void fireMissile() 
{
  if (missile.isDead() && !ship.isDead()) {
    missile.setPos(ship.getPos());
    missile.setSpeed(missileSpeed, upRadians);
    missile.setDead(false);
  }
}

void stopMissile() 
{
  missile.setSpeed(0, upRadians);
  missile.setDead(true);
}



// Detect collisions between sprites
void processCollisions() 
{
  // Detect collisions between Grid Monsters and Missile
  for (int idx = 0; idx < monsters.length; idx++) {
    Sprite monster = monsters[idx];
    if (!missile.isDead() && !monster.isDead() 
      && monster != fallingMonster 
      && missile.bb_collision(monster)) {
      score += gridMonsterPts;
      monsterHit(monster);
      missile.setDead(true);
    }
  }

  // Between Falling Monster and Missile
  if (!missile.isDead() && fallingMonster != null 
    && missile.cc_collision(fallingMonster)) {
    score += fallingMonsterPts;
    monsterHit(fallingMonster); 
    missile.setDead(true);
    fallingMonster = null;
  }
  // Between Falling Monster and Ship
  if (fallingMonster!= null && !ship.isDead() 
    && fallingMonster.bb_collision(ship)) {
    explodeShip();
    monsterHit(fallingMonster);
    fallingMonster = null;
    gameOver = true;
  }
}

void monsterHit(Sprite monster) 
{
  //soundPlayer.playPop();
  monster.setDead(true);
}

void explodeShip() 
{
  soundPlayer.playExplosion();
  explosion.setPos(ship.getPos());
  explosion.setFrameSequence(0, 16, 0.1, 1);
  ship.setDead(true);
}


public void draw() 
{
  background(0);
  S4P.drawSprites();
  if (gameOver)
    drawGameOver();
  if (!started && timer++%100 == 0)
    pressEnter.setDead(!pressEnter.isDead());
}

void drawGameOver() 
{
  gameOverSprite.setXY(width/2, height/2);
  gameOverSprite.setDead(false);
}
