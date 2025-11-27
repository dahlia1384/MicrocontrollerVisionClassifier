#!/usr/bin/env python3

import argparse
import os

import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers


def build_model(input_shape, num_classes):
    """
    Build a lightweight CNN using depthwise separable convolutions.
    Good candidate for int8 quantization and CMSIS-NN.
    """
    inputs = keras.Input(shape=input_shape)

    x = layers.Rescaling(1.0 / 255.0)(inputs)

    # Block 1
    x = layers.Conv2D(16, 3, padding="same", activation="relu")(x)
    x = layers.MaxPooling2D(2)(x)

    # Block 2 (depthwise-separable)
    x = layers.SeparableConv2D(32, 3, padding="same", activation="relu")(x)
    x = layers.MaxPooling2D(2)(x)

    # Block 3
    x = layers.SeparableConv2D(64, 3, padding="same", activation="relu")(x)
    x = layers.MaxPooling2D(2)(x)

    x = layers.GlobalAveragePooling2D()(x)
    x = layers.Dropout(0.2)(x)

    outputs = layers.Dense(num_classes, activation="softmax")(x)

    model = keras.Model(inputs, outputs, name="microcontroller_cnn")
    return model


def parse_args():
    parser = argparse.ArgumentParser(description="Train lightweight CNN for MCU vision.")
    parser.add_argument("--data-root", type=str, required=True,
                        help="Root directory containing 'train' and 'val' subdirectories.")
    parser.add_argument("--img-size", type=int, default=96,
                        help="Input image height and width.")
    parser.add_argument("--batch-size", type=int, default=32,
                        help="Batch size.")
    parser.add_argument("--epochs", type=int, default=20,
                        help="Number of training epochs.")
    parser.add_argument("--out", type=str, default="out/model.h5",
                        help="Output path for saved Keras model (.h5).")
    parser.add_argument("--grayscale", action="store_true",
                        help="Use grayscale images instead of RGB.")
    return parser.parse_args()


def main():
    args = parse_args()

    img_size = (args.img_size, args.img_size)
    color_mode = "grayscale" if args.grayscale else "rgb"
    channels = 1 if args.grayscale else 3

    train_dir = os.path.join(args.data_root, "train")
    val_dir = os.path.join(args.data_root, "val")

    if not os.path.isdir(train_dir) or not os.path.isdir(val_dir):
        raise FileNotFoundError("Expected 'train' and 'val' subdirectories under data-root.")

    train_ds = tf.keras.utils.image_dataset_from_directory(
        train_dir,
        image_size=img_size,
        batch_size=args.batch_size,
        color_mode=color_mode,
        shuffle=True,
    )

    val_ds = tf.keras.utils.image_dataset_from_directory(
        val_dir,
        image_size=img_size,
        batch_size=args.batch_size,
        color_mode=color_mode,
        shuffle=False,
    )

    class_names = train_ds.class_names
    num_classes = len(class_names)
    print(f"Detected classes: {class_names} (num_classes={num_classes})")

    # Improve performance
    AUTOTUNE = tf.data.AUTOTUNE
    train_ds = train_ds.cache().shuffle(1000).prefetch(buffer_size=AUTOTUNE)
    val_ds = val_ds.cache().prefetch(buffer_size=AUTOTUNE)

    model = build_model(input_shape=(img_size[0], img_size[1], channels),
                        num_classes=num_classes)

    model.compile(
        optimizer=keras.optimizers.Adam(1e-3),
        loss="sparse_categorical_crossentropy",
        metrics=["accuracy"],
    )

    model.summary()

    os.makedirs(os.path.dirname(args.out), exist_ok=True)

    callbacks = [
        keras.callbacks.ModelCheckpoint(
            filepath=args.out,
            monitor="val_accuracy",
            save_best_only=True,
            verbose=1,
        ),
        keras.callbacks.EarlyStopping(
            monitor="val_loss",
            patience=5,
            restore_best_weights=True,
        ),
    ]

    model.fit(
        train_ds,
        validation_data=val_ds,
        epochs=args.epochs,
        callbacks=callbacks,
    )

    # Final save (best model is already saved by ModelCheckpoint)
    print(f"Training complete. Best model saved to: {args.out}")


if __name__ == "__main__":
    main()
