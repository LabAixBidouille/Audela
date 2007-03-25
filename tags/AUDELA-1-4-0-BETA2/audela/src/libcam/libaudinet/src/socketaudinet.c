/* socketaudinet.c
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : Michel PUJOL <michel-pujol@wanadoo.fr>
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or (at
 * your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */

/*
 * ce fichier contient les fonctions de communication 
 * utilisant des sockets TCP/IP
 * pour dialoguer a un périphérique connecte par liaison
 * ethernet
 *
 * $Id: socketaudinet.c,v 1.3 2006-12-06 22:45:23 michelpujol Exp $
 */


#include "sysexp.h"

#if defined(OS_WIN)
#include <windows.h>
#include <winsock.h>
#endif

#if defined(OS_LIN) || defined(OS_MACOS)
#include <errno.h>
#include <unistd.h>
#include <ctype.h>
#include <stdlib.h>
#include <netinet/in.h>
#include <sys/time.h>
#include <sys/types.h>
#include <sys/socket.h>		/* for socket definitions */
#include <arpa/inet.h>
#include <string.h>
#include <netdb.h>
#endif

#if defined(OS_LIN)
#include <asm/socket.h>		/* DM, added for SO_* options definition !!!! ??? */
#endif

#include "socketaudinet.h"
#include "log.h"


#ifndef BYTE
#define BYTE char
#endif
#ifndef UCHAR
#define UCHAR unsigned char
#endif
#ifndef ULONG
#define ULONG unsigned int	/* unsigned 64 bits */
#endif

#ifndef SOCKET_ERROR
#define SOCKET_ERROR (-1)
#endif

// common variable
struct sockaddr_in _sockAddr;
int _socketTcp;
int _socketUdp;
char sHttp[1024];
char _sURLHost[256];

struct sockaddr_in _addrBindUDP;
struct sockaddr_in _addrSendUDP;

#define SOCKADDR struct sockaddr


#define DEFAULT_NET_TIMEOUT 5	/* seconds */
#define STRNCPY(_d,_s)  strncpy(_d,_s,sizeof _d) ; _d[sizeof _d-1] = 0


/***************************************************
 *  TCP SOCKET
 ***************************************************
 */
int socktcp_open(char *sHost, int httpPort)
{
    struct hostent *pHostEnt;
    int connStatus;

#if defined(OS_WIN)
    WORD wVer;
    WSADATA wsaData;
    wVer = MAKEWORD(1, 1);	// request WinSock version 1.1
    if (WSAStartup(wVer, &wsaData) != 0) {	// if startup failed
	logError("socktcp_open version WSA incorrecte");
	return (false);
    }
#endif


    memset((void *) &_sockAddr, 0, sizeof _sockAddr);	/* zero sockaddr */
    _sockAddr.sin_family = AF_INET;
    _sockAddr.sin_port = htons((unsigned short) httpPort);


    if (isdigit(sHost[0])) {	/* by address */
	_sockAddr.sin_addr.s_addr = inet_addr(sHost);
    } else {			/* by name - need resolver */
	pHostEnt = gethostbyname(sHost);
	if (pHostEnt == NULL) {	/* hostname lookup error */
	    logError("%s: unknown host\n", sHost);
	    return (false);
	}
	_sockAddr.sin_addr =
	    *((struct in_addr *) pHostEnt->h_addr_list[0]);
    }

    _socketTcp = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    if (_socketTcp == -1) {
	logError("socktcp_open socket(AF_INET)");
	return false;
    }


    connStatus =
	connect(_socketTcp, (struct sockaddr *) &_sockAddr,
		sizeof _sockAddr);
    if (connStatus != 0) {
	logError("socktcp_open connect connStatus=%d errno=%d", connStatus,
		 errno);
	return false;
    }

    return true;

}

int socktcp_close()
{
#if defined(OS_WIN)
    return closesocket(_socketTcp);
#endif
#if defined(OS_LIN) || defined(OS_MACOS)
    return close(_socketTcp);
#endif
}

int socktcp_recv(char *buffer, int len)
{
    fd_set ReadSet;
    int n;
    struct timeval Time;


    FD_ZERO(&ReadSet);
    FD_SET(_socketTcp, &ReadSet);
    Time.tv_sec = DEFAULT_NET_TIMEOUT;
    Time.tv_usec = 0;

    // recv without timeout
    n = recv(_socketTcp, buffer, len, 0);
    return (n);
}


/**
 * build HTTP request string
 * 
 * return null if uri is too long, otherwise return the string pointer
 */
char *getRequestString(char *ipAdress, char *uri)
{
    char *_sPost = NULL;
    char *_sProxy = NULL;
    char *_sURL = NULL;
    char *_sSocks = NULL;
    char sTemp[1024];
    int i, j;

    /* replace special characters ( space, '+') by hexa value in uri */

    j = 0;
    sTemp[j] = 0;
    for (i = 0; i < (int) strlen(uri); i++) {
	char c = uri[i];

	if (c == ' ' || c == '+') {
	    sTemp[j] = '%';
	    sprintf(&sTemp[j + 1], "%2x", c);
	    j += 3;
	} else {
	    sTemp[j] = c;
	    j++;
	}
	if (j > sizeof sTemp) {
	    return 0;
	}
    }
    sTemp[j] = 0;		/* make null terminated string */


    sprintf(sHttp,
	    "%s %s HTTP/1.1\r\n"
	    "%sUser-Agent: Audace \r\n"
	    "Pragma: no-cache\r\n"
	    "Host: %s\r\n"
	    "Accept: text/html, image/gif, image/jpeg, *; q=.2, */*;q=.2\r\n"
	    "Connection: keep-alive\r\n\r",
	    (_sPost == NULL) ? "GET" : "POST",
	    (_sProxy == NULL) ? ((_sPost == NULL) ? sTemp : _sURL) : _sURL,
	    (_sProxy == NULL
	     && _sSocks == NULL) ? "" : "Proxy-Connection: Keep-Alive\r\n",
	    ipAdress);

    return sHttp;

}


int socktcp_send(char *ipAdress, int port, char *uri)
{
    int n;
    char *sRequestString;

    sRequestString = getRequestString(ipAdress, uri);

    n = strlen(sRequestString);

    if (n == 0) {
	logError("CHttpSocket::sendRequest request too long %s", uri);
	return false;
    }


    if (send(_socketTcp, sRequestString, n, 0) != n) {
	logError("socktcp_send send");
	socktcp_close();
	return false;
    }
    return true;

}

/***************************************************
 *  UDP SOCKET
 ***************************************************
 */

int sockudp_open(char *destIP, int destport, int listenport)
{

#if defined(OS_WIN)
    WORD wVer;
    WSADATA wsaData;
    wVer = MAKEWORD(1, 1);	// request WinSock version 1.1
    if (WSAStartup(wVer, &wsaData) != 0) {	// if startup failed
	logError("CHttpSocket::initSocket version WSA incorrecte");
	return (false);
    }
#endif

    //-- Open a UDP socket 
    if ((_socketUdp = socket(AF_INET, SOCK_DGRAM, 0)) < 0) {
	logError("Unable to create socket");
	return false;
    }
    //setSocketBufferSize (_socket, SO_RCVBUF, 4096);

    //-- Fill in structure fields for binding to local host
    memset((char *) &_addrBindUDP, 0, sizeof(_addrBindUDP));
    _addrBindUDP.sin_family = AF_INET;
    _addrBindUDP.sin_addr.s_addr = htonl(INADDR_ANY);
    _addrBindUDP.sin_port = htons((u_short) listenport);

    //-- Bind it
    if (bind(_socketUdp, (SOCKADDR *) & _addrBindUDP, sizeof(_addrBindUDP))
	< 0) {
	logError("Error:  bind() failed.");
	return false;
    }
    //-- Fill in target addr for send message
    memset((char *) &_addrSendUDP, 0, sizeof(_addrSendUDP));
    _addrSendUDP.sin_family = AF_INET;
    _addrSendUDP.sin_addr.s_addr = inet_addr(destIP);
    _addrSendUDP.sin_port = htons((u_short) destport);

    return true;


}

int sockudp_send(char *message)
{
    if (sendto
	(_socketUdp, message, strlen(message), 0,
	 (SOCKADDR *) & _addrSendUDP, sizeof(_addrSendUDP)) == -1) {
	logError("Error: sendto() failed err=%d.", errno);
    }
    return true;

}

int sockudp_recv(char *buffer, int bufferLen)
{
    fd_set ReadSet;
    int n, result;
    struct timeval Time;
    SOCKADDR addr_Cli;
    unsigned int clilen;

    //-- Prepare Client address to receive new data
    memset(&addr_Cli, 0, sizeof(addr_Cli));
    clilen = sizeof(addr_Cli);

    FD_ZERO(&ReadSet);
    FD_SET(_socketUdp, &ReadSet);
    Time.tv_sec = DEFAULT_NET_TIMEOUT;
    Time.tv_usec = 0;
    n = select(_socketUdp + 1, &ReadSet, NULL, NULL, &Time);
    if (n > 0) {
	n = recvfrom(_socketUdp, buffer, bufferLen, 0,
		     (SOCKADDR *) & addr_Cli, &clilen);
	if (n == -1) {
	    logError("sockudp_recv recfrom errno=%d", errno);
	    result = -1;
	} else {
	    result = n;
	}
    } else if (n == 0) {
	logError("sockudp_recv select timeout error");
	result = -2;
    } else {
	logError("sockudp_recv select result=%d errno=%d", n, errno);
	result = -3;
    }

    return result;

}




int sockudp_close()
{
#if defined(OS_WIN)
    return closesocket(_socketUdp);
#endif
#if defined(OS_LIN) || defined(OS_MACOS)
    return close(_socketUdp);
#endif
}

int sockudp_shutdown()
{
#if defined(OS_WIN)
    shutdown(_socketUdp, 1);
    return closesocket(_socketUdp);
#endif
#if defined(OS_LIN) || defined(OS_MACOS)
    return close(_socketUdp);
#endif
}


/***************************************************
 *  PING
 ***************************************************
 */
#define ICMP_ECHO 8
#define ICMP_ECHOREPLY 0
#define false 0
#define true 1

#define ICMP_MIN 8		// minimum 8 byte icmp packet (just header)

/* The IP header */
typedef struct iphdr {
    unsigned int h_len:4;	// length of the header
    unsigned int version:4;	// Version of IP
    unsigned char tos;		// Type of service
    unsigned short total_len;	// total length of the packet
    unsigned short ident;	// unique identifier
    unsigned short frag_and_flags;	// flags
    unsigned char ttl;
    unsigned char proto;	// protocol (TCP, UDP etc)
    unsigned short checksum;	// IP checksum

    unsigned int sourceIP;
    unsigned int destIP;

} IpHeader;

/**
 * ICMP header
 */
typedef struct _ihdr {
    char i_type;
    char i_code;		/* type sub code */
    unsigned short i_cksum;
    unsigned short i_id;
    unsigned short i_seq;
    /* This is not the std header, but we reserve space for time */
    ULONG timestamp;
} IcmpHeader;

#define STATUS_FAILED 0xFFFF
#define DEF_PACKET_SIZE 32
#define MAX_PACKET 1024

#define xmalloc(s) malloc(s)
#define xfree(p)   free(p)

void fillPacketData(char *, int);
unsigned short checksum(unsigned short *, int);
int decode_resp(char *, int, struct sockaddr_in *);
unsigned long makeTimeStamp();
unsigned short getPid();


int ping(char *hostName, int nbTry, int receivedTimeOut)
{
    int cr = false;
    int sockRaw;		/* Socket file descriptor */
    struct sockaddr_in dest, from;
    struct hostent *hp;
    int bread, datasize;
    unsigned int fromlen = sizeof(from);
#if !defined(OS_LIN) || defined(OS_MACOS)
    int timeout = 1000;
#endif
    char *dest_ip;
    char *icmp_data;
    char *recvbuf;
    unsigned int addr = 0;
    unsigned short seq_no = 0;
    int i;

#if defined(OS_WIN)
    WSADATA wsaData;
    if (WSAStartup(MAKEWORD(1, 1), &wsaData) != 0) {
	logError("ping:  WSAStartup failed: %d\n", GetLastError());
	return false;
    }
#endif

    if ((sockRaw = socket(AF_INET, SOCK_RAW, IPPROTO_ICMP)) < 0) {
	logError("pong: create socket error %d", errno);
	return false;
    }
#if !defined(OS_LIN)
    bread =
	setsockopt(sockRaw, SOL_SOCKET, SO_RCVTIMEO, (char *) &timeout,
		   sizeof(timeout));
    if (bread == SOCKET_ERROR) {
	logError("ping:failed to set recv timeout: %d\n", errno);
	return false;
    }

    bread =
	setsockopt(sockRaw, SOL_SOCKET, SO_SNDTIMEO,
		   (char *) &receivedTimeOut, sizeof(receivedTimeOut));
    if (bread == SOCKET_ERROR) {
	logError("ping:failed to set send timeout: %d\n", errno);
	return false;
    }
#endif
    memset(&dest, 0, sizeof(dest));

    hp = gethostbyname(hostName);

    if (!hp) {
	addr = inet_addr(hostName);
    }
    if ((!hp) && (addr == INADDR_NONE)) {
	logError("ping:unable to resolve %s\n", hostName);
	return false;
    }

    if (hp != NULL)
	memcpy(&(dest.sin_addr), hp->h_addr, hp->h_length);
    else
	dest.sin_addr.s_addr = addr;

    if (hp)
	dest.sin_family = hp->h_addrtype;
    else
	dest.sin_family = AF_INET;

    dest_ip = inet_ntoa(dest.sin_addr);

    datasize = DEF_PACKET_SIZE;

    datasize += sizeof(IcmpHeader);

    icmp_data = xmalloc(MAX_PACKET);
    recvbuf = xmalloc(MAX_PACKET);

    if (!icmp_data) {
	logError("ping:memory alloc  failed %d\n", errno);
	return false;
    }


    memset(icmp_data, 0, MAX_PACKET);
    fillPacketData(icmp_data, datasize);

    for (i = 0; i < nbTry && cr == false; i++) {
	int bwrote;

	((IcmpHeader *) icmp_data)->i_cksum = 0;
	((IcmpHeader *) icmp_data)->timestamp = makeTimeStamp();

	((IcmpHeader *) icmp_data)->i_seq = seq_no++;
	((IcmpHeader *) icmp_data)->i_cksum =
	    checksum((unsigned short *) icmp_data, datasize);

	bwrote =
	    sendto(sockRaw, icmp_data, datasize, 0,
		   (struct sockaddr *) &dest, sizeof(dest));
	if (bwrote == -1) {
	    logInfo("ping: %s timed out", hostName);
	    continue;
	}

	if (bwrote < datasize) {
	    logInfo("ping:wrote %d bytes != %d bytes expected \n", bwrote,
		    datasize);
	}

	bread =
	    recvfrom(sockRaw, recvbuf, MAX_PACKET, 0,
		     (struct sockaddr *) &from, &fromlen);
	if (bread == -1) {
	    logInfo("ping: %s timed out", hostName);
	    continue;
	}

	cr = decode_resp(recvbuf, bread, &from);
#if defined(OS_WIN)
	Sleep(1000);
#endif
#if defined(OS_LIN) || defined(OS_MACOS)
	sleep(1);
#endif
    }

#if defined(OS_WIN)
    closesocket(sockRaw);
#endif
#if defined(OS_LIN) || defined(OS_MACOS)
    close(sockRaw);
#endif
    return cr;


}


/** 
 * The response is an IP packet. We must decode the IP header to locate 
 * the ICMP data 
 */
int decode_resp(char *buf, int bytes, struct sockaddr_in *from)
{

    IpHeader *iphdr;
    IcmpHeader *icmphdr;
    unsigned short iphdrlen;

    iphdr = (IpHeader *) buf;

    iphdrlen = (unsigned short) (iphdr->h_len * 4);	// number of 32-bit words *4 = bytes

    if (bytes < iphdrlen + ICMP_MIN) {
	logError("ping:too few bytes from %s\n",
		 inet_ntoa(from->sin_addr));
	return false;
    }

    icmphdr = (IcmpHeader *) (buf + iphdrlen);

    if (icmphdr->i_type != ICMP_ECHOREPLY) {
	logError("ping:non-echo type %d recvd\n", icmphdr->i_type);
	return false;
    }
    if (icmphdr->i_id != (unsigned short) getPid()) {
	logError("ping:someone else's packet!\n");
	return false;
    }
    logInfo("ping: %d bytes from %s: icmp_seq = %d. time: %d ms ",
	    bytes,
	    inet_ntoa(from->sin_addr),
	    icmphdr->i_seq, makeTimeStamp() - icmphdr->timestamp);
    return true;

}


/** 
 * compute checksum
 */
unsigned short checksum(unsigned short *buffer, int size)
{

    unsigned long cksum = 0;

    while (size > 1) {
	cksum += *buffer++;
	size -= sizeof(unsigned short);
    }

    if (size) {
	cksum += *(unsigned char *) buffer;
    }

    cksum = (cksum >> 16) + (cksum & 0xffff);
    cksum += (cksum >> 16);
    return (unsigned short) (~cksum);
}


/** 
 * fill ICMP packet (header + dummy data).
 */
void fillPacketData(char *icmp_data, int datasize)
{

    IcmpHeader *icmp_hdr;
    char *datapart;



    icmp_hdr = (IcmpHeader *) icmp_data;

    icmp_hdr->i_type = ICMP_ECHO;
    icmp_hdr->i_code = 0;
    icmp_hdr->i_id = getPid();
    icmp_hdr->i_cksum = 0;
    icmp_hdr->i_seq = 0;

    datapart = icmp_data + sizeof(IcmpHeader);
    //
    // Place some junk in the buffer.
    //
    memset(datapart, 'E', datasize - sizeof(IcmpHeader));

}

/** 
 * make a timestamp with the current date
 */
unsigned long makeTimeStamp()
{
    unsigned long timeStamp;
#if defined(OS_WIN)
    timeStamp = (unsigned long) GetTickCount();
#endif

#if defined(OS_LIN) || defined(OS_MACOS)
    struct timeval date;
    gettimeofday(&date, NULL);
    timeStamp = date.tv_sec * 1000 + date.tv_usec / 1000;
#endif

    return timeStamp;
}

/** 
 * get current process id
 */
unsigned short getPid()
{
    unsigned short pid;
#if defined(OS_WIN)
    pid = (unsigned short) GetCurrentProcessId();
#endif

#if defined(OS_LIN) || defined(OS_MACOS)
    pid = getpid();		/* process.h ?? must be included */
#endif

    return pid;
}
