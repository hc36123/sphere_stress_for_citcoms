clear;



%% (A) Control parameters
dir = './5e21Q80_Rim1e-1_Y100_R65/';
r = [1 0.99687 0.99375 0.99063 0.9875 0.98438 0.98125 0.97813 0.975 0.96684];
%r = [1 0.99844 0.99687 0.99531 0.99375 0.99219 0.99063 0.98906 0.9875 0.98594 0.98438 0.98281 0.98125 0.97969 0.97813 0.97656 0.975 0.97092 0.96684 0.96276];
npoints = 167;
nlines = 1;
refvisc = 1e21;
step = 1;



%% Main Flow
scale = (refvisc * 1e-6) / (6371e3 ^ 2 * 1e6) ;
nr = length(r);
V1 = zeros(nr, npoints, nlines);
V2 = zeros(nr, npoints, nlines);
V3 = zeros(nr, npoints, nlines);
X  = zeros(nr, npoints);
Y  = zeros(nr, npoints);

tensor_prefix = strcat(dir, 'stress_tensor.');
points_prefix = strcat(dir, 'great_circle_points.');

for i = 1 : nlines
    for j = 1 : nr
        rad = r(j);
        tensor_file = strcat(tensor_prefix, string(step), '.', string(rad));
        points_file = strcat(points_prefix, string(i));
        output = stress_on_line(tensor_file, points_file);
        V1(j, :, i) = output(:, 2)' * scale;
        V2(j, :, i) = output(:, 3)' * scale;
        V3(j, :, i) = output(:, 4)' * scale;
        X(j, :) = output(:, 1)';
        Y(j, :) = rad;
    end
    figure('position', [50, 50, 800, 100], 'units', 'centimeters');
    pcolor(X, Y, V1(:, :, i));
    xlabel("Degree");
    ylabel("Radius");
    colormap jet;
    c = colorbar;
    c.Label.String = "MPa";
    
    figure('position', [50, 50, 800, 100], 'units', 'centimeters');
    pcolor(X, Y, V2(:, :, i));
    xlabel("Degree");
    ylabel("Radius");
    colormap jet;
    c = colorbar;
    c.Label.String = "MPa";
end

figure('position', [50, 50, 800, 150], 'units', 'centimeters');
V1_inc1 = V1(end-3, 2 : end, 1) - V1(end-3, 1 : end - 1, 1);
V1_inc2 = V1(end-2, 2 : end, 1) - V1(end-2, 1 : end - 1, 1);
plot(V1_inc1);

figure('position', [50, 50, 800, 150], 'units', 'centimeters');
V2_inc1 = (V2(end-3, 2 : end, 1) + V2(end-3, 1 : end - 1, 1)) / 2;
V2_inc2 = (V2(end-2, 2 : end, 1) + V2(end-2, 1 : end - 1, 1)) / 2;
plot(V2_inc1);

figure('position', [50, 50, 800, 150], 'units', 'centimeters');
plot((V1_inc1 + V1_inc2) / 2 * (r(end-3) - r(end-2)) * 6371 - (V2_inc2 - V2_inc1) * 50);


