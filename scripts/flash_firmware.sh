#!/usr/bin/env bash
set -e

BOARD=""
BUILD_DIR="build"
ELF_FILE="firmware.elf"
OPENOCD_CFG="board/stm32f4discovery.cfg"  # Example; change for your board

while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    --board)
      BOARD="$2"
      shift
      shift
      ;;
    --build-dir)
      BUILD_DIR="$2"
      shift
      shift
      ;;
    --elf)
      ELF_FILE="$2"
      shift
      shift
      ;;
    *)
      echo "Unknown argument: $1"
      exit 1
      ;;
  esac
done

echo "Board: ${BOARD}"
echo "Build directory: ${BUILD_DIR}"
echo "Firmware ELF: ${ELF_FILE}"

# Build step (adapt as needed: make, cmake, etc.)
if [ -f "${BUILD_DIR}/Makefile" ]; then
  echo "Running make in ${BUILD_DIR}..."
  make -C "${BUILD_DIR}"
else
  echo "No Makefile found in ${BUILD_DIR}. Skipping build step."
fi

FULL_ELF_PATH="${BUILD_DIR}/${ELF_FILE}"

if [ ! -f "${FULL_ELF_PATH}" ]; then
  echo "Error: ELF file not found at ${FULL_ELF_PATH}"
  exit 1
fi

echo "Flashing firmware using OpenOCD..."
openocd -f "${OPENOCD_CFG}" \
  -c "program ${FULL_ELF_PATH} verify reset exit"

echo "Done."
