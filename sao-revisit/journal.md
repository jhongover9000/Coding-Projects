#### A New Adventure.

So. The idea that I have in mind is creating a side-scroller game where you basically keep fighting ~~until you die~~.
I'm not really sure what the goal of the game will be, but I just have this desire to actually make a working version of
the game that I failed to create a year ago. I have no idea if it'll work, because I'm running across a *lot* of issues
at the moment. The idea is to allow players to select from two different characters, grind EXP and levels for a while, then
face off against a boss or two. I also think it'd be really cool to have cutscenes and stuff (not really
sure how I'll pull it off, which is why it's still more of a concept than anything.

One big problem that I foresee is not having enough time to get everything done to the point where I'm satisfied with it.
I have grand plans, but chances are my lack of experience and time will keep me from carrying them all out...

#### Days

[October 13](journal.md#oct-13)

[October 14](journal.md#oct-14)

[October 15](journal.md#oct-15)

[October 16](journal.md#oct-16)

[October 17](journal.md#oct-17)

[October 18](journal.md#oct-18)

[October 19](journal.md#oct-19)

[October 20](journal.md#oct-20)

[October 22](journal.md#oct-22)

[October 23](journal.md#oct-23)

[October 25](journal.md#oct-25)

[October 26](journal.md#oct-26)

[October 27](journal.md#oct-27)

#### Oct. 13

So... The problems are already here. Started very basic by formatting the file I'm using. Wrote down in pseudocode how I'm thinking of structuring the code,
and started seting up the functions for image loading. Aaaand I came across a problem. So, I don't really know how to access
the current working directory on Java. Like, I've scoured the internet and the solution is apparently using the command

    String cmd = System.getProperty("user.dir");

but the problem is that *it doesn't work*. I don't know if it's a Processing thing, but it's really getting on my nerves.
I think I'll just start coding everything else for now.



#### Oct. 14

Yeah, no, I'm not doing great right now. Kind of frustrated. I'm the type that doesn't like leaving a problem be, so I've
been trying to solve this problem for the past I-don't-know-how-long. So the problem right now is that the command 
    String cmd = System.getProperty("user.dir");
is giving me my home directory ("/User/username") rather than the actual directory that the file is being run from. There
was also something about using "class.java.path", but that returns the JAR files that are run with the program, which is
*not* what I want. What I'm trying to do (I realize I didn't actually explain this) is use the current working directory to
access folders with character images. The reason behind this is because of the peculiarity of the sprites that I'm using.
They aren't actually a single sheet of multiple images, but rather multiple sheets of single images. So that's why I wanted
to keep everything organized in files, but I dunno if it's gonna work.

Besides that, I've created classes for the entities that will be in the game (err, the player, enemies, and flying objects)
by making the player a subclass of the entities class, and the enemy a subclass of the player. I'm thinking of using functions
to make the enemies do things by setting values of movement booleans to certain values (not there yet, though).

#### Oct. 15

At this point I'm thinking that it's just a problem with Processing. Literally everything that I've looked up is telling me
that using System.getProperty("user.dir") *should return the right directory* but it's not working, instead giving me the
home directory which should be given when using System.getProperty("user.home"). It's frustrating. *Really* frustrating. I've
spent nearly eight hours combined trying to make this work by researching and testing different methods in hopes for it to work.
It's not working, so right now I might just place all of the images in the same folder as the Processing file and just load
the images from there. Screw organization!

###### I also have worked on trying to come up with a system of boolean values in order to determine the player's actions and statuses. More on this later, once I cool down.



#### Oct. 16

Right now, I have a choice to make. The images that I have already have their respective identifiers (characterName + moveNumber + "_" + moveNumberFrame).
I can change this, or adapt the program to call the images in this format. I started with the former, but I might just choose
the latter depending on how long this takes (I've been renaming files for an hour now). However, the former might be a better
option because I realized that different characters have different image identifying numbers, meaning that I can't make the
program adapt using the same movesets for each character. I... am currently wondering why I chose such complicated images
(emphasis on the plurality) for this game...

Oh, and the boolean system. So basically, it looks like this:

    //These three are the present "position" booleans
    boolean isStanding;       //check if standing
    boolean isCrouching;      //check if crouching
    boolean isJumping;        //check if jumping

    //These three are the past "position" booleans
    boolean wasStanding;
    boolean wasCrouching;
    boolean wasJumping;

    //Each position boolean has three present "status" booleans
    boolean isAttacking;    //attacking or not
    boolean isGuarding;      //guarding (reduce damage taken)
    boolean isStill;

    //Each position boolean has three past "status" booleans
    boolean wasAttacking;
    boolean wasGuarding;
    boolean wasStill;

The character's movements are divided into three broad categories: standing, crouching, and jumping. When one of these *present*
position booleans are true, the others are set to false. The past ones are meant to just keep track of what the previous action
was. Anyway, this limits the character to the specified movesets for that position. It *looks* really nice, but I have no
idea if it'll actually *work*, since I haven't planned out all of the conditions and especially the update() function for the
player.

#### Oct. 17

Ok so tbh I've kinda given up on trying to get the current working directory to work... I'm just gonna shove 500+ images in the
same folder as the program. Fun times! I think I'll upload the program first, but the images will come later since I have to
rename them and check if this thing will work (I still don't have a working portion for the player movements). *Yay*. But that's
what I'm planning on doing. Once I get myself two nice rib eye steaks.

Update: they were out of rib eyes so I had to settle with sirloins. They weren't bad, but they weren't as good as the rib eyes...

#### Oct. 18

Didn't write the journal, but worked on the code for the player movements using the action booleans. Tried to make it so that it'd be a bit more efficient by using else-ifs rather than all ifs. The main reason why I'm using boolean variables instead of strings is for efficiency as well, so that the program doesn't have to read each string and compare them, instead just checking if the value is a 0 or 1 (true or false).

The player's update functions is largely split into whether or not the player has been hit by an object. This is so that being hit will override any movements the player is making and send them into the hit animation for 20-30 counts.

#### Oct. 19

I actually started to touch up on the animation sequences (in other words I loaded the files and made the program run). Yay! The all-images-in-the-same-file thing will probably work, and this will include the sound files as well (it's gonna be a pain organizing them). So far, the player can jump and walk and guard. Obviously I'm going to add more actions (as seen by the player's animation sequence tuples in the class data members), but this was just to check if everything is working right.

Everything is *not* working right, as is to be expected. Problems range from the character shooting into the sky to gliding across the screen while being "still". The problem, from what I can tell, is in the UpdateLastAction() function.

      void updateLastAction() {
    //Update true position booleans
    if (isStanding) {
      wasStanding = true;
    } else {
      wasStanding = false;
    }
    if (isCrouching) {
      wasCrouching = true;
    } else {
      wasCrouching = false;
    }
    if (isJumping) {
      wasJumping = true;
    } else {
      wasJumping = false;
    }
    //Update true action booleans
    if (isAttacking) {
      wasAttacking = true;
    } else {
      wasAttacking = false;
    }
    if (isGuarding) {
      wasGuarding = true;
    } else {
      wasGuarding = false;
    }
    if (isWalking) {
      wasWalking = true;
    } else {
      wasWalking = false;
    }
    }

This is the update function. I'm not really sure why it isn't working, so I ended up making a function called moveSetComplete() which returns true when all the frames of an animation sequence have been iterated through. This function will be used for attacking and jumping, which are the two that are giving me or will probably be giving me the most issues with shifting to the next sequence. This will also be useful for displaying the character being hit (at least when they're standing or crouching; when jumping, the player will need to hit the ground first). Here's the jump function, which has been causing me problems for the past few hours.

      //Jumping
      if (isJumping) {
        //If the player just started jumping
        if (!wasJumping) {
          changeMoveSet(jump, 0.3);
          velY = -7;
        }
        //If player is in the process of jumping
        else {
          //If rising up
          if (velY <= 0) {
            if (moveFramePoint >= 2) {
              moveFrameIncrementor = 0;
              moveFramePoint = 2;
            }
          }
          //If falling down
          else if (velY > 0) {
            moveFrameIncrementor = 0.2;
            if (moveFramePoint > 6) {
              moveFrameIncrementor = 0;
              moveFramePoint = 6;
            }
          }
          //If hitting the ground, automatically go into still mode
          if (moveSetComplete()) {
            changeMoveSet(still, 0.4);
            isJumping = false;
            wasJumping = false;
            isStanding = true;
          }
          //moveFrame += moveFrameIncrementor;
        }
      }
      
The idea is to have the player animations freeze when they're at the peak of their jump, and I tried to do this by mapping the player velocity to the frame of the animation. This, however, didn't work out properly so I ended up doing a bit of hardcoding so that the frames are stopped when they reach a certain point. However, I plan to get back to this if I have more time in the future (given the other projects, midterms, and deadlines, things ain't lookin' too bright).

#### Oct. 20

Uploaded the latest version of the code. Will upload images in a bit. Maybe tomorrow. Will work on the animations a bit more. The best thing (or at least what I'm hoping to be the best thing) is that the player class will most likely be the only thing I need besides the background and stage setup, since I can base the enemies and bosses (maybe) on the class. This was also another reason behind the movement booleans, since I can just set a few values to true and get them to do things.

#### Oct. 22

Worked on the animations a bit more, then I realized that what I'm thinking of is *way* too much to do in the next 4-5 days on top of everything I have to do and study for. I know that I'm going to probably use this player animaton anyway, so I'm going to work on it and finish it, but I'll rethink the plans that I have for the actual game itself and how it's going to work. The game that I have in mind is, bluntly put, beyond my capabilities. I didn't have any experience coding until recently, and even now I'm still not exactly great at it. I will try and implement the ideas I have, but there *will* come a point where I need to rethink what I'm doing, and that'll be tomorrow. For now, I'm just going to refine the player animations.

#### Oct. 23

By refine animations, it seems as though I need to do a lot of things because I realized during my coding that user input is going to be an issue, especially when it comes to being able to do multiple moves at the same time. My most common problem was the character moving while attacking and getting stuck in an animation loop, which is showing me the downside of selecting boolean values to be my source of differentiation between movesets. It's gotten extremely complicated to the point that I need to set a bunch of conditions for each key pressed, like this:

      else if (keyCode == 65) {
        if (player.isStanding && !player.wasCrouching && (player.isStill() || player.wasStill() || player.wasWalking) ) {
          player.isWalking = true;
          player.dir = -1;
        }
      }
      
This code is only for a single command, to send the player into a walking animation. I wanted to use boolean values in the beginning because I wanted to make the program read the position of the character faster (0 or 1s opposed to string values), but right now in terms of efficiency the two methods are pretty much the same, with all of the conditions I need to add for the player to do the things it could do if they were using a single variable which could be changed to represent a certain moveset. Either that, or I could have two variables –– one representing standing/crouching/jumping and the other representing the actual actions of the player.

Right now, I have my update() function set up in a divisional form –– in other words, by position booleans. This means that each position (standing, crouching, jumping) has its own if-segments. If I switched this to a functional form –– by actions like attacking, guarding, and being passive (I realize that jumping can also be considered a part of this), this might lessen the number of conditions I need to put on a key press because the update() function would handle those bits internally.

It's kinda crazy right now because I spent so long on trying to get the images to load properly and now I'm trying to get the player movements to stop glitching. I'm at a point in the road where I choose the slightly less efficient code (what I have right now with the booleans) or try and change to some kind of numbering system and hope that's more efficient. Either way, I need to get the player animations done and test if the functions for the NPCs will work (attack, walk, guard, etc.). Theoretically it should but theoretically I should have been done with the player animations a long time ago.

#### Oct. 25

I've come across a problem in the coding for the enemies, mainly that they seem to be freezing up when they get within range of the player. I don't know if this has to do with the function I wrote. Here it is:

    //If player is not in hitting range, walk towards player. Jump if player is jumping.
        if (distance(player) >= imgWidth/2) {
          if (frameCount%180 == 30) {
            attack(2);
          } else
            if (player.locX > locX) {
              walkRight();
            } else if (player.locX < locX) {
              walkLeft();
            }
          if (distance(player) < imgWidth && player.locY > locY) {
            jump();
          }
        }
        //Once in hitting range, select a move randomly
        else if (distance(player) < imgWidth/2) {
          print(isStill());
          if(isWalking){
            isWalking = false;
            changeMoveSet(still, 0.4);
          }
          else if ( isStill() || ((wasAttacking || wasJumping) && moveSetComplete()) || ((isGuarding || isWalking) && completeCount > 30 )) {
            setCurrentActionsFalse();
            int diceRoll = rand.nextInt(6);
            if (diceRoll%2 == 0) {
              attack(0);
            } else if (diceRoll%2 == 1) {
              guard();
            }
          }
        }
        
I don't understand what's wrong with the code. For some reason the enemy just keeps freezing up. The moveFrame is fixed at 2 and the moveFrameIncrementor is fixed at 0. I have no idea what's going on.

Okay, so I had a moment of realization where I found out I was being really stupid for a full two hours changing everything in the code when the problem was that I never got the enemy to "unblock". Here's part of the code for the blocking section:

    //If starting to guard
        if (!wasGuarding) {
          if (isStanding) {
            changeMoveSet(guard, 0.6);
          } else if (isCrouching) {
            changeMoveSet(crouchGuard, 0.3);
          }
        }

        //Keeps player in 'blocking' frame
        if (moveFramePoint >= 2) {
          moveFrameIncrementor = 0;
          moveFramePoint = 2;
        }
        
So stupid me never thought about how the action booleans aren't automatically reset, and as I mentioned I've had issues with the functions resetting them. Well, it turns out that the enemy character was never moving out of guarding, which was why the moveFrame was fixed at 2 and the incrementor at 0. I don't know why I do such stupid things...

Other than that, I set up the hit animations so that there's one for when you're crouching and another for when you're standing/jumping. They're based off of the function moveSetComplete(), which I mentioned previously. Here's the actual function:

    //check whether the move set has been completed (for attacking, jumping)
      boolean moveSetComplete() {
        if (moveFramePoint + moveIndexStart >= moveIndexStop) {
          return true;
        } else {
          return false;
        }
      }

Super simple, but it'll help out a lot when dealing with character animations. I've also more or less finished the enemy programming, which is a simple guard-or-attack system that follows the player if they're out of range. Also, there's a slight chance that it'll pull off a ranged attack when it's too far away from the character. This means that you might have random objects flying at you out of nowhere. It's all part of the fun, right?

#### Oct. 26

So, I need to make the class for stages and then create the class for the game itself, which has a menu and instructions. That's what I'll be working on today, and try to finish this stupidly-big project that I have no idea if I can finish in time. Next time, I'll try to be less ambitious with my work (I'll choose something within my skill range).

My life right now in a nutshell is nullPointerException. I don't know why I'm getting this problem. Everything works fine when I have them in separate classes, but when I put them together in a stage class everything breaks down. I've been trying to figure this out for the past hour and a half. Don't have a lot of time left...

#### Oct. 27

Okay, so it's currently 2 AM. I have a lot of things I finished, but I think I'll write about them after I sleep.
Technically, to fulfill the criteria, all I need is to add sound. However, I'd like to add a moving background and some movie files as well, if possible.

Okay. So, first off, fixed the nullPointerException. The problem was I was trying to instantiate a custom object in a constructor, and that was throwing off the compiler. I've created a main menu, too, and set up a system to move stages and to also to reset the game upon death. I particularly like my instruction screen, where you can actually play around with the character to get a hang of the moves before setting out in the actual game. What I have to do in the next few hours is a) put in sound files b) add more character files (and rename them <-- this takes the longest) and c) put in backgrounds for both the game and the main menu. So here we go.

So a problem that I ran across was that things weren't resetting properly, and I found out that it was because of the object instantiation and the constructor that I made for each object class. Because I didn't initialize the objects based on the arguments they received in the constructor, they were only getting the basic values that were made outside of the constructor.

Aight, more or less finished with the game. It's not pretty (well actually it is very pretty and beautiful in my eyes, just that I didn't get to implement everything I wanted to), but it works! Added music to the game and sat for around 5 minutes just listening to the music and watching the background change.

Renamed another character, so character selection is finally possibe! I need to add 2-3 more characters so that I can have various enemies. Off to work, then!

Finished. Didn't have time for the cutscenes in the end, but I plan on adding those in my spare time.
