//IM Assignment Final: Bank Heist
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
//====================================================================================================================================
//====================================================================================================================================
//Global Variables & Setup

//lights (RGB LED)
const int rLED = 2;     //port 2, red LED
const int gLED = 4;     //port 4, green LED
const int bLED = 6;     //port 6, blue LED
int lights[] = {bLED, gLED, rLED};

//buttons
const int rButton = 3;  //port 3, red button
const int gButton = 5;  //port 5, green button
const int bButton = 7;  //port 7, blue button
int buttons[] = {bButton, gButton, rButton};

//sonar sensor
const int trigPin = 8;    //connects to the trigger pin
const int echoPin = 9;    //connects to the echo pin

//light game variables
bool firstGame = true;    //ensures that the initialization of the game only happens once
int patternType;          //uses randomSeed() to designate a specific pattern
int patternIncr = 2;      //increment by 2 each phase
int patternLength = 2;    //current pattern length
int pattern[16];          //stores the current pattern for the phase
int passcodeLength = 8;  //passcode length
int passcode[16];         //stores entire pattern, to be sent to Processing

int phaseCounter = 0;     //number of phases completed
int gameCounter = 0;      //number of matched lights in each phase (I know it doesn't make sense but it does in my head)
int phaseEndCount = 8;    //phaseEndCount-1 * patternIncr = number of digits in passcode
bool phaseEnd = true;     //phase ended?
bool gameEnd = true;      //game ended?



//Serial things
int inByte = 0;         //received input
int buttonPressed = 0;  //stores which button is pressed
int potPosition = 0;    //potentiometer
float distance = 0;     //stores the distance measured by the distance sensor

//setup
void setup() {
  //leds
  pinMode(rLED, OUTPUT);
  pinMode(gLED, OUTPUT);
  pinMode(bLED, OUTPUT);

  //button
  pinMode(rButton, INPUT_PULLUP);
  pinMode(gButton, INPUT_PULLUP);
  pinMode(bButton, INPUT_PULLUP);

  //sonar sensor
  pinMode(trigPin, OUTPUT);
  pinMode(echoPin, INPUT_PULLUP);

  //set up passcode for keypad
  randomSeed(analogRead(A5));
  patternType = (int)random(0, 50);
  initializePasscode();

  Serial.begin(9600);
  establishContact();
}


//====================================================================================================================================
//====================================================================================================================================
//Functions

//check if button is pressed (update buttonPressed value) if not, default value (is decided depending on whether it's a keypad stage)
bool buttonPressedCheck(boolean isKeyPad) {
  if (!digitalRead(buttons[0])) {
    buttonPressed = 0;
    return true;
  }
  else if (!digitalRead(buttons[1])) {
    buttonPressed = 1;
    return true;
  }
  else if (!digitalRead(buttons[2])) {
    buttonPressed = 2;
    return true;
  }
  else {
    //else, button remains constant
    buttonPressed = buttonPressed;
    return false;
  }
}


//returns distance (from DistanceSensor example)
float getDistance()
{
  float echoTime;                   //variable to store the time it takes for a ping to bounce off an object
  float calculatedDistance;         //variable to store the distance calculated from the echo time

  //send out an ultrasonic pulse that's 10ms long
  digitalWrite(trigPin, HIGH);
  delayMicroseconds(10);
  digitalWrite(trigPin, LOW);

  echoTime = pulseIn(echoPin, HIGH);      //use the pulsein command to see how long it takes for the
  //pulse to bounce back to the sensor

  calculatedDistance = echoTime / 148.0;  //calculate the distance of the object that reflected the pulse (half the bounce time multiplied by the speed of sound)

  return calculatedDistance;              //send back the distance that was calculated
}




//====================================================================================================================================
//====================================================================================================================================
//Execution

//pretty much the only function of this board is to push a button
void loop() {
  // if we get a valid byte, read analog ins:
  if (Serial.available() > 0) {

    // get incoming byte:
    inByte = Serial.read();
    //Serial.println(inByte);

    //    if (inByte == 2) {
    //      //distance sensor
    //      distance = getDistance();
    //      Serial.print((int)distance);
    //      Serial.print(",");
    //
    //      //check button pressed
    //      if (buttonPressedCheck(false)) {
    //        Serial.println(1);
    //      }
    //      else {
    //        Serial.println(0);
    //      }
    //    }

    //if keypad stage, begins game and reports to processing the code
    if (inByte == 5) {
      //send passcode to Processing
      sendCode();
      //begin light game for player to figure out code
      lightGame();
    }
    //if vault stage, send 2 values: the button that is pressed and the potentiometer value
    else if (inByte == 6) {
      //read potentiometer
      potPosition = analogRead(A0);
      //button pressed
      buttonPressedCheck(false);
      //send values:
      Serial.print(potPosition);
      Serial.print(",");
      //if in practice mode, there's no need for changing dials
      Serial.println(buttonPressed);
    }
    else if (inByte == 12) {
      //set up passcode for keypad
      patternType = (int)random(0, 50);
      initializePasscode();
    }
    else {
      Serial.println("test");
    }
  }
}


void establishContact() {
  while (Serial.available() <= 0) {
    Serial.println("0,0,0,0,0,0");   // send an initial string
  }
}
