#!/usr/bin/env python3
import argparse
import os
import pathlib
import sys
import numpy as np
from PIL import Image
import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers, models, optimizers, callbacks
from sklearn.metrics import classification_report

def build_model(input_shape, num_classes):
    inputs = keras.Input(shape=input_shape)
    x = layers.Rescaling(1.0 / 255.0)(inputs)
    x = layers.Conv2D(16, 3, padding="same", activation="relu")(x)
    x = layers.MaxPooling2D(2)(x)
    x = layers.SeparableConv2D(32, 3, padding="same", activation="relu")(x)
    x = layers.MaxPooling2D(2)(x)
    x = layers.SeparableConv2D(64, 3, padding="same", activation="relu")(x)
    x = layers.MaxPooling2D(2)(x)
    x = layers.GlobalAveragePooling2D()(x)
    x = layers.Dropout(0.2)(x)
    outputs = layers.Dense(num_classes, activation="softmax")(x)
    return models.Model(inputs, outputs, name="mcu_vision_cnn")

def parse_args():
    p = argparse.ArgumentParser()
    p.add_argument("--data-root", type=str, required=True)
    p.add_argument("--img-size", type=int, default=96)
    p.add_argument("--batch-size", type=int, default=32)
    p.add_argument("--epochs", type=int, default=20)
    p.add_argument("--out", type=str, default="out/model.h5")
    p.add_argument("--grayscale", action="store_true")
    return p.parse_args()

def main():
    a = parse_args()
    sz = (a.img_size, a.img_size)
    ch = 1 if a.grayscale else 3

    tr = pathlib.Path(a.data_root) / "train"
    va = pathlib.Path(a.data_root) / "val"
    if not tr.exists() or not va.exists():
        sys.exit(1)

    tds = keras.utils.image_dataset_from_directory(
        tr,
        batch_size=a.batch_size,
        image_size=sz,
        color_mode="grayscale" if a.grayscale else "rgb",
        shuffle=True
    )
    vds = keras.utils.image_dataset_from_directory(
        va,
        batch_size=a.batch_size,
        image_size=sz,
        color_mode="grayscale" if a.grayscale else "rgb",
        shuffle=False
    )

    cls = tds.class_names
    nc = len(cls)

    tds = tds.cache().shuffle(1000).prefetch(buffer_size=tf.data.AUTOTUNE)
    vds = vds.cache().prefetch(buffer_size=tf.data.AUTOTUNE)

    m = build_model((a.img_size, a.img_size, ch), nc)
    m.compile(
        optimizer=optimizers.Adam(learning_rate=1e-3),
        loss="sparse_categorical_crossentropy",
        metrics=["accuracy"]
    )
    os.makedirs(os.path.dirname(a.out), exist_ok=True)
    cbs = [
        callbacks.ModelCheckpoint(filepath=a.out, monitor="val_accuracy", save_best_only=True, verbose=1),
        callbacks.EarlyStopping(monitor="val_loss", patience=5, restore_best_weights=True)
    ]

    m.fit(tds, validation_data=vds, epochs=a.epochs, callbacks=cbs)

    yt = []
    yp = []
    for im, lb in vds:
        pr = m.predict(im)
        yt.extend(lb.numpy())
        yp.extend(np.argmax(pr, axis=1))

    print(classification_report(yt, yp, target_names=cls))

if __name__ == "__main__":
    main()
