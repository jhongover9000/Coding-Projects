// AI Project 1: 8-Puzzle Solver
// Joseph Hong
// Description: This is a program that will solve an 8-puzzle problem using
//              the A* algorithm with both weighted and unweighted heuristics.
// ==============================================================================================================
// ==============================================================================================================
// Includes
#include <cstdlib>
#include <stdlib.h>

#include <iostream>
#include <fstream>
#include <sstream>
#include <fcntl.h>

#include <unistd.h>

#include <stdio.h>

#include <string.h>

#include <map>
#include <vector>
#include <list>
// just using vectors for the tilemaps could help speed up and simplify the
// comparison process for the tilemap states; i.e. compare tilemap vector to
// tilemap vectors in the search tree, or add the state to the "reached nodes"
// note: does this mean that you need pointers? possibly.

using namespace std;

// ==============================================================================================================
// ==============================================================================================================
// Classes

// State Node
class Node
{

private:
    int* mapState;              // state of puzzle
    int* locations;             // array of coordinates for each number
    int g;                      // g(n)
    int h;                      // h(n)
    int f;                      // sum of g(n) + h(n)
    int dir;                    // direction
    vector<int> pastMoves;      // saves move directions of predecessors
    vector<int> pastValues;     // saves values of predecessors
    int totalNodes;             // used only at end to save total nodes generated

public:
    // Constructor
    Node(int* numArray){
        mapState = (int*)malloc(9 * sizeof(int));
        locations = (int*)malloc(18 * sizeof(int));
        // populate the map (L to R, T to B) and save locations
        for(int i = 0; i < 9; i++){
            // save number to puzzle
            this->mapState[i] = numArray[i];
            // save row
            this->locations[numArray[i]*2] = int(i/3);
            // save column
            this->locations[numArray[i]*2+1] = i%3;
        }
    };

    // Destructor
    ~Node(){};

    // save locations
    void saveLocations(int* numArray){
        for(int i = 0; i < 9; i++){
            // save row
            this->locations[numArray[i]*2] = int(i/3);
            // save column
            this->locations[numArray[i]*2+1] = i%3;
        }
    }
    // Return Locations
    int* getLocations(){
        return this->locations;
    }
    // Return State of Puzzle
    int* getState(){
        return this->mapState;
    };
    // Get Direction
    int getDir(){
        return this->dir;
    }
    // Set Direction
    void setDir(int dir){
        this->dir = dir;
    }
    // Add to the Past Moves and Values
    void recordStats(){
        this->pastMoves.push_back(this->dir);
        this->pastValues.push_back(this->f);
    }
    // Receive Records from Parent Node
    void receiveRecords(vector<int> pastMoves, vector<int> pastValues){
        for(int i = 0; i < pastMoves.size(); i++){
            this->pastMoves.push_back(pastMoves[i]);
        }
        for(int i = 0; i < pastValues.size(); i++){
            this->pastValues.push_back(pastValues[i]);
        }
    }
    // Get Past Moves
    vector<int> getPastMoves(){
        return pastMoves;
    }
    // Get Past Values
    vector<int> getPastValues(){
        return pastValues;
    }
    // Get Cost
    int getTotalCost(){
        return f;
    }
    // Calculate Cost
    int calcTotalCost(int* goalLocations, int heuristicNum){
        if(heuristicNum == 1){
            // set heuristic
            this->h = manhattanSum(goalLocations);
        }
        else{
            // set heuristic (USES GOAL STATE, NOT LOC)
            this->h = nilssonSum(goalLocations);
        }
        // f(n) = g(n) + h(n)
        this->f = this->g + this->h;
        // cout<<"TOTAL COST F(N):"<<this->f<<endl;
        return this->f;
    }
    // Get g(n) Value of Function
    int getCost(){
        return this->g;
    }
    // Set g(n) Value of Function
    void setCost(int cost){
        this->g = cost;
        // debug
        // cout<<"NODE COST G(N):"<<this->g<<endl;
    }
    // Get Sum of Manhattan Distances
    int manhattanSum(int* goalLocations){
        int totalSum = 0;
        // 0 is blank, therefore should not be counted (to make h1 admissible)
        for(int i = 2; i < 18; i++){
            totalSum += abs(locations[i] - goalLocations[i]);
        }
        // debug
        // cout<<"MAN SUM:"<<totalSum<<endl;
        return totalSum;
    }
    // Get Nilsson's Seq Score
    int nilssonSum(int* goalLocations){
        // convert locations to state
        int* gState = locToState(goalLocations);
        // variables for sum
        int nilSum = 0;
        int manSum = 0;
        int totalSum = 0;
        // indicies (clockwise) 0, 1, 2, 5, 8, 7, 6, 3
        int clockwiseIndices[8] = {0, 1, 2, 5, 8, 7, 6, 3};
        int clockwiseGoal[8] = {gState[0],gState[1],gState[2],gState[5],gState[8],gState[7],gState[6],gState[3]};
        for(int i = 0; i < 8; i++){
            if(mapState[clockwiseIndices[i]] != gState[4] && nextNum(mapState[clockwiseIndices[i]], clockwiseGoal) != mapState[clockwiseIndices[(i+1)%8]]){
                nilSum += 2;

                // debug
                // cout<<"Mismatch: Tile following "<<mapState[clockwiseIndices[i]]<<" should be "<<nextNum(mapState[clockwiseIndices[i]], clockwiseGoal)
                // <<" but is "<<mapState[clockwiseIndices[(i+1)%8]]<<"."<<endl;
            }
        }
        // center 4
        if(mapState[4] != gState[4]){
            nilSum += 1;
        }
        // multiply nilson sum
        nilSum *= 3;
        // debug
        // cout<<"NIL SUM:"<<nilSum<<endl;
        // get manhattan sum
        manSum = manhattanSum(goalLocations);
        // add sums
        totalSum = manSum + nilSum;
        // debug
        // cout<<"TOTAL COST H(N):"<<totalSum<<endl;
        // return val
        return totalSum;
    }
    // Get Next Number (for Nilsson Sum)
    int nextNum(int num, int clockwise[]){
        // int clockwise[8] = {goalState[0],goalState[1],goalState[2],goalState[5],goalState[8],goalState[7],goalState[6],goalState[3]};
        // need to link each of the numbers to the next
        // create a function that will give the next number on the array
        for(int i = 0; i < 9; i++){
            if(num == clockwise[i]){
                return clockwise[(i+1)%8];
            }
        }
        // if the number is not found (is center), return same num
        return num;
    }
    // Convert Location Array to State
    int* locToState(int* locations){
        // create array
        int* gState = (int*)malloc(9 * sizeof(int));
        // one by one, insert number at correct coordinates
        for(int i = 0; i < 9; i++){
            gState[locations[i*2]*3 + locations[i*2+1]] = i;
        }
        return gState;
    }
    // Print State (for debugging)
    void printState(){
        for(int i = 0; i < 9; i++){
            if( i > 0 && i%3 == 0){
                cout << endl;
            }
            cout<<mapState[i]<<" ";
        }
        cout << endl;
    }
    // Print Locations (for debugging)
    void printLocations(){
        // cout << "val: " << numArray[i]<<" | row: "<< numArray[i]*2 <<" - " <<int(i/3)<< " | col: "<<numArray[i]*2+1<<" - " << i%3 <<endl;
        for(int i = 0; i < 17; i++){
            cout<<this->locations[i]<<",";
        }
        cout<<this->locations[17] << endl;
    }
    // Print State and Costs (for debugging)
    void printStats(){
        printState();
        cout<<"Costs"<<endl
        <<"g(n): "<<this->g<<endl
        <<"h(n): "<<this->h<<endl
        <<"f(n): "<<this->f<<endl<<endl;
    }
    // Set Total Nodes
    void setTotalNodes(int totalNodes){
        this->totalNodes = totalNodes;
    }
    // Get Total Nodes
    int getTotalNodes(){
        return this->totalNodes;
    }


};

// ==============================================================================================================
// ==============================================================================================================
// Functions

// Convert State to Location Array
int* stateToLoc(int* state){
    // create array
    int* locations = (int*)malloc(18 * sizeof(int));
    // one by one, insert number at correct coordinates
    for(int i = 0; i < 9; i++){
        locations[state[i]*2] = int(i/3);
        locations[state[i]*2+1] = i%3;
    }
    return locations;
}

// Check for Goal State
bool checkGoal(int* currentState, int* endState){
    for(int i = 0; i < 9; i++){
        if(currentState[i] != endState[i]){
            return false;
        }
    }
    return true;
}

vector<int> movesPerformed(vector<int*> states){

}

// Yield Child Node
void yieldNode(Node* node, vector<Node>& children, int row, int col, int changeVal, int* goalLocations, int heuristicNum){
    // placeholder (number to be shifted to)
    int placeholder;
    // vectors to transfer records to child node
    vector<int> pastMoves;
    vector<int> pastValues;
    // create new array to copy location
    int* state = (int*)malloc(9*sizeof(int));
    // copy data to array (for creating new nodes)
    for(int i = 0; i < 9; i++){
        state[i] = node->getState()[i];
    }
    // get value at target loc by using index of 0 in state and adding changeVal
    placeholder = state[row*3 + col + changeVal];        
    // shift blank tile
    state[row*3 + col + changeVal] = 0;
    state[row*3 + col] = placeholder;
    // generate child of action
    Node* temp = (Node*)malloc(sizeof(Node));
    temp = new Node(state);
    // increase path cost by 1 from parent node cost
    temp->setCost(node->getCost()+1);    
    // debug
    // cout<<"Updated Cost:" <<temp->getCost()<<endl;
    // calculate total cost
    temp->calcTotalCost(goalLocations, heuristicNum);

    // set direction
    if(changeVal == -1){temp->setDir(1);}       // left
    else if(changeVal == 1){temp->setDir(2);}   // right
    else if(changeVal == -3){temp->setDir(3);}  // up
    else if(changeVal == 3){temp->setDir(4);}   // down

    // transfer to child
    temp->receiveRecords(node->getPastMoves(), node->getPastValues());

    // add to vector
    children.push_back(*temp);
    // debug
    // cout << "placeholder: " << state[row*3 + col + changeVal] << endl;
    // temp->printStats();
}

// Expand Node
vector<Node> expandNode(Node* node, int* goalLocations, int heuristicNum){
    // holds children to expand
    vector<Node> children;
    // save parent values
    node->recordStats();
    // check the locations to see what moves are available
    int row = node->getLocations()[0];
    int col = node->getLocations()[1];
    // if 0 is on left/center, move RIGHT (index +1)
    if(col < 2){
        //debug
        // cout<<"Move right"<<endl;
        // move right
        yieldNode(node, children, row, col, 1, goalLocations, heuristicNum);
    }
    // if 0 is on right/center, move LEFT (index -1)
    if(col > 0){
        //debug
        // cout<<"Move left"<<endl;
        // move left
        yieldNode(node, children, row, col, -1, goalLocations, heuristicNum); 
    }
    // if 0 is on top/center, move DOWN (index +3)
    if(row < 2){
        //debug
        // cout<<"Move down"<<endl;
        // move down
        yieldNode(node, children, row, col, 3, goalLocations, heuristicNum);
    }
    // if 0 is on bottom/center, move UP (index -3)
    if(row > 0){
        //debug
        // cout<<"Move up"<<endl;
        // move up
        yieldNode(node, children, row, col, -3, goalLocations, heuristicNum);
    }
    // debug
    // cout<<"size:"<<children.size()<<endl;
    // for(int i = 0; i < children.size(); i++){
    //     children.at(i).printState();
    //     cout << endl;
    // }
    return children;
}

// Using A* to solve puzzle
Node puzzlebot(int* initialState, int* goalState, int heuristicNum){
    // variables
    int* goalLocations = stateToLoc(goalState);
    int totalNodes = 0;
    Node* currentNode;
    list<Node> frontier;                // priority queue ordered by f(n)
    list<Node>::iterator front_it;      // iterator for frontier
    map<vector<int>, int> reached;      // map to store visited states and f(n) values
    vector<Node> children;              // vector to store children on expansion
    
    vector<Node>::iterator child_it;    // iterator for children vector
    int currentDepth;                   // depth of tree (increases each iteration)
    // create first node, increment total generated nodes
    currentNode = new Node(initialState);
    totalNodes++;
    // currentNode->setCost(0);
    currentNode->calcTotalCost(goalLocations, heuristicNum);
    // convert to vector for adding to reached
    vector<int> startNodeState;
    for(int i = 0; i < 9; i++){
        startNodeState.push_back(currentNode->getState()[i]);
    }
    // add node to the frontier
    frontier.push_back(*currentNode);
    // add node state and f(n) value to reached
    reached.insert(pair<vector<int>,int>(startNodeState, currentNode->getTotalCost()));
    // while frontier is not empty, expand nodes according to f(n) value
    while(!frontier.empty()){
        //debug
        // cout<< "Assigning Node..."<<endl;s
        // assign current node to front of frontier  
        *currentNode = frontier.front();
        // debug
        // cout<<"CURRENT STATE:"<<endl;
        // currentNode->printStats();
        // cout<<endl;
        // check if goal state
        if( checkGoal(currentNode->getState(), goalState) ){
            // if goal state, save values and return node
            // save parent values
            currentNode->recordStats();
            currentNode->setTotalNodes(totalNodes);
            return *currentNode;
        }
        // debug
        // cout<<endl<<"Expanding..."<<endl<<endl;
        // expand node
        children = expandNode(currentNode, goalLocations, heuristicNum);
        // increment number of nodes generated (includes repeated states since they are GENERATED but added conditonally)
        totalNodes += children.size();
        // pop lowest (current head)
        frontier.pop_front();
        // keep track of child index
        int childIndex = 0;    
        // go through generated children that haven't been reached
        for(child_it = children.begin(); child_it != children.end(); child_it++){
            // debug
            // cout<<endl<<"CHILD STATE:"<<endl;
            // child_it->printState();
            // create vector to add/find children to/in reached
            vector<int> tempVec;
            for(int i = 0; i < 9; i++){
                tempVec.push_back(child_it->getState()[i]);
            }
            // debug
            // cout<<"Reached: "<<(reached.find(tempVec) != reached.end())<<endl;
            // if(reached.find(child_it->getState()) != reached.end()){(cout<<"Cost Compare (if reached): "<<child_it->getTotalCost()<<" | "<< reached.at(child_it->getState())<<endl;}
            // if state is not found or the f(n) of the child is less, replace
            if((reached.find(tempVec) == reached.end()) || (child_it->getTotalCost() < reached.at(tempVec)) ){     
                // add the child node to the reached table, update value if need be
                reached[tempVec] = child_it->getTotalCost();
                // save frontier size (because adding children will increase it each iteration and will cause infinity loop)
                int frontierSize = frontier.size();
                // go through frontier to prioritize by cost
                for(front_it = frontier.begin(); front_it != frontier.end(); front_it++){
                    //debug
                    // cout<<"Costs"<<endl
                    // <<"Child: " << child_it->getTotalCost()<< " | Current Node: " << front_it->getTotalCost()<<endl; 
                    // if total cost is lower than node in front, insert in front
                    if(child_it->getTotalCost() < front_it->getTotalCost()){
                        frontier.insert(front_it, children.at(childIndex));
                        // debug
                        // cout<< "Node Added to Frontier"<<endl
                        // <<"Child Cost: "<<child_it->getTotalCost()<<endl
                        // <<"Child Num:" << childIndex<<endl;
                        // cout<<"Frontier Size: " <<frontier.size()<<endl;
                        // cout<<endl;
                        break;
                    }                    
                }
                tempVec.clear();
                // if all costs in queue are lower, add to end
                frontier.push_back(children.at(childIndex));

                // debug
                // cout << "Finishing Child" << endl;
            }
            else{
                // cout<< "REDUNDANT, DID NOT ADD TO FRONTIER."<<endl;
            }
            
            childIndex++;
            
        }
        // clear vector of children
        children.clear();
        
        // increment depth level
        currentDepth++;
    }
    // return failure
    cout << "Solution not found." << endl;
    exit(1);
}

// Checker for Digits. Ensures that the command line arguments (where applicable) are digits only.
bool isDigits(char* argument) {
  int length = strlen(argument);
  for(int i = 0; i < length; ++i) {
    if(!isdigit(argument[i])){
        return false;
    }
  }
  return true;
}

// ==============================================================================================================
// ==============================================================================================================
// Execution
int main(int argc, char *argv[]){
    // Input/Output Variables
    string inputFile;                   // file path for input file
    string outputFile = "output";                  // file path for output file
    char fileNum;                       // file number (for output file)
    int heuristicNum = 0;               // heuristic number
    // Parse Command Line Arguments
    if(argc < 3){
        cout << "Error: Usage is " << argv[0] <<"-i <inputFile> -h <heuristicFuncType>, where "
        << "heuristicFuncType is integer between 1 and 2." << endl
        << "Note that heuristicNum may affect the output." << endl;
        exit(1);
    }
    else{
        for(int i = 1; i < argc; i++){
            // Check arguments
            if(argv[i][0] == '-'){
                // if '-i', check to make sure that the file exists
                if(argv[i][1] == 'i'){
                    inputFile = argv[i+1];
                    ifstream readFile(inputFile);
                    if(readFile.good()){
                        // set file num (for output)
                        fileNum = inputFile.at(inputFile.find(".")-1);
                    }
                    else{
                        cout<< "Error: File " << inputFile << " cannot be read. Make sure to type the entire file with its extension"<<
                        "and directory, if applicable."<<endl;
                        exit(1);
                    }
                }
                // if '-h' set heuristicNum
                else if(argv[i][1] == 'h'){
                    if(isDigits(argv[i+1])){
                        int temp = atoi(argv[i+1]);
                        if (1 <= temp && temp <= 2){
                            heuristicNum = temp;
                        }
                    }
                    else{
                        cout<< "Please give a valid number for the heuristic function to use (1 or 2)."<<endl;
                        exit(1);
                    }
                }
            }
        }
    }
    // set outputfile name
    outputFile += fileNum;
    outputFile += 'h';
    outputFile += '0' + heuristicNum;
    outputFile += ".txt";
    
    //debug
    cout << "File: "<<inputFile <<endl;
    cout << "Output:" << outputFile << endl;
    cout << "hNum: " << heuristicNum << endl;
    cout << "fNum: " << fileNum << endl;

    // Input File Variables
    int lineCount = 0;
    int tileCount = 0;
    int initialStateInput[9];
    int goalStateInput[9];
    // Read Input File
    FILE* fp;
    char line[80];
    fp = fopen(inputFile.c_str(), "r");
    while (fgets(line, sizeof(line), fp) != NULL)
    {
        // skip fourth line
		if(lineCount == 4){
			continue;
		}
        // get first token
        char* token = strtok(line, " ");
        // loop and extract all tokens
        while( token != NULL ) {
            // skip if newline
            if(*token == '\n'){
                continue;
            }
            // if tileCount is less than 9, stay on inital state
            if(tileCount <= 9){
                initialStateInput[tileCount] = atoi(token);
			    tileCount++;
            }
            // else move to goal state
			else{
                goalStateInput[tileCount%10] = atoi(token);
			    tileCount++;
            }
            token = strtok(NULL, " ");
        }
    }

    // Setting Up the Algorithm
    int* initialState;
    int* goalState;
    initialState = initialStateInput;
    goalState = goalStateInput;
    // Create Nodes to Start
    Node* start = new Node(initialState);
    Node* goal = new Node(goalState);

    // debug
    // cout<<"INITIAL:"<<endl;
    // start->printState();
    // cout<<endl;
    // cout<<"GOAL:"<<endl;
    // goal->printState();
    // cout<<endl;

    // Node puzzlebot(int* initialState, int* goalState, int heuristicNum)
    Node solutionNode = puzzlebot(start->getState(), goal->getState(), heuristicNum);

    ofstream wfile(outputFile);
    // line 1-3 write start state
    for(int i = 0; i < 9; i++){
        if( i > 0 && i%3 == 0){
            wfile << endl;
        }
        wfile << start->getState()[i] << " ";
    }
    wfile << endl;
    // skip line 4
    wfile << endl;
    // line 5-7 write goal state
    for(int i = 0; i < 9; i++){
        if( i > 0 && i%3 == 0){
            wfile << endl;
        }
        wfile << goal->getState()[i] << " ";
    }
    wfile << endl;
    // skip line 8
    wfile << endl;
    // line 9 depth of goal node
    wfile << solutionNode.getCost() << endl;
    // line 10 total number of nodes (including ones generated but not added)
    wfile << solutionNode.getTotalNodes() << endl;
    // line 11 moves made (start at i = 1 to ignore root)
    for(int i = 1; i < solutionNode.getPastMoves().size(); i++){
        char moves[4] = {'L','R','U','D'};
        wfile << moves[solutionNode.getPastMoves()[i]-1] << " ";
    }
    wfile << endl;
    // line 12 f(n) values
    for(int i = 0; i < solutionNode.getPastValues().size(); i++){
        wfile << solutionNode.getPastValues()[i] << " ";
    }


    

    solutionNode.printStats();
    cout<<"Total Nodes Generated: " << solutionNode.getTotalNodes() << endl;
    cout<<"Moves: "<<solutionNode.getPastMoves().size()<<" | Values: "<<solutionNode.getPastValues().size()<<endl;
    for(int i = 0; i < solutionNode.getPastMoves().size(); i++){
        cout<<solutionNode.getPastMoves()[i]<<" ";
    }
    cout<<endl;
    for(int i = 0; i < solutionNode.getPastValues().size(); i++){
        cout<<solutionNode.getPastValues()[i]<<" ";
    }
    cout<<endl;

    cout << "Successfully terminated." << endl;
    

    return EXIT_SUCCESS;
}