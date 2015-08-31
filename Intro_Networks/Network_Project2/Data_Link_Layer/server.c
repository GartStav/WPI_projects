#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/time.h>
#include <signal.h>
#include <fcntl.h>
#include <errno.h>
#include <sys/socket.h>
#include <netdb.h>
#include <arpa/inet.h>
#include "data_link_layer.h"

#define PORT "8888"
#define	MTU 1500	/* max transmission unit */
#define FILE_STARTER 3
#define FILE_DATA 4
#define FILE_END 5
#define APPDATA 6

void run_command(char *command);
void udt_send(Frame *buf, int size);
int udt_recv(Frame *buf, int size);
void *get_in_addr(struct sockaddr *sa);
void scheduled_handler();

int listener;
fd_set master;
int fdmax;
int sockfd;
int erate ;
int corrupted;
int seqn;
int retransmission_mode = 0; // 0=>go-back-N; 1=>selective repeat
debug_info di;
extern FQueue fqueue;
extern FQueue pqueue;
static sigset_t sigs; /* sigset_t for SIGALRM */


int main() {
	int i;
	char command[50];
    srand((int) time(0));
	fd_set read_fds;
	FD_ZERO(&master); // clear the master and temp sets
	FD_ZERO(&read_fds);
	FD_SET(0, &master);
	fqueue_init(&fqueue, WINDOWSIZE);
	fqueue_init(&pqueue, WINDOWSIZE);
	
	
	//listener = listen_port();
	struct addrinfo hints, *servinfo, *p;
	socklen_t sin_size;
	struct sigaction sa;
	int yes = 1;
	int rv;
	memset(&hints, 0, sizeof(hints));
	hints.ai_family = AF_INET;
	hints.ai_socktype = SOCK_STREAM;
	hints.ai_flags = AI_PASSIVE; // use my IP
	if ((rv = getaddrinfo(NULL, PORT, &hints, &servinfo)) != 0) {
		fprintf(stderr, "getaddrinfo: %s\n", gai_strerror(rv));
		return -1;
	}
	// loop through all the results and bind to the first we can find
	for(p = servinfo; p != NULL; p = p->ai_next) {
		if ((listener = socket(p->ai_family, p->ai_socktype, p->ai_protocol)) == -1) {
			perror("server: socket");
			continue;
		}
		if (setsockopt(listener, SOL_SOCKET, SO_REUSEADDR, &yes, sizeof(int)) == -1) {
			perror("setsockopt");
			exit(1);
		}
		if (bind(listener, p->ai_addr, p->ai_addrlen) == -1) {
			close(listener);
			perror("server: bind");
			continue;
		}
		break;
	}
	if (p == NULL) {
		fprintf(stderr, "server: failed to bind\n");
		return -1;
	}
	freeaddrinfo(servinfo); // all done with this structure
	if (listen(listener, 10) == -1) {
		perror("listen");
		exit(1);
	}
	FD_SET(listener, &master);
	fdmax = listener;
		
	printf("Server is online, please input frame loss rate (%%): ");
	gets(command);
	erate = atoi(command);
	printf("please input frame corruption rate (%%): ");
	gets(command);
	corrupted = atoi(command);
	printf("please choose retransmission mode(0: go-back-N; 1: selective repeat): \n");
	gets(command);
	retransmission_mode = atoi(command);
	if(retransmission_mode == 1) {
		fqueue.maxsize = 5;
	}
	//set up a timer
	signal(SIGALRM, scheduled_handler);
	sigemptyset(&sigs);
	sigaddset(&sigs, SIGALRM);
	struct itimerval tt;
	tt.it_interval.tv_sec = 0;
	tt.it_interval.tv_usec = 2*TIMER_TICK;
	tt.it_value.tv_sec = 0;
	tt.it_value.tv_usec = 2*TIMER_TICK;
	if (setitimer(ITIMER_REAL, &tt, NULL) < 0) {
		perror("sender: setitimer");
		exit(1);
	}
	
	while(1) {
	read_fds = master;
	if (select(fdmax+1, &read_fds, NULL, NULL, NULL) == -1) {	
		continue;
	}
		for(i = 0; i <= fdmax; i++) {
			if(FD_ISSET(i, &read_fds)) {
				if(i==0) {
					gets(command);
					run_command(command);
				} else if(i == listener) {
					struct sockaddr_storage remoteaddr; // client address
					socklen_t addrlen;
					char remoteIP[INET6_ADDRSTRLEN];
					addrlen = sizeof(remoteaddr);
					int newfd = accept(listener,(struct sockaddr *)&remoteaddr,&addrlen);
					if (newfd == -1) {
						perror("accept");
					} else {
						FD_SET(newfd, &master); // add to master set
					if (newfd > fdmax) { // keep track of the max
						fdmax = newfd;
					}
					printf("New connection received from %s on socket %d\n",
					inet_ntop(remoteaddr.ss_family,
					get_in_addr((struct sockaddr*)&remoteaddr), remoteIP, INET6_ADDRSTRLEN), newfd);
					}
					sockfd = newfd;
				} else {
					receiver_handler(i);
					DataLinkRecv();
				}
			}
		}
	}

}


void scheduled_handler() {
	sender_handler();
}

void run_command(char *command) {
	char value[50];
	if(strcmp("transfer", command) == 0) {
		printf("Please input the file name: \n");
		char filename[50];
		gets(filename);
		int fd_s; /* file for tx */
		while((fd_s = open(filename, O_RDONLY)) < 0) {
			perror("open");
			printf("Please input the file name: \n");
			gets(filename);
		}
		DataLinkSend(filename, strlen(filename)+1, FILE_STARTER);
		int cnt;
		char buf[DATASIZE];
		while((cnt = read(fd_s, buf, DATASIZE)) > 0) {
			DataLinkSend(buf, cnt, FILE_DATA);
		}
		if(cnt == 0) {
			DataLinkSend(NULL, 0, FILE_END);
			close(fd_s);
		}
	} else if(strcmp("loss rate", command) == 0) {
		printf("Please input the new value: \n");
		gets(value);
		erate = atoi(value);
	} else if(strcmp("corruption rate", command) == 0) {
		printf("Please input the new value: \n");
		gets(value);
		corrupted = atoi(value);
	} else if(strcmp("retrans mode", command) == 0) {
		printf("please choose retransmission mode(0: go-back-N; 1: selective repeat): \n");
		gets(value);
		retransmission_mode = atoi(value);
		if(retransmission_mode == 1) {
			fqueue.maxsize = 5;
		} else if(retransmission_mode == 0) {
			fqueue.maxsize = WINDOWSIZE;
		}
	} else if(strcmp("print", command) == 0) {
	
		printf("retransmission mode: %d\nerate %%: %d\ncorruption %%: %d\nframe sent num: %d\n\
		retrans_num: %d\nack_sent_num: %d\nack_recved_num: %d\ndata_amount: %d\n\
		dup_frame_recved_num: %d\ntime_required: %f\n",di.retrans_mode, di.erate, di.corrupted,\
		di.frame_sent_num, di.retrans_num,di.ack_sent_num, di.ack_recved_num, di.data_amount, \
		di.dup_frame_recved_num, di.time_required);
	} else {
		DataLinkSend(command, strlen(command)+1, APPDATA);
	}
}



void *get_in_addr(struct sockaddr *sa) {
	if(sa->sa_family == AF_INET) {
		return &(((struct sockaddr_in*)sa)->sin_addr);
	}
	return &(((struct sockaddr_in6*)sa)->sin6_addr);
}


void udt_send(Frame *buf, int size) {
	if(size > MTU) {
		return;
	}
	
	int rnd;
	
    //srand((time.tv_sec * 1000) + (time.tv_usec / 1000));
/*    int i;*/
/*    for (i = 0; i < 100; i++){*/
/*        printf("NUmber: %d \n", rand()%100+1);*/
/*    }*/
	rnd=rand()%100+1;
	

    printf("Drop Rnd: %d \n", rnd);
	if(rnd < erate) {
		printf("Drop the frame!\n");
		fflush(stdout);
		return;
	}
	rnd = rand()%100+1;
    printf("Corrupt Rnd: %d \n", rnd);
	if(rnd < corrupted) {
		Frame f;
		f.seqn = buf->seqn;
		f.checksum = buf->checksum;
		strcpy(f.buffer, "corrupted data!");
		printf("Corrupt the frame!\n");
		fflush(stdout);
		if(send(sockfd, &f, FRAMESIZE, 0) == -1) {
			perror("send");
			return;
		}
	}
	if(send(sockfd, buf, FRAMESIZE, 0) == -1) {
		perror("send");
	}
}


int udt_recv(Frame *buf, int size){

	int recvinfo;
	recvinfo=recv(sockfd,(void*)buf, size, 0);
	return recvinfo;
}
