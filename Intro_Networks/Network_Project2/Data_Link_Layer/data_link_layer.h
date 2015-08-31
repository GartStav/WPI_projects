#include <stdbool.h>
#define WINDOWSIZE 100000	
#define TIMER_TICK 500
#define DATASIZE 100 
#define FRAMESIZE (sizeof(Frame))
#define ACKSIZE sizeof("ACK")
//type of Frame
#define ACK 1
#define NAK 2
#define FILE_STARTER 3
#define FILE_DATA 4
#define FILE_END 5
#define MESSAGE 6

typedef struct {
	int sn;
	int nbuffer;
	int type;
	char checksum;
	char buffer[DATASIZE];
} Frame;

typedef struct {
	int head;
	int length;
	int maxsize;
	Frame* frames;
} FQueue;

typedef struct {
	int retrans_mode;
	int lostrate;
	int corruptrate;
	int frame_sent_num;
	int retrans_num;
	int ack_sent_num;
	int ack_recved_num;
	int data_amount;
	int dup_frame_recved_num;
	double time_required;
} debug_info;

debug_info di;

int PMOD(int n, int b);
void fqueue_init(FQueue* queue, int windowsize);
void fqueue_destroy(FQueue *queue);
int fqueue_length(FQueue* queue);
Frame* fqueue_tail(FQueue* queue);
Frame* fqueue_head(FQueue* queue);
Frame* fqueue_push(FQueue* queue);
Frame* fqueue_pop(FQueue* queue);
Frame* fqueue_poptail(FQueue* queue);
bool fqueue_empty(FQueue* queue);
void fqueue_map(FQueue* queue, void (*fn)(Frame*) );
void fqueue_debug_print(FQueue* queue);
void DataLinkSend(char *buf, int size, int type);
void DataLinkRecv();
void send_acknowledge(int sn, int sockfd);
static int make_timer( char *name, timer_t *timerID, int expireMS, int intervalMS );
static void timer_handler( int sig, siginfo_t *si, void *uc );
static int stop_timer(timer_t *timerid);
static int restart_timer(timer_t *timerid, int expireMS, int intervalMS);
static char checksum(char* s);
static void go_back_N();
static void selective_repeat();





