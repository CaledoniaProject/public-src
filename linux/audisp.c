
Auditd Real-time Event Interface Specifications
===============================================

Definitions
-----------
An audit event is all records that have the same host (node), timestamp, and
serial number. Each event on a host (node) has a unique timestamp and serial
number. An event is composed of multiple records which have information about
different aspects of an audit event. Each record is denoted by a type which
indicates what fields will follow. Information in the fields are held by a
name/value pair that contains an '=' between them. Each field is separated
from one another by a space or comma.


Ground Rules
------------
The audit daemon will start up a program when its "dispatcher=" line is
non-NULL. The program will be started as root. Therefore, please take care
to ensure the program is safe with those capabilities or shed them. The program
should not fork and call setsid since that would escape the audit daemon's grip
on the program. (Its ok to fork child processes.) When the audit daemon starts
the dispatcher process, it opens stdin to the socketpair used to pass events.
So, the dispatcher only needs to read stdin. The dispatcher should never send
anything back to the audit daemon. It doesn't listen for anything and you might
fill up the buffers. The dispatcher must read the events as fast as possible
since the IPC communication buffers have a limited size.


Signals
-------
The audit daemon will send SIGTERM to indicate that the dispatcher should exit.
The audit daemon will send SIGHUP to indicate that the dispatcher should
re-read its configuration.


Data Format
-----------
The audit daemon sends 2 things for each record: a header and the full data.
The header is defined in libaudit.h as:

struct audit_dispatcher_header {
        uint32_t        ver;    /* The version of this protocol */
        uint32_t        hlen;   /* Header length */
        uint32_t        type;   /* Message type */
        uint32_t        size;   /* Size of data following the header */
};

Currently, the version number is 0. The above data structure is valid only
when the first 32 bits == 0. Any changes to the structure will be made at
the end so that the first 32 bytes will always be the version number. 
Dispatchers should look for this number and handle the data structure 
appropriately - which may mean exitting with a message in syslog.


Example Code
------------

/* skeleton.c --
 * 
 * This is a sample program that you can customize to create your own audit
 * event handler. It will be started by auditd via the dispatcher option in
 * /etc/auditd.conf. This program can be built as follows:
 *
 * gcc skeleton.c -o skeleton -laudit
 */

#include <stdio.h>
#include <sys/types.h>
#include <sys/uio.h>
#include <unistd.h>
#include <stdlib.h>
#include <signal.h>
#include <fcntl.h>
#include <errno.h>
#include <string.h>
#include <locale.h>
#include "libaudit.h"


// Local data
static volatile int signaled = 0;
static int pipe_fd;
static const char *pgm = "skeleton";

// Local functions
static int event_loop(void);

// SIGTERM handler
static void term_handler( int sig )
{
	signaled = 1;
}


/*
 * main is started by auditd. See dispatcher in auditd.conf
 */
int main(int argc, char *argv[])
{
	struct sigaction sa;

	setlocale (LC_ALL, "");
	openlog(pgm, LOG_PID, LOG_DAEMON);
	syslog(LOG_NOTICE, "starting...");

#ifndef DEBUG
	// Make sure we are root
	if (getuid() != 0) {
		syslog(LOG_ERR, "You must be root to run this program.");
		return 4;
	}
#endif

	// register sighandlers
	sa.sa_flags = 0 ;
	sa.sa_handler = term_handler;
	sigemptyset( &sa.sa_mask ) ;
	sigaction( SIGTERM, &sa, NULL );
	sa.sa_handler = term_handler;
	sigemptyset( &sa.sa_mask ) ;
	sigaction( SIGCHLD, &sa, NULL );
	sa.sa_handler = SIG_IGN;
	sigaction( SIGHUP, &sa, NULL );
	(void)chdir("/");

	// change over to pipe_fd
	pipe_fd = dup(0);
	close(0);
	open("/dev/null", O_RDONLY);
	fcntl(pipe_fd, F_SETFD, FD_CLOEXEC);

	// Start the program
	return event_loop();
}

static int event_loop(void)
{
	void* data;
	struct iovec vec[2];
	struct audit_dispatcher_header hdr;

	// allocate data structures
	data = malloc(MAX_AUDIT_MESSAGE_LENGTH);
	if (data == NULL) {
		syslog(LOG_ERR, "Cannot allocate buffer");
		return 1;
	}
	memset(data, 0, MAX_AUDIT_MESSAGE_LENGTH);
	memset(&hdr, 0, sizeof(hdr));

	do {
		int rc;
		struct timeval tv;
		fd_set fd;

		tv.tv_sec = 1;
		tv.tv_usec = 0;
		FD_ZERO(&fd);
		FD_SET(pipe_fd, &fd);
		rc = select(pipe_fd+1, &fd, NULL, NULL, &tv);
		if (rc == 0) 
			continue;
		 else if (rc == -1)
			break;

		/* Get header first. it is fixed size */
		vec[0].iov_base = (void*)&hdr;
		vec[0].iov_len = sizeof(hdr);

        	// Next payload 
		vec[1].iov_base = data;
		vec[1].iov_len = MAX_AUDIT_MESSAGE_LENGTH; 

		rc = readv(pipe_fd, vec, 2);
		if (rc == 0 || rc == -1) {
			syslog(LOG_ERR, "rc == %d(%s)", rc, strerror(errno));
			break;
		}

		// handle events here. Just for illustration, we print
		// to syslog, but you will want to do something else.
		syslog(LOG_NOTICE,"type=%d, payload size=%d", 
			hdr.type, hdr.size);
		syslog(LOG_NOTICE,"data=\"%.*s\"", hdr.size,
			(char *)data);

	} while(!signaled);

	return 0;
}

