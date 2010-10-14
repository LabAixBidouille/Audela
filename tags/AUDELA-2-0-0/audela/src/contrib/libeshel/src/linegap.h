

#ifndef _INC_LINE_GAP
#define _INC_LINE_GAP

typedef struct
{
   int    order;
   double l_obs;
   double l_calc;
   double l_diff;
   double l_posx;   
   double l_posy; 
   short  valid;
} LINE_GAP;


#endif