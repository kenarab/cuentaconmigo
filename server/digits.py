"""Handwritten digit reader for aligned cells (sdd/specs/scrutiny-backend/SPEC.md, SB-2).

The cell is already located by the layout alignment in readings.py, so reading reduces
to: split the ink into digits, normalize each one like MNIST (20x20 box centered by
mass in 28x28) and classify it with a small neural network (numpy MLP trained by
server/train_digits.py on MNIST with augmentation). Runs on our own server, no cloud.

Returns suggestions only; people confirm the values.
"""
from pathlib import Path

import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
MODEL = ROOT / "data/models/digits-mlp.npz"
_weights = None


def _load():
    global _weights
    if _weights is None and MODEL.exists():
        z = np.load(MODEL)
        _weights = [z[k] for k in ("W1", "b1", "W2", "b2", "W3", "b3")]
    return _weights


def available():
    return _load() is not None


def forward(weights, x):
    W1, b1, W2, b2, W3, b3 = weights
    h1 = np.maximum(0, x @ W1 + b1)
    h2 = np.maximum(0, h1 @ W2 + b2)
    z = h2 @ W3 + b3
    z = z - z.max(axis=1, keepdims=True)
    e = np.exp(z)
    return e / e.sum(axis=1, keepdims=True)


def normalize(ink):
    """ink: 2-D float array, 1 = ink. Returns a 784 vector in MNIST style."""
    ys, xs = np.nonzero(ink > 0.5)
    if len(xs) == 0:
        return None
    ink = ink[ys.min():ys.max() + 1, xs.min():xs.max() + 1]
    h, w = ink.shape
    s = 20.0 / max(h, w)
    nh, nw = max(1, round(h * s)), max(1, round(w * s))
    small = np.asarray(Image.fromarray((ink * 255).astype(np.uint8)).resize((nw, nh), Image.BILINEAR),
                       dtype=np.float32) / 255
    canvas = np.zeros((28, 28), np.float32)
    total = small.sum() or 1
    cy = (small.sum(axis=1) * np.arange(nh)).sum() / total
    cx = (small.sum(axis=0) * np.arange(nw)).sum() / total
    top = int(round(14 - cy))
    left = int(round(14 - cx))
    top, left = min(max(top, 0), 28 - nh), min(max(left, 0), 28 - nw)
    canvas[top:top + nh, left:left + nw] = small
    return canvas.reshape(-1)


def split(ink):
    """Splits a cell's ink into digit images by empty columns, left to right."""
    cols = ink.sum(axis=0) > 0
    pieces, start = [], None
    for x, filled in enumerate(list(cols) + [False]):
        if filled and start is None:
            start = x
        elif not filled and start is not None:
            pieces.append(ink[:, start:x])
            start = None
    if not pieces:
        return []
    heights = [int(np.ptp(np.nonzero(p.sum(axis=1))[0])) + 1 for p in pieces]
    tallest = max(heights)
    # Drop specks and stray marks much shorter than the digits.
    kept = [p for p, h in zip(pieces, heights) if h >= 0.4 * tallest and p.sum() >= 6]
    # Touching digits come out as one wide piece: cut it at the thinnest columns.
    out = []
    for p in kept:
        n = int(round(p.shape[1] / (0.7 * tallest)))
        if n < 2:
            out.append(p)
            continue
        cols = p.sum(axis=0)
        cuts, step = [], p.shape[1] / n
        for k in range(1, n):
            lo, hi = int(k * step - step / 3), int(k * step + step / 3)
            cuts.append(lo + int(np.argmin(cols[lo:hi])))
        edges = [0] + cuts + [p.shape[1]]
        out += [p[:, a:b] for a, b in zip(edges, edges[1:]) if b - a > 1]
    return out


def read(bw_image):
    """bw_image: PIL image, black ink on white, lines removed and cropped to the ink.
    Returns (value, confidence) or None when it does not look like 1-4 digits."""
    weights = _load()
    if weights is None:
        return None
    ink = (np.asarray(bw_image.convert("L"), dtype=np.float32) < 128).astype(np.float32)
    digits = split(ink)
    if not 1 <= len(digits) <= 4:
        return None
    x = np.stack([v for v in (normalize(d) for d in digits) if v is not None])
    if len(x) != len(digits):
        return None
    p = forward(weights, x)
    value = int("".join(str(int(d)) for d in p.argmax(axis=1)))
    return value, float(np.prod(p.max(axis=1)))
