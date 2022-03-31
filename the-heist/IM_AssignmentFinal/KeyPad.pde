/*KeyPad*/
/*Description: */
class KeyPad {

  int locX;               //locX and locY are corner values
  int locY;
  int squareSize;
  ArrayList<Key> keys;

  Lock lock;
  ArrayList<Integer> passcodeCoords;
  ArrayList<ArrayList<Integer> > numMatrix;
  ArrayList<Integer> playerInput;

  int passcodeLen;            //length of passcode

  boolean noInput;            //checks if player hasn't inputted anything

  boolean wrongAnswer;        //if player typed wrong answer
  int wrongAnswerCounter;     //counter used to change colors for wrong answer

  boolean isComplete;         //if stage is complete

  //Constructor
  KeyPad(int locX, int locY, int squareSize, int passcodeLen) {
    this.locX = locX;
    this.locY = locY;
    this.squareSize = squareSize;
    this.keys = new ArrayList<Key>();
    //create the keys for the keypad and add to keys
    for (int i = 0; i < 9; i++) {
      Key tempKey = new Key(locX + (i%3 * squareSize), (locY + (i/3) * squareSize), i+1, squareSize);
      keys.add(tempKey);
    }
    this.lock = new Lock(passcodeLen, 0, 3, false);                    
    this.passcodeCoords = new ArrayList<Integer>();
    this.numMatrix = new ArrayList<ArrayList<Integer> >();
    this.playerInput = new ArrayList<Integer>();

    this.passcodeLen = passcodeLen;
    this.noInput = true; 
    this.wrongAnswer = false;               
    this.isComplete = false;            

    //make the matrix of 1-9 (3x3)
    int num = 1;
    for (int i = 0; i < 3; i++) {
      ArrayList<Integer> temp = new ArrayList<Integer>();
      numMatrix.add(temp);
      for (int j = 0; j < 3; j ++) {
        numMatrix.get(i).add(num);
        num++;
      }
    }
  }

  //Get passcoords with Serial Input
  void getPassCoords(int[] inputs) {
    //println("clearing");
    passcodeCoords.clear();
    //populates the passcodecoords array with input from Serial
    for (int i : inputs) {
      passcodeCoords.add(i);
    }
    // print("coords: ");
    // int i  = 0;
    // for (; i < passcodeCoords.size() -1; i++) {
    //   print(passcodeCoords.get(i) + ",");
    // }
    // println(passcodeCoords.get(i));
  }

  void createPasscode() {
    //creates passcode using the pairs of numbers (increments by 2)
    int j = 0;
    int i = 0;
    while (i <= 15) {
      //print("passcode: ");
      int row = passcodeCoords.get(i);
      //print("row:" + row);
      i++;
      int col = passcodeCoords.get(i);
      //print(" col:" + col);
      i++;
      int digit = numMatrix.get(row).get(col);
      //println(" num:" + digit);
      lock.passcode.set(j, digit);
      j++;
      if (j == passcodeLen) {
        break;
      }
    }
    //print("passcode: ");
    //i = 0;
    //for (; i < lock.passcode.size() - 1; i++) {
    //  print(lock.passcode.get(i) + ",");
    //}
    //println(lock.passcode.get(i));
  }

  //Check Inputs
  boolean checkInputs() {
    for (int i = 0; i < playerInput.size(); i++) {
      //if at least one digit doesn't match then reset the player input
      if (lock.checkInput(playerInput.get(i))) {
        lock.iter++;
      } else {
        return false;
      }
    }
    return true;
  }

  //Update
  void update(int[] inputs) {
    if(lock.isFresh){
      playerInput.clear();
      lock.isFresh = false;
    }
    if (!isComplete) {
      //populate the passcode array with serial input
      getPassCoords(inputs);
      //println("passcode creating?");
      if (passcodeCoords.size() >= passcodeLen) { 
        createPasscode();
      }
      //print("passcode created");
      //update keys; if one is selected then add to the player's input
      for (Key k : keys) {
        //print("updating");
        k.update();
        if (k.isSelected) {
          noInput = false;
          if (playerInput.size() < passcodeLen) {
            button.play();
            button.amp(0.2);
            playerInput.add(k.num);
          }
          k.isSelected = false;
        }
      }

      if (!noInput && !wrongAnswer) {
        //if player input is the length of the passcode, then check for correctness
        if (playerInput.size() == passcodeLen) {
          if (checkInputs()) {
            isComplete = true;
          } else {
            //clear answer and reduce time
            //println("wrong answer!");
            wrongAnswer = true;
            reduceTime(100*timeReducer);
          }
        }
      }
    } else {
      for (Key k : keys) {
        k.update();
      }
      //   println("complete");
    }

    //always reset mouseReleased at end of update function
    mouseReleased = false;
  }


  //Display
  void display() {
    //display keys
    for (Key k : keys) {
      k.display();
    }

    //display wires
    for (int i = 0; i < 3; i++) {
      fill(0);
      circle(locX + (squareSize/2) + (i * squareSize), locY + (squareSize*3) + squareSize/2, squareSize/5);
      //color of wires
      if (i == 0) {
        fill(0, 0, 255);
      } else if (i == 1) {
        fill(0, 255, 0);
      } else {
        fill(255, 0, 0);
      }
      rect(locX + (squareSize/2) + (i * squareSize) - squareSize/12, locY + (squareSize*3) + squareSize/2, squareSize/6, screenHeight);
    }
    for (int i = 0; i < 3; i++) {
      fill(0);
      circle(locX + (squareSize*3) + squareSize/2, locY + (squareSize/2) + (i * squareSize), squareSize/5);
      //color of wires
      if (i == 0) {
        fill(0, 0, 255);
      } else if (i == 1) {
        fill(0, 255, 0);
      } else {
        fill(255, 0, 0);
      }
      rect(locX + (squareSize*3) + squareSize/2, locY+ (squareSize/2) + (i * squareSize) - squareSize/12, screenWidth, squareSize/6);
    }

    //display inputs
    rectMode(CORNER);
    fill(0);
    rect(locX, locY - (squareSize + 5), squareSize*3, squareSize);

    textAlign(CORNER, TOP);
    if (isComplete) {
      fill(0, 255, 0);
    } else if (wrongAnswer) {
      if (wrongAnswerCounter < 50) {
        fill(255, 0, 0);
        wrongAnswerCounter++;
      } else {
        wrongAnswerCounter = 0;
        wrongAnswer = false;
        noInput = true;
        lock.iter = 0;
        playerInput.clear();
      }
    } else {
      fill(255);
    }
    textSize(squareSize/2);
    String s = "";
    if (!noInput) {
      for (int i = 0; i < playerInput.size(); i++) {
        s += playerInput.get(i);
      }
    }
    text(s, locX + 5, locY - (squareSize - 10));
  }
}
