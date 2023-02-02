function mycart2sph(x, y, z)
    [az, el] = cart2sph(x, y, z);
    
    r2d = 180 / pi;
    lon = az * r2d;
    lat = el * r2d;
    
    if lon < 0
        lon = lon + 360;
    end
    
    fprintf('longtitude/latitude: %.2f/%.2f\n', lon, lat);
end