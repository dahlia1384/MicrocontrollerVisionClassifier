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

## Getting Started

### 1. Clone the repository

```bash
git clone <your_repo_url>.git
cd <your_repo_name>
