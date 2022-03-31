/*KeyPadGame*/
/*This is the game that you match the light pattern in order to get the passcode for the door lock in the keypad stage.*/
//====================================================================================================================================
//====================================================================================================================================
//Functions

//set up passcode to send to Processing
void initializePasscode() {
  randomSeed(patternType);
  for (int i = 0; i < (phaseEndCount - 1) * patternIncr; i++) {
    passcode[i] = round(random(3) );
  }
}

//send code to Serial
void sendCode() {
  int i = 0;
  //iterate through each index and print the number
  for (; i < (passcodeLength * 2) - 1; i++) {
    Serial.print(passcode[i]);
    Serial.print(",");
  }
  //end with the last digit and add new line
  Serial.println(passcode[i]);
}

//make new pattern (reset)
void newPattern() {
  int i = 0;
  for (; i < patternLength; i++) {
    pattern[i] = passcode[i];
  }
}

//display the pattern
void showPattern() {
  turnOffAll();
  for (int i = 0; i < patternLength; i++) {
    turnOnOne(pattern[i]);
    delay(300);
    turnOffOne(pattern[i]);
    delay(200);
  }
}

//check if user input is same as the current light on the pattern
bool checkPattern(int userInput, int patternNumber) {
  if (userInput == pattern[patternNumber] ) {
    return true;
  }
  else {
    return false;
  }
}

//turn on a specific led
void turnOnOne(int num) {
  digitalWrite(lights[num], true);
}

//turn on all leds
void turnOnAll() {
  for (int i : lights) {
    digitalWrite(i, true);
  }
}

//turn off a specific led
void turnOffOne(int num) {
  digitalWrite(lights[num], false);
}

//reset all leds to off
void turnOffAll() {
  for (int i : lights) {
    digitalWrite(i, false);
  }
}

//next phase! this will light up the rgb LED with one color per turn (all three will result in white)
void nextPhase() {
  delay(300);
  patternLength += patternIncr;

}

//lose sequence
void lose() {
  for (int i = 0; i < 3; i++) {
    turnOnAll();
    delay(300);
    turnOffAll();
    delay(300);
  }
}

//====================================================================================================================================
//====================================================================================================================================
//Game


void lightGame() {
  //if all phases have been cleared, end game
  if (phaseCounter == phaseEndCount) {
    turnOffAll();
    gameEnd = true;
    phaseEnd = true;
  }
  //if game is not over, keep the game going
  if (!phaseEnd) {
    for (int i = 0; i <= patternLength; i++) { //for each button to be pressed in the sequence
      //wait for user input
      while (!phaseEnd) {
        //if button is pressed, turn on led
        if (buttonPressedCheck(true) && buttonPressed < 3) {
          turnOnOne(buttonPressed);
          delay(300);
          //if the button is the same as the light pattern, then break to next i
          if (checkPattern(buttonPressed, i)) {
            turnOffAll();
            gameCounter++;
            //if player matches entire pattern they move to next phase
            if (gameCounter == patternLength) {
              delay(300);
              phaseCounter++;
              if (phaseCounter < phaseEndCount) {
                nextPhase();
              }
              phaseEnd = true;
              break;
            }
            break;
          }
          //otherwise end the game & reset values
          else {
            turnOffAll();
            delay(100);
            lose();
            patternLength -= phaseCounter * patternIncr;
            phaseEnd = true;
            gameEnd = true;
            firstGame = true;
            break;
          }
        }
        //all lights are off otherwise
        else {
          turnOffAll();
        }
      }
    }
  }
  //if phase AND game is ended, then show the code over and over whenever button is pressed
  else if (phaseEnd && gameEnd) {
    if (buttonPressedCheck(true)) {
      if (firstGame) {
        firstGame = false;
        gameCounter = 0;
        phaseCounter = 0;
        //Start game
        phaseEnd = false;
        gameEnd = false;
        newPattern();
        showPattern();
      }
      else {
        showPattern();
      }
    }
  }
  //if phase is over, then move to next phase
  else if (phaseEnd) {
    delay(300);
    newPattern();
    showPattern();
    gameCounter = 0;
    phaseEnd = false;
  }
}
