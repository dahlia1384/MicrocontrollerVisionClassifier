#ifndef PREPROCESS_H
#define PREPROCESS_H

#include <stdint.h>

#define PREPROCESS_FRAME_WIDTH 32
#define PREPROCESS_FRAME_HEIGHT 32
#define PREPROCESS_FRAME_SIZE (PREPROCESS_FRAME_WIDTH * PREPROCESS_FRAME_HEIGHT)

typedef struct {
  uint8_t pixels[PREPROCESS_FRAME_SIZE];
} PreprocessOutput;

void preprocess_frame(PreprocessOutput *output);

#endif  // PREPROCESS_H
