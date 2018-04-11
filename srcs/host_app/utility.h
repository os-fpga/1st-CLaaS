#ifndef UTILITY_H
#define UTILITY_H

typedef struct color {
  unsigned char color[3];
} color_t;

typedef struct color_transition {
  color_t color_transition[256];
} color_transition_t;

int *get_bits(int n, int bitswanted);

int extract_bits(int value, int bit_quantity, int start_from);

color_transition_t get_transition_set(unsigned char init_R, unsigned char init_G, unsigned char init_B, int to_update);

color_transition_t * get_color_scheme();

#endif