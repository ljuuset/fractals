def newton(f, fp, Z):
    return Z - f(Z) / fp(Z)


def ifj(f, fp, Z):
    u = f(Z) / fp(Z)
    h = (fp(Z - (2 / 3) * u) - fp(Z)) / fp(Z)
    return Z - u + (3 / 4) * u * h * (1 - (3 / 2) * h)


def steffensen(f, _, Z):
    g = (f(Z + f(Z)) - f(Z)) / f(Z)
    return Z - f(Z) / g