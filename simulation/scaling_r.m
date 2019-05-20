function r = scaling_r(theta)
theta = theta * 180 / pi;
theta = mod(theta,90);
if theta < 15
    r = 1 / cos(deg2rad(theta));
else
    if theta < 75
        r = 2 * sqrt(2) * cos(deg2rad(45-theta)) - 2 * sqrt(sin(deg2rad(2 * theta)));
    else
        % if theta <= 90
        r = 1 / sin(deg2rad(theta));
        % end
    end
end

