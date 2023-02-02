%% fuction: stress_on_line
% Do the interpolation of stress tensor field in a specified line

function output = stress_on_line(tensor_file, points_file)
    %fprintf('%s\n%s\n', file_stress, file_sample);
    % tensor_t: theta angle of the raw data (radian 0~pi)
    % tensor_f: phi angle of the raw data   (radian 0~2pi)
    % Then convert the unit and latitude of sampled points to radian and theta,
    % respectively. note the range of f should not be less than 0.
    % points_t: theta angle of points (radian 0~pi)
    % points_f: phi angle of points   (radian 0~2pi)
    tensor_file = load(tensor_file);
    points_file = load(points_file);
    
    tensor_t = tensor_file(:, 1);
    tensor_f = tensor_file(:, 2);
    
    points_t = points_file(:, 1);
    points_f = points_file(:, 2);

    % stress: raw data of stress (nondimension)
    % tensor_i: the ith tensor value
    len = size(points_file);
    tensor = zeros(len(1), 6);
    
    method_interp = 0;
    for i = 1 : 6
        tensor_i = tensor_file(:, 2 + i);
        if method_interp == 1
            F = scatteredInterpolant(tensor_t, tensor_f, tensor_i);
            tensor(:, i) = F(points_t, points_f);
        else
            tensor(:, i) = griddata(tensor_t, tensor_f, tensor_i, points_t, points_f, 'nearest');
        end
    end

    % Calculate the stress following the tangent direction of the great circle
    % output: store the results [degree, normal_stress]
    output = zeros(len(1) - 1, 4);
    
    % beg_xyz: position of supercontinent center (in the order of x, y, z)
    beg_xyz = mysph2cart(points_t(1), points_f(1), 1);

    for i = 2 : len
        % position of every sample point (in the order of theta, phi, r),
        % and its corresponding cartesian coordinates
        end_tfr = [points_t(i), points_f(i), 1];
        end_xyz = mysph2cart(points_t(i), points_f(i), 1);

        % tan_xyz: the tangent vector in cartasian coordinates
        % tan_tfr: the tangent vertor in spherecial coordinates
        tan_xyz = cross(end_xyz, cross(end_xyz, beg_xyz));
        tan_xyz = tan_xyz / norm(tan_xyz);
        tan_tfr = mytandirec(end_tfr(1), end_tfr(2), tan_xyz);

        % vec1 = sigma_theta_theta, sigma_theta_phi, sigma_theta_r
        % vec2 = sigma_phi_theta,   sigma_phi_phi,   sigma_phi_r
        % vec3 = sigma_r_theta,     sigma_r_phi,     sigma_r_r
        vec1 = [tensor(i, 1), tensor(i, 4), tensor(i, 5)];
        vec2 = [tensor(i, 4), tensor(i, 2), tensor(i, 6)];
        vec3 = [tensor(i, 5), tensor(i, 6), tensor(i, 3)];

        stress = vec1 * tan_tfr(1) + vec2 * tan_tfr(2) + vec3 * tan_tfr(3);
        %stress = [vec1; vec2; vec3] * tan_tfr';
        stress = dot(stress, tan_tfr);
        output(i - 1, 1) = points_file(i, 3);
        output(i - 1, 2) = stress;
        
        stress = -vec3;
        stress = dot(stress, tan_tfr);
        output(i - 1, 3) = stress;
        
        stress = -vec2;
        stress = dot(stress, tan_tfr);
        output(i - 1, 4) = stress;
    end
end



function xyz = mysph2cart(t, f, r)
    [x, y, z] = sph2cart(f, pi/2 - t, r);
    xyz = [x, y, z];
end



function tan_tfr = mytandirec(t, f, tan_xyz)
    vec_t = [cos(t) * cos(f), cos(t) * sin(f), -sin(t)];
    vec_f = [-sin(f), cos(f), 0];
    vec_r = [sin(t) * cos(f), sin(t) * sin(f), cos(t)];
    tan_tfr = [dot(vec_t, tan_xyz), dot(vec_f, tan_xyz), dot(vec_r, tan_xyz)];
end
