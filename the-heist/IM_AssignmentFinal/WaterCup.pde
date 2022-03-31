/*Water Cup*/
/*This file holds the class for a cup of water, which is used for the vault dial. When the dial lock
 returns true (correct digit), the water in the cup will ripple. You can move the cup between dials
 if you need to by using the buttons.*/

class WaterCup {
  //for ripple effect
  boolean isRippling;
  int frameCounter;
  int rippleDepth;
  //location (centered)
  int locX;
  int locY;

  //Constructor
  WaterCup(int locX, int locY) {
    this.locX = locX;
    this.locY = locY;
    this.isRippling = true;
  }

  //Ripple effect (just a dip in the water, nothing complicated)
  void ripple() {
    if (frameCounter <= 5) {
      rippleDepth = frameCounter;
    } else if (frameCounter > 5) {
      rippleDepth = 10 - frameCounter;
    }
    arc(locX, locY, 110, rippleDepth, 0, PI);
    frameCounter++;
    if (frameCounter >= 10) {
      frameCounter = 0;
      isRippling = false;
    }
  }

  //Display
  void display() {
    //base of cup
    line(locX - 50, locY + 50, locX + 50, locY + 50);
    //sides
    line(locX - 50, locY + 50, locX - 60, locY - 50);
    line(locX + 50, locY + 50, locX + 60, locY - 50);
    //water
    if (!isRippling) {
      noFill();
      line(locX - 55, locY, locX + 55, locY);
    } else {
      ripple();
    }
  }
}
