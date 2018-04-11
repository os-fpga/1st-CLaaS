/*
**
** This utility library is used to compute different color schemes depending on users needs.
** It is used to create the colored mandelbrot images.
**
*/

#include <stdio.h>
#include <stdlib.h>

#include "utility.h"
/*
**
** This function returns a color transition set:
**
** e.g. if we want to transition from black to red we need to go from (0, 0, 0) to (255, 0, 0).
** With this function we can say how many transition we want (MAX_NUMBER_OF_TRANSITIONS = 256)
**
*/
color_transition_t get_transition_set(unsigned char init_R, unsigned char init_G, unsigned char init_B, int to_update, int number_of_transition){
  color_transition_t transition_set;

  color_t color;

  color.color[0] = init_R;
  color.color[1] = init_G;
  color.color[2] = init_B;

  if(color.color[to_update] == 255)
    color.color[to_update] = 0;

  for(int i = 0; i < number_of_transition; i++){
    transition_set.color_transition[i] = color;
    color.color[to_update] += 256/number_of_transition;
  }

  return transition_set;
}

/*
**
** This funciton returns the color scheme with all the color transitions
**
*/
color_transition_t * get_color_scheme(){
  color_transition_t * color_scheme = (color_transition_t *) malloc(sizeof(color_transition_t) * 8);
  int * bits;
  unsigned char init_R, init_G, init_B;

  for(int i = 7; i >=0; i--){
    bits = get_bits(i, 3);

    init_R = bits[0] ? 255 : 0;
    init_G = bits[1] ? 255 : 0;
    init_B = bits[2] ? 255 : 0;

    color_scheme[i] = (color_transition_t) get_transition_set(init_R, init_G, init_B, i % 3, 64);
  }

  return color_scheme;
}

// This function returns an array of bits representing the number "n"
int * get_bits(int n, int bitswanted){
  int * bits = (int *) malloc(sizeof(int) * bitswanted);

  int k;
  for(k=0; k < bitswanted; k++){
    int mask =  1 << k;
    int masked_n = n & mask;
    int thebit = masked_n >> k;
    bits[k] = thebit;
  }

  return bits;
}

// This function is used to extract bits from an integer number
int extract_bits(int value, int bit_quantity, int start_from){
  unsigned mask;
  mask = ((1 << bit_quantity) - 1) << start_from;

  return (value & mask) >> start_from;
}