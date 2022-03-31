/*Lock*/
/*Description: Locks consist of an array of integers (the code, which can be assigned using the
 random function; the parameters of the function will be set in the constructor, as well as the
 number of digits in the passcode) and have a method of checking a specific index with a number.*/

class Lock {
  public ArrayList<Integer> passcode;    //stores passcode digits
  int len;                 //length of passcode
  int iter;                    //acts as an iterator reference by storing the index of current digit
  boolean isFresh;          //is true when the lock is fresh
  boolean isUnlocked;         //is true when all digits have been matched

  //Constructor (length of passcode, parameters for digits, whether or not the lock is a dial)
  Lock(int len, int startNum, int endNum, boolean isDial) {
    this.passcode = new ArrayList<Integer>();
    this.len = len;
    this.iter = 0;
    //If dial, the numbering system for digits is different (not completely random, has a pattern)
    if (isDial) {
      //set initial value (first digit)
      int val1 = (int)random(startNum, endNum + 1);
      //print(val1 + ",");
      passcode.add(val1);
      //when a value is selected, this becomes the endpoint value for the next number
      //after that, the next value is the start point. then the next is the endpoint.
      //this forces a player to turn right, then left, then right... (like a lock dial)
      for (int i = 1; i < len; i++) {
        int temp;
        //if i is odd, (int)random(startNum,passcode.get(i-1) -1). subtract 1 to keep from getting same number consecutively
        if (i % 2 == 1) {
          temp = (int)random(startNum, passcode.get(i - 1) - 1);
          //print(temp + ",");
          passcode.add(temp);
        }
        //if i is even, (int)random(val2 +1,endNum). add 1 to keep from getting same number consecutively
        else if (i % 2 == 0) {
          temp = (int)random(passcode.get(i - 1) + 1, endNum + 1);
          //print(temp + ",");
          passcode.add(temp);
        }
      }
    }
    //if not dial, then just populate with random numbers
    else {
      for (int i = 0; i < len; i++) {
        passcode.add((int)random(startNum, endNum+1));
      }
    }
    this.isUnlocked = false;
    this.isFresh = true;
  }

  //Get Last Digit (used to store value of latest matched digit in passcode)
  int getLastDigit() {
    if (iter > 0) {
      return passcode.get(iter - 1);
    } else {
      return passcode.get(0);
    }
  }

  //Check Input
  boolean checkInput(int input) {
    //print("digit: " + passcode.get(iter) + "input: " + input);
    if (passcode.get(iter) == input) {
      return true;
    } else {
      return false;
    }
  }

  //Check Lock (if unlocked)
  boolean checkLock() {
    //if the iter reaches the length of the passcode returns true and sets isUnlocked to true
    if (iter >= len) {
      //println("setting as unlocked");
      isUnlocked = true;
      return true;
    } else {
      return false;
    }
  }

  //Overturning the dial or guessing the incorrect code makes the lock reset
  void reset() {
    iter = 0;
    isFresh = true;
  }
}
