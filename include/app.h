#ifndef APP_H
#define APP_H

typedef struct {
  unsigned int label;
  float score;
} AppResult;

void app_init(void);
void app_output_result(const AppResult *result);

#endif  // APP_H
