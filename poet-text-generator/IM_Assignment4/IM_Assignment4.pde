//Intro to IM Assignment 4: Generative Text (Due Oct. 6)
//Joseph Hong
//Description: This program uses generative text with a simple (somewhat recursive) set of functions, using the number of words and adjectives
//             as limiters. The program reads from a CSV file and uses the words with random selection (following a grammar
//             structure placed in each types function) in order to create 5 different formats of lines for the poem. It 
//             displays one line at a time, and there are also some particle effects (snow) to set the mood :)
//Note: the CSV file needs to have 6 lines, with each line as follows: pronoun, noun, adjective, preposition, article, verb.
//============================================================================================================================================
//============================================================================================================================================
//Imports
import java.util.ArrayList;    //for the size-changing array
import java.util.Random;       //for selecting a random integer (as opposed to a float)


//============================================================================================================================================
//============================================================================================================================================
//Global Variables and Setup

//Arrays (static) for fixed-value groups (split into groups according to grammar)
String pronoun[];      //ex) his, her, my
String noun[];         //ex) sun, moon, star
String adjective[];    //ex) bright, dark, mellow
String preposition[];  //ex) over, under, below
String article[];      //ex) the, a, an
String verb[];         //ex) shines, glimmers, glows

//Variables to adjust sentence length & structure
int adjCount;
int lineLength;
int wordIndex;

//String that holds the entire line to be printed
String line = "";

//Array that will hold the words selected for a line
ArrayList<String> lineArray = new ArrayList<String>();

//Random Integer Generator
Random rand = new Random();

//For particle effects
int circleSize = 3;
ObjectList particleEffects = new ObjectList();

//Screen Dimensions (also change size() function)
int screenWidth = 800;
int screenHeight = 800;

//Setup
void setup() {
  //Size of Screen & Background
  size(800, 800);
  background(10);
  //frameRate(10);
  
  //Load arrays with words
  String words[] = loadStrings("text.csv");
  pronoun = split(words[0], ",");
  noun = split(words[1], ",");
  adjective = split(words[2], ",");
  preposition = split(words[3], ",");
  article = split(words[4], ",");
  verb = split(words[5], ",");
}


//============================================================================================================================================
//============================================================================================================================================
//Main Functions (Sentence Formats)

//Sentence Format 1: prounoun -> (adjective) -> noun -> verb -> preposition -> article -> (adjective) -> noun
void sentenceF1() {
  lineLength = 8;
  adjCount = 2;
  addPronoun(lineArray);
}

//Sentence Format 2: article -> (adjective) -> noun -> verb -> preposition -> article -> (adjective) -> noun
void sentenceF2() {
  lineLength = 8;
  adjCount = 2;
  addArt(lineArray);
}

//Sentence Format 3: article -> (adjective) -> noun -> verb
void sentenceF3() {
  lineLength = 4;
  adjCount = 1;
  addArt(lineArray);
}

//Sentece Format 4: (article) -> (adjective) -> noun
void sentenceF4() {
  lineLength = 3;
  adjCount = 1;
  addArt(lineArray);
}

//Sentence Format 5: (adjective) -> noun
void sentenceF5() {
  lineLength = 2;
  adjCount = 1;
  //Because adjectives are optional, there's a dice roll and if it's even then an adjective is added
  int diceRoll = rand.nextInt(5);
  if (diceRoll%2 == 0) {        
    addAdj(lineArray);
  }
  //Otherwise it's just a noun
  else {
    addNoun(lineArray);
  }
}


//============================================================================================================================================
//============================================================================================================================================
//Definition Functions

//Adds a random pronoun
void addPronoun(ArrayList<String> array) {
  wordIndex = rand.nextInt(pronoun.length);
  //print(wordIndex);
  //print(pronoun[wordIndex]);
  //print("\n");
  array.add(pronoun[wordIndex]);
  //Because adjectives are optional, there's a dice roll and if it's even then an adjective is added
  int diceRoll = rand.nextInt(7);
  if (diceRoll%2 == 0) {        
    addAdj(array);
  }
  //Otherwise it's just a noun
  else {
    addNoun(array);
  }
}

//Adds a random noun
void addNoun(ArrayList<String> array) {
  wordIndex = rand.nextInt(noun.length);
  //print(wordIndex);
  //print(noun[wordIndex]);
  //print("\n");
  array.add(noun[wordIndex]);
  //If the noun is at the end of the sentence (found through comparing the size of the array), then add a "." to the end.
  if ( (array.size() >= lineLength - adjCount - 1 ) && (array.size() <= lineLength - 1) ||  (array.size() > lineLength - 1) ) {
    array.add(".");
  } else {
    addVerb(array);
  }
}

//Adds a random adjective
void addAdj(ArrayList<String> array) {
  wordIndex = rand.nextInt(adjective.length);
  //print(wordIndex);
  //print(adjective[wordIndex]);
  //print("\n");
  array.add(adjective[wordIndex]);
  addNoun(array);
}

//Adds a random preposition
void addPrep(ArrayList<String> array) {
  wordIndex = rand.nextInt(preposition.length);
  //print(wordIndex);
  //print(preposition[wordIndex]);
  //print("\n");
  array.add(preposition[wordIndex]);
  addArt(array);
}

//Adds a random verb
void addVerb(ArrayList<String> array) {
  wordIndex = rand.nextInt(verb.length);
  //print(wordIndex);
  //print(verb[wordIndex]);
  //print("\n");
  array.add(verb[wordIndex]);
  addPrep(array);
}

//Adds a random article
void addArt(ArrayList<String> array) {
  wordIndex = rand.nextInt(article.length);
  //print(wordIndex);
  //print(article[wordIndex]);
  //print("\n");
  //Because an article is also optional when it's at the start of a sentence
  if (array.size() < 1) {
    int diceRoll = rand.nextInt(7);
    if (diceRoll%2 == 0) {
      array.add(article[wordIndex]);
    }
  } else {
    array.add(article[wordIndex]);
  }
  //Because adjectives are optional, there's a dice roll and if it's even then an adjective is added
  int diceRoll = rand.nextInt(7);
  if (diceRoll%2 == 0) {        
    addAdj(array);
  }
  //Otherwise it's just a noun
  else {
    addNoun(array);
  }
}

//Concatenates sentence
void makeSentence() {
  for (int i = 0; i < lineArray.size(); i++) {
    line += lineArray.get(i);
    //If the word is not at the end of the sentence, put a space
    if (i < lineArray.size() - 2) {
      line += " ";
    }
  }
}

//Reset line and array
void reset() {
  lineArray.clear();
  line = "";
}

//============================================================================================================================================
//============================================================================================================================================
//Flair (Particle Effects, like snow falling)

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

  //constructor (adds 50 circles of random speeds and coordinates to an array)
  ObjectList() {
    for (int i = 0; i<50; i++) {
      Circle circle = new Circle( random(0, 800), random(0, 800) , 0 , random(0.05, 0.1), circleSize);
      circles.add(circle);
    }
  }
  
    //getter
  ArrayList<Circle> getCircles(){
    return circles;
  }

  //update locations of particles
  void updateAndDisplay() {
    for (Circle i : this.getCircles()) {            
      i.update();    //update the velocities/locations of the circles
      i.display();
    }
  }
}


  //============================================================================================================================================
  //============================================================================================================================================
  //

  void draw() {
    //decides which format is used via the modulus (sometimes none are used, depending on the diceRoll result)
    //the line and array are reset before each format is used to make a line
    if (frameCount%250 == 0) {
      int diceRoll = rand.nextInt(5);
      if (diceRoll == 0) {
        reset();
        sentenceF1();
        makeSentence();
      } else if (diceRoll == 1) {
        reset();
        sentenceF2();
        makeSentence();
      } else if (diceRoll == 2) {
        reset();
        sentenceF3();
        makeSentence();
      } else if (diceRoll == 3) {
        reset();
        sentenceF4();
        makeSentence();
      } else if (diceRoll == 4) {
        reset();
        sentenceF5();
        makeSentence();
      }
    }
    background(10);
    //display particle effects (snow falling)
    particleEffects.updateAndDisplay();
    //display text
    textAlign(CENTER);
    textSize(20);
    text(line, width/2, height/2);
    //print(line);
    //print("\n");
  }
