#!/usr/bin/env python3
"""Train the handwritten digit MLP used by server/digits.py (numpy only, no GPU).

Data: MNIST (http://yann.lecun.com/exdb/mnist/, mirror storage.googleapis.com/cvdf-datasets/mnist/)
in data/private/mnist/*.gz. Augmentation adds shifts and thicker or thinner strokes to
look more like pen on paper. Output: data/models/digits-mlp.npz.
"""
import gzip
import sys
from pathlib import Path

import numpy as np

ROOT = Path(__file__).resolve().parents[1]
RAW = ROOT / "data/private/mnist"
OUT = ROOT / "data/models/digits-mlp.npz"


def load(name, images):
    with gzip.open(RAW / name) as f:
        data = np.frombuffer(f.read(), np.uint8, offset=16 if images else 8)
    return data.reshape(-1, 784).astype(np.float32) / 255 if images else data.astype(np.int64)


def augment(x, rng):
    imgs = x.reshape(-1, 28, 28)
    out = np.empty_like(imgs)
    for i, im in enumerate(imgs):
        dy, dx = rng.integers(-2, 3, size=2)
        im = np.roll(np.roll(im, dy, axis=0), dx, axis=1)
        r = rng.random()
        if r < 0.3:  # thicker stroke
            im = np.maximum.reduce([im, np.roll(im, 1, 0), np.roll(im, 1, 1)])
        elif r < 0.45:  # thinner stroke
            im = np.minimum(im, np.roll(im, 1, 1))
        out[i] = im
    return out.reshape(-1, 784)


def main():
    rng = np.random.default_rng(2026)
    xtr, ytr = load("train-images-idx3-ubyte.gz", True), load("train-labels-idx1-ubyte.gz", False)
    xte, yte = load("t10k-images-idx3-ubyte.gz", True), load("t10k-labels-idx1-ubyte.gz", False)
    sizes = [784, 256, 128, 10]
    params = []
    for a, b in zip(sizes, sizes[1:]):
        params += [rng.normal(0, np.sqrt(2 / a), (a, b)).astype(np.float32), np.zeros(b, np.float32)]
    m = [np.zeros_like(p) for p in params]
    v = [np.zeros_like(p) for p in params]
    lr, b1, b2, step = 1e-3, 0.9, 0.999, 0
    sys.path.insert(0, str(ROOT / "server"))
    from digits import forward  # noqa: E402

    for epoch in range(8):
        order = rng.permutation(len(xtr))
        for s in range(0, len(order), 128):
            idx = order[s:s + 128]
            x, y = augment(xtr[idx], rng), ytr[idx]
            W1, c1, W2, c2, W3, c3 = params
            h1 = np.maximum(0, x @ W1 + c1)
            h2 = np.maximum(0, h1 @ W2 + c2)
            z = h2 @ W3 + c3
            z -= z.max(axis=1, keepdims=True)
            p = np.exp(z)
            p /= p.sum(axis=1, keepdims=True)
            g = p
            g[np.arange(len(y)), y] -= 1
            g /= len(y)
            gW3, gc3 = h2.T @ g, g.sum(0)
            g2 = (g @ W3.T) * (h2 > 0)
            gW2, gc2 = h1.T @ g2, g2.sum(0)
            g1 = (g2 @ W2.T) * (h1 > 0)
            gW1, gc1 = x.T @ g1, g1.sum(0)
            step += 1
            for i, gr in enumerate([gW1, gc1, gW2, gc2, gW3, gc3]):
                m[i] = b1 * m[i] + (1 - b1) * gr
                v[i] = b2 * v[i] + (1 - b2) * gr * gr
                params[i] -= lr * (m[i] / (1 - b1 ** step)) / (np.sqrt(v[i] / (1 - b2 ** step)) + 1e-8)
        acc = (forward(params, xte).argmax(1) == yte).mean()
        print(f"epoch {epoch + 1}: MNIST test accuracy {acc:.4f}", file=sys.stderr)
    OUT.parent.mkdir(parents=True, exist_ok=True)
    np.savez_compressed(OUT, **dict(zip(("W1", "b1", "W2", "b2", "W3", "b3"), params)),
                        test_accuracy=np.float32(acc))
    print(f"wrote {OUT}", file=sys.stderr)


if __name__ == "__main__":
    main()
