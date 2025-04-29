clear
clc

dir Launches\23.04.09\wind_data_2023apr9.csv

M = readmatrix('Launches\23.04.09\wind_data_2023apr9.csv');

% Reference point
lat0 = 37.19703;
lon0 = -80.57858; % adjusted from 279.42142
R = 6371370;      % Earth's radius in meters

x = test(:,1);
y = test(:,2);

% Convert to latitude and longitude
lat = lat0 + (y / R) * (180 / pi);
long = lon0 + (x ./ (R * cosd(lat0))) * (180 / pi);

