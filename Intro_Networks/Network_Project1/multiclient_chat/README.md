# __Multi-Channel-Chat__
==================

## Project description

The code implements a multichannel IRC-like chat server and a client. The server maintains a channel between two clients allowing them to chat. The server can handle multiple channels (sessions) at a time. The server also has an admin enitity that can issue different commands to the server to manage the chatting process. The clients in the chat are identified by names.

### Client commands
* HELP - lists all the commands accepted from a client
* CONNECT - connects a client to the server
* NAME - followed by string _S_, assignes the name _S_ to the client
* CHAT - issues the desire to chat with a "random" client
* TRANSFER - followed by the filename _F_, transfers file _F_ to the chat partner
* FLAG - flags the chat partner as a violator of the rules of the chat
* QUIT - quit the current session

### Server commands
* STATS - provides the statistics about currrent chat sessions: number of clients connected to the server, number of clients chatting, data usage for each channel, list of flagged clients, their names and status
* BLOCK - followed by the the client id _ID_, blocks this client and prevents him from chat
* UNBLOCK - followed by the the client id _ID_, unblocks a client
* THROWOUT - followed by the the client id _ID_, throws out the client from the chat channel

## Running guidelines

To execute the files you need to run "make" command from the terminal in the directory, where all files are. This will create binaries.
To run the server use type "./multiclient'_'server" in the terminal. To run the client type "./client.c".


