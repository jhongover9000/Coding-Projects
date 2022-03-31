/*Dial*/
/*Dials are part of the vault lock. These are spinny circles (pardon my childish speech; I can't help it)
 that are controlled with the potentiometer.*/


class Dial {
  int dialNum;
  float pan;

  int imgWidth;
  int imgHeight;
  int locX;
  int locY;

  //Member Objects
  Lock lock;
  WaterCup waterCup;

  //Update Function Stuff
  int totalDigits;		//49 or 99
  int segmentSize;		//size of each segment

  //save & return feature stuff
  boolean isMatched;  //whether player has matched a digit
  boolean isSelected;	//whether or not lock is selected by player
  boolean isActive;		//whether or not lock is being used
  boolean isAssigned;  //whether or not lock is supposed to be used

  //potentiometer stuff
  int lockDigit;			//stores number of current digit
  int lockDigitPast;		//stores number of the latest matched password digit
  int potPosPast;	//stores past value of potentiometer

  boolean wrongAnswer;

  boolean isUnlocked;

  //Constructor
  Dial(int dialNum, int totalDigits, int locX, int locY, int imgWidth, int imgHeight) {
    this.dialNum = dialNum;
    this.pan = dialNum - 1.0;
    this.imgWidth = imgWidth;

    this.imgHeight = imgHeight;
    this.locX = locX;
    this.locY = locY;

    this.lock = new Lock(dialLength, 0, totalDigits, true);
    this.waterCup = new WaterCup(locX, locY - (imgHeight / 2 + 65));

    this.isUnlocked = false;
    this.potPosPast = 0;
    this.totalDigits = totalDigits;
    this.segmentSize = 1023 / totalDigits;

    this.isMatched = false;
    this.isSelected = false;
    this.isActive = false;
    this.isAssigned = false;

    this.wrongAnswer = false;
  }

  //if player overturns the dial, failure count will increase and lock will reset
  boolean checkOverTurn() {
    if (lock.iter != 0 && lock.iter%2 == 0) {
      if (lockDigit < lock.getLastDigit()) {
        //println("overturn. timeRemaining:"+ timeRemaining);
        return true;
      } else {
        return false;
      }
    } else {
      if (lockDigit > lock.getLastDigit()) {
        //println("overturn. timeRemaining:"+ timeRemaining);
        return true;
      } else {
        return false;
      }
    }
  }

  //which digit pot is pointing to. if over totalDigits set to totalDigits as default (cannot go over)
  int convertToDigit(int potPosition, int totalDigits) {
    lockDigit = (int)map(potPosition, 0, 1023, 0, totalDigits);
    if (lockDigit > totalDigits) {
      lockDigit = totalDigits;
    }
    if (lockDigit < 0) {
      lockDigit = 0;
    }
    return lockDigit;
  }

  //Update
  void update(int potPosition) {
    //constrain(num, 0, 1023);

    if (!isSelected) {
      isActive = false;
    }

    if (wrongAnswer) {
      wrongAnswer = false;
    }

    //while locked, player can move dial
    if (!isUnlocked) {
      //Tester
      //println("isSelected:" + isSelected + "isAssigned:" + isAssigned +"  isActive:"+isActive+"  isUnlocked:"+isUnlocked+"  lockdigit:"+lockDigit+
      //  "  passcodeDigit:"+lock.passcode.get(lock.iter) + "  iter:" + lock.iter +"  checkIter:"+lock.checkInput(lockDigit));

      //if dial has been selected (when you press a different button it deselects)
      if (isSelected) {
        //get lock digit on dial
        convertToDigit(potPosition, totalDigits);
        //autoCrack();

        //if the lock is not active (player is returning to lock), cannot proceed with updates until
        //potPosPast is the same as what the current pot value is (until player matches ghost dial with real dial)
        //must be the correct lock in order to activate.
        if (!isActive) {
          if (lockDigit == lockDigitPast) {
            isActive = true;
          }
        }

        //if lock is active, then values begin to update (with the real dial moving)
        else {
          //play dial tick
          if (lockDigit != lockDigitPast) {
            if (dialClick.isPlaying() || dialClack.isPlaying()) {
              if (dialTick.isPlaying()) {
                dialTick.stop();
              }
            } else {
              if (dialTick.isPlaying()) {
                dialTick.stop();
              }
              dialTick.play();
              dialTick.amp(0.5);
              dialTick.pan(pan);
            }
          }

          //for the case that a spike value appears (more than +-5 the past value), the value is ignored.
          //if lock is fresh, must start at 0. otherwise, the value must be within range of error (+-5)
          //this doubles as a restrictor that keeps the player from turning the dial too quickly and makes the stage
          //take longer to complete.
          if ((potPosPast - 10 <= potPosition && potPosition <= potPosPast + 10)) {

            //if overturn, reset lock and reduceTime()
            if (checkOverTurn()) {
              wrongAnswer = true;
              reduceTime(timeReducer);
            }
            //if unassigned and player matches digit, reset lock and reduceTime()
            if (!isAssigned && lock.checkInput(lockDigit)) {
              wrongAnswer = true;
              //println("not right!! time remaining:"+timeRemaining);
              reduceTime(timeReducer);
            }
            //if the lock digit is assigned and correct, then the lock will move on to the next digit.
            else if (isAssigned && lock.checkInput(lockDigit)) {
              if	(isAssigned && !lock.checkLock()) {
                lock.iter++;
              }

              //println("passcode:" + lock.getLastDigit() + "lockdigit:"+lockDigit);
              isMatched = true;
              //water ripples
              waterCup.isRippling = true;
              //upon matching the digit, the dial checks if the entire passcode has been matched
              if (lock.checkLock()) {
                //print("unlocked");
                isUnlocked = true;
              }
            }

            //update value of last digit and potPosPast
            lockDigitPast = lockDigit;
            potPosPast = potPosition;
          } else {
            isActive = false;
          }
        }
      }
    }
  }

  //Display
  void display() {
    rectMode(CENTER);
    imageMode(CENTER);

    fill(150);
    rect(locX, locY, imgWidth + 10, imgHeight + 30);

    //triangle over dial
    if (isUnlocked) {
      fill(0, 255, 0);
    } else {
      fill(255, 0, 0);
    }
    triangle(locX, locY - imgHeight/2 - 3, locX + 10, locY - imgHeight/2 -10, locX - 10, locY - imgHeight/2 -10);
    fill(0);


    //display real dial (using lockDigitPast)
    pushMatrix();
    float rotationReal = map(lockDigitPast, 0, totalDigits, 360, 3.64);
    translate(locX, locY);
    //println(rotationReal);
    rotate(radians(rotationReal));
    image(vaultDialImg, 0, 0, imgWidth, imgHeight);
    popMatrix();

    if (isSelected) {
      //if inactive (lockDigit != lockDigitPast)
      if (!isActive) {
        //display ghost dial (using lockDigit)
        pushMatrix();
        float rotationGhost = map(lockDigit, 0, totalDigits, 360, 0);
        translate(locX, locY);
        rotate(radians(rotationGhost));
        //lower opacity of image before displaying
        tint(255, 120);
        image(vaultDialImg, 0, 0, imgWidth, imgHeight);
        popMatrix();
        noTint();
      }

      //display water cup
      waterCup.display();
    }
  }

  //   //AutoCracker (tester)
  //   void autoCrack() {
  //     print(lockDigitPast + ":" +num);
  //     println(num);

  //     isSelected = true;

  //     //while inactive, gets to the right number to activate lock
  //     if (!isActive && lockDigit != lockDigitPast) {
  //       if (lockDigit > lockDigitPast) {
  //         num--;
  //       } else if (lockDigit < lockDigitPast) {
  //         num++;
  //       }
  //     }
  //     //once active, solves for digit
  //     else if (isActive && lock.iter < dialLength) {
  //       if (lockDigit != lock.passcode.get(lock.iter)) {
  //         if (lock.iter % 2 == 0) {
  //           num++;
  //         } else {
  //           num--;
  //         }
  //       } else {
  //         println("match : " + lockDigit + " iter : " + lock.iter);
  //       }
  //     }
  //   }
}
