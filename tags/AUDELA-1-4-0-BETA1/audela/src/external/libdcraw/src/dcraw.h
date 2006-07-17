
// File   :libdcraw.h .
// Date   :05/08/2005
// Author :Michel Pujol

#define CLASS

#define ushort UshORt
typedef unsigned char uchar;
typedef unsigned short ushort;

extern   ushort (*image)[4];
extern   char *ifname, *meta_data;
extern   FILE *ifp;
extern   int flip;
extern   int iheight, iwidth, shrink;
extern   unsigned filters;
extern   int   meta_length;
extern   int verbose;
extern   int use_gamma;
extern   int output_color;
extern   int data_offset;

extern   int height, width, fuji_width;
extern   int is_foveon;
extern   int document_mode;
extern   int quick_interpolate;
extern   int xmag, ymag;
extern   int histogram[3][0x2000];
extern   float bright;
extern   int  is_raw;
extern   int black;
extern   int maximum;
extern   int colors;
extern   int top_margin;
extern   int left_margin;

extern     time_t timestamp;
extern     char make[64];
extern     char model[72];
extern     float flash_used;
extern     float iso_speed;
extern     float shutter;
extern     float aperture;
extern     float focal_len;

//extern   int raw_height, raw_width, top_margin, left_margin;
extern   int clip_color;

extern int  CLASS identify ();
extern void CLASS merror (void *ptr, char *where);
extern void CLASS bad_pixels();
extern void CLASS foveon_interpolate();
extern void CLASS scale_colors();
extern void CLASS vng_interpolate();
extern void CLASS ahd_interpolate();
extern void CLASS fuji_rotate();
extern void CLASS convert_to_rgb();
extern void CLASS flip_image();
extern void CLASS border_interpolate (int border);
extern void CLASS cam_to_cielab (ushort cam[4], float lab[3]);

extern void (*load_raw)();
//extern void write_ppm(FILE *);
extern void (*write_fun)(FILE *);
