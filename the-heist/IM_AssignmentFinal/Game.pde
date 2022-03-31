 /*Game*/
/*This is the overarching class that contains all of the stages.*/

//Game
class Game {
  int gameState = 0;

  //Setting main menu image
  int menuImageNum;
  PImage menuImage = new PImage();
  boolean newGame;
  int diffSelect;

  boolean newStage;
  int newStageCounter;
  int backgroundSet;

  //practice stages cause errors for arduino sometimes so i commented out
  // KeyPad practiceKeyPad;
  // Dial practiceDial;

  VaultStage vault;
  KeyPad keypad;

  int colorChange;              //alternates colors for background on game over
  ObjectList objects;
  boolean gameClear;


  Game() {
    this.gameState = 0;
    this.menuImageNum = 0;
    this.newGame = true;

    this.diffSelect = 0;

    this.newStage = true;
    this.newStageCounter = 0;
    this.backgroundSet = 0;

    //practiceKeyPad = new KeyPad(2*screenWidth/3, screenHeight/3, 50, 4);
    //practiceDial = new Dial(0, 99, screenWidth/2, screenHeight/3, 300, 300);

    vault = new VaultStage();
    keypad = new KeyPad(screenWidth/2 - 75, screenHeight/3, 50, keyPadLength);

    this.colorChange = 0;
    this.objects = new ObjectList();
    this.gameClear = false;
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
        //Add sound effect of button being selected
        if (!button.isPlaying()) {
          button.play();
        }
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

  //Play Function
  void play() {

    //Music
    //Stop others, play right file
    if (gameState <= 2 && (newGame || !openingOST.isPlaying()) ) {
      if (victory.isPlaying()) {
        victory.stop();
      }
      if (defeat.isPlaying()) {
        defeat.stop();
      }
      if (!openingOST.isPlaying()) {
        openingOST.play();
        openingOST.amp(0.1);
      }
    }
    //Game (I want absolute silence, especially for the dial)
    else if ((3 < gameState && gameState < 9) && newStage) {
      if (victory.isPlaying()) {
        victory.stop();
      }
      if (defeat.isPlaying()) {
        defeat.stop();
      }
      if (openingOST.isPlaying()) {
        openingOST.stop();
      }
      //Game Over
      else if (gameState == 7 && !defeat.isPlaying()) {
        if (victory.isPlaying()) {
          victory.stop();
        }
        defeat.play();
        defeat.amp(0.1);
      }
      //Victory
      else if (gameState == 8 && !victory.isPlaying()) {
        if (defeat.isPlaying()) {
          defeat.stop();
        }
        victory.play();
        victory.amp(0.1);
      }
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
      text("the HEIST", screenWidth/20 + (5*screenWidth/12) / 2, screenHeight/9 + screenHeight/12 );

      //Set location of first button
      float firstButtonX1 = screenWidth/20;
      float firstButtonX2 = screenWidth/20 + screenWidth/4;
      float firstButtonY1 = screenHeight/2;
      float firstButtonY2 = screenHeight/2+screenHeight/12;

      //Start Game
      nthMenuButton(0, 4, firstButtonX1, firstButtonX2, firstButtonY1, firstButtonY2, "Depart");

      //Instructions
      nthMenuButton(1, 1, firstButtonX1, firstButtonX2, firstButtonY1, firstButtonY2, "Practice");

      //Exit
      nthMenuButton(2, 10, firstButtonX1, firstButtonX2, firstButtonY1, firstButtonY2, "Exit");

      //Change Background
      nthMenuButton(3, 9, firstButtonX1, firstButtonX2, firstButtonY1, firstButtonY2, "Change Background");
    }


    //Instructions (practice modes caused arduino to disconnect so I'm just writing them out)
    else if (gameState == 1) {
      //Display instructions
      background(0);
      textAlign(CENTER);
      textSize(32);
      fill(200);
      text("Instructions", screenWidth/2, screenHeight/8);
      textAlign(LEFT);
      textSize(20);
      text("THE KEYPAD \n Follow the pattern of lights and finish the game in order to get the full 8-digit code." +
        "\n \n THE VAULT \n Match the right numbers on the dials, which alternate, and crack the vault. The water cup" +
        " and sounds will guide you. \n \n Press SPACE to Return to Title.", screenWidth/20, screenHeight/4, screenWidth/3, screenHeight-screenHeight/12);
    }
    ////Drill practice
    //else if (gameState == 2) {
    //}

    // //Keypad practice 
    // else if (gameState == 2) {
    //  myPort.write(3);
    //  if (newStage) {
    //    if (newStageCounter < 200) {
    //      background(0);
    //      textSize(32);
    //      textAlign(CENTER, CENTER);
    //      text("PROLOGUE: THE BASICS (1)", screenWidth/2, screenHeight/2);
    //      newStageCounter++;
    //    } else {
    //      keyPadLength = 4;
    //      newStageCounter = 0;
    //      newStage = false;
    //    }
    //  } else {
    //    background(240);
    //    practiceKeyPad.display();
    //  }
    //  //pause a moment before moving to next stage
    //  if (practiceKeyPad.isComplete) {
    //    if (newStageCounter < 50) {
    //      newStageCounter++;
    //    } else {
    //      newStageCounter = 0;
    //      gameState = 3;
    //    }
    //  }
    // }

    // //Vault practice
    // else if (gameState == 3) {
    //  myPort.write(4);
    //  if (newStage) {
    //    if (newStageCounter < 200) {
    //      background(0);
    //      textSize(32);
    //      textAlign(CENTER, CENTER);
    //      text("PROLOGUE: BASICS (2)", screenWidth/2, screenHeight/2);
    //      newStageCounter++;
    //    } else {
    //      dialLength = 3;
    //      newStage = false;
    //    }
    //  } else {
    //    background(240);
    //    practiceDial.display();
    //  }
    //  //pause a moment before moving to main menu
    //  if (practiceDial.isUnlocked) {
    //    if (newStageCounter < 50) {
    //      newStageCounter++;
    //    } else {
    //      newStageCounter = 0;
    //      gameState = 0;
    //    }
    //  }
    // }

    //Difficulty Selection
    else if (gameState == 4) {
      background(0);
      //if on right, highlight right (shoplifter dif)
      if ((0 < mouseX && mouseX < screenWidth/3)) {
        fill(10, 100, 10);
        rectMode(CORNER);
        rect(0, 0, screenWidth/3, screenHeight);
        textAlign(CENTER);
        textSize(32);
        fill(200);
        text("Shoplifter", screenWidth/6, screenHeight/4);
        if (mouseClicked) {
          mouseClicked = false;
          mouseReleased = false;
          //set difficulty and change game state
          diffSelect = 0;
          gameState = 5;
        }
      }
      //else if, highlight middle (bank robber)
      else if ((screenWidth/3+1 < mouseX && mouseX < 2*screenWidth/3)) {
        fill(10, 10, 100);
        rectMode(CORNER);
        rect(screenWidth/3, 0, screenWidth/3, screenHeight);
        textAlign(CENTER);
        textSize(32);
        fill(200);
        text("Bank Robber", screenWidth/2, screenHeight/4);
        if (mouseClicked) {
          mouseClicked = false;
          mouseReleased = false;
          //set difficulty and change game state
          diffSelect = 1;
          gameState = 5;
        }
      }
      //else, highlight left (master thief dif)
      else if ((2*screenWidth/3+1 < mouseX && mouseX < screenWidth)) {
        fill(100, 10, 10);
        rectMode(CORNER);
        rect(2*screenWidth/3, 0, screenWidth/3, screenHeight);
        textAlign(CENTER);
        textSize(32);
        fill(200);
        text("Phantom Thief", 5*screenWidth/6, screenHeight/4);
        if (mouseClicked) {
          mouseClicked = false;
          mouseReleased = false;
          //set difficulty and change game state
          diffSelect = 2;
          gameState = 5;
        }
      }
      textAlign(CENTER);
      textSize(32);
      fill(200);
      text("Select Difficulty \n \n \n \n \n \n \n \n Press SPACE to Return to Title.", screenWidth/2, screenHeight/8);
    }

    // //Drill Stage
    // else if (gameState == 6) {
    //   if (newStage) {

    //   }
    // else{
    //   background(240);
    // stage.display();}


    //   //If time runs out, move to game over.
    //   if (timeRemaining == 0) {
    //     gameState = 4;
    //   }

    //   //If stage is complete
    //   if (drill.isComplete) {
    //     gameState = 5;
    //   }
    // }
    //Keypad Stage
    else if (gameState == 5) {
      if (newStage) {
        if (newStageCounter < 200) {
          background(0);
          fill(255);
          textSize(32);
          textAlign(CENTER, CENTER);
          text("CHAPTER 1: THE KEYPAD", screenWidth/2, screenHeight/2);
          newStageCounter++;
        } else {
          newStageCounter = 0;
          newStage = false;
        }
      } else {
        background(240);
        //on hardest difficulty, if you make a single mistake you lose automatically
        if (game.diffSelect == 2 && keypad.wrongAnswer) {
          game.gameState = 7;
        }
        keypad.display();
      }
      //if time runs out end game
      if (timeRemaining <= 0) {
        gameState = 7;
      }
      //pause a moment before moving to next stage
      if (keypad.isComplete) {
        if (newStageCounter < 50) {
          newStageCounter++;
        } else {
          newStage = true;
          newStageCounter = 0;
          gameState = 6;
        }
      }
    }
    //Vault Stage
    else if (gameState == 6) {
      if (newStage) {
        if (newStageCounter < 200) {
          background(0);
          fill(255);
          textSize(32);
          textAlign(CENTER, CENTER);
          text("CHAPTER 2: THE VAULT", screenWidth/2, screenHeight/2);
          newStageCounter++;
        } else {
          newStageCounter = 0;
          newStage = false;
        }
      } else {
        background(240);
        //on hardest difficulty, if you make a single mistake you lose automatically
        if (game.diffSelect == 2 && vault.wrongAnswer) {
          game.gameState = 7;
        }
        vault.display();
      }
      //if time runs out end game
      if (timeRemaining <= 0) {
        gameState = 7;
      }
      //pause a moment before moving to next stage
      if (vault.isComplete) {
        if (newStageCounter < 50) {
          newStageCounter++;
        } else {
          newStage = true;
          newStageCounter = 0;
          gameState = 8;
        }
      }
    }

    //Game Over & Reset (with space bar)
    else if (gameState == 7) {
      background(0);
      //Display level & score
      textAlign(CENTER, CENTER);
      fill(255);
      textSize(32);
      String time = "";
      //display time
      if ((timeRemaining/(1000 * 60)) % 60 > 9) {
        time += String.valueOf((timeRemaining/(1000 * 60)) % 60);
      } else if ((timeRemaining/(1000 * 60)) % 60 > 0) {
        time += "0" + String.valueOf((timeRemaining/(1000 * 60)) % 60);
      } else {
        time += "00";
      }
      time += ":";
      if ((timeRemaining/1000) % 60 > 9) {
        time += String.valueOf((timeRemaining/1000) % 60);
      } else if ((timeRemaining/1000) % 60 > 0) {
        time += "0" + String.valueOf((timeRemaining/1000) % 60);
      } else {
        time += "00";
      }
      text("You Lose... \n Time: "+ time + "\n\n Press SPACE to return to menu.", screenWidth/2, screenHeight/2 );
    }

    //Game Complete
    else if (gameState == 8) {
      if (newStage) {
        if (newStageCounter < 150) {
          //Game end
          background(0);
          newStageCounter++;
        } else {
          newStage = false;
          newStageCounter = 0;
          if (!victory.isPlaying()) {
            victory.play();
          }
        }
      } else {
        //Display gameEnd
        background(0);
        textAlign(CENTER, CENTER);
        objects.updateAndDisplay();
        fill(255);
        textSize(100);
        text("the HEIST", screenWidth/2, screenHeight/2);
        newStageCounter++;
        if (newStageCounter > 1000) {
          tint(255, 110);
          objects.updateAndDisplay();
          noTint();
          text("the HEIST", screenWidth/2, screenHeight/2);
          textSize(20);
          fill(100);
          text("press SPACE to restart", screenWidth/2, screenHeight/2 + 70);
        }
      }
    }

    //Change Background
    else if (gameState == 9) {
      menuImageNum = rand.nextInt(menuBackgrounds.size());
      menuImage = menuBackgrounds.get(menuImageNum);
      //Move to main menu
      gameState = 0;
    }

    //Exit
    else if (gameState == 10) {
      exit();
    }
  }
}
