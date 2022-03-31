/*Vault Stage*/
/*The vault stage uses dials, locks, and watercups in order to create a contraption of three dials that must be
 alternated from while solving the code for all of them. This stage uses the pan() function in order to give hints
 to which dial is the next assigned dial, so headphones are recommended for play (or stereo speakers). The stage
 is marked as completed when all three dials have been unlocked.*/

class VaultStage {
  //dials
  ArrayList<Dial> dials;    //stores dials
  ArrayList<Integer> completedDials;

  int selectedDial;         //which dial is selected by player
  int selectedDialPast;
  int assignedDial;          //which dial is supposed to be used currently
  int assignedDialPast;

  boolean isNew;            //if new stage
  boolean isComplete;       //if completed or not
  boolean wrongAnswer;      //if mistakes were made



  //Constructor
  VaultStage() {
    //create dials
    dials = new ArrayList<Dial>();
    for (int i = 0; i < 3; i++) {
      Dial dial = new Dial(i, 99, (i + 1) * screenWidth / 4, 3 * screenHeight / 5, 190, 190);
      dials.add(dial);
    }
    this.completedDials = new ArrayList<Integer>();
    this.selectedDial = 0;
    this.selectedDialPast = 0;

    this.assignedDial = 0;
    this.assignedDialPast = 0;

    this.isNew = true;
    this.isComplete = false;
    this.wrongAnswer = false;
  }

  //Dial Select (Player)
  void dialSelect(int buttonPressed) {
    deselectAll();
    selectedDial = buttonPressed;
    dials.get(buttonPressed).isSelected = true;
  }

  //Dial Assign (Program)
  void dialAssign() {
    unassignAll();
    int choice = 0;
    //select a random dial as long as it is not unlocked and there are locked dials remaining
    choice = (int)random(0, 3);
    if (checkCompleteAll()) {
      //play sound of unlock complete
      muteSounds(vaultDialSounds);
      dialClack.play();
      dialClack.amp(1);
      dialClack.pan(0);

      //set as stage complete
      isComplete = true;
    } else {
      while (dials.get(choice).isUnlocked == true) {
        choice = (int)random(0, 3);
      }
      //println("assinging " + choice);
      assignedDial = choice;

      //assign dial
      dials.get(assignedDial).isAssigned = true;

      //make sound; pan according to which dial it is
      if (dialTick.isPlaying()) {
        dialTick.stop();
      }
      dialClick.play();
      dialClick.amp(1);
      dialClick.pan(assignedDial-1.0);
    }
  }

  //Deselect All Dials
  void deselectAll() {
    for (Dial d : dials) {
      d.isSelected = false;
    }
  }

  //Unassign All Dials
  void unassignAll() {
    for (Dial d : dials) {
      d.isAssigned = false;
    }
  }

  //Check Completion
  boolean checkMatch(int dialNum) {
    //checks if lock has been matched, resets match flag and returns boolean
    if (dials.get(dialNum).isMatched) {
      //print("match occurred");
      dials.get(dialNum).isMatched = false;

      //if the lock is unlocked, then add its number to completedDials
      if (dials.get(dialNum).isUnlocked) {
        completedDials.add(dialNum);
      }
      return true;
    } else {
      return false;
    }
  }

  //Check Completion
  boolean checkCompleteAll() {
    if (completedDials.size() >= 3) {
      //println("everything completed");
      return true;
    } else {
      return false;
    }
  }

  //Update (uses potentiometer and button for dial selection)
  void update(int potPosition, int buttonPressed) {
    //resets wrongAnswer
    if (wrongAnswer) {
      wrongAnswer = false;
    }

    //if all dials have been completed, stage is complete
    //if new, assign first dial
    if (isNew) {
      isNew = false;
      dialAssign();
    }
    //otherwise go to checking
    else {
      //player selected button
      dialSelect(buttonPressed);
      //update dials
      dials.get(selectedDial).update(potPosition);
      //sets wronganswer to true if working dial is wrong
      if (dials.get(selectedDial).wrongAnswer) {
        this.wrongAnswer = true;
      }
      //if player has correctly match the assigned dial, assign a new one
      if (checkMatch(assignedDial)) {
        dialAssign();
      }
    }
  }

  //Display
  void display() {
    //display background

    //display dials
    for (Dial d : dials) {
      // println("x:" + d.locX + "  y:" + d.locY);
      d.display();
    }
  }

  // int autoSelect() {
  //   // println("assigned:"+assignedDial + "  selected:"+selectedDial + "  digit:"+ dials.get(selectedDial).lockDigit
  //   // + "  match:"+ dials.get(selectedDial).isMatched);
  //   selectedDial = assignedDial;
  //   return assignedDial;
  // }
}
