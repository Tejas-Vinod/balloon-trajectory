function state_dot = EOM(t, state, p_i, V_i, C_d, m, T_i, wind, lat0, lon0)

pos = state(1:3); % [x, y, z]
vel = state(4:6); % [vx, vy, vz]
x = pos(1);
y = pos(2);
z = pos(3);

% Earth's radius
R = 6371370; % meters

% Convert x, y to latitude and longitude (for possible future use)
lat = lat0 + (y / R) * (180 / pi);
lon = lon0 + (x / (R * cosd(lat0))) * (180 / pi);

% Constant Wind
u_wind = wind(1); % Eastward wind component (constant)
v_wind = wind(2); % Northward wind component (constant)

% Balloon Forces
Vz = V_z(z, p_i, V_i, T_i);
Az = (Vz * 3 / (4 * pi))^(2/3) * pi;
Fasc = F_d(z, vel(3), C_d, Az);
az = (L_z(z, Vz) - Fasc) / m;

% Relative velocities
u_rel = vel(1) - u_wind;
v_rel = vel(2) - v_wind;

% Drag Forces
Fu = F_d(z, u_rel, C_d, Az);
Fv = F_d(z, v_rel, C_d, Az);

% Accelerations
au = -Fu / m * sign(u_rel + eps);
av = -Fv / m * sign(v_rel + eps);

% Output
state_dot = [vel; au; av; az];
end





% Lift at Altitude z
function Lz = L_z(z, Vz)
[~, ~, ~, rho] = atmosisa(z);  % get density at altitude z

Lz = 9.81*rho*Vz;
end

% Volume at Altitude z
function Vz = V_z(z, p_i, V_i, T_i)
[Temp, ~, P, ~] = atmosisa(z);  % get temperature and pressure at altitude z

Vz = (p_i * V_i / T_i) * (Temp / P);
end

% Drag Force
function Fd = F_d(z, v, Cd, Az)
[~, ~, ~, rho] = atmosisa(z);  % get density at altitude z

Fd = 0.5*rho*v^2*Cd*Az;
end