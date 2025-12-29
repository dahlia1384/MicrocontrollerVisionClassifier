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
- `backend/`: local API server for demo and integration testing
- `frontend_flutter/`: Flutter web dashboard for monitoring inference output

---

## Getting Started

### 1. Clone the repository

```bash
git clone <your_repo_url>.git
cd <your_repo_name>
```

### 2. Install Python dependencies (optional)

Create a virtual environment and install common TinyML tooling used by the scripts.

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
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

---

## Demo Web App (Frontend + Backend)

The project includes a simple dashboard and a lightweight backend API for local
testing. Use these to validate data flow before deploying to hardware.

### Backend

```bash
python3 backend/app.py
```

The backend runs on `http://localhost:5000` and exposes:

- `GET /api/health`
- `POST /api/infer`

### Frontend (Flutter)

Run the Flutter web dashboard locally:

```bash
cd frontend_flutter
flutter pub get
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8000 \
  --dart-define=API_BASE=http://localhost:5000
```

Open `http://localhost:8000` to access the dashboard.

### Run both with one command

```bash
./scripts/run_demo.sh
```

---

## Model Integration Workflow

1. Train or export a TensorFlow Lite model.
2. Convert the model to a C array using `scripts/tflite_to_c_array.py`.
3. Replace `src/model/model_data.c` and `src/model/model_data.h` with the generated output.
4. Update preprocessing dimensions in `src/preprocess/preprocess.h` to match your model input.

---

## Example Data Flow

```
camera frame -> preprocess_frame() -> run_inference() -> app_output_result()
```

`preprocess_frame()` should normalize and resize pixels into the expected input tensor.
`run_inference()` should call your CMSIS-NN/TFLM interpreter and populate `InferenceResult`.

---

## Board Bring-Up Checklist

- Clock and peripheral initialization
- Camera driver capture and frame buffers
- DMA/interrupt configuration for frame capture
- UART/USB/LED output for classification results
- Memory layout tuned for model arena + frame buffers

---

## Troubleshooting

- **Build fails due to missing toolchain:** verify ARM GCC or your vendor IDE is installed and on `PATH`.
- **Model input mismatch:** update `PREPROCESS_FRAME_WIDTH/HEIGHT` and regenerate `model_data`.
- **Out of memory:** reduce model size or adjust tensor arena and frame buffer sizes.

---

## Contributing

- Keep firmware modules small and portable.
- Prefer headers in `include/` for public APIs.
- Add board-specific code under `boards/<vendor>/`.
