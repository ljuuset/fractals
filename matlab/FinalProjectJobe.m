% Store polynomials, derivatives, coefficients, names, and methods in
% cell arrays so that they can be looped over easier
polys      = {@(z) z.^3 - 1,       @(z) z.^3 - 2*z + 2,  @(z) z.^3 + 1i*z + 1};
polyPs     = {@(z) 3*z.^2,         @(z) 3*z.^2 - 2,       @(z) 3*z.^2 + 1i};
polyCoeffs = {[1 0 0 -1],          [1 0 -2 2],             [1 0 1i 1]};
polyNames  = {'z^3 - 1',           'z^3 - 2z + 2',        'z^3 + iz + 1'};
methods     = {@newton, @ifj, @steffensen};
methodNames = {'Newton', 'IFJ', 'Steffensen'};

resolution = 1000;
maxiter    = 100;
tol        = 1e-15;

% Find roots dynamically based on polynomial degree
for p = 1:length(polys)
    r       = roots(polyCoeffs{p});
    n_roots = length(r);

    % Custom colormap consistent with normal basin of attraction behavior
    % observed in most fractal images
    % Dynamically generates one black-to-color gradient per root using
    % evenly spaced hues so any number of roots is supported
    n           = 256;
    cmap        = zeros(n, 3);
    base_colors = hsv(n_roots);
    seg         = floor(n / n_roots);
    for k = 1:n_roots
        idx_start = (k-1)*seg + 1;
        idx_end   = n;
        if k < n_roots
            idx_end = k*seg;
        end
        for c = 1:3
            cmap(idx_start:idx_end, c) = linspace(0, base_colors(k,c), idx_end - idx_start + 1);
        end
    end

    % Generate figures for each method and polynomial 
    for m = 1:length(methods)
        figNum = (p-1)*length(methods) + m;
        fig    = figure(figNum);
        clf(fig);

        % Stores every figure-specific parameter as a data structure in
        % UserData so each figure can be independent of the others
        data.f          = polys{p};
        data.fp         = polyPs{p};
        data.method     = methods{m};
        data.roots      = r;
        data.n_roots    = n_roots;
        data.methodName = methodNames{m};
        data.polyName   = polyNames{p};
        data.cmap       = cmap;
        data.resolution = resolution;
        data.maxiter    = maxiter;
        data.tol        = tol;
        data.zoomLevel  = 1;

        % Changes viewing window for figure 6 as the real-valued root lies
        % outside of -1 and 1
        if p == 2 && m == 3
            data.ax = -2; data.bx = 2;
            data.ay = -2; data.by = 2;
        else
            data.ax = -1; data.bx = 1;
            data.ay = -1; data.by = 1;
        end

        set(fig, 'UserData', data);

        % Renders initial fractal images and adds a zoom button to each
        % figure
        renderFractal(fig);
        uicontrol('Parent', fig, 'Style', 'pushbutton', 'String', 'Zoom In', ...
            'Position', [10 10 80 30], ...
            'Callback', @(src, evt) zoomFractal(fig));
    end
end

% Builds the complex grid and reads stored data
function renderFractal(fig)
    data = get(fig, 'UserData');

    x = linspace(data.ax, data.bx, data.resolution);
    y = linspace(data.ay, data.by, data.resolution);

    Z          = x + 1i*y.';
    M          = zeros(size(Z));
    F          = true(size(Z));
    Errors     = zeros([size(Z) data.n_roots]);
    iter       = 0;
    fill_ratio = 0;

    % Iterates the chosen root-finding method on all points simultaneously
    while (fill_ratio < 0.999) && (iter < data.maxiter)
        iter = iter + 1;
        Z    = data.method(data.f, data.fp, Z);
        for k = 1:data.n_roots
            Errors(:,:,k) = abs(Z - data.roots(k));
        end
        minError   = min(Errors, [], 3);
        I          = F & (minError < data.tol);
        M(I)       = iter;
        F(I)       = false;
        fill_ratio = 1 - nnz(F)/numel(F);
    end

    % Dynamic coloring - assigns each basin its own segment of the colormap
    % scaling linearly with the number of roots
    C          = zeros(size(Z));
    [~,rootIdx] = min(Errors, [], 3);
    for k = 1:data.n_roots
        Ik   = (rootIdx == k) & ~F;
        C(Ik) = (k-1) + (1 - M(Ik)/iter);
    end

    figure(fig);
    imagesc(x, y, C);
    colorbar
    colormap(data.cmap)
    title([data.methodName ':  f = ' data.polyName ...
        ',   ' num2str(iter) ' iterations,  Zoom level=' num2str(data.zoomLevel)])
end

% Called on press of zoom in button, focuses on specific figure to zoom
% independently
function zoomFractal(fig)
    data           = get(fig, 'UserData');
    figure(fig);
    roi            = drawrectangle;
    rect           = roi.Position;
    data.ax        = rect(1);
    data.bx        = data.ax + rect(3);
    data.ay        = rect(2);
    data.by        = data.ay + rect(4);
    data.zoomLevel = data.zoomLevel + 1;
    set(fig, 'UserData', data);
    renderFractal(fig);
end

% Root finding methods
function out = newton(f, fp, Z)
    out = Z - f(Z)./fp(Z);
end

function out = ifj(f, fp, Z)
    u   = @(x) f(x)./fp(x);
    h   = @(x) (fp(x - (2/3)*u(x)) - fp(x))./fp(x);
    out = Z - u(Z) + (3/4)*u(Z).*h(Z).*(1 - (3/2)*h(Z));
end

function out = steffensen(f, ~, Z)
    g   = @(x) (f(x + f(x)) - f(x))./f(x);
    out = Z - f(Z)./g(Z);
end