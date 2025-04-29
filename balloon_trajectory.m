clear
clc

dir functions\
dir Launches\23.04.09\wind_data_2023apr9.csv

% Constants
g = 9.80665;       % Acceleration due to gravity [m/s^2]
C_d = 0.25;        % Drag coefficient, from Manufacturer
m = 1.5 + 5.27;    % Mass of the balloon system [kg]
V_i = 10.48;       % Initial volume [m^3]
T_i = 273.15 + 12; % Initial temperature [K]
p_i = 962.68*100;  % Initial pressure [Pa]
V_b = 476.72;       

% Time settings
t = 0:1:9000;      % Time vector [s]
h = 1;             % Time step [s]

% Calculations
h_b = 7238.3*log(V_b/V_i);

% Initializing Runge Kutta 4
state = [0; 0; 0; 0; 0; 0]; % Initial state, [x; y; z;vx;vy;vz]

% Launch Location
lat0 =  37.19703;
lon0 = -80.57858; 
R = 6371370;      % Earth's radius in meters

% Wind Data
M = readmatrix('Launches\23.04.09\wind_data_2023apr9.csv'); 
windInterpU = scatteredInterpolant(M(:,1), M(:,6), M(:,7), M(:,2), 'linear', 'nearest');
windInterpV = scatteredInterpolant(M(:,1), M(:,6), M(:,7), M(:,3), 'linear', 'nearest');

state_f = runga_kutta_4(state, t, h, p_i, V_i, C_d, m, T_i, windInterpU, windInterpV, h_b, lat0, lon0);

x_pos = state_f(:,1); % x-position [meters]
y_pos = state_f(:,2); % y-position [meters]

lat = lat0 + (y_pos / R) * (180/pi);
lon = lon0 + (x_pos ./ (R * cosd(lat0))) * (180/pi);
alt = state_f(:,3); % z-position (altitude) [meters]

write_kml(lat, lon, alt, 'balloon_trajectory.kml');