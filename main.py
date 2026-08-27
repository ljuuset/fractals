import matplotlib.pyplot as plt

from fractals.roots import find_roots
from fractals.methods import newton
from fractals.render import render_fractal


def main():
    all_cases = find_roots()

    for case in all_cases:
        render_fractal(case, newton)

    plt.show()


if __name__ == "__main__":
    main()