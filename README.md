# Microcontroller Vision Classifier

Lightweight CNN model running on ARM-based microcontrollers using CMSIS-NN. Demonstrates AI on constrained hardware.

An embedded TinyML vision classification project optimized for microcontrollers and edge devices. This repository provides firmware, model integration, and deployment utilities for running real-time image classification using lightweight neural networks.

---

## Features

- Lightweight CNN optimized for ARM-based microcontrollers
- Uses CMSIS-NN for efficient fixed-point inference
- Runs on resource-constrained hardware
- Supports common embedded platforms (e.g., STM32, nRF, other Cortex-M boards)
- On-device inference: capture → preprocess → classify → output
- Compatible with TinyML frameworks (TensorFlow Lite Micro, Edge Impulse, etc.)
- Modular, portable firmware structure

---

## Hardware Requirements

- ARM Cortex-M microcontroller (Cortex-M3/M4/M7 or similar recommended)
- Sufficient RAM/Flash for ML inference  
  - Recommended: 256 KB+ RAM, 1 MB+ Flash
- Camera module or image sensor supported by your board
- Optional: LEDs, GPIOs, or serial output for classification results

---

## Software Requirements

- ARM GCC toolchain or vendor-specific IDE (e.g., STM32CubeIDE, Keil, IAR)
- CMSIS and CMSIS-NN libraries
- Build system (CMake, Make, or vendor IDE project)
- Optional: Python 3.x for model training and conversion scripts

---

## Repository Layout

- `src/`: firmware runtime (app loop, preprocessing, inference)
- `include/`: public headers
- `src/model/`: generated model arrays
- `scripts/`: training and model conversion utilities
- `boards/`: platform-specific board support packages

---

## Getting Started

### 1. Clone the repository

```bash
git clone <your_repo_url>.git
cd <your_repo_name>
```

### 2. Train a model (optional)

```bash
python3 scripts/train_cnn.py
```

### 3. Convert the model to a C array

```bash
python3 scripts/convert_tflite.py
python3 scripts/tflite_to_c_array.py --input model.tflite --output src/model/model_data.c
```

### 4. Configure your board support

Add board-specific startup files and drivers under `boards/`.

### 5. Build the firmware (CMake example)

```bash
cmake -S . -B build
cmake --build build
```

### 6. Flash to your target

```bash
./scripts/flash_firmware.sh
```
