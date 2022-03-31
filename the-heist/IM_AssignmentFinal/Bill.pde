/*Bills & Snow*/
/*For if you win.*/
class Bill {
  float locX;
  float locY;

  float velX;
  float velY;

  int orientation;
  int imgWidth;
  int imgHeight;

  int rotateCounter;
  int rotateIncr;

  //constructor
  Bill(float locX, float locY, float velX, float velY, int imgWidth, int imgHeight) {
    this.locX = locX;
    this.locY = locY;
    this.velX = velX;
    this.velY = velY;
    this.orientation = (int)random(0, 4);
    this.imgWidth = imgWidth;
    this.imgHeight = imgHeight;
    this.rotateCounter = 500;
    this.rotateIncr = -1;
  }

  //Update
  void update() {
    //if rotateCounter == 0 and is decreasing, start increasing. if 500 and increasing, start decreasing.
    if ((rotateCounter == 0 && rotateIncr < 0) || (rotateCounter == 500 && rotateIncr > 0)) {
      rotateIncr *= -1;
    }

    //if out of screen, then make it appear again
    if (locY >= screenHeight || locY <= 0) {
      locY = -imgHeight;
    } else if (locX >= screenWidth || locX <= 0) {
      locY = screenHeight - locY;
      if (velX > 0) {
        locX = 0;
      } else {
        locX = screenWidth;
      }
    }

    //update values
    locX += velX;
    locY += velY;
    rotateCounter += rotateIncr;
  }


  //Display
  void display() {
    pushMatrix();
    translate(locX, locY);
    float rotation;
    if (orientation == 0) {
      rotation = map(rotateCounter, 0, 500, 0, 30);
    } else if (orientation == 1) {
      rotation = map(rotateCounter, 0, 500, 90, 120);
    } else if (orientation == 2) {
      rotation = map(rotateCounter, 0, 500, 180, 210);
    } else {
      rotation = map(rotateCounter, 0, 500, 270, 300);
    }
    rotate(radians(rotation));
    image(dollarBillImg, 0, 0, imgWidth, imgHeight);
    popMatrix();
  }
}

//circle class (position, speed, and size)
class Circle {
  //Coordinates
  float locX;
  float locY;

  //Velocity
  float velX;
  float velY;

  //Size (radius)
  float r;

  //constructor
  Circle(float locX, float locY, float velX, float velY, float r) {
    this.locX = locX;
    this.locY = locY;
    this.velX = velX;
    this.velY = velY;
    this.r = r;
  }

  //used for checking movement of circles (testing)
  void display() {
    fill(200);
    noStroke();
    ellipse(locX, locY, 2*r, 2*r);
    fill(255);
  }

  //update velocity & location of circle when hitting boundaries of screen (only y since x is the same)
  void update() {
    if (locY >= screenHeight || locY <= 0) {
      locY = 0;
    }
    locY = locY + velY;
  }
}


//object list class (stores all particles on screen in an array)
class ObjectList {
  ArrayList<Circle> circles = new ArrayList<Circle>();
  ArrayList<Bill> bills = new ArrayList<Bill>();

  //constructor (adds 25 circles and 25 bills of random speeds and coordinates to an array)
  ObjectList() {
    for (int i = 0; i<25; i++) {
      Circle circle = new Circle( random(0, screenWidth), random(0, screenHeight), 0, random(0.05, 0.1), 2);
      Bill bill = new Bill(random(0, screenWidth), random(0, screenHeight), random(-0.1, 0.1), random(0.05, 0.1), 100, 90);
      while (bill.velX == 0) {
        bill.velX = random(-0.1, 0.1);
      }
      circles.add(circle);
      bills.add(bill);
    }
  }

  //update locations of particles
  void updateAndDisplay() {
    for (Circle i : this.circles) {            
      i.update();    //update the velocities/locations of the circles
      i.display();
    }

    for (Bill b : this.bills) {            
      b.update();    //update the velocities/locations of the bills
      b.display();
    }
  }
}
