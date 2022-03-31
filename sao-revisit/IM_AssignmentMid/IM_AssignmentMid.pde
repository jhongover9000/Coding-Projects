//IM Assignment 6 (Midterm): A Game.
//Joseph Hong
//Description: This is a generic sidescroller where you level up by killing enemies. Each stage boosts up a level with
//             harder enemies, and there's a boss battle at the end. If you beat the boss, you win! There's music, but
//             I didn't manage to add all the sound effects for the players (hence the 0 sound files in initialization).
//             Fun menu that changes backgrounds, and an interactive instruction screen! I had fun making this even if
//             I spent an all-nighter trying to get it to work. Have fun playing!
//=======================================================================================================================
//=======================================================================================================================
//Imports
import java.util.ArrayList;    //for the size-changing array
import java.util.Random;       //for selecting a random integer (as opposed to a float)
import java.io.File;
import processing.sound.*;

//=======================================================================================================================
//=======================================================================================================================
//Global Variables & Setup

//This method of retrieving the current directory doesn't work with processing
//String cmd = System.getProperty("user.dir");

//Random Integer Generator
Random rand = new Random();

//Screen dimensions (need to change on setup as well)
float screenWidth = 720;
float screenHeight = 405;

//Character image width and height
int characterImageWidth = 300;
int characterImageHeight = 207;
//Selection of main character
int mainCharSelect;

int ground = 375;

//Decides difficulty increment per stage
int levelInc = 10;

//Character Files
//Main
CharacterFile krt = new CharacterFile("kirito", 70, 15, 0);
CharacterFile asn = new CharacterFile("asuna", 70, 5, 0);
//Enemies
CharacterFile yki = new CharacterFile("yuuki", 70, 0, 0);
CharacterFile akr = new CharacterFile("akira", 70, 0, 0);

//UI Stuff for game
PFont font; 
SoundFile openingOST;
SoundFile button;
SoundFile stageOST1;
SoundFile stageOST2;
SoundFile bossOST;
SoundFile defeat;
SoundFile victory;
ArrayList<SoundFile> stageMusic = new ArrayList<SoundFile>();

//Arrays of images and image arrays
ArrayList<CharacterFile> characters = new ArrayList<CharacterFile>();
ArrayList<PImage> menuBackgrounds = new ArrayList<PImage>();
ArrayList<ArrayList<PImage> > backgroundSets = new ArrayList<ArrayList<PImage> >();



Player player = new Player(characterImageWidth/2, (ground - characterImageHeight/2));

Game game = new Game(player);


void setup() {
  size(720, 405);
  frameRate(30);

  button = new SoundFile(this, "button_click.wav");
  openingOST = new SoundFile(this, "13 Worldmap.mp3");
  defeat = new SoundFile(this, "18 Sad.mp3");
  victory = new SoundFile(this, "14 Results.mp3");

  stageOST1 = new SoundFile(this, "01 Quest SAO.mp3");
  stageOST2 = new SoundFile(this, "02 Quest ALO.mp3");
  bossOST = new SoundFile(this, "04 Boss SAO.mp3");
  stageMusic.add(stageOST1);
  stageMusic.add(stageOST2);
  stageMusic.add(bossOST);


  font = createFont("SAOUITT-Regular.ttf", 32);

  //Load main characters
  loadImages(krt);
  loadImages(asn);
  characters.add(krt);
  characters.add(asn);

  //Load enemies
  loadImages(yki);
  loadImages(akr);
  characters.add(yki);
  characters.add(akr);

  player.linkImageSets(characters.get(0));
  loadBackgrounds(3);
  loadMenuBackgrounds(7);
}

//=======================================================================================================================
//=======================================================================================================================
//Images & Sounds

//function used to load images (given a character name, index in image array, identifier of first image, 
void loadImages(CharacterFile characterName) {
  //Load Main Images
  for (int i = 0; i < characterName.numImages; i++) {
    String numBuffer;        //to match the image identifier
    if (i > 9) {
      numBuffer = "0";
    } else if (i > 99) {
      numBuffer = "";
    } else {
      numBuffer = "00";
    }
    PImage p = loadImage(characterName.name + numBuffer + String.valueOf(i) + ".png");
    characterName.moveSets.add(p);
  }

  //Load Extra Images
  for (int i = 0; i < characterName.numImagesExtra; i++) {
    String numBuffer;        //to match the image identifier
    if (i > 9) {
      numBuffer = "";
    } else if (i > 99) {
      numBuffer = "";
    } else {
      numBuffer = "0";
    }
    PImage p = loadImage(characterName.name + "ex" + numBuffer + String.valueOf(i) + ".png");
    characterName.moveSetsExtra.add(p);
  }

  //Load Sound Files
  for (int i = 0; i < characterName.numSFX; i++) {
    String numBuffer;
    if (i > 9) {
      numBuffer = "";
    } else if (i > 99) {
      numBuffer = "";
    } else {
      numBuffer = "0";
    }
    SoundFile s = new SoundFile(this, "characterName.name" + "sfx" +numBuffer + String.valueOf(i) + ".wav");
    characterName.sfx.add(s);
  }
}

//load backgrounds in sets
void loadBackgrounds(int numSets) {
  for (int i = 0; i < numSets; i++) {
    ArrayList<PImage> tempSet = new ArrayList<PImage>();
    for (int j = 0; j < 4; j++) {
      PImage p = loadImage(String.valueOf(i) + String.valueOf(j) + ".png");
      tempSet.add(p);
    }
    backgroundSets.add(tempSet);
  }
}

void loadMenuBackgrounds(int numImages) {
  for (int i = 0; i < numImages; i++) {
    String numBuffer;
    if (i > 9) {
      numBuffer = "";
    } else if (i > 99) {
      numBuffer = "";
    } else {
      numBuffer = "0";
    }
    PImage p = loadImage("menubackground" + numBuffer + String.valueOf(i) + ".jpg");
    menuBackgrounds.add(p);
  }
}

//=======================================================================================================================
//=======================================================================================================================
//Classes


//Overall Entities (Basically All Objects On-Screen)
class Entity {
  float locX;
  float locY;
  float velX;  
  float velY;

  PImage img;

  int imgHeight;
  int imgWidth;

  int dir;            //direction

  boolean gravity() {
    print(locY + characterImageHeight/2);
    print("\n" + ground +"\n");
    if (locY + characterImageHeight/2 < ground) {
      velY += 0.3;
    } else if (locY + characterImageHeight/2 >= ground) {
      velY = ground - (locY + characterImageHeight/2);
      if (locY + characterImageHeight/2 > ground) {
        velY = ground - (locY + characterImageHeight/2);
      }
    }
    if (locY + characterImageHeight/2 == ground) {
      return true;
    } else {
      return false;
    }
  }

  void update() {
    locX += velX;
    locY += velY;
  }
}

//Player Class
class Player extends Entity {

  //Stores images for character
  ArrayList<PImage> moveSets;
  ArrayList<PImage> moveSetsExtra;
  String charName;
  int moveIndexStart;
  int moveIndexStop;
  float moveFramePoint;      //This is the variable that stores the decimal values (for adjusting frame speed)
  float moveFrameIncrementor;
  int moveFrame;
  int imgHeight = characterImageHeight;
  int imgWidth = characterImageWidth;

  //Determines walking speed (to slow down enemies)
  int walkSpeed = 7;

  //When standing
  Tuple still = new Tuple(0, 7);
  Tuple normalATK = new Tuple(8, 11);
  Tuple burstATK = new Tuple(12, 17);
  Tuple knockbackATK = new Tuple(18, 24);
  Tuple walk = new Tuple(25, 29);
  Tuple guard = new Tuple(30, 32);
  //When crouching
  Tuple crouch = new Tuple(33, 36);
  Tuple crouchATK = new Tuple(44, 47);
  Tuple crouchGuard = new Tuple(48, 50);
  //When jumping
  Tuple jump = new Tuple(37, 43);
  //When hit
  Tuple hitStand = new Tuple(51, 54);
  Tuple hitJump = new Tuple(51, 54);
  Tuple hitCrouch = new Tuple(55, 59);
  //When dead
  Tuple dead = new Tuple(60, 69);

  //Stats
  float currentEXP = 0;
  float maxEXP = 10;
  int currentLevel = 1;
  float levelMultiplier = currentLevel * 0.1;
  float maxHP = 100*currentLevel;            //total health points
  float currentHP = maxHP;        //current health points
  float maxMP = 10*currentLevel;             //total mana points
  float currentMP = maxMP;         //current mana points
  float maxDP = 20*currentLevel;             //damage points
  int blockCount = 5;          //number of blocks (guards) available; refreshes on level up

  //Becomes true when HP hits 0
  boolean playerDeath = false;

  //Display
  String displayText = "";
  int displayCount = 0;

  //These three are the present "position" booleans
  boolean isStanding = true;       //check if standing
  boolean isCrouching = false;      //check if crouching
  boolean isJumping = false;        //check if jumping

  //These three are the past "position" booleans
  boolean wasStanding = false;
  boolean wasCrouching = false;
  boolean wasJumping = false;

  //Each position boolean has three present "action" booleans. If all three are false, the player is still.
  boolean isAttacking = false;     //attacking or not
  boolean isGuarding = false;      //guarding (reduce damage taken)
  boolean isWalking = false;     //walking or not

  //Each position boolean has three past "action" booleans
  boolean wasAttacking = false;
  boolean wasGuarding = false;
  boolean wasWalking = false;

  //Check if player is transitioning from one move to another (only for certain ones)
  boolean isTransitioning = false;

  //Attack type
  int attackType;

  //Getting hit will override all movements and send through hit animation
  boolean isHit = false;
  int hitCounter = 0;

  Player(int locX, int locY) {
    maxHP = 100*currentLevel;            //total health points
    currentHP = maxHP;        //current health points
    maxMP = 10*currentLevel;             //total mana points
    currentMP = maxMP;         //current mana points
    maxDP = 20*currentLevel;             //damage points
    blockCount = 5;          //number of blocks (guards) available; refreshes on level up
    this.locX = locX;
    this.locY = locY;
    dir = 1;
  }

  //when initializing the character, use to link the image arrays to the character
  void linkImageSets(CharacterFile characterName) {
    this.moveSets = characterName.moveSets;
    this.moveSetsExtra = characterName.moveSetsExtra;
    this.charName = characterName.name;
  }

  //Display stats
  void statBar() {
    //Frame
    noStroke();
    fill(200);
    quad(0, 0, 210, 0, 160, 50, 0, 50);

    //Name
    textAlign(LEFT);
    fill(150);
    textSize(10);
    text(charName.toUpperCase(), 3, 10);

    //HP Bar
    fill(180);
    quad(16, 15, 180, 15, 180-10, 25, 16, 25);
    fill(150);
    textSize(8);
    text("HP", 3, 21);
    if (currentHP > 0) {
      if (currentHP/maxHP > 0.7) {
        fill(0, 220, 0);
      } else if (currentHP/maxHP > 0.3) {
        fill(220, 220, 0);
      } else if (currentHP/maxHP > 0) {
        fill(220, 30, 0);
      }
      if (180*(currentHP/maxHP)-10 > 15) {
        quad(16, 15, 180*(currentHP/maxHP), 15, 180*(currentHP/maxHP)-10, 25, 16, 25);
      } else {
        quad(16, 15, 180*(currentHP/maxHP), 15, 16, 25, 16, 25);
      }
    }

    //MP Bar
    fill(180);
    quad(16, 30, 160, 30, 160-5, 35, 16, 35);
    fill(150);
    textSize(8);
    text("MP", 3, 35);
    if (currentMP > 0) {
      fill(0, 130, 230);
      if (160*(currentMP/maxMP)-5 > 15) {
        quad(16, 30, 160*(currentMP/maxMP), 30, 160*(currentMP/maxMP)-5, 35, 16, 35);
      } else {
        quad(16, 30, 160*(currentMP/maxMP), 30, 16, 35, 16, 35);
      }
    }

    //EXP Bar
    fill(180);
    quad(5, 40, 150, 40, 145, 42, 5, 42);
    fill(0, 180, 230);
    if (currentEXP > 0) {
      quad(5, 40, 150*(currentEXP/maxEXP), 40, 145*(currentEXP/maxEXP)-5, 42, 5, 42);
    }
  }

  //Taking damage reduces health and sends into hit animation
  void takeDamage(float maxDP) {
    currentHP -= maxDP;
    setCurrentActionsFalse();
    isHit = true;
  }

  //Level Up!!
  void levelUp() {
    if (currentEXP >= maxEXP) {
      displayNotif("Level Up!");
      levelMultiplier = currentLevel * 0.1;
      currentLevel++;
      //Increase HP,MP,DP
      maxHP += 20*levelMultiplier;
      maxMP += 10*levelMultiplier;
      maxDP += 10*levelMultiplier;
      //Reset HP & MP
      currentHP = maxHP;
      currentMP += 10;
      if (currentMP > maxMP) {
        currentMP = maxMP;
      }
      //Change EXP
      maxEXP = maxEXP*1.5;
      currentEXP = 0;
      //Reset BlockCount
      blockCount = 5;
    }
  }

  //Death Animation
  void death() {
    resetCurrent();
    resetPast();
    changeMoveSet(dead, 0.3);
  }


  //Display notifier text (no MP, cannot use attack, etc.)
  void displayNotif(String notif) {
    displayText = notif;
    displayCount = 0;
  }

  //Set all current positions to false (usually followed by setting one position to true)
  void setCurrentPosFalse() {
    isStanding = false;
    isCrouching = false;
    isJumping = false;
  }

  //Set all current positions to false (usually followed by setting one position to true)
  void setPastPosFalse() {
    wasStanding = false;
    wasCrouching = false;
    wasJumping = false;
  }

  //Set all current actions to false (usually followed by setting one action to true)
  void setCurrentActionsFalse() {
    isAttacking = false;
    isGuarding = false;
    isWalking = false;
  }

  //Set all past actions to false (usually followed by setting one action to true)
  void setPastActionFalse() {
    wasAttacking = false;
    wasGuarding = false;
    wasWalking = false;
  }

  //reset all current positions/actions
  void resetCurrent() {
    setCurrentPosFalse();
    setCurrentActionsFalse();
  }

  //reset all past positions/actions
  void resetPast() {
    setPastPosFalse();
    setPastActionFalse();
  }

  //Change move set and player image frame count
  void changeMoveSet(Tuple moveParameters, float moveFrameIncrementor) {
    this.moveFrame = 0;
    this.moveFramePoint = 0;
    this.moveFrameIncrementor = moveFrameIncrementor;
    this.moveIndexStart = moveParameters.x;
    this.moveIndexStop = moveParameters.y;
  }

  //check whether the move set has been completed (for attacking, jumping)
  boolean moveSetComplete() {
    if (moveFramePoint + moveIndexStart >= moveIndexStop) {
      return true;
    } else {
      return false;
    }
  }

  void updateLastAction() {
    //Update true position booleans
    if (isStanding) {
      wasStanding = true;
    } else {
      wasStanding = false;
    }
    if (isCrouching) {
      wasCrouching = true;
    } else {
      wasCrouching = false;
    }
    if (isJumping) {
      wasJumping = true;
    } else {
      wasJumping = false;
    }
    //Update true action booleans
    if (isAttacking) {
      wasAttacking = true;
    } else {
      wasAttacking = false;
    }
    if (isGuarding) {
      wasGuarding = true;
    } else {
      wasGuarding = false;
    }
    if (isWalking) {
      wasWalking = true;
    } else {
      wasWalking = false;
    }
  }

  //returns a value to see if player's current action is still
  boolean isStill() {
    if (!isAttacking && !isGuarding && !isJumping && !isWalking) {
      return true;
    } else {
      return false;
    }
  }

  //returns a value to see if player's last action was still
  boolean wasStill() {
    if (!wasAttacking && !wasGuarding && !wasJumping && !wasWalking) {
      return true;
    } else {
      return false;
    }
  }

  void updateLoc() {
    //Update location and velocity (keep player from going out of bounds)
    if (locX - imgWidth/4 < 0 && dir == -1) {
      velX = 0;
    }
    locX += velX;
    locY += velY;
  }

  void update(boolean isPlayer, ArrayList<Projectile> projectiles) {

    //Update player gravity
    gravity();

    //Check for level up
    levelUp();

    //Check if player is dead (game ends)
    if (currentHP <= 0 || playerDeath) {
      if (!playerDeath) {
        death();
        playerDeath = true;
      } else if (playerDeath) {
        if (moveSetComplete()) {
          moveFrameIncrementor = 0;
        }
      }
    }
    //Otherwise keep going 
    else {
      //Check if hit  
      if (!isHit) {
        //If jumping
        if (isJumping) {

          //If player has started jumping
          if (isStanding && !isAttacking && !isGuarding) {
            isStanding = false;
            changeMoveSet(jump, 0.3);
            velY = -10;
          }
          //If player is in the process of jumping
          else {
            //If rising up
            if (velY <= 0) {
              if (moveFramePoint >= 2) {
                moveFrameIncrementor = 0;
                moveFramePoint = 2;
              }
            }

            //If falling down
            else if (velY > 0) {
              moveFrameIncrementor = 0.2;
              if (moveFramePoint > 6) {
                moveFrameIncrementor = 0;
                moveFramePoint = 6;
              }
            }

            //If hitting the ground, automatically go into still mode
            if (gravity()) {
              if (isWalking) {
                changeMoveSet(walk, 0.3);
              }
              isJumping = false;
              isStanding = true;
            }
          }
        }//jumping end

        else if (isCrouching && !wasCrouching) {
          velX = 0;
          isWalking = false;
          isCrouching = true;
          changeMoveSet(crouch, 0.2);
        }

        //If attacking
        else if (isAttacking) {

          //No movement
          velX = 0;

          //If player just started attacking
          if (!wasAttacking) {
            if (attackType == 0 && isStanding) {
              changeMoveSet(normalATK, 0.3);
            } else if (attackType == 0 && isCrouching) {
              changeMoveSet(crouchATK, 0.2);
            } else if (attackType > 0 && isCrouching) {
              displayNotif("Cannot Use Attack!");
            } else if (attackType == 1 && currentMP >= 5) {
              changeMoveSet(burstATK, 0.3);
              Projectile proj = new Projectile(locX, locY, isPlayer, false, maxDP*1.5, dir);
              projectiles.add(proj);
              currentMP -= 5;
            } else if (attackType == 2 && currentMP >= 10) {
              changeMoveSet(knockbackATK, 0.3);
              Projectile proj = new Projectile(locX, locY, isPlayer, true, maxDP*2, dir);
              projectiles.add(proj);
              currentMP -= 10;
            }
          }

          //Once moveset is complete, go back to still
          if (moveSetComplete()) {
            if (isWalking && isStanding) {
              changeMoveSet(walk, 0.3);
            }
            isAttacking = false;
          }
        }//end attacking

        //If walking
        else if (isWalking) {
          if (isStanding) {
            if (!wasWalking) {
              changeMoveSet(walk, 0.3);
            }
            velX = dir*walkSpeed;
          }
        }//walking end

        //If guarding
        else if (isGuarding) {

          //No movement
          velX = 0;

          //If starting to guard
          if (!wasGuarding) {
            if (isStanding) {
              changeMoveSet(guard, 0.6);
            } else if (isCrouching) {
              changeMoveSet(crouchGuard, 0.3);
            }
          }

          //Keeps player in 'blocking' frame
          if (moveFramePoint >= 2) {
            moveFrameIncrementor = 0;
            moveFramePoint = 2;
          }
        }//guarding end

        //If still
        if (isStill()) {
          //No movement
          velX = 0;

          //If standing
          if (isStanding) {
            //if coming out of guarding or standing up, undergo transition animation
            if (isTransitioning || wasCrouching || wasGuarding) {
              //This value doesn't affect anything else, which makes it useful in tracking if a transition is happening
              isTransitioning = true;
              wasCrouching = false;
              wasGuarding = false;
              //go backwards in frames
              if (moveFrame > 0) {
                moveFrameIncrementor = -0.6;
              } 
              //when frames hit 0, change to still
              else if (moveFrame <= 0) {
                changeMoveSet(still, 0.4);
                isTransitioning = false;
              }
            }
            //else, just transition to still (after attack/jump)
            else {
              //check if player was still in previous frame; if not, change the moveset
              if ( !wasStill() || !wasStanding ) {
                changeMoveSet(still, 0.4);
              }
            }
          }

          //If crouching
          else if (isCrouching) {
            //If coming out of guarding, undergo transition animation
            if (wasGuarding|| isTransitioning) {
              //This value doesn't affect anything else, which makes it useful in tracking if a transition is happening
              isTransitioning = true;
              wasGuarding = false;
              //go backwards in frames
              if (moveFrame > 0) {
                moveFrameIncrementor = -0.1;
              }
              //when frames hit 0, change to still
              else if (moveFrame < 0.5) {
                changeMoveSet(crouch, 0.2);
                moveFramePoint = 2;
                isTransitioning = false;
              }
            } else if (wasAttacking && !isAttacking) {
              changeMoveSet(crouch, 0.2);
              moveFramePoint = 2;
            } else if (!wasCrouching) {
              changeMoveSet(crouch, 0.2);
            }
            //This makes the player stay in the 'crouch' frame until mouse button is released
            else {
              if (moveFramePoint > 3.8) {
                moveFrameIncrementor = 0.05;
                moveFrameIncrementor *= -1;
              }
              if (moveFramePoint < 2.1 && moveFrameIncrementor < 0) {
                moveFrameIncrementor *= -1;
              }
            }
          }
        }//still end
      }  //If not hit End


      //If Hit (when not guarding)
      else {

        //Reset all actions
        if (hitCounter == 0) {
          if (isStanding) {
            velX = -1*dir;
            setCurrentActionsFalse();
            isStanding = true;
            changeMoveSet(hitStand, 0.2);
          } else if (isCrouching) {
            velX = -1*dir;
            setCurrentActionsFalse();
            isCrouching = true;
            changeMoveSet(hitCrouch, 0.2);
          } else if (isJumping) {
            velX = -1*dir;
            isJumping = true;
            changeMoveSet(hitJump, 0.2);
          }
        }
        //If jumping, stay hit until hitting the ground. Else, wait until animation is complete.
        if (isJumping) {
          if (gravity()) {
            velX = 0;
            changeMoveSet(still, 0.4);
            resetCurrent();
            isStanding = true;
            isHit = false;
            hitCounter = 0;
          }
        } else if (moveSetComplete()) {
          velX = 0;
          if (isStanding) {
            if (isWalking) {
              changeMoveSet(walk, 0.4);
            } else {
              changeMoveSet(still, 0.4);
            }
            isHit = false;
            hitCounter = 0;
          } else if (isCrouching) {
            changeMoveSet(crouch, 0.2);
            moveFramePoint = 3;
            isHit = false;
            hitCounter = 0;
          }
        } else {
          hitCounter++;
        }
      }
    }

    //Update past position and action
    updateLastAction();

    updateLoc();


    //Increment frame
    moveFramePoint += moveFrameIncrementor;
    moveFrame = (int) moveFramePoint % (moveIndexStop - moveIndexStart + 1);

    //Select image for display
    img = moveSets.get( (moveIndexStart + moveFrame) );
  }//end update

  void display(int middleX) {
    //print("\n Frame Start: " + moveIndexStart + "    Frame Stop: " + moveIndexStop);
    //print("\n Frame: " + moveFrame + "    Frame Inc: " + moveFrameIncrementor);
    //print("\n isWalking: " + isWalking + "    wasWalking: " + wasWalking + "\n isJumping: " + isJumping + "    wasJumping: " + wasJumping +
    //  "\n isStill(): " + isStill() +"    wasStill(): " + wasStill() + "\n isAttacking: " + isAttacking + "    wasAttacking: "
    //  + wasAttacking + "\n isStanding: " + isStanding + "    wasStanding: " + wasStanding);
    imageMode(CENTER);

    //Here, the player will stop moving when reaching the middle but the screen will keep moving, giving
    //the illusion of a "sidescroller"
    if (dir == 1) {
      image(img, locX-middleX, locY, imgWidth, imgHeight);
    } else {
      image(img, locX-middleX, locY, imgWidth, imgHeight, 928, 0, 0, 640);
    }

    //Display HUD
    statBar();

    //Display notifications (if exist)
    if (displayText != "") {
      if (displayCount < 20) {
        stroke(0);
        fill(240);
        textSize(15);
        textAlign(CENTER, CENTER);
        if (isCrouching) {
          text(displayText, locX-middleX, locY - imgHeight/6);
        } else {
          text(displayText, locX-middleX, locY - imgHeight/4);
        }
        displayCount++;
        noStroke();
      } else {
        displayText = "";
        displayCount = 0;
      }
    }
  }//end display
}

//Enemy Class
class Enemy extends Player {

  //This number decides which function is called (which move)
  int completeCount;
  //Distance before stopping
  int stopDistance;
  //Is boss?
  boolean isBoss = false;
  //Keep from shooting constantly
  int rangeCounter = 0;

  //Constructor (location, image size, level)
  public Enemy(int locX, int locY, int level) {
    super(locX, locY);
    maxHP = 100*level;            //total health points
    currentHP = maxHP;        //current health points
    maxMP = 10*level;             //total mana points
    currentMP = maxMP;         //current mana points
    maxDP = 20*level;             //damage points
    blockCount = 5;          //number of blocks (guards) available; refreshes on level up
    this.locX = locX;
    this.locY = locY;
    this.currentLevel = level;
    walkSpeed = (int) random(2, 6);
    stopDistance = (int) random(imgWidth/3, imgWidth/2);
    maxDP /= 2;    //I had to do this because they were too strong
  }

  //Show health bar


  //Distance between player
  float distance(Player player) {
    return abs(player.locX - locX);
  }

  //Distance between ally
  float distanceAlly(Enemy ally) {
    return abs(ally.locX - locX);
  }

  //Jump
  void jump() {
    isJumping = true;
  }

  //Crouch
  void crouch() {
    isCrouching = true;
  }

  //Walk Left
  void walkLeft() {
    isWalking = true;
    dir = -1;
  }

  //Walk Right
  void walkRight() {
    isWalking = true;
    dir = 1;
  }

  //Stop Walking
  void stopWalking() {
    isWalking = false;
    velX = 0;
  }

  //Attack (given type argument)
  void attack(int attackType) {
    isAttacking = true;
    this.attackType = attackType;
  }

  //Guard
  void guard() {
    isGuarding = true;
  }

  //Stop guarding
  void stopGuard() {
    isGuarding = false;
  }

  //Update location of enemy
  void updateLoc() {
    locX += velX/2;
    locY += velY/2;
  }

  //Enemy update
  void enemyUpdate(Player player, ArrayList<Projectile> projectiles) {

    //Always face player after an animation
    if (moveSetComplete()) {
      if (player.locX > locX) {
        dir = 1;
      } else if (player.locX < locX) {
        dir = -1;
      }
    }
    //If player is not in hitting range, walk towards player. Jump if player is jumping.
    if (distance(player) >= stopDistance) {
      //Finish animation before going after player when they're out of range
      if (moveSetComplete() || isGuarding) {
        setCurrentActionsFalse();
        rangeCounter++;
        //Ranged attack (only do if you're confident in skills)
        if (isBoss) {
          if (rangeCounter > 50 && rand.nextInt(18) == 4) {
            attack(1);
            rangeCounter = 0;
          }
        }
        //Otherwise, walk towards player
        else if (player.locX > locX) {
          walkRight();
        } else if (player.locX < locX) {
          walkLeft();
        }
        //Jump after player if they jump  
        if (distance(player) < imgWidth/2 && player.locY > locY) {
          jump();
        }
      }
    }


    //Once in hitting range, select a move randomly (attack or guard)
    else if (distance(player) < stopDistance) {
      //If next to ally, movement will stop

      if (moveSetComplete()) {
        completeCount++;
      }
      if (isWalking) {
        isWalking = false;
        changeMoveSet(still, 0.4);
      } else if ( completeCount > 30 ) {
        setCurrentActionsFalse();
        int diceRoll = rand.nextInt(6);
        //Boss attacks more frequently and more variety
        if (isBoss) {
          if (diceRoll%3 == 0) {
            attack(0);
          } else if (diceRoll%3 == 1) {
            attack(1);
          } else if (diceRoll%3 == 2) {
            attack(2);
          } else if (diceRoll%2 == 1) {
            guard();
          }
        } else {
          if (diceRoll%3 == 0) {
            attack(0);
          } else if (diceRoll%2 == 1) {
            guard();
          }
        }
        //Reset completeCount
        completeCount = 0;
      }
    }


    //Damage Calculations

    //If enemy is in hitting range
    if (distance(player) < stopDistance) {
      //If player is attacking, enemy takes damage once if player is facing enemy. This increases player's MP by 5.
      if (player.isAttacking && !player.wasAttacking && (player.dir*(locX-player.locX) >= 0) ) {
        dir = player.dir*-1;
        float playerDamage = player.maxDP;
        //Amount of damage depends on the attack type (normal < burst < knockback), and if the enemy is guarding
        if (player.attackType == 0) {
        } else if (player.attackType == 1) {
          playerDamage *= 1.5;
        } else if (player.attackType == 2) {
          playerDamage *= 2;
        }
        if (isGuarding) {
          currentHP -= playerDamage;
        } else {
          takeDamage(playerDamage);
        }
        player.currentMP += 5;
        //If excess keep at top
        if (player.currentMP > player.maxMP) {
          player.currentMP = player.maxMP;
        }
      }
      //If enemy is attacking, player takes damage once if enemy is facing player
      if (isAttacking && !wasAttacking && (dir*(player.locX - locX) >= 0)) {
        //If guarding, damage is reduced
        if (player.isGuarding) {
          if (player.blockCount > 0) {
            player.currentHP -= maxDP/2;
            player.blockCount -= 1;
            print(player.blockCount);
          } else {
            player.currentHP -= maxDP;
            player.displayNotif("Shield Broken!");
          }
        }
        //Else, take damage
        else {
          player.dir = dir*-1;
          player.takeDamage(maxDP);
        }
      }
    }

    //Update actions
    update(false, projectiles);



    // print("\n Frame Start: " + moveIndexStart + "    Frame Stop: " + moveIndexStop );
    // print("\n Frame: " + moveFrame + "    Frame Inc: " + moveFrameIncrementor + "    Frame Point: " + moveFramePoint);
    // print("\n isWalking: " + isWalking + "    wasWalking: " + wasWalking + "\n isJumping: " + isJumping + "    wasJumping: " + wasJumping +
    //   "\n isStill(): " + isStill() +"    wasStill(): " + wasStill() + "\n isAttacking: " + isAttacking + "    wasAttacking: "
    //   + wasAttacking + "\n isStanding: " + isStanding + "    wasStanding: " + wasStanding + "\n isGuarding: " + isGuarding + "    wasGuarding: " + wasGuarding);
  }

  void display(int middleX) {
    //print("\n Frame Start: " + moveIndexStart + "    Frame Stop: " + moveIndexStop);
    //print("\n Frame: " + moveFrame + "    Frame Inc: " + moveFrameIncrementor);
    //print("\n isWalking: " + isWalking + "    wasWalking: " + wasWalking + "\n isJumping: " + isJumping + "    wasJumping: " + wasJumping +
    //  "\n isStill(): " + isStill() +"    wasStill(): " + wasStill() + "\n isAttacking: " + isAttacking + "    wasAttacking: "
    //  + wasAttacking + "\n isStanding: " + isStanding + "    wasStanding: " + wasStanding);
    imageMode(CENTER);

    //Here, the player will stop moving when reaching the middle but the screen will keep moving, giving
    //the illusion of a "sidescroller"
    if (dir == 1) {
      image(img, locX-middleX, locY, imgWidth, imgHeight);
    } else {
      image(img, locX-middleX, locY, imgWidth, imgHeight, 928, 0, 0, 640);
    }
  }//end display
}

//Projectile Class (just little orbs)
class Projectile extends Entity {
  //Existence timer
  int timer = 0;
  //Is from player or enemy
  boolean isFromPlayer;
  //Is knockback or normal
  boolean isKnockback;
  //Damage of projectile
  float damage;

  Projectile(float locX, float locY, boolean isFromPlayer, boolean isKnockback, float damage, int dir) {
    this.locX = locX;
    this.locY = locY;
    this.isFromPlayer = isFromPlayer;
    this.isKnockback = isKnockback;
    this.damage = damage;
    this.dir = dir;
  }

  void update() {
    //Initial speed setting
    if (timer == 0) {
      if (isKnockback) {
        velX = 3*dir;
        locY = locY + locY/4;
      } else {
        velX = 5*dir;
      }
    }
    //Update location, timer, and velocity
    locX += velX;
    timer++;
    velX *= 1.05;
  }

  //Display
  void display(int middleX) {
    //print("\n X: " + locX + "    Y:" + locY + "\n");
    if (!isKnockback) {
      fill(240);
      circle(locX-middleX, locY, 10);
     } else {
       fill(240);
       circle(locX-middleX, locY + locY/4, 10);
     }
  }
}

//Stage Class
class Stage {
  float stageWidth;
  float stageHeight;
  int middleX;
  int level;                  //level of enemies
  int score;
  int timer;

  boolean bossStage;  //true if boss stage
  boolean newStage;    //gets set to false when the stage starts
  boolean stageEnd;    //End of stage?
  boolean gameClear;   //End of game?

  Player player;

  //Store objects of flying objects, enemies, and backgrounds
  ArrayList<Projectile> projectiles = new  ArrayList<Projectile>();
  ArrayList<Projectile> usedProjectiles = new  ArrayList<Projectile>();
  ArrayList<Enemy> enemies = new ArrayList<Enemy>();
  ArrayList<Enemy> deadEnemies = new ArrayList<Enemy>();
  int background = 0;

  Stage(int level, Player p, int background, boolean bossStage) {

    stageWidth = screenWidth*3;
    stageHeight = screenHeight;
    middleX = 0;
    score = 0;

    this.bossStage = bossStage;
    newStage = true;
    gameClear = false;
    stageEnd = false;

    projectiles = new  ArrayList<Projectile>();
    usedProjectiles = new  ArrayList<Projectile>();

    enemies = new ArrayList<Enemy>();
    deadEnemies = new ArrayList<Enemy>();

    this.level = level;
    this.player = p;
    this.background = background;
  }

  //Update
  void update() {

    //Check if game has been cleared
    if (bossStage && stageEnd) {
      gameClear = true;
    }

    //Initialize enemies
    if (newStage) {
      //If boss stage, spawn boss
      if (bossStage) {
        Enemy boss = new Enemy(rand.nextInt((int)stageWidth), (ground - characterImageHeight/2), level*5);
        //Spawns the other character that wasn't selected at beginning
        boss.linkImageSets(characters.get( (mainCharSelect+1)%2 ) );
        enemies.add(boss);
        newStage = false;
      }
      //Else, load enemies
      else {
        for (int i = 0; i < 5; i++) {
          print(level);
          Enemy temp = new Enemy(rand.nextInt((int)stageWidth), (ground - characterImageHeight/2), level);
          temp.linkImageSets(characters.get( rand.nextInt(2) + 2 ));
          enemies.add(temp);
          newStage = false;
        }
      }
    }
    if (!bossStage) {
      //Every 300 counts, spawn a random enemy in a random location if less than 5 (in front of the player)
      if (enemies.size() < 5) {
        if (enemies.size() == 0 || frameCount%300 == 0) {
          Enemy temp = new Enemy(rand.nextInt((int)stageWidth), (ground - characterImageHeight/2), level);
          temp.linkImageSets(characters.get( rand.nextInt(2) + 2 ));
          enemies.add(temp);
        }
      }
    } 
    //If boss is killed, then game ends
    else {
      if (enemies.size() == 0) {
        gameClear = true;
      }
    }

      //Projectile updated to player
    for (Projectile p : projectiles) {
        //If timer is up, remove
      if (p.timer >= 60) {
        usedProjectiles.add(p);
        continue;
      }
        //Only update (don't calc) if player's
      if (p.isFromPlayer) {
        p.update();
      }
        //If not, check
      else {
        if (p.locX > (player.locX - player.imgWidth/8) && p.locX < (player.locX + player.imgWidth/8)) {
          if (p.locY < (player.locY+player.imgHeight/3)) {
              //If hit, do the relative amount of damage for attack type. Damagae is based on first enemy in array.
            player.dir = -1*p.dir;
              //Knockback remains for all 20 counts
            if (p.isKnockback) {
              if (player.isGuarding) {
                player.currentHP -= p.damage/2;
                player.blockCount--;
              } else {
                player.takeDamage(p.damage);
                player.locX -= player.dir;
              }
            }
              //burst disappears after hit
            else {
              if (player.isGuarding) {
                player.currentHP -= p.damage/2;
                player.blockCount--;
              } else {
                player.takeDamage(p.damage);
                player.locX -= player.dir;
              }
              usedProjectiles.add(p);
            }
          }
        }
        p.update();
      }
    }
    projectiles.removeAll(usedProjectiles);

      //Update enemies & projectiles and if dead, remove from game
    for (Enemy i : enemies) {
        //print("\n X: " + i.locX + "    Y:" + i.locY + "\n");
      for (Projectile p : projectiles) {
          //If enemy projectile, ignore
        if (!p.isFromPlayer) {
          continue;
        }
          //If not, compare locations
        else {
          if (p.locX > (i.locX - i.imgWidth/8) && p.locX < (i.locX + i.imgWidth/8)) {
            if (p.locY < (i.locY+i.imgHeight/3)) {
                //If hit, do the relative amount of damage for attack type
              i.dir = -1*p.dir;
                //Knockback remains for all counts, if guarding you only take damage
              if (p.isKnockback) {
                if (i.isGuarding) {
                  i.currentHP -= p.damage/2;
                } else {
                  i.takeDamage(p.damage);
                  i.locX -= i.dir;
                }
              }
                //burst disappears after hit
              else {
                if (i.isGuarding) {
                  i.currentHP -= p.damage/2;
                } else {
                  i.takeDamage(p.damage);
                  i.locX -= i.dir;
                }

                usedProjectiles.add(p);
              }
            }
          }
        }
      }
        //Update enemies
      i.enemyUpdate(player, projectiles);
        //Check if enemies are dead
      if (i.playerDeath && i.moveSetComplete()) {
        player.currentEXP += i.currentLevel*3;
        deadEnemies.add(i);
        score++;
      }
    }
      //Remove all dead enemies and used projectiles
    enemies.removeAll(deadEnemies);
    projectiles.removeAll(usedProjectiles);

      //Update player
    player.update(true, projectiles);



      //Update enemies and damage
      //Iterating through actions to calculate damage


      //This will move the screen along with the player
    if (player.locX > screenWidth/2 && player.locX < stageWidth) {
      middleX += player.velX;
    }
      //If the player isn't in the middle of the screen (moving forward), then they can go backwards
    else if (player.locX <= screenWidth/2) {
      middleX = 0;
    }
  }

    //Display
  void display() {
    update();

      //Display Background
    int imgNumber = 4;

      //Using the middleX to make the background "move"
    for (PImage img : backgroundSets.get(background)) {
      int x = (int)(middleX/imgNumber) % (int)screenWidth;

      imageMode(CORNER);
      image(img, 0, 0, screenWidth - (x), screenHeight, (int) x, 0, (int) screenWidth, (int) screenHeight);
      image(img, screenWidth - x, 0, x, screenHeight, 1, 0, (int) x, (int) screenHeight);
      imgNumber--;
    }
      //Make ground (this lowers the lag)
      //fill(10);
      //rect(0,ground - 10, screenWidth, screenHeight - (ground - 10));


      //Display Projectiles
    for (Projectile p : projectiles) {
      p.display(middleX);
    }

      //Display Enemies
    for (Enemy i : enemies) {
      i.display(middleX);
    }

    //Display
    if (bossStage) {
      if (timer < 100) {
        textAlign(CENTER);
        textSize(40);
        fill(255, 0, 0);
        text("BOSS INCOMING", screenWidth/2, screenHeight/4);
        timer++;
      }
    }

      //If player reaches edge of stage, give choice to stay or progress
    if (player.locX >= stageWidth - player.imgWidth) {
      if (player.locX >= stageWidth) {
        player.locX = stageWidth;
      }
      textAlign(CENTER, CENTER);
      fill(0);
      textSize(20);
      text("Move to next stage? \n Press SPACE to proceed, go back to stay in stage.", screenWidth/2, screenHeight/4);
        //Gives option to move to next stage
      stageEnd = true;
    } else {
      stageEnd = false;
    }

      //Display Player
    player.display(middleX);
  }
}

  //Game Class
class Game {
  int gameState = 6;
    int score;        //aka number of enemies killed
    int currentLevel = 1;
    int backgroundSet = 0;
    int stageNum = 0;

    //Setting main menu image
    int menuImageNum = 0;
    PImage menuImage = new PImage();
    boolean newGame = true;

    //Frame details for pre-game character selection
    int frame1 = 0;
    float framePoint1 = 0;
    float frameInc1 = 0.3;
    int frame2 = 0;    
    float framePoint2 = 0;
    float frameInc2 = 0.3;
    boolean characterSelected = false;

    //Mouse released
    boolean mouseClicked = false;
    boolean mouseReleased = false;

    boolean newStage = true;
    Stage stage;


    Player player;


    Game(Player player) {
      //Set up character and stage 
      this.player = player;
      stage = new Stage(1, player, backgroundSet, false);
    }

    void nthMenuButton(int n, int game, float firstButtonX1, float firstButtonX2, float firstButtonY1, float firstButtonY2, String word) {

      //Increment n times
      for (int i = 0; i < n; i++) {
        firstButtonY1 = firstButtonY2 + screenHeight/48;
        firstButtonY2 = firstButtonY1 + screenHeight/12;
      }

      if ( ( firstButtonX1 < mouseX && mouseX < firstButtonX2) && (firstButtonY1 < mouseY && mouseY < firstButtonY2) ) {
        fill(230);
        //If mouse is pressed while hovering over option, return gameState
        if (mouseClicked) {
          //Add sound effect of button being selected (hovered over)
          button.play();
          mouseClicked = false;
          mouseReleased = false;
          gameState = game;
        }
      } else {
        fill(200);
      }
      rect(firstButtonX1, firstButtonY1, (firstButtonX2 - firstButtonX1), (firstButtonY2 - firstButtonY1) );
      textAlign(CENTER, CENTER);
      textFont(font);
      textSize(20);
      fill(100);
      text(word, firstButtonX1 + (firstButtonX2 - firstButtonX1)/2, firstButtonY1 + (firstButtonY2 - firstButtonY1)/2);

      //Stay in Main Menu if no option is selected
    }

    void stopMusic(ArrayList<SoundFile> music) {
      for (SoundFile i : music) {
        if(i.isPlaying()){i.stop();}
      }
    }

    //Play Function
    void play() {

      //Music
      //Stop others, play right file
      if (gameState <= 2 && (newGame || !openingOST.isPlaying()) ) {
        if(victory.isPlaying()){victory.stop();}
        if(defeat.isPlaying()){defeat.stop();}
        if(openingOST.isPlaying()){openingOST.stop();}
        stopMusic(stageMusic);
        if (!openingOST.isPlaying()){
          openingOST.play();
        }
      }
      //Game
      else if (gameState == 3 && stage.newStage) {
        if(victory.isPlaying()){victory.stop();}
        if(defeat.isPlaying()){defeat.stop();}
        if(openingOST.isPlaying()){openingOST.stop();}
        stopMusic(stageMusic);
        //If boss, play boss music
        if (stage.bossStage) {
          stageMusic.get(2).play();
        }
        //Else select normal track
        else {
          if(!stageMusic.get(stageNum%2).isPlaying()){stageMusic.get(stageNum%2).play();}
        }
      }
      //Game Over
      else if (gameState == 4 && !defeat.isPlaying()) {
        if(victory.isPlaying()){victory.stop();}
        stopMusic(stageMusic);
        defeat.play();
      }
      //Victory
      else if (gameState == 5 && !victory.isPlaying()) {
        if(defeat.isPlaying()){defeat.stop();}
        stopMusic(stageMusic);
        victory.play();
      }

      //Menu
      if (gameState == 0) {
        //Choose background for screen (random every 500 counts)
        if (newGame || frameCount%500 == 0) {
          menuImageNum = rand.nextInt(menuBackgrounds.size());
          menuImage = menuBackgrounds.get(menuImageNum);
          newGame = false;
        }
        imageMode(CENTER);
        image(menuImage, screenWidth/2, screenHeight/2, screenWidth, screenHeight);



        //Display Main Menu
        fill(230);
        rect(screenWidth/20, screenHeight/9, (5*screenWidth/12), screenHeight/6);
        textAlign(CENTER, CENTER);
        textSize(40);
        fill(100);
        text("SAO: ReVISIT", screenWidth/20 + (5*screenWidth/12) / 2, screenHeight/9 + screenHeight/12 );

        //Set location of first button
        float firstButtonX1 = screenWidth/20;
        float firstButtonX2 = screenWidth/20 + screenWidth/4;
        float firstButtonY1 = screenHeight/2;
        float firstButtonY2 = screenHeight/2+screenHeight/12;

        //Start Game
        nthMenuButton(0, 2, firstButtonX1, firstButtonX2, firstButtonY1, firstButtonY2, "Start");

        //Instructions
        nthMenuButton(1, 1, firstButtonX1, firstButtonX2, firstButtonY1, firstButtonY2, "Instructions");

        //Exit
        nthMenuButton(2, 7, firstButtonX1, firstButtonX2, firstButtonY1, firstButtonY2, "Exit");

        //Change Background
        nthMenuButton(3, 6, firstButtonX1, firstButtonX2, firstButtonY1, firstButtonY2, "Change Background");
      }


      //Instructions Screen
      else if (gameState == 1) {
        //Display instructions
        background(0);
        textAlign(CENTER);
        textSize(32);
        fill(200);
        text("Instructions", screenWidth/2, screenHeight/8);
        textAlign(LEFT);
        textSize(12);
        text("Move around with WASD. \nGuard: Right Hold (Mouse)\n" +
          "Guard decreases damage received, and prevents player from flinching.\n\nNormal Attack: Left Click (Mouse)" +"Specials: require MP, but are stronger.\n" + 
          "Burst Attack: X (5 MP)   \nUltra Attack: C (10 MP)\n\nLevel up to increase and restore HP, MP, and Damage.\n\n" +
          "Press SPACE to go back to Main Menu.", screenWidth/20, screenHeight/4, screenWidth/3, screenHeight-screenHeight/12);

        //Let player test moves and stuff
        player.linkImageSets(characters.get(0));
        player.locX = screenWidth - screenWidth/4;
        player.update(true, stage.projectiles);
        player.display(stage.middleX);
        player.currentMP = player.maxMP;
      }

      //Character Selection
      else if (gameState == 2) {
        background(0);
        imageMode(CENTER);
        //Set up selection for character
        CharacterFile fileOne = characters.get(0);
        CharacterFile fileTwo = characters.get(1);

        //If on right, highlight right (krt)
        if ((5*screenWidth/8 < mouseX && mouseX < 7*screenWidth/8)) {
          fill(30);
          rect(screenWidth/2, 0, screenWidth/2, screenHeight);
          framePoint1 += frameInc1;
          frame1 = (int) (framePoint1 % fileOne.numImagesExtra);
          image(fileOne.moveSetsExtra.get(frame1), 3*screenWidth/4, screenHeight/2);
          if (mouseClicked) {
            mouseClicked = false;
            mouseReleased = false;
            mainCharSelect = 0;
            //Link player
            if (!characterSelected) {
              player.linkImageSets(characters.get(mainCharSelect));
              characterSelected = true;
            }
            gameState = 3;
          }
        }
        //Else, highlight left (asn)
        else if ((screenWidth/8 < mouseX && mouseX < 3*screenWidth/8)) {
          fill(30);
          rect(0, 0, screenWidth/2, screenHeight);
          framePoint2 += frameInc2;
          frame2 = (int) (framePoint2 % fileTwo.numImagesExtra);
          image(fileTwo.moveSetsExtra.get(frame2), screenWidth/4, screenHeight/2);
          if (mouseClicked) {
            mouseClicked = false;
            mouseReleased = false;
            mainCharSelect = 1;
            //Link player
            if (!characterSelected) {
              player.linkImageSets(characters.get(mainCharSelect));
              characterSelected = true;
            }
            gameState = 3;
          }
        }

        textAlign(CENTER);
        textSize(32);
        fill(200);
        text("Select a Character.", screenWidth/2, screenHeight/8);
      }

      //Stage
      else if (gameState == 3) {

        //Reset Player's location and basic stats
        if (newStage) {
          player.locX = characterImageWidth/2;
          player.locY = (ground - characterImageHeight/2);
          player.currentHP = player.maxHP; 
          player.currentMP = player.maxMP;
          player.blockCount = 5;
          newStage = false;
        }
        stage.display();
        

        //If player dies, move to game over.
        if (player.playerDeath && player.moveSetComplete()) {
          gameState = 4;
        }

        //If game is complete
        if (stage.gameClear) {
          gameState = 5;
        }
      }

      //Game Over & Reset (with space bar)
      else if (gameState == 4) {
        background(0);
        //Display level & score
        textAlign(CENTER, CENTER);
        fill(100);
        textSize(32);
        text("Defeat... \nLevel: " + player.currentLevel + "  Stage: " + stageNum + "  Score: " + score + "\n\n Press SPACE to return to menu.", screenWidth/2, screenHeight/2 );
      }

      //Game Complete
      else if (gameState == 5) {
        //Game end
        background(0);
        //Display level & score
        textAlign(CENTER, CENTER);
        fill(100);
        textSize(32);
        text("Congratulations! You Win! \nLevel: " + player.currentLevel + "  Score: " + score + "\n\n Press SPACE to return to menu.", screenWidth/2, screenHeight/2 );
      }

      //Change Background
      else if (gameState == 6) {
        menuImageNum = rand.nextInt(menuBackgrounds.size());
        menuImage = menuBackgrounds.get(menuImageNum);
        //Move to main menu
        gameState = 0;
      }

      //Exit
      else if (gameState == 7) {
        exit();
      }
    }
  }

  //Pair Class (for pairing elements)
  class Tuple {
    final int x;
    final int y;
    Tuple(int x, int y) {
      this.x = x;
      this.y = y;
    }
  }

  //Character File Class (for setup)
  class CharacterFile {
    //Used as identifier for image loading
    String name;
    //Number of images associated with character (normal)
    int numImages;
    //Number of images associated with character (extra)
    int numImagesExtra;
    //Number of SFX files
    int numSFX;
    //Array of all in-game movesets for character
    ArrayList<PImage> moveSets = new ArrayList<PImage>();
    //Array of all pre-game movesets for character
    ArrayList<PImage> moveSetsExtra = new ArrayList<PImage>();
    //Array of character sfx
    ArrayList<SoundFile> sfx = new ArrayList<SoundFile>();

    CharacterFile(String name, int numImages, int numImagesExtra, int numSFX) {
      this.name = name;
      this.numImages = numImages;
      this.numImagesExtra = numImagesExtra;
      this.numSFX = numSFX;
    }
  }

  //===================================================================================================================
  //===================================================================================================================
  //Functions



  //===================================================================================================================
  //===================================================================================================================
  //Game Execution

  void draw() {
    game.play();
  }

  //keypressed
  //Only works when player is in instruction mode or in the game
  void keyPressed() {

    //down (D)
    if (keyCode == 83) {
      if (game.gameState == 1 || game.gameState == 3) {
        if (player.isStanding && (player.isStill() || player.wasStill() || player.wasWalking) ) {
          player.isCrouching = true;
          player.isStanding = false;
        }
      }
    }

    //up (W)
    else if (keyCode == 87) {
      if (game.gameState == 1 || game.gameState == 3) {
        if (player.isStill() || player.wasWalking) {
          player.isJumping = true;
        }
      }
    }

    //left (A)
    else if (keyCode == 65) {
      if (game.gameState == 1 || game.gameState == 3) {
        if (player.isStanding && !player.isCrouching && (player.isStill() || player.wasStill() || player.wasWalking) ) {
          player.isWalking = true;
          player.dir = -1;
        }
      }
    }

    //right (D)
    else if (keyCode == 68) {
      if (game.gameState == 1 || game.gameState == 3) {
        if (player.isStanding && !player.isCrouching && (player.isStill() || player.wasStill() || player.wasWalking)) {
          player.isWalking = true;
          player.dir = 1;
        }
      }
    }

    //burst attack (C)
    else if (keyCode == 88) {
      if (game.gameState == 1 || game.gameState == 3) {
        if (player.currentMP >= 5 && !player.isJumping && (player.isStill() || player.wasStill() || player.wasWalking) ) {
          player.isAttacking = true;
          player.attackType = 1;
        }
      }
    }

    //knockback attack (V)
    else if (keyCode == 67) {
      if (game.gameState == 1 || game.gameState == 3) {
        if (player.currentMP >= 10 &&!player.isJumping && (player.isStill() || player.wasStill() || player.wasWalking) ) {
          player.isAttacking = true;
          player.attackType = 2;
        }
      } else if (keyCode == 89) {
        player.takeDamage(10);
      }
    }
  }

  void keyReleased() {

    //down (S)
    if (keyCode == 83) {
      if (game.gameState == 1 || game.gameState == 3) {
        if (!player.isJumping || !player.wasJumping) {
          player.isCrouching = false;
          if ((keyCode != 65 && keyCode != 68) && !player.wasJumping && !player.isAttacking || !player.wasAttacking) {
            player.isStanding = true;
          }
        }
      }
    }

    //left (A)
    else if (keyCode == 65) {
      if (game.gameState == 1 || game.gameState == 3) {
        player.isWalking = false;
      }
    }

    //right (D)
    else if (keyCode == 68) {
      if (game.gameState == 1 || game.gameState == 3) {
        player.isWalking = false;
      }
    }

    //SPACE -- RESET GAME OR NEW STAGE
    else if (keyCode == 32) {
      //Reset Game
      if (game.gameState == 1 || game.gameState == 4 || game.gameState == 5) {
        player = null;
        player = new Player(characterImageWidth/2, characterImageHeight/2+ground);
        game = new Game(player);
        game.gameState = 0;
        game.newGame = true;
      }
      //New Stage
      if (game.gameState == 3 && game.stage.stageEnd) {
        //Increase stage level and change background images
        game.currentLevel += levelInc;
        game.stageNum++;
        game.backgroundSet = (1 + game.backgroundSet) % 3;
        game.newStage = true;
        game.score += game.stage.score;
        //Boss on stage 4
        if (game.stageNum > 3) {
          game.stage = new Stage(game.currentLevel, player, game.backgroundSet, true);
        } else {
          game.stage = new Stage(game.currentLevel, player, game.backgroundSet, false);
        }
      }
    }
  }

  void mouseClicked() {
    //Attack
    if (mouseButton == LEFT) {
      if (game.gameState == 1 || game.gameState == 3) {
        if (!player.isJumping && (player.isStill() || player.wasStill() || player.wasWalking || player.isCrouching) ) {
          player.isAttacking = true;
          player.attackType = 0;
        }
      }
    }
  }

  void mousePressed() {
    if (mouseButton == LEFT) {
      if ((game.gameState == 2 && game.mouseReleased) || game.gameState == 0) {
        game.mouseClicked = true;
      }
    } else if (mouseButton == RIGHT) {
      if (game.gameState == 1 || game.gameState == 3) {
        if (!player.isAttacking) {
          player.isWalking = false;
          player.isGuarding = true;
        }
      }
    }
  }

  void mouseReleased() {
    //This is for the character selection screen
    if (mouseButton == LEFT) {
      if (game.gameState == 2) {
        game.mouseReleased = true;
      }
    } 
    //This is for the game instructions/stage
    else if (mouseButton == RIGHT) {
      if (game.gameState == 1 || game.gameState == 3) {
        player.isGuarding = false;
      }
    }
  }
