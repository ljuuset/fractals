import numpy as np

cases = [
    {
        "poly": lambda z: z**3 - 1,
        "poly_p": lambda z: 3*z**2,
        "coeffs": np.array([1, 0, 0, -1]),
        "name": "z^3 - 1"
    },
    {
       "poly": lambda z: z**3 - 2*z + 2,
       "poly_p": lambda z: 3*z**2 - 2,
       "coeffs": np.array([1, 0, -2, 2]),
       "name": "z^3 - 2z + 2"
    },
    {
        "poly": lambda z: z**3 +1j*z + 1,
        "poly_p": lambda z: 3*z**2 + 1j,
        "coeffs": np.array([1, 0, 1j, 1]),
        "name": "z^3 + jz + 1"
    }
    ]

def find_roots():

    for case in cases:

        case["roots"] = np.roots(case["coeffs"])

    return cases