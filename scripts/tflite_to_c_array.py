#!/usr/bin/env python3
import argparse
import os
import textwrap


def parse_args():
    parser = argparse.ArgumentParser(description="Convert TFLite file to C array header.")
    parser.add_argument("--model", type=str, required=True,
                        help="Input .tflite model file.")
    parser.add_argument("--out", type=str, required=True,
                        help="Output .h header file.")
    parser.add_argument("--var-name", type=str, default="g_model",
                        help="C variable name for the model array.")
    return parser.parse_args()


def format_c_array(data_bytes, var_name):
    hex_bytes = [f"0x{b:02x}" for b in data_bytes]
    lines = []
    line = []
    for i, hb in enumerate(hex_bytes):
        line.append(hb)
        if (i + 1) % 12 == 0:
            lines.append(", ".join(line))
            line = []
    if line:
        lines.append(", ".join(line))

    array_body = ",\n  ".join(lines)

    header = textwrap.dedent(f"""\
        #ifndef MODEL_DATA_H_
        #define MODEL_DATA_H_

        #include <stdint.h>

        // Generated from TFLite file. Do not edit by hand.

        const unsigned char {var_name}[] = {{
          {array_body}
        }};

        const unsigned int {var_name}_len = {len(data_bytes)};

        #endif  // MODEL_DATA_H_
    """)
    return header


def main():
    args = parse_args()

    if not os.path.isfile(args.model):
        raise FileNotFoundError(f"Model file not found: {args.model}")

    os.makedirs(os.path.dirname(args.out), exist_ok=True)

    with open(args.model, "rb") as f:
        data = f.read()

    header_text = format_c_array(data, args.var_name)

    with open(args.out, "w") as f:
        f.write(header_text)

    print(f"C header written to: {args.out}")
    print(f"Array name: {args.var_name}, length: {len(data)} bytes")


if __name__ == "__main__":
    main()