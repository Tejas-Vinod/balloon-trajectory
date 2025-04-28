% Governing Equation of Motion
function state_dot = EOM(t, state, p_i, V_i, C_d, m, T_i, wind)
    pos = state(1:3);
    vel = state(4:end);
    z = pos(3);

    Vz = V_z(z, p_i, V_i, T_i);
    Az = (Vz * 3 / (4 * pi))^(2 / 3) * pi;
    Fasc = F_d(z, vel(3), C_d, Az);
    az = (L_z(z,Vz)-Fasc)/m;

    uvel = vel(1)-wind(1);
    Fu = F_d(z, uvel, C_d, Az);
    au = -Fu/(m*uvel)*(vel(1)-wind(1));

    vvel = vel(2)-wind(2);
    Fv = F_d(z, vvel, C_d, Az);
    av = -Fv/(m*vvel)*(vel(2)-wind(2));
    
    if width(vel) == 3
        state_dot = [vel'; au; av; az];
    elseif height(vel) == 3
        state_dot = [vel; au; av; az];
    else
        warning('Error')
    end
end

% Lift at Altitude z
function Lz = L_z(z, Vz)
[~, ~, ~, rho] = atmosisa(z);  % get density at altitude z

Lz = rho*Vz;
end

% Volume at Altitude z
function Vz = V_z(z, p_i, V_i, T_i)
[Temp, ~, P, ~] = atmosisa(z);  % get temperature and pressure at altitude z

Vz = (p_i * V_i / T_i) * (Temp / P);
end

% Drag Force
function Fd = F_d(z, v, Cd, Az)
[~, ~, ~, rho] = atmosisa(z);  % get density at altitude z

Fd = 0.5*rho*v*norm(v)*Cd*Az;
end