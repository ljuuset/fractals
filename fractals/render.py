import matplotlib

try:
    matplotlib.use("QtAgg")
except Exception:
    try:
        matplotlib.use("TkAgg")
    except Exception:
        matplotlib.use("Agg")

import matplotlib.pyplot as plt
import numpy as np

from .methods import newton

resolution = 1000
maxiter = 100
tol = 1e-15


def render_fractal(case, method=newton, resolution=1000, maxiter=100, tol=1e-12):
    roots = case["roots"]

    x = np.linspace(-1, 1, resolution)
    y = np.linspace(-1, 1, resolution)
    X, Y = np.meshgrid(x, y)
    Z = X + 1j * Y

    M = np.zeros_like(Z, dtype=float)
    F = np.ones_like(Z, dtype=bool)
    Errors = np.zeros((*Z.shape, len(roots)), dtype=float)

    iter_count = 0
    fill_ratio = 0.0

    while fill_ratio < 0.999 and iter_count < maxiter:
        iter_count += 1
        Z = method(case["poly"], case["poly_p"], Z)

        for k in range(len(roots)):
            Errors[:, :, k] = np.abs(Z - roots[k])

        min_error = np.min(Errors, axis=2)
        I = F & (min_error < tol)

        M[I] = iter_count
        F[I] = False
        fill_ratio = 1 - np.count_nonzero(F) / F.size

    C = np.zeros_like(Z, dtype=float)
    root_idx = np.argmin(Errors, axis=2)

    for k in range(len(roots)):
        Ik = (root_idx == k) & (~F)
        C[Ik] = (k - 1) + (M[Ik] / iter_count)

    fig, ax = plt.subplots()
    image = ax.imshow(C, extent=[-1, 1, -1, 1], origin="lower", cmap="hsv", interpolation="nearest")
    fig.colorbar(image, ax=ax)
    ax.set_title(f"{case['name']} via {method.__name__}")
    return fig
