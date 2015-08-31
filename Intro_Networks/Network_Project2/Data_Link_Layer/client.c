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


#define SERVER "localhost"
#define PORT "8888"



int sockfd;
int sn;
int lostrate=0;
int corruptrate=0;
int retransmission_mode=0;




extern FQueue fqueue,pqueue;



static sigset_t sigs; /* sigset_t for SIGALRM */


void timeout_handler();
void udt_send(Frame *buf, int size);
int udt_recv(Frame *buf, int size);

void *get_in_addr(struct sockaddr *sa) {
	if(sa->sa_family == AF_INET) {
		return &(((struct sockaddr_in*)sa)->sin_addr);
	}
		return &(((struct sockaddr_in6*)sa)->sin6_addr);
}


int main() {
	
	system("clear");
	int rv;
	char s[INET6_ADDRSTRLEN];
	struct addrinfo hints, *servinfo, *p;
	srand((int) time(0));
		
	memset(&hints, 0, sizeof(hints));
	hints.ai_family = AF_UNSPEC;
	hints.ai_socktype = SOCK_STREAM;
	rv = getaddrinfo(SERVER, PORT, &hints, &servinfo);

	for(p = servinfo; p != NULL; p = p->ai_next) {
		sockfd = socket(p->ai_family, p->ai_socktype, p->ai_protocol);
		connect(sockfd, p->ai_addr, p->ai_addrlen);
		break;
	}

	inet_ntop(p->ai_family, get_in_addr((struct sockaddr *)p->ai_addr), s, sizeof(s));
	printf("Client is connecting to %s\n", s);
	freeaddrinfo(servinfo);
		
	fqueue_init(&fqueue, WINDOWSIZE);
	fqueue_init(&pqueue, WINDOWSIZE);
	
	char value[50];
	char command[50];
	
	
	printf("Input LOST rate: (0-100): ");
	gets(value);
	lostrate = atoi(value);
	printf("Set LOST rate to %d%%.\n\n",lostrate);
	printf("Input CORRUPT rate (0-100): ");
	gets(value);
	corruptrate = atoi(value);
	printf("Set CORRUPT rate to %d%%.\n\n",corruptrate);
	printf("Choose retransmission mode\n 0: Go-Back-N\n 1: Selective Repeat\nYour choice (0 or 1)? ");
	gets(value);
	retransmission_mode = atoi(value);
	if(retransmission_mode == 1) {
		fqueue.maxsize = 5;
		printf("Set Mode: Selective Repeat.\n\n");
	}else if(retransmission_mode == 0) {
		printf("Set Mode: Go-Back-N.\n\n");
	}
	di.lostrate = lostrate;
	di.corruptrate = corruptrate;
	di.retrans_mode = retransmission_mode;
	printf("Client is ready!\nPlease input messages or commands. You can input HELP for more infomation.\n");
	
	
	//set up a timer
	signal(SIGALRM, timeout_handler);	
	sigemptyset(&sigs);
	sigaddset(&sigs, SIGALRM);
	
	struct itimerval tt;
	tt.it_interval.tv_sec = 0;
	tt.it_interval.tv_usec = TIMER_TICK;
	tt.it_value.tv_sec = 0;
	tt.it_value.tv_usec = TIMER_TICK;
	
	if (setitimer(ITIMER_REAL, &tt, NULL) < 0) {
		perror("sender: setitimer");
		exit(1);
	}

	
	fd_set master;
	fd_set read_fds;
	FD_ZERO(&master); 
	FD_ZERO(&read_fds);
	FD_SET(0, &master);
	FD_SET(sockfd, &master);
	
	while(1) {
		read_fds = master;
		if (select(sockfd+1, &read_fds, NULL, NULL, NULL) == -1) {
			continue;
		}
		int i=0;	
		for(i; i <= sockfd; i++) {
			if(FD_ISSET(i, &read_fds)) {
				if(i==0) {
					gets(command);
					if(strcmp("TRANSFER", command) == 0) {
						system("clear");
						printf("Please input the file name: \n");
						gets(value);
						int fp_r; 
						while((fp_r = open(value, O_RDONLY)) < 0) {
							perror("open");
							printf("Please check the file name and input again: \n");
							gets(value);
						}

						DataLinkSend(value, strlen(value)+1, FILE_STARTER);

						int content;
						char buf[DATASIZE];
						while((content = read(fp_r, buf, DATASIZE)) > 0) {
							DataLinkSend(buf, content, FILE_DATA);
						}
						if(content == 0) {
							DataLinkSend(NULL, 0, FILE_END);
							close(fp_r);
						}
					} else if(strcmp("LOST", command) == 0) {
						printf("Please input the new lost rate (0-100): \n");
						gets(value);
						lostrate = atoi(value);
					} else if(strcmp("CORRUPT", command) == 0) {
						printf("Please input the new corrupt rate: \n");
						gets(value);
						corruptrate = atoi(value);
					} else if(strcmp("MODE", command) == 0) {
						printf("please choose retransmission mode:\n(0: go-back-N;\n 1: selective repeat): \n");
						gets(value);
						retransmission_mode = atoi(value);
						if(retransmission_mode == 1) {
							fqueue.maxsize = 5;
						} else if(retransmission_mode == 0) {
							fqueue.maxsize = WINDOWSIZE;
						}
					} else if(strcmp("STATUS", command) == 0) {
						system("clear");
						
						if(di.retrans_mode==0){
							printf("1.  Retransmission Mode: Go-Back-N.\n");
						}else{
							printf("1.  Retransmissoin Mode: Selective Repeat.\n");
						}
						printf("2.  Lost Rate: %d\n",di.lostrate);
						printf("3.  Corrupt Rate: %d\n",di.corruptrate);
						printf("4.  %d frames have sent.\n",di.frame_sent_num);
						printf("5.  %d frames have resent.\n",di.retrans_num);
						printf("6.  %d duplicate frames received.\n",di.dup_frame_recved_num);
						printf("7.  %d ACKs have sent.\n",di.ack_sent_num);
						printf("8.  %d ACKs have received.\n",di.ack_recved_num);
						printf("9.  %d data have sent.\n",di.data_amount);
						printf("10. Time used: %f seconds\n",di.time_required);
					}else if(strcmp("HELP",command)==0){
						printf("Commands you can use: \n 1. TRANSFER: Send a file.\n 2. LOST: Change the lost rate. \n 3. CORRUPT: Change the corruption rate.\n 4. MODE: Change the retransformation mode.\n 5. STATUS: Show traffic statistics.\n 6. HELP\n ");	
								
					} else {
						DataLinkSend(command, strlen(command)+1, MESSAGE);
					}

					
				} else {
					receiver_handler(i);
					DataLinkRecv();
				}
			}
		}
	}
}


void timeout_handler() {
	sender_handler();
}



void udt_send(Frame *buf, int size) {
	
	
	int rnd;

	rnd=rand()%100+1;
	
	if(rnd < lostrate) {
		printf("Drop the frame!\n");
		fflush(stdout);
		return;
	}
	rnd = rand()%100+1;
	if(rnd < corruptrate) {
		Frame f;
		f.sn = buf->sn;
		f.checksum = buf->checksum;
		strcpy(f.buffer, "corruptrate data!");
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


