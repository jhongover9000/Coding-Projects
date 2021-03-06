# Voting Managment System

### Description: This is a system that lets a manager monitor a poll. In this, a number of qualified votes can participate. You will have to create structures that facilitate the fast access of information pertinent to the poll. Your application will be based on both hashing and linked-lists that jointly help rapidly assess the progress of a poll.

### Instructions for Running:
1) call 'make' to create executable, mvote

1.5) call 'make clean' to delete excess files

2) run mvote using the command './mvote -f <file> -m <size>', where <file> is the file (extension and directory) of registered voters and <size> is an integer designating the size of the hash table.

3) the menu should show you what commands are available and which are not.

Note: at the end, in termination, there is an abort because there's a pointer that is freed that hasn't been allocated, but this means that there isn't a memory leak so I thought it wasn't too bad. I wasn't sure what was causing the problem, and gdb didn't really help in finding the source. However, I know that it does have to do with the destructors that I've created. At one point, I created an pointer without a reference and I ended up deleting it, which is what is causing the issue. This happens specifically after I register voters in bulk.

### The Structure
Anyway, the system is divided into two main parts: a ZIP code list and a hash table of voters. The ZIP code list is a doubly linked list where each node holds another doubly linked list of voters. Each ZipCodeNode corresponds to a ZIP code.
The hash table is an array of linked lists (to implement the hash chaining). The linked list type used for the hash map and the ZIP code list are the same, as VoterNodeList.

### VoterNodeList
VoterNodeList is a doubly linked list made up of nodes that point to a specific voter. Here, I added capabilities to add and remove the nodes without deleting the voter object, then referencing it later and deleting it using the hash map data member cachedVoter. 

### CachedVoter
With cachedVoter, I was able to call the most-recently modified voter and reflect those changes in the ZIP code list without having to worry about incorrect references to a voter. This ensured that I would be referencing the same voter in each function for registering votes or removing voters.

### Bubblesort
I though that this was pretty cool. The way that I sorted the nodes in the ZipCodeNodeList was that I would swap the places of the iterator node and the node next to it by changing around the pointers of those nodes and the nodes surrounding them. It took me a good thirty minutes to figure out how to do it without causing any problems (it was really, really trippy and I kept getting lost), but drawing it out really helped.


