//========================================================================================================================================================================
//========================================================================================================================================================================
//Library System by Joseph Hong
//========================================================================================================================================================================
//========================================================================================================================================================================
//Libraries Included
#include <iostream>		//Input/output
#include <fstream>		//File read/write
#include <vector>		//For vectors
#include <stdexcept>	//Used for debugging
#include <string>		//String library
#include <sstream>		//For readline, to take each line as a separate value then use for readline again
#include <unistd.h>		//To use getcwd()
#include <locale> 		//For capitilizations (search function)
#include <math.h>		//For hashcode generation
using namespace std;


//========================================================================================================================================================================
//========================================================================================================================================================================
//Setting global variables
string PASSWORD = "a";		//Password for librarian authentication
int SIZE;			//Number of bookcases in library (used for file loading/creation)
char* pathChar;
string path = getcwd(pathChar, 255);
string title;


//========================================================================================================================================================================
//========================================================================================================================================================================
//Classes (Book, BookPointer, Shelf, Bookcase, HashCatalogue)

//Book Class
class Book{
private:
	//Main Data Members (Title, Author, ISBN, Year, Copies)
	string title;
	string author;
	string isbn;
	string year;
	vector<int> copies;			//this vector will store information from the BookPointers
	friend class BookPointer;	//friend class BookPointer, to access private members
public:
	//Constructor & Destructor (copies are edited with different function)
	Book(const string title, const string author, const string isbn, const string year){
		this->title = title;
		this->author = author;
		this->isbn = isbn;
		this->year = year;
	}
	~Book(){};

	//Getters and Converters	
	string getTitle(){					//Title
		return this->title;	
	}
	string getAuthor(){					//Author
		return this->author;
	}
	string getIsbn(){					//ISBN
		return this->isbn;		
	}
	string getYear(){					//Year
		return this->year;		
	}
	int getCopies(){					//Copies
		return this->copies.size();
	}
	vector<int> getAllLocations(){		//All Copies' Locations
		return this->copies;
	}
	string getKey(){					//Creates key for hash catalogue
		string str = this->title + ";" + this->author;
		string key = "";
		for(int i = 0; i < str.length(); i++){
			key += tolower(str.at(i));
		}
		return key;
	}
	//Convert locationComparator of BookPointer to an identifier
	string locationComparator2Identifier(int locationComparator){
		int bookcaseIndex = locationComparator/100;
		int shelfIndex = (locationComparator - bookcaseIndex*100)/10;
		int bookIndex = (locationComparator - bookcaseIndex*100 - shelfIndex*10);
		string identifier = "";
		identifier += char(bookcaseIndex+65);
		identifier += char((int) shelfIndex + 49);
		identifier += ".";
		if(bookIndex >= 9){
			identifier += "10";
		}
		else{identifier += char((int) bookIndex + 49);}
		return identifier;
	}

	//Copies Editors (Add and Remove)
	void addCopy(int BookPointerComparator){
		if(copies.empty()){copies.push_back(BookPointerComparator);}		//if empty push back
		else{
			for(int i = 0; i < copies.size(); i++){
				if(BookPointerComparator < copies[i]){
					copies.insert(copies.begin()+i, BookPointerComparator);
					break;
				}
				else if(BookPointerComparator > copies.back() || copies[i] == copies.back()){	//if larger than last value or all values have been iterated push back
					copies.push_back(BookPointerComparator);
					break;
				}
				
			}
		}
	}
	string removeCopy(int comparator){
		if(copies.empty()){return "No more copies remain.";}
		else{
			for(int i = 0; i < copies.size(); i++){
				if(this->copies[i] == comparator){
					this->copies.erase(copies.begin()+i);
					break;
				}
			}
			return "Removed.";
		}
	}
	//Capitalize Entry
	string capFirst(string str){
		string capped = "";
		capped += toupper(str.at(0));
		bool spaceBefore = false;
		for(int i = 1; i < str.length(); i++){
			if(spaceBefore){
				capped += toupper(str.at(i));
				spaceBefore = false;
			}
			else{
				capped += tolower(str.at(i));
			}
			if(str.at(i) == ' '){		//If there's a space before the next letter, it'll automatically capitalize it
				spaceBefore = true;		//in the next iteration
			}
		}
		return capped;
	}

	//Print Function (for catalogue)
	void print(){
		cout<<"Title: "<<capFirst(getTitle())<<endl
		<<"Author: "<<capFirst(getAuthor())<<endl
		<<"ISBN: "<<getIsbn()<<endl
		<<"Printing Year: "<<getYear()<<endl
		<<"Copies: "<<getCopies()<<endl
		<<"Copy Locations: ";
		for(int i = 0; i < copies.size(); i++){
			cout<<this->locationComparator2Identifier(copies[i])<<" ";
		}
		cout<<endl;
	}

};

//BookPointer Class
class BookPointer{
private:
	//Private Data Members (Location Identifiers, Book pointer)
	int bookcaseIndex;
	int shelfIndex;
	int bookIndex;
	Book* book;
	friend class Shelf;

public:
	//Constructor and Destructor
	BookPointer(int bookcaseIndex, int shelfIndex, int bookIndex){
		this->bookcaseIndex = bookcaseIndex;
		this->shelfIndex = shelfIndex;
		this->bookIndex = bookIndex;
		book = nullptr;
	}
	~BookPointer(){
		this->book->removeCopy(this->getlocationComparator());		//Remove instance of book from copies when destructed
	}


	//Getters for Book	
	string getTitle(){					//Title
		return this->book->getTitle();	
	}
	string getAuthor(){					//Author
		return this->book->getAuthor();
	}
	string getIsbn(){					//ISBN
		return this->book->getIsbn();		
	}
	string getYear(){					//Year
		return this->book->getYear();		
	}
	int getCopies(){					//Copies
		return this->book->getCopies();
	}
	vector<int> getAllLocations(){		//All Copies' Locations
		return this->book->getAllLocations();
	}

	//Getters for BookPointer
	Book& getBook(){return *book;}
	int getBookcaseIndex(){return this->bookcaseIndex;}

	int getShelfIndex(){return this->shelfIndex;}

	int getBookIndex(){return this->bookIndex;}

	int getlocationComparator(){					//used for sorting the locations in Book object
		int locationComparator = 0;
		locationComparator += this->bookcaseIndex*100;
		locationComparator += this->shelfIndex*10;
		locationComparator += this->bookIndex;
		return locationComparator;
	}
	string locationComparator2Identifier(int locationComparator){
		int bookcaseIndex = locationComparator/100;
		int shelfIndex = (locationComparator - bookcaseIndex*100)/10;
		int bookIndex = (locationComparator - bookcaseIndex*100 - shelfIndex*10);
		string identifier = "";
		identifier += char(bookcaseIndex+65);
		identifier += char((int) shelfIndex + 49);
		identifier += ".";
		if(bookIndex >= 9){
			identifier += "10";
		}
		else{identifier += char((int) bookIndex + 49);}
		return identifier;
	}

	//Updaters
	void linkBook(Book& book){
		this->book = &book;										//link book
		this->book->addCopy(this->getlocationComparator());		//automatically add new copy to copies of referenced Book object
	}

	void updateBookIndex(int bookIndex){			//update index within books
		this->book->removeCopy(this->getlocationComparator()); 	//remove original copy from copies
		this->bookIndex = bookIndex;
		this->book->addCopy(this->getlocationComparator());		//add new copy to copies
	}

	void updateLocation(int bookcaseIndex, int shelfIndex, int bookIndex){		//update if moved to new location entirely
		this->book->removeCopy(this->getlocationComparator()); 	//remove original copy from copies
		this->bookcaseIndex = bookcaseIndex;						//update values
		this->shelfIndex = shelfIndex;
		this->bookIndex = bookIndex;
		this->book->addCopy(this->getlocationComparator());		//add new copy to copies
	}	

};

//Shelf Class
class Shelf{
private:
	//Private Data Members (Index of shelf, vector of BookPointers)
	vector<BookPointer*> books;

public:
	//Constructor and Destructor
	Shelf(){}
	~Shelf(){
		while(!(this->books.empty())){
			this->books.pop_back();
		}
	}

	//Getters, Setters, and Checkers
	BookPointer* operator[](int index){		//Overloaded index operator
		return this->books[index];
	}
	BookPointer* atIndex(int index){
		return this->books[index];
	}
	int getSize(){							//Size
		return this->books.size();
	}
	bool isFull(){							//Check if full
		return (this->books.size() == 10);
	}
	bool isEmpty(){							//Check if empty
		return this->books.empty();
	}


	//Edit Methods

	//Initial Adding
	string addBook(Book& book, int bookcaseIndex, int shelfIndex, int index, int copies){
		if((books.size() + copies) > 10 || this->isFull()){
			cout<<"Not enough space on shelf."<<endl;
			return "null";
		}
		else if(books.empty()){
			for(int i = 0; i < copies; i++){
				BookPointer* bookPointer = new BookPointer(bookcaseIndex, shelfIndex, i);
				bookPointer->linkBook(book);
				books.push_back(bookPointer);
			}
		}
		else{
			if(index > books.size()){index = books.size();}
			for(int i = index; i < index+copies; i++){
				BookPointer* bookPointer = new BookPointer(bookcaseIndex, shelfIndex, i);
				bookPointer->linkBook(book);
				books.insert(books.begin()+i, bookPointer);

			}
			
		}
		updateShelf();
		return books[index]->getBook().getTitle();
	}
	//Remove Book
	void removeBook(int bookcaseIndex, int shelfIndex, int bookIndex){
		if(books.empty()){cout<<"Shelf is Empty."<<endl;}
		else{
			this->books[bookIndex]->getBook().removeCopy(books[bookIndex]->getlocationComparator());
			delete(this->books[bookIndex]);
			this->books.erase(this->books.begin()+bookIndex);
		}
		updateShelf();
	}

	//Update indicies of BookPointers
	void updateShelf(){
		for(int i = 0; i < this->books.size(); i++){
			if(this->books[i]->getBookIndex() != i){			//if index of book is different from index in shelf
				this->books[i]->getBook().removeCopy(this->books[i]->getlocationComparator());				//update index and reflect in catalogue
				this->books[i]->bookIndex = i;
				this->books[i]->getBook().addCopy(this->books[i]->getlocationComparator());
			}
		}
	}

};

//Bookcase Class
class Bookcase{
	private:
		Shelf* shelves[5];
	public:
		Bookcase(){
			for(int i = 0; i < 5; i++){
				shelves[i] = new Shelf();
			}
		}

		//Returns a shelf from the array
		Shelf* operator[](int i){return shelves[i];}

};

//Catalogue Class (Set as Hash Map)
class Catalogue{
private:
	//Private Data Members (pointer array bookList)
	Book** bookList;
	int size;
	int capacity;

public:
	//Constructor and Destructor
	Catalogue(int capacity){
		this->bookList = new Book*[capacity];
		this->capacity = capacity;
		this->size = 0;
	}
	~Catalogue(){
		delete[] bookList;
	}

	//Getters
	int getSize(){
		return size;
	}
	int getCapacity(){
		return capacity;
	}


	//Helper Methods

	//Hash Code Generator
	unsigned long hashCode(const string key){
		string hash = "";							//conversion to lowercase (case-insensitivity)
		for(int i = 0; i < key.length(); i++){
			hash = hash + char(tolower(key.at(i)));
		}
		unsigned long code = 0;
		for(int i = 0; i < key.length(); i++){
			code += (int)key[i] * pow(i,6);
		}
		return code;
	}

	//Search for Book
	string search(const string key){									//Search for book using quadratic probing
		string hash = "";							//conversion to lowercase (case-insensitivity)
		for(int i = 0; i < key.length(); i++){
			hash = hash + char(tolower(key.at(i)));
		}
		int probes = 1;
		int hashIndex = hashCode(key)%capacity;
		int counter = 0;
		do{
			if(bookList[hashIndex] != nullptr && bookList[hashIndex]->getKey() == hash){
				system("clear");
				cout<<"Book found: "<<endl;
				bookList[hashIndex]->print();
				return "";
			}
			hashIndex = (hashIndex+(probes*probes))%this->capacity;
			counter++;
			probes++;
		}while(counter < capacity);
		return "null";
	}


	//Edit Methods

	//Add Book to Catalogue
	Book& addBook(Book& book){										//Insert new book using quadratic probing
		string key = book.getKey();
		int probes = 1;
		int hashIndex = hashCode(key)%capacity;
		while(this->bookList[hashIndex] != NULL){		//while hashIndex taken use linear probing to find empty space
			if(this->bookList[hashIndex]->getKey() == book.getKey()){
				return *bookList[hashIndex];
			}
			hashIndex = (hashIndex+(probes*probes))%this->capacity;
			probes++;						
		}
		Book* b = new Book(book.getTitle(), book.getAuthor(), book.getIsbn(), book.getYear());
		for(int i = 0; i < book.getCopies(); i++){
			b->addCopy(book.getAllLocations()[i]);
		}
		bookList[hashIndex] = b;
		size++;
		return *b;
	}

	//Remove Book From Catalogue
	Book* removeBook(const string key){
		unsigned long hashIndex = hashCode(key)%this->capacity;
		int counter = 0;
		int probes = 1;
		while(bookList[hashIndex] != nullptr && counter < this->capacity){
			if(bookList[hashIndex]->getKey() == key){
				system("clear");
				Book& book = *bookList[hashIndex];
				Book* bp = &book;
				bookList[hashIndex] = nullptr;						//reassign bookList[hashIndex] to nullptr
				return bp;											//return pointer to delete instances
			}
			hashIndex = (hashIndex+(probes*probes))%this->capacity;			//use quadratic probing
			probes++;
		}
		return nullptr;
	}


	void print(){
		for(int i = 0; i < capacity; i++){
			if(bookList[i] == NULL){continue;}
			else{bookList[i]->print(); cout<<endl;}
		}
	}
				

};
//========================================================================================================================================================================
//========================================================================================================================================================================
//Helper Functions

//Display commands available
void help(){
	//Options a user can select from
	cout << "Please Select An Option From Below\n";
	cout << "1) Search for a book\n";
	cout << "2) Add a new book\n";
	cout << "3) Delete ALL instances of a book\n";
	cout << "4) Remove a book from shelf\n";
	cout << "5) Move a book\n";
	cout << "6) Check number of books on shelf\n";
	cout << "7) Check number of bookcases in library\n";
	cout << "8) Display catalogue (unsorted).\n";
	cout << "9) Exit the program\n";
}

//Save titlebar (initialization)
void saveTitle(string& title, string barHere){
	title = barHere;
}

//Save size (Initialization)
void saveSize(int& SIZE, int sizeNum){
	SIZE = sizeNum;
}

//Input Converters

//To Lowercase
string toLower(string str){
	string lowercase = "";
	for(int i = 0; i < str.length(); i++){
		lowercase += tolower(str.at(i));
	}
	return lowercase;
}
//To Uppercase
string toUpper(string str){
	string upper = "";
	for(int i = 0; i < str.length(); i++){
		upper += toupper(str.at(i));
	}
	return upper;	
}
//Capitalize Entry
string capFirst(string str){
	string capped = "";
	capped += toupper(str.at(0));
	bool spaceBefore = false;
	for(int i = 1; i < str.length(); i++){
		if(spaceBefore){
			capped += toupper(str.at(i));
			spaceBefore = false;
		}
		else{
			capped += tolower(str.at(i));
		}
		if(str.at(i) == ' '){		//If there's a space before the next letter, it'll automatically capitalize it
			spaceBefore = true;		//in the next iteration
		}
	}
	return capped;
}
//To Indicies
int toIndex(char chr, string str){
	if(str == "letter"){		//i.e. A1
		return (int)tolower(chr) - 97;
	}
	else if(str == "number"){
		return (int)chr - 48;
	}
	else{return 0;}
}


//Function called to authenticate a user, returns true if authenticated, false otherwise
bool authenticate(){
	string password;
	cout << "Enter the password: ";
	cin >> password;

	if(password == PASSWORD){
		return true;
	}
	return false;
}
//Returns whether or not a passed string is a valid location in the correct form (A1.1 - A3.10)
bool validLocation(int SIZE, string str){
	//Check for initial wrong length
	if(!(str.length() == 4 || str.length() == 5)){
		return false;
	}
	//First character determinging to be valid
	int firstChar = (int)str.at(0);
	//if it is lowercase convert to upper
	if(firstChar >= 97 && firstChar <= 122){
		firstChar -= 32;
	}
	//See if the first character falls within the range of alloted bookshelves
	if(firstChar >= 65 && firstChar < 65 + SIZE){
		//Second character is 1-5
		if(str.at(1) == '1' || str.at(1) == '2' || str.at(1) == '3' || str.at(1) == '4' || str.at(1) == '5'){
			if(str.at(2) == '.'){
				if(isdigit(str.at(3)) && str.at(3) != '0'){
					if(str.length() == 4){
						return true;
					}
					else if(str.length() == 5 && str.at(4) == '0'){
						return true;
					}
				}
			}
		}
	}
	return false;
}

//Returns whether or not a passed string is a valid shelf in the correct form (A1, B2, C3, etc.)
bool validShelf(string str){
	//Check for initial wrong length
	if(!(str.length() == 2)){
		return false;
	}
	//First character determinging to be valid
	int firstChar = (int)str.at(0);
	//if it is lowercase convert to upper
	if(firstChar >= 97 && firstChar <= 122){
		firstChar -= 32;
		//See if the first character falls within the range of alloted bookshelves
		if(firstChar >= 65 && firstChar < 65 + SIZE){
			//Second character is 1-5
			if(str.at(1) == '1' || str.at(1) == '2' || str.at(1) == '3' || str.at(1) == '4' || str.at(1) == '5'){
					return true;
			}
		}
	}
	return false;
}

//Returns whether <title>;<author> is valid (if only one ";" exists)
bool validSearch(string str){
	if(str.find(";") != string::npos){
		if(str.substr(0,str.find(";")) == str.substr(0,str.rfind(";"))){
			if(str.substr(str.find(";")) == str.substr(str.rfind(";"))){
				return true;
			}
		}
	}
	return false;

}


//Final File Saver
void saveLibrary(vector<Bookcase> bookcases){
	//Iterates through files and saves bookcases
	int copyCount = 1;											//Using a counter for copies (to input to csv)
	for(int i = 0; i < SIZE; i++){
		string fileEnd(1, char(65+i));
		ofstream writeFile(path + "/Bookcase" + fileEnd +".csv");
		//cout << path + "Bookcase" + fileEnd +".csv" << endl;
		writeFile << title << endl;							//Adds the category bar removed when reading files
		
		//Going through each shelf, checking for copies (in shelf) to keep track of books
		for(int j = 0; j < 5; j++){
			if(bookcases[i][j]->isEmpty()){continue;}
			for(int k = 0; k < bookcases[i][j]->getSize(); k++){
				bool check = false;
				if(k < bookcases[i][j]->getSize() - 1){
					check = true;
				}
				if(check && bookcases[i][j]->atIndex(k)->getTitle() == bookcases[i][j]->atIndex(k+1)->getTitle()){					//If there's a copy, add to the counter
					copyCount++;
				}
				else{											//If there are no more consecutive copies on a shelf, input the file and update the copy counter
					//If there are commas in the title, they're put between quotation marks
					if (bookcases[i][j]->atIndex(k)->getBook().getTitle().find(',') != string::npos){
						writeFile << "\"" << bookcases[i][j]->atIndex(k)->getBook().getTitle() << "\"," << bookcases[i][j]->atIndex(k)->getBook().getAuthor() << "," << bookcases[i][j]->atIndex(k)->getBook().getIsbn() << "," << bookcases[i][j]->atIndex(k)->getBook().getYear() << "," << copyCount << endl;
					}
					else{
						writeFile << bookcases[i][j]->atIndex(k)->getBook().getTitle() << "," << bookcases[i][j]->atIndex(k)->getBook().getAuthor() << "," << bookcases[i][j]->atIndex(k)->getBook().getIsbn() << "," << bookcases[i][j]->atIndex(k)->getBook().getYear() << "," << copyCount << endl;
					}
					copyCount = 1;
				}
			}
		}
		writeFile.close();
	}
}


//========================================================================================================================================================================
//========================================================================================================================================================================
//Main Program
int main(){
	
	//Initialize Bookcases
	vector<Bookcase> bookcases;

	//Dynamic bookcase size measurement, using try and catch
	try{
		int fileCount = 0;
		int fileIndex = 0;
		bool working = true;
		while(working){
			string fileEnd(1, char(65+fileIndex));
			ifstream readFile(path + "/Bookcase" + fileEnd +".csv");
			if(readFile.good()){
				fileCount++;
				fileIndex++;
			}
			else{
				working = false;
			}
		}
		throw(fileCount);
	}
	catch(int f){
		saveSize(SIZE,f);
	}
	for(int i = 0; i < SIZE; i++){
		bookcases.push_back(Bookcase());

	}

	//Initialize Catalogue
	Catalogue catalogue = Catalogue(SIZE*50);		//Max number of books in library (dynamic)

	//Loading Files
	for(int i = 0; i < SIZE; i++){
		string fileEnd(1, char(65+i));
		ifstream readFile(path + "/Bookcase" + fileEnd +".csv");
		//cout << path + "/Bookcase" + fileEnd +".csv" << endl;
		vector<string> info;
		string line, word, titleBar, placeHolder;
		getline(readFile, titleBar);			//Removes the unnecessary top line in the csv file
		saveTitle(title,titleBar);
		int bookCount = 0;						//Counter for shelf placement
		//This takes each line and breaks it down,
		while(getline(readFile, line)){
			if(line[0] == ','){
				continue;
			}
			stringstream s(line);
			while(getline(s, word, ',')){
				info.push_back(word);
			}
			if(info.size() > 5){
				while((info.size() > 5)){
					info[0] += "," + info[1];
					info.erase(info.begin()+1);
				}
				
				for(int a = 0; a < 2; a++){
					int quoteLoc = info[0].find("\"");
					info[0].erase(info[0].begin()+quoteLoc);
				}
			}
			//Creates a Book object and places it into the catalogue
			Book temp(info[0], info[1], info[2], info[3]);
			Book& book = catalogue.addBook(temp);
			//Inserts each book the amount of copies it has, into a shelf. Integer bookCount is used to differentiate shelves and slot numbers.
			for(int j = 0; j < stoi(info[4]); j++){
				bookcases[i].operator[](bookCount/10)->addBook(book,i,bookCount/10,bookCount%10,1);
				bookCount++;
			}
			info.clear();								//Reset info vector
		}
		readFile.close();						//Close file
	}



	//INITIALIZE PROGRAM
	bool running = true;
	string command;
	system("clear");

	//Main Running Loop
	while(running){
		int input;
		help();
		cin >> input;
		switch(input){
			case 1:
				//User Searching for book
			{
				string searchTitle;
				cout << "Enter <title>;<fullAuthorName>";
				getline(cin, searchTitle);
				getline(cin, searchTitle);
				while(searchTitle.find(";") ==  string::npos){
					cout<<"Invalid Entry. Please enter in <title>;<fullAuthorName> format."<<endl;
					getline(cin, searchTitle);
				}
				string lower = toLower(searchTitle);	//change to lowercase
				string searchResult = catalogue.search(lower);
				if(searchResult == "null"){
					cout << "No matching book found for title " + capFirst(searchTitle.substr(0,searchTitle.find(";"))) + " by " + capFirst(searchTitle.substr(searchTitle.find(";")+1)) + "."<<endl;;
				}
				cout << "\nPress enter to continue..\n";

			}
			break;
			case 2:
				//Librarian adding a new book
				//Check for password first
				if(!authenticate()){
					system("clear");
					cout << "\nInvalid Password\n";
					continue;	//If the password is wrong, exit the switch statement
				}
				//The password is right
				else{
					string title;
					string author;
					string ident;
					string isbn;
					string year;
					int copies;

					system("clear");
					//Enter book information
					cout << "Enter the title: ";
					getline(cin, title);
					getline(cin, title);

					cout << "Enter the author: ";
					getline(cin, author);
					// getline(cin, author);

					cout << "Enter the ISBN: ";
					getline(cin, isbn);

					cout << "Enter the year: ";
					getline(cin, year);

					cout << "Enter the copies to be added: ";

					//Check if valid int for copies is inputed
					while(!(cin >> copies)){
						cin.clear();
				        cin.ignore(numeric_limits<streamsize>::max(), '\n');	//Clear the error
				        cout << "Please enter only integers.\nEnter the copies to be added: ";
					}
					//Get a valid location to put the books
					cout << "Enter the location to be added: ";
					cin >> ident;
					while(!validLocation(SIZE, ident)){
						system("clear");
						cout << "Invalid location, please enter a valid location such as \"A1.3\": ";
						cin >> ident;
					}
					//Captialize if needed
					string upper = toUpper(ident);

					//Check if space is available
					int bookcaseIndex = (int)upper.at(0) - 65;
					int shelfIndex = (int)upper.at(1) - 49;
					int bookIndex = (int)upper.at(3) - 49;
					if(upper.substr(upper.find(".")+1) == "10"){
						bookIndex = 9;
					}

					//If not enough space, say so and do nothing.
					if(bookcases[bookcaseIndex].operator[](shelfIndex)->getSize() + copies > 10){
						system("clear");
						cout << "Not enough space on shelf." << endl;
					}
					//Otherwise, create book, place on shelf, and add in catalogue.
					else{
						//Creates a Book object and places it into the catalogue
						system("clear");
						Book temp(title, author, isbn, year);
						Book& book = catalogue.addBook(temp);
						bookcases[bookcaseIndex].operator[](shelfIndex)->addBook(book, bookcaseIndex, shelfIndex, bookIndex, copies);
						cout<<"Book moved to first open space on shelf "<< upper.substr(0,upper.find("."))<<"."<<endl<<endl;
					}

					//Save library
					saveLibrary(bookcases);
				}
			break;
			case 3:
				//Librarian can delete a book from catalogue (and whole library)

				//Authenticate librarian
				if(!authenticate()){
					system("clear");
					cout << "\nInvalid Password\n";
					continue;	//If the password is wrong, exit the switch statement
				}
				else{
					//Password was correct

					system("clear");
					//Get a valid location to remove the book from
					string ident;
					cout << "Enter the book to delete in <title>;<fullAuthorName> format: ";
					getline(cin,ident);
					getline(cin,ident);
					while(ident.find(";") == string::npos){
						cout<<"Invalid Entry. Please enter in <title>;<fullAuthorName> format."<<endl;
						getline(cin,ident);
					}
					string lower = toLower(ident);
					Book* book = catalogue.removeBook(lower);
					if(book == nullptr){
						system("clear");
						cout<<"Book not found."<<endl;
					}
					else{
						system("clear");
						cout<<capFirst(ident.substr(0,ident.find(";"))) + " by " + capFirst(ident.substr(ident.find(";")+1)) + " removed from catalogue and library.";
						while(book->getAllLocations().size() > 0){			//deletes all instances of book
							int locationComparator = book->getAllLocations()[0];
							int bookcaseIndex = locationComparator/100;
							int shelfIndex = (locationComparator - bookcaseIndex*100)/10;
							int bookIndex = (locationComparator - bookcaseIndex*100 - shelfIndex*10);
							bookcases[bookcaseIndex][shelfIndex]->removeBook(bookcaseIndex, shelfIndex, bookIndex);
						}
					}

					cout << "\nPress enter to continue..\n";

					//Save library
					saveLibrary(bookcases);

				}	
			break;
			case 4:
				//Librarian can removed a book from a passed indentifier

				//Authenticate librarian
				if(!authenticate()){
					system("clear");
					cout << "\nInvalid Password\n";
					continue;	//If the password is wrong, exit the switch statement
				}
				else{
					//Password was correct

					system("clear");
					//Get a valid location to remove the book from
					string ident;
					cout << "Enter the location to remove a book from: ";
					cin >> ident;
					while(!validLocation(SIZE, ident)){
						cout << "Invalid location, please enter a valid location such as \"A1.3\": ";
						cin >> ident;
					}

					//Change to uppercase
					string upper = toUpper(ident);
					
					//Convert to indicies
					int bookcaseIndex = (int)upper.at(0) - 65;
					int shelfIndex = (int)upper.at(1) - 49;
					int bookIndex = (int)upper.at(3) - 49;
					cout<<upper.substr(upper.find(".")+1)<<endl;
					if(upper.substr(upper.find(".")+1) == "10"){
						bookIndex = 9;
					}

					//See if the passed identifier is in the shelf, if not report that the book does not exist to be removed
					if(bookIndex >= bookcases[bookcaseIndex][shelfIndex]->getSize()){
						system("clear");
						cout << "A book does not exist at " + upper + ".\n";
					}
					//Otherwise remove the book
					else{
						system("clear");
						string bookTitle = bookcases[bookcaseIndex][shelfIndex]->atIndex(bookIndex)->getTitle();
						string bookAuthor = bookcases[bookcaseIndex][shelfIndex]->atIndex(bookIndex)->getAuthor();
						bookcases[bookcaseIndex][shelfIndex]->removeBook(bookcaseIndex,shelfIndex,bookIndex);
						cout<<"Removed "<< capFirst(bookTitle) + " by " + capFirst(bookAuthor) + " at " + upper + ". \n\n";
					}

					//Save library
					saveLibrary(bookcases);

				}	
			break;
			case 5:
				//Move a book from a specified location to a target location

				//Authenticate librarian
				if(!authenticate()){
					system("clear");
					cout << "\nInvalid Password\n";
					continue;	//If the password is wrong, exit the switch statement
				}
				else{
					//Password was correct

					system("clear");
					//Get book location to be moved
					string ident;
					cout << "Enter the location to remove a book from: ";
					cin >> ident;
					while(!validLocation(SIZE, ident)){
						system("clear");
						cout << "Invalid location, please enter a valid location such as \"A1.3\": ";
						cin >> ident;
					}
					//Captialize if needed
					if((int)ident.at(0) >= 97 && (int)ident.at(0) <= 122){
						ident.at(0) = (char)((int)ident.at(0)-32);
					}
					//Get target location
					string targetIdent;
					cout << "Enter the location to put the book: ";
					cin >> targetIdent;
					while(!validLocation(SIZE, targetIdent)){
						system("clear");
						cout << "Invalid location, please enter a valid location such as \"A1.3\": ";
						cin >> targetIdent;
					}
					//Captialize if needed
					string str = toUpper(targetIdent);
					targetIdent = str;

					//Get the shelfs, and indexes of the original and target locations
					int bookcaseIndex = (int)ident.at(0) - 65;
					int shelfIndex = (int)ident.at(1) - 49;
					int bookIndex = (int)ident.at(3) - 49;
					if(ident.substr(ident.find(".")+1) == "10"){
						bookIndex = 9;
					}

					int targetBookcaseIndex = (int)targetIdent.at(0) - 65;
					int targetShelfIndex = (int)targetIdent.at(1) - 49;
					int targetBookIndex = (int)ident.at(3) - 49;
					if(ident.substr(ident.find(".")+1) == "10"){
						targetBookIndex = 9;
					}

					//check to make sure book exists & location on shelf is available
					if(bookcases[bookcaseIndex].operator[](shelfIndex)->getSize() < bookIndex){
						system("clear");
						cout<<"No book exists at "<< toUpper(ident) <<"."<<endl<<endl;
					}
					else if(bookcases[targetBookcaseIndex].operator[](targetShelfIndex)->isFull()){
						system("clear");
						cout<<"Target location is full."<<endl<<endl;
					}
					else{
						system("clear");
						BookPointer* newPointer = bookcases[bookcaseIndex].operator[](shelfIndex)->atIndex(bookIndex);

						bookcases[targetBookcaseIndex].operator[](targetShelfIndex)->addBook(bookcases[bookcaseIndex].operator[](shelfIndex)->atIndex(bookIndex)->getBook(), targetBookcaseIndex, targetShelfIndex, targetBookIndex, 1);
						bookcases[bookcaseIndex].operator[](shelfIndex)->removeBook(bookcaseIndex,shelfIndex,bookIndex);
						cout<<"Book moved to first open space on shelf "<< targetIdent.substr(0,targetIdent.find("."))<<"."<<endl<<endl;
					}

					//Save library
					saveLibrary(bookcases);

				}

			break;
			case 6:
				//Check number of books of a certain shelf

				//Authenticate librarian
				if(!authenticate()){
					system("clear");
					cout << "\nInvalid Password\n";
					continue;	//If the password is wrong, exit the switch statement
				}
				else{

					system("clear");
					string ident;

					//Enter location and checks for validity
					cout << "Enter the shelf location (i.e. A1, B2, C3): "<<endl;
					cin >> ident;
					while(!validShelf(ident)){
						system("clear");
						cout << "Invalid location, please enter a valid location such as \"A1, B2, C3\": "<<endl;
						cin >> ident;
					}
					ident[0] = toupper(ident.at(0));
					//Prints number of books (size) in shelf
					cout << endl << "Number of Books on Shelf " << ident << ": "<< bookcases[int(ident.at(0))-65].operator[](int(ident.at(1))-49)->getSize() << endl<<endl;
					
				}
			break;
			case 7:
				//Check number of bookcases in library

				//Authenticate librarian
				if(!authenticate()){
						system("clear");
						cout << "\nInvalid Password\n";
						continue;	//If the password is wrong, exit the switch statement
					}
					else{
						system("clear");

						cout <<"Number of bookcases in library: " << SIZE << endl << endl;
						
					}

			break;
			case 8:
				system("clear");
				//Print Catalogue
				catalogue.print();
				cout<<endl<<endl;

			break;
			case 9:
				//Save library, then exit.
				system("clear");
				saveLibrary(bookcases);
				running = false;
				cout<<"Program terminated successfully."<< endl << endl;			
			break;
			default:
				cout << "Invalid input\n"<<endl;
			}


		//Clear any errors
		cin.clear();
		cin.ignore(numeric_limits<streamsize>::max(), '\n');
	}



	return EXIT_SUCCESS;
}











