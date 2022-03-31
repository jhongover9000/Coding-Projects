/*Key*/
/*Single key for keypad*/
class Key {
  int locX;
  int locY;
  int squareSize;         //size of square

  int num;                //stores value
  boolean isHovering;     //mouse is hovering over
  boolean isSelected;     //is selected

  //Constructor
  Key(int locX, int locY, int num, int squareSize) {
    this.locX = locX;
    this.locY = locY;
    this.num = num;
    this.squareSize = squareSize;
    this.isHovering = false;
    this.isSelected = false;
  }

  //Update
  void update() {
    if ((locX <= mouseX && mouseX < locX + squareSize) && (locY <= mouseY && mouseY < locY + squareSize)) {
      isHovering = true;
      if (mouseReleased) {
        isSelected = true;
        mouseReleased = false;
      }
    } else {
      isHovering = false;
      isSelected = false;
    }
  }

  //Display
  void display() {
    rectMode(CORNER);
    if (isHovering) {
      fill(230);
    } else {
      fill(200);
    }
    rect(locX, locY, squareSize, squareSize);
    textAlign(CENTER, CENTER);
    if (isHovering) {
      fill(130);
    } else {
      fill(100);
    }
    textSize(squareSize/2);
    text(num, locX + (squareSize/2), locY + (squareSize/2));
  }
}
