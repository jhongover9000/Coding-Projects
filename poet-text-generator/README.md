### Assignment 4: Generative Text

![](IM_Assignent4_Screenshot.png)

#### Description

This is a random text generator that uses grammar rules (sentence structure) in order to create one-line poetic sentences.
This is done using functions that call one another according to the grammar rules (i.e. a noun should come after
an adjective). The words themselves are read off of a CSV file, meaning that you can always add or subtract the words you
want in the sentences. There are also some particle effects that look like snow to set the mood ;) Oh, the program is kinda power-hungry and it doesn't actually end (I made it so there's a new line every 250 frames, but that's it), so make sure you
end the program in the case that you run it.
###### Note: the CSV file needs to have 6 lines, with each line as follows: pronoun, noun, adjective, preposition, article, verb.

#### The Birth of an Idea

To be honest, I didn't want to do this. I wanted to do something that I knew I could do, like a program that could fill in a 
MadLib. This was mostly because I didn't want to do all of the hardcoding bits of each sentence structure and had no idea 
where to start with something like this. I looked through the internet and found stuff like Natural Language Processing that
further discouraged me. But after a bit I thought that I might as well do the hardcoding because I wanted to make a poem
generator at some point anyways. Some examples are on https://www.poem-generator.org.uk/. I didn't choose to make an entire
poem, since I'm not at the point where I can attempt that, but I *did* make a pretty cool sentence generator, which could
technically be used as a poem generator..? 

![](PoemGenerator_Screenshot.png)

#### The *Aha* Moment

What was really amazing was what I found out while I was writing the code. I was originally going to have each format function have a list of the words I wanted to use like this (summarized because I deleted the original hehe),

    void sentenceF1(){
        addPronoun();
        if(random(0,2)%2 == 1){addAdj();}
        addNoun();
        addPrep();
        addArt();
        if(random(0,2)%2 == 1){addAdj();}
        addNoun();

but I found a way to represent the code like this: 

    void sentenceF1() {
      lineLength = 8;
      adjCount = 2;
      addPronoun(lineArray);
      }
            
All I needed to do was specify the number of words in the sentence (lineLength) and the number of adjectives (which are optional) at the beginning of each call, which cut down the whole complicated process of adding probability bits over and
over again. I went from having to write each call of a function to writing down one call for a single function and merely 
setting limiters so that they would call each other over and over until a sentence was formed, and the program would 
automatically stop. I actually think it's rather ingenius that I came up with this method (no bragging, just really think 
that it's cool).

For explanation, here's a line from the code, which shows what I did in order to set the grammar rules for 
each call of a function:

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

This function (addNoun) in particular is the "ending call" for the set of functions using the conditions of whether the noun
is at the end of the sentence or not. This method was actually something that was really interesting because I didn't think
of using this until nearly halfway through the entire coding process. If it isn't at the end of a sentence, the function
will call a verb (which comes next in a sentence structure).
This method of having each function call the next, and make the entire system go in a loop over and over until the 
addNoun function returned a non-function command allowed me to shorten each function to ~5 lines.

#### Overall Difficulties

Something difficult that I ran across was when I would occasionally run into situations where the program would get stuck
in a loop and constantly call functions without ending, which is why I had to modify the addNoun() function so that in 
the case that the number of words was over, it would automatically end the line and put a period. Also, getting the whole
optional bit (articles and adjectives) to work via the grammar rules was kind of complicated as well, but I got through it
with grit and determination ;)
