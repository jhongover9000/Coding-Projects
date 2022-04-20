CFLAGS = -O
CC = g++

all: puzzlebot

puzzlebot: puzzlebot.o
	$(CC) $(CFLAGS) -o puzzlebot puzzlebot.o
puzzlebot.o: puzzlebot.cpp
	$(CC) $(CFLAGS) -c puzzlebot.cpp

clean:
	rm -f *.o *~