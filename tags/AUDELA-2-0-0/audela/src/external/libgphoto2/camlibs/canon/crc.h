/*
 * $Id: crc.h,v 1.1 2006-12-03 09:56:40 michelpujol Exp $
 */
 
#ifndef CRC_H
#define CRC_H

unsigned short canon_psa50_gen_crc(const unsigned char *pkt, int len);
int canon_psa50_chk_crc(const unsigned char *pkt, int len, unsigned short crc);

#endif
