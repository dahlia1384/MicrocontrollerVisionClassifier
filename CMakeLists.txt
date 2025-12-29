cmake_minimum_required(VERSION 3.16)
project(MicrocontrollerVisionClassifier C)

set(CMAKE_C_STANDARD 11)

add_library(app
  src/app.c
  src/inference/inference.c
  src/model/model_data.c
  src/preprocess/preprocess.c
)

target_include_directories(app PUBLIC include src)

add_executable(mv_classifier src/main.c)

target_link_libraries(mv_classifier PRIVATE app)
