#include "app.h"
#include "inference/inference.h"
#include "preprocess/preprocess.h"

int main(void) {
  app_init();
  PreprocessOutput frame = {0};
  InferenceResult inference_result = {0};

  while (1) {
    preprocess_frame(&frame);
    run_inference(&frame, &inference_result);
    AppResult app_result = {
        .label = (unsigned int)inference_result.top_label,
        .score = inference_result.score,
    };
    app_output_result(&app_result);
  }

  return 0;
}
