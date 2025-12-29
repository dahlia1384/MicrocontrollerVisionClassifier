#include "preprocess.h"

void preprocess_frame(PreprocessOutput *output) {
  if (!output) {
    return;
  }

  for (uint32_t i = 0; i < PREPROCESS_FRAME_SIZE; ++i) {
    output->pixels[i] = (uint8_t)(i & 0xFF);
  }
}
