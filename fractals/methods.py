def newton(f, fp, Z):

    return Z - f(Z)/fp(Z)

def ifj(f, fp, Z):

    u = lambda x: f(x) / fp(x)
    h = lambda x: (fp(x - (2/3)*u(x)) - fp(x))/fp(x)

    return Z - u(Z) + (3/4)*u(Z)*h(Z)*(1 - (3/2)*h(Z))

def steffensen(f, Z):

    g = lambda x: (f(x + f(x)) - f(x))/f(x)

    return Z - f(Z)/g(Z)