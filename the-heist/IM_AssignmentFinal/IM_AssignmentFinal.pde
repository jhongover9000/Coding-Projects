//IM Assignment 11 (Final): Bank Heist.
//Joseph Hong
//Description: This is a game that simulates a bank heist. There are two stages, one a keypad and
//another a vault. I don't want to give hints, mostly because it's one of those things you need to
//figure out and win on your own through experience, but here are the instructions anyway.
//The keypad has 8 digits that you need to find by using the lights on the breadboard. The first light 
//represents a row, the second a column. You need to complete the entire pattern (16 lights) before
//you can enter the code.
//The vault is made up of three dials, each of which alternate amongst each other. Only when it's
//correct can you match the right number. Failing to do so will decrease the amount of time you have
//left. I recommend using headphones for the stage, as there is audio panning to help you know which
//dial is the one to use.
//When the timer runs out, you lose. If you're on the hardest difficulty, one mistake will end the game.
//Good luck! Btw the theme is Money Heist.
//=======================================================================================================================
//=======================================================================================================================
//Imports
import java.util.ArrayList;    //for the size-changing array
import java.util.Random;       //for selecting a random integer (as opposed to a float)
import java.io.File;
import processing.sound.*;
import processing.serial.*;		//import serial

//=======================================================================================================================
//=======================================================================================================================
//Global Variables and Setup

int screenWidth = 896;
int screenHeight = 504;

//Random Integer Generator
Random rand = new Random();

//UI Stuff for game
PFont font; 
SoundFile openingOST;
SoundFile button;
SoundFile stageOST1;
SoundFile stageOST2;
SoundFile bossOST;
SoundFile defeat;
SoundFile victory;

//Assets
PImage vaultDialImg;
PImage dollarBillImg;
ArrayList<SoundFile> vaultDialSounds;
SoundFile dialTick;
SoundFile dialClick;
SoundFile dialClack;
ArrayList<PImage> menuBackgrounds;

//Timer
int savedTime;
int timeRemaining = 300000;        //time, in milliseconds
int timeReducer = 100;
int displayCounter = 0;
boolean timerNew = true;

//Sesnors & Things
int distance;                            //distance sensor
ArrayList<Integer> passcodeCoords;       //light game
int buttonPressed;                       //buttons
boolean buttonPushed;                    //if button is being held down
int potPosition;                         //potentiometer

//Game game = new Game();
int dialLength = 10;
int[] keyPadInput;
int keyPadLength = 8;

//Checkers for Mouse
boolean mouseClicked;
boolean mouseReleased;

//Serial (from SerialCallResponse)
Serial myPort;                       // The serial port
int[] serialInArray = new int[3];    // Where we'll put what we receive
boolean firstContact = true;		 // Whether we've heard from the microcontroller
String val;

void setup() {
  size(896, 504);

  //Setup for Timer
  savedTime = millis();

  font = createFont("SAOUITT-Regular.ttf", 32);

  //Sound
  Sound s = new Sound(this);
  s.volume(0.2);
  openingOST = new SoundFile(this, "openOST.mp3");
  defeat = new SoundFile(this, "18 Sad.mp3");
  victory = new SoundFile(this, "victory.mp3");
  button = new SoundFile(this, "button_click.wav");
  vaultDialSounds = new ArrayList<SoundFile>();
  dialTick = new SoundFile(this, "dialTick.wav");
  dialClick = new SoundFile(this, "dialClick.wav");
  dialClack = new SoundFile(this, "dialClack.wav");
  vaultDialSounds.add(dialTick);
  vaultDialSounds.add(dialClick);
  vaultDialSounds.add(dialClack);

  //Images
  vaultDialImg = loadImage("vaultDial.png");
  dollarBillImg = loadImage("bill.png");
  menuBackgrounds =  new ArrayList<PImage>();
  loadMenuBackgrounds(7);

  //Serial
  String portName = Serial.list()[3];
  myPort = new Serial(this, portName, 9600);
  myPort.bufferUntil('\n');
}


//=======================================================================================================================
//=======================================================================================================================
//Functions

//Load Menu Backgrounds
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

void muteSounds(ArrayList<SoundFile> sounds) {
  for (SoundFile s : sounds) {
    if (s.isPlaying()) {
      s.stop();
    }
  }
}

void reduceTime(int timeReducer) {
  timeRemaining -= timeReducer;
}

//Display Time
void displayTime(int timeRemaining, int normalTime) {
  if (timeRemaining <= 0) {
    timeRemaining = 0;
    normalTime = timeRemaining;
  }
  textSize(15);
  textAlign(CENTER);
  //if player made mistake or time is less than 30 sec, turn red
  if (timeRemaining != normalTime || timeRemaining <= 30000) {
    fill(255, 0, 0);
  } else {
    fill(0);
  }
  textFont(font, 20);
  //seconds
  if ((timeRemaining/1000) % 60 > 9) {
    text(String.valueOf((timeRemaining/1000) % 60), screenWidth/2 + 50, 50);
  } else if ((timeRemaining/1000) % 60 > 0) {
    text("0" + String.valueOf((timeRemaining/1000) % 60), screenWidth/2 + 50, 50);
  } else {
    text("00", screenWidth/2 + 50, 50);
  }
  text(":", screenWidth/2, 50);
  //minutes
  if ((timeRemaining/(1000 * 60)) % 60 > 9) {
    text(String.valueOf((timeRemaining/(1000 * 60)) % 60), screenWidth/2 - 50, 50);
  } else if ((timeRemaining/(1000 * 60)) % 60 > 0) {
    text("0" + String.valueOf((timeRemaining/(1000 * 60)) % 60), screenWidth/2 - 50, 50);
  } else {
    text("00", screenWidth/2 - 50, 50);
  }
  //text(String.valueOf((timeRemaining/(1000 * 60)) % 60) + ":" + String.valueOf((timeRemaining/1000) % 60), screenWidth - 200, 50);
}

//=======================================================================================================================
//=======================================================================================================================
//Execution

//Autocrack Assets
//int num = 0;

Game game = new Game();

void draw() {
  //save time before update
  int normalTime = timeRemaining;
  int passedTime = millis();

  game.play();

  //if timer is new, change the amount of time depending on the difficulty
  if ((4 < game.gameState && game.gameState < 7)) {
    //when the stage is starting
    if ((timerNew) && game.newStageCounter > 199) {
      if (game.diffSelect == 0) {
        timeRemaining = 480000;   //8 min on easy
        timeReducer = 100;
      } else if (game.diffSelect == 1) {
        timeRemaining = 300000;   //6 min on normal
        timeReducer = 1000;
      } else {
        timeRemaining = 180000;   //3 min on hard
      }
      timerNew = false;
    }
    if (!game.newStage) {

      //on hardest difficulty, if you make a single mistake you lose automatically
      if (game.diffSelect == 2 && timeRemaining != normalTime) {
        game.gameState = 7;
      }

      //Update Time & savedTime
      int subtract = passedTime - savedTime;
      normalTime -= subtract;
      timeRemaining -= subtract;
      savedTime = passedTime;
      //println(normalTime + ":" + timeRemaining);
      displayTime(timeRemaining, normalTime);
    }
  }
}

//Serial Event
void serialEvent(Serial myPort) {
  //read the serial buffer:
  String myString = myPort.readStringUntil('\n');
  //if you got any bytes other than the linefeed:
  myString = trim(myString);
  //println(myString);
  myPort.clear();
  //split the string at the commas and convert the sections into integers:
  int sensors[] = int(split(myString, ','));

  //spent too much time debugging; drill phase was excluded
  //if (game.gameState == 2) {
  //  if (sensors.length > 1) {
  //    distance = sensors[0];
  //    if (sensors[1] == 1) {
  //      buttonPushed = true;
  //    } else { 
  //      buttonPushed = false;
  //    }
  //  }
  //}

  //if keypad
  if (game.gameState == 5) {
    if (sensors.length > 5) {
      keyPadInput = sensors;
      game.keypad.update(keyPadInput);
      //game.practiceKeyPad.update(keyPadInput);
    }
  }
  //if vault
  else if (game.gameState == 6) {
    if (1 < sensors.length && sensors.length < 3) {
      potPosition = sensors[0];
      buttonPressed = sensors[1];
      game.vault.update(potPosition, buttonPressed);
      //game.practiceDial.update(potPosition);
    }
  }
  if (game.gameState == 7 || game.gameState == 8) {
    myPort.write(12);
  } else {
    myPort.write(game.gameState);
  }
}

void mousePressed() {
  if (mouseButton == LEFT) {
    if ((game.gameState >= 2 && mouseReleased) || game.gameState == 0) {
      mouseClicked = true;
    }
  }
}

void mouseReleased() {
  //This is for the character selection screen
  if (mouseButton == LEFT) {
    if (game.gameState >= 2) {
      mouseReleased = true;
    }
  }
}

void keyReleased() {
  //SPACE -- RESET GAME
  if (keyCode == 32) {
    //Reset Game
    if (game.gameState == 1 || game.gameState == 4 || game.gameState == 7 || game.gameState == 8) {
      screenWidth = 896;
      screenHeight = 504;
      game = new Game();
      timeRemaining = 300000;
      timerNew = true;
    }
  }
}
