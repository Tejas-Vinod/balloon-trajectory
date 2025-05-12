clear
clc


pyenv("ExecutionMode","OutOfProcess")
addpath('C:\Users\johnr\Documents\GitHub')
dir functions\

% Constants
g = 9.80665;       % Acceleration due to gravity [m/s^2]
C_d = 0.25;        % Drag coefficient, from Manufacturer
m = 1.5 + 5.27;    % Mass of the balloon system [kg]
V_i = 10.48;       % Initial volume [m^3]
T_i = 273.15 + 12; % Initial temperature [K]
p_i = 962.68*100;  % Initial pressure [Pa]
V_b = 476.72;

% Time settings
% offset = seconds(t);
% d = '2025-04-27 14:30:00';
% unix = convertTo(datetime(d,'InputFormat','yyyy-MM-dd HH:mm:ss')+offset,'posixtime');
% t = unix;
h = 1;             % Time step [s]
t = 0:h:9000;      % Time vector [s]
% Calculations
h_b = 7238.3*log(V_b/V_i);

% Initializing Runge Kutta 4
% Launch Location
lat0 =  37.196976;
lon0 = -80.578335;
R = 6371370;      % Earth's radius in meters


state = [0; 0; 513; 0; 0; 0]; % Initial state, [x; y; z;vx;vy;vz]
% df = readtable('Launches\23.04.09\wind_data_2023apr9.csv');
df = readtable("C:\Users\johnr\Documents\GitHub\balloon-trajectory\Launches\pressure27.csv");

state_f = runga_kutta_4(state, t, h, p_i, V_i, C_d, m, T_i, df, h_b, lat0, lon0);

% KML Generation
% Extract positions
x_pos = state_f(:,1); % x-position [meters]
y_pos = state_f(:,2); % y-position [meters]

lat = lat0 + (y_pos / R) * (180/pi);
lon = lon0 + (x_pos ./ (R * cosd(lat0))) * (180/pi);
alt = state_f(:,3); % z-position (altitude) [meters]

% Write the trajectory to a KML file
write_kml(lat, lon, alt, 'balloon_trajectory.kml');