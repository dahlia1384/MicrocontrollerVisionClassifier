#ifndef INFERENCE_H
#define INFERENCE_H

#include <stddef.h>

#include "preprocess/preprocess.h"

typedef struct {
  size_t top_label;
  float score;
} InferenceResult;

void run_inference(const PreprocessOutput *input, InferenceResult *result);

#endif  // INFERENCE_H
