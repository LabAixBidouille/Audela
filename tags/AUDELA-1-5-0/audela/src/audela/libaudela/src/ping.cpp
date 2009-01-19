/* ping.cpp
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : TOTO <toto@toto.com>
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

#include "sysexp.h"
#include <stdio.h>

#if defined(OS_WIN)
#include <windows.h>
#include <winsock.h>
#endif

#if defined(OS_LIN) 
#include <errno.h>
#include <unistd.h>
#include <ctype.h>
#include <stdlib.h>
#include <netinet/in.h>
#include <sys/time.h>
#include <sys/types.h>
#include <sys/socket.h> /* for socket definitions */
#include <asm/socket.h>   /* DM, added for SO_* options definition !!!! ??? */
#include <arpa/inet.h>
#include <string.h>
#include <netdb.h>
#endif

#if defined(OS_MACOS)
#include <errno.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <unistd.h>
#include <sys/time.h>
#include <sys/socket.h> /* for socket definitions */
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>
#endif

#ifndef BYTE
#define BYTE char
#endif
#ifndef UCHAR
#define UCHAR unsigned char
#endif
#ifndef ULONG
#define ULONG unsigned int   /* unsigned 64 bits */
#endif

#ifndef SOCKET_ERROR
#define SOCKET_ERROR (-1)
#endif

/***************************************************
 *  PING
 ***************************************************
 */
#define ICMP_ECHO 8
#define ICMP_ECHOREPLY 0
#define false 0
#define true 1

#define ICMP_MIN 8 // minimum 8 byte icmp packet (just header)

/* The IP header */
typedef struct iphdr {
	unsigned int h_len:4;          // length of the header
	unsigned int version:4;        // Version of IP
	unsigned char tos;             // Type of service
	unsigned short total_len;      // total length of the packet
	unsigned short ident;          // unique identifier
	unsigned short frag_and_flags; // flags
	unsigned char  ttl;
	unsigned char proto;           // protocol (TCP, UDP etc)
	unsigned short checksum;       // IP checksum
	unsigned int sourceIP;
	unsigned int destIP;
}IpHeader;

/**
 * ICMP header
 */
typedef struct _ihdr {
  char i_type;
  char i_code; /* type sub code */
  unsigned short i_cksum;
  unsigned short i_id;
  unsigned short i_seq;
  /* This is not the std header, but we reserve space for time */
  ULONG timestamp;
}IcmpHeader;

#define STATUS_FAILED 0xFFFF
#define DEF_PACKET_SIZE 32
#define MAX_PACKET 1024

#define xmalloc(s) malloc(s)
#define xfree(p)   free(p)

void fillPacketData(char *, int);
unsigned short checksum(unsigned short *, int);
int decode_resp(char *,int ,struct sockaddr_in *,char *result);
unsigned long makeTimeStamp();
unsigned short getPid();

int ping(char * hostName, int nbTry, int receivedTimeOut, char *result) {
  int cr = false;
  int sockRaw;                          /* Socket file descriptor */
  struct sockaddr_in dest,from;
  struct hostent * hp;
  int bread,datasize;
  int fromlen = sizeof(from);
#if !defined(OS_LIN)
  int timeout = 1000;
#endif
  char *dest_ip;
  char *icmp_data;
  char *recvbuf;
  unsigned int addr=0;
  unsigned short seq_no = 0;
  int i ;

  sprintf(result,"ping OK with %s",hostName);

#if defined(OS_WIN)
  WSADATA wsaData;
  if (WSAStartup(MAKEWORD(1,1),&wsaData) != 0){
	  sprintf(result,"WSAStartup failed: %d\n",GetLastError());
	  return false;
  }
#endif

  if ((sockRaw = socket(AF_INET, SOCK_RAW, IPPROTO_ICMP)) < 0)
	    {
		sprintf(result,"create socket error %d", errno);
	  return false;
  }

#if !defined(OS_LIN)
  bread = setsockopt(sockRaw,SOL_SOCKET,SO_RCVTIMEO,(char*)&timeout, sizeof(timeout));
  if(bread == SOCKET_ERROR) {
  	sprintf(result,"failed to set recv timeout: %d\n",errno);
	  return false;
  }
  bread = setsockopt(sockRaw,SOL_SOCKET,SO_SNDTIMEO,(char*)&receivedTimeOut, sizeof(receivedTimeOut));
  if(bread == SOCKET_ERROR) {
  	sprintf(result,"failed to set send timeout: %d\n",errno);
	  return false;
  }
#endif

  memset(&dest,0,sizeof(dest));
  hp = gethostbyname(hostName);
  if (!hp){
	  addr = inet_addr(hostName);
  }
  if ((!hp)  && (addr == INADDR_NONE) ) {
	  sprintf(result,"unable to resolve %s\n",hostName);
	  return false;
  }
  if (hp != NULL) {
	  memcpy(&(dest.sin_addr),hp->h_addr,hp->h_length);
  } else {
  	  dest.sin_addr.s_addr = addr;
  }
  if (hp) {
	  dest.sin_family = hp->h_addrtype;
  } else {
	  dest.sin_family = AF_INET;
  }
  dest_ip = inet_ntoa(dest.sin_addr);
  datasize = DEF_PACKET_SIZE;
  datasize += sizeof(IcmpHeader);
  icmp_data = (char*)xmalloc(MAX_PACKET);
  recvbuf = (char*)xmalloc(MAX_PACKET);
  if (!icmp_data) {
    	sprintf(result,"memory alloc  failed %d\n",errno);
	  return false;
  }
  memset(icmp_data,0,MAX_PACKET);
  fillPacketData(icmp_data,datasize);
  for(i= 0; i< nbTry && cr == false; i++ )  {
	  int bwrote;
	  ((IcmpHeader*)icmp_data)->i_cksum = 0;
	  ((IcmpHeader*)icmp_data)->timestamp = makeTimeStamp();
	  ((IcmpHeader*)icmp_data)->i_seq = seq_no++;
	  ((IcmpHeader*)icmp_data)->i_cksum = checksum((unsigned short*)icmp_data, datasize);
	  bwrote = sendto(sockRaw,icmp_data,datasize,0,(struct sockaddr*)&dest, sizeof(dest));
	  if (bwrote == -1) {
	    sprintf(result,"timed out for sending");
	  } else {
        if (bwrote < datasize ) {
	        sprintf(result,"wrote %d bytes != %d bytes expected ",bwrote, datasize);
	     }
#if defined(OS_WIN)
   	  bread = recvfrom(sockRaw,recvbuf,MAX_PACKET,0,(struct sockaddr*)&from, &fromlen);
#else
   	  bread = recvfrom(sockRaw,recvbuf,MAX_PACKET,0,(struct sockaddr*)&from, (socklen_t*)&fromlen);
#endif
	     if (bread == -1){
		     sprintf(result,"timed out for receiving");
        } else {
           cr = decode_resp(recvbuf,bread,&from,result);
        }
     }
     if (nbTry>1) {
#if defined(OS_WIN)
	  Sleep(1000);
#endif
#if defined(OS_LIN)
	  sleep(1);
#endif
     }
  }
#if defined(OS_WIN)
   closesocket(sockRaw) ;
#endif
#if defined(OS_LIN)
   close(sockRaw);
#endif
  return cr;
}


/**
 * The response is an IP packet. We must decode the IP header to locate
 * the ICMP data
 */
int decode_resp(char *buf, int bytes,struct sockaddr_in *from,char *result) {
	IpHeader *iphdr;
	IcmpHeader *icmphdr;
	unsigned short iphdrlen;
	iphdr = (IpHeader *)buf;
	iphdrlen = (unsigned short) (iphdr->h_len * 4) ; // number of 32-bit words *4 = bytes
	if (bytes  < iphdrlen + ICMP_MIN) {
		sprintf(result,"too few bytes from %s",inet_ntoa(from->sin_addr));
		return false ;
	}
	icmphdr = (IcmpHeader*)(buf + iphdrlen);
	if (icmphdr->i_type != ICMP_ECHOREPLY) {
		sprintf(result,"non-echo type %d recvd",icmphdr->i_type);
		return false ;
	}
	if (icmphdr->i_id != (unsigned short)getPid()) {
		strcpy(result,"someone else's packet!");
		return false ;
	}
   sprintf(result,"%d bytes from %s: icmp_seq = %d. time: %d ms",
    bytes,
    inet_ntoa(from->sin_addr),
    icmphdr->i_seq, (int)makeTimeStamp() - icmphdr->timestamp );
  return true;
}


/**
 * compute checksum
 */
unsigned short checksum(unsigned short *buffer, int size) {
  unsigned long cksum=0;
  while(size >1) {
	cksum+=*buffer++;
	size -=sizeof(unsigned short);
  }
  if(size ) {
	cksum += *(unsigned char*)buffer;
  }
  cksum = (cksum >> 16) + (cksum & 0xffff);
  cksum += (cksum >>16);
  return (unsigned short)(~cksum);
}


/**
 * fill ICMP packet (header + dummy data).
 */
void fillPacketData(char * icmp_data, int datasize){
  IcmpHeader *icmp_hdr;
  char *datapart;
  icmp_hdr = (IcmpHeader*)icmp_data;
  icmp_hdr->i_type = ICMP_ECHO;
  icmp_hdr->i_code = 0;
  icmp_hdr->i_id = getPid();
  icmp_hdr->i_cksum = 0;
  icmp_hdr->i_seq = 0;
  datapart = icmp_data + sizeof(IcmpHeader);
  //
  // Place some junk in the buffer.
  //
  memset(datapart,'E', datasize - sizeof(IcmpHeader));
}

/**
 * make a timestamp with the current date
 */
unsigned long makeTimeStamp() {
   unsigned long timeStamp;

#if defined(OS_WIN)
   timeStamp=(unsigned long)GetTickCount();
#elif defined(OS_LIN) || defined(OS_MACOS)
   struct timeval date;
   gettimeofday(&date,NULL);
   timeStamp = date.tv_sec*1000 + date.tv_usec/1000;
#else
   timeStamp = 0;
#endif

   return timeStamp;
}

/**
 * get current process id
 */
unsigned short getPid() {
   unsigned short pid;

#if defined(OS_WIN)
   pid= (unsigned short) GetCurrentProcessId();
#elif defined(OS_LIN) || defined(OS_MACOS)
   pid=getpid();     /* process.h ?? must be included */
#else
   pid = 0;
#endif

   return pid;
}


