#!/usr/bin/env python3

import argparse
import os
import numpy as np
import tensorflow as tf


def parse_args():
    parser = argparse.ArgumentParser(description="Convert Keras model to TFLite.")
    parser.add_argument("--model", type=str, required=True,
                        help="Path to input Keras .h5 model.")
    parser.add_argument("--out", type=str, required=True,
                        help="Path to output .tflite model.")
    parser.add_argument("--quantize", type=str, default="none",
                        choices=["none", "dynamic", "int8"],
                        help="Quantization mode.")
    parser.add_argument("--rep-data-dir", type=str,
                        help="Directory of images for int8 representative dataset.")
    parser.add_argument("--img-size", type=int, default=96,
                        help="Image size for representative dataset (if needed).")
    parser.add_argument("--grayscale", action="store_true",
                        help="Use grayscale for representative dataset.")
    return parser.parse_args()


def representative_dataset_gen(rep_data_dir, img_size, grayscale):
    """
    Yields calibration samples for full int8 quantization.
    Assumes images are in rep_data_dir (any class structure).
    This is a simple implementation; you can improve it as needed.
    """
    import pathlib
    from PIL import Image

    color_mode = "L" if grayscale else "RGB"
    img_paths = list(pathlib.Path(rep_data_dir).rglob("*.*"))
    print(f"Using {len(img_paths)} images for representative dataset.")

    def gen():
        for path in img_paths:
            try:
                img = Image.open(path).convert(color_mode)
                img = img.resize((img_size, img_size))
                arr = np.array(img, dtype=np.float32)
                if grayscale:
                    arr = np.expand_dims(arr, axis=-1)
                arr = arr / 255.0
                arr = np.expand_dims(arr, axis=0)
                yield [arr]
            except Exception as e:
                print(f"Skipping {path}: {e}")

    return gen


def main():
    args = parse_args()

    if not os.path.isfile(args.model):
        raise FileNotFoundError(f"Model not found: {args.model}")

    os.makedirs(os.path.dirname(args.out), exist_ok=True)

    model = tf.keras.models.load_model(args.model)
    converter = tf.lite.TFLiteConverter.from_keras_model(model)

    if args.quantize == "none":
        print("Exporting float32 TFLite model.")
        # No additional settings needed

    elif args.quantize == "dynamic":
        print("Exporting dynamic range quantized TFLite model.")
        converter.optimizations = [tf.lite.Optimize.DEFAULT]

    elif args.quantize == "int8":
        if not args.rep_data_dir:
            raise ValueError("int8 quantization requires --rep-data-dir")
        print("Exporting full int8 quantized TFLite model.")
        converter.optimizations = [tf.lite.Optimize.DEFAULT]
        converter.target_spec.supported_ops = [tf.lite.OpsSet.TFLITE_BUILTINS_INT8]
        converter.inference_input_type = tf.int8
        converter.inference_output_type = tf.int8
        converter.representative_dataset = representative_dataset_gen(
            args.rep_data_dir,
            img_size=args.img_size,
            grayscale=args.grayscale,
        )

    tflite_model = converter.convert()

    with open(args.out, "wb") as f:
        f.write(tflite_model)

    print(f"TFLite model written to: {args.out}")


if __name__ == "__main__":
    main()
