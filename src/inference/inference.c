#include "inference.h"

#include "model/model_data.h"

#include <stdint.h>

void run_inference(const PreprocessOutput *input, InferenceResult *result) {
  if (!input || !result) {
    return;
  }

  uint32_t accumulator = 0;
  for (uint32_t i = 0; i < PREPROCESS_FRAME_SIZE; ++i) {
    accumulator += input->pixels[i];
  }

  accumulator += (uint32_t)kModelDataLen;
  result->top_label = accumulator % 3U;
  result->score = (float)(accumulator % 100U) / 100.0f;
}
