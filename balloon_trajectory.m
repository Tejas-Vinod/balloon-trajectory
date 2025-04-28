clear
clc

dir functions\

% Constants
g = 9.80665;         % Acceleration due to gravity [m/s^2]
Cd = 0.25;           % Drag coefficient (assumed spherical balloon)
m = 1.5 + 5.27;      % Mass of the balloon system [kg]
V_i = 10.48;         % Initial volume [m^3]
T_i = 273.15 + 12;   % Initial temperature [K]
p_i = 962.68*100;    % Initial pressure [Pa]

% Time settings
t = 0:1:3000;        % Time vector [s]
h = 1;               % Time step [s]

x_0 = [0; 0; 0; 0];
A = @(z) (V_z(z, p_i, V_i, T_i) * 3 / (4 * pi))^(2 / 3) * pi;

state = [0;0;0;0;0;0];
%       [x,y,z,vx,vy,vz]
wind = [1,1];
Vb = 476.72;
hb = 7238.3*log(Vb/V_i);

positions = runga_kutta_4(state, t, h, p_i, V_i, Cd, m, T_i, wind);