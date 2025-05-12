clear;clc;
% res = pyrunfile("testiingfunc.py", "result", tejas=4)
addpath('C:\Users\johnr\Documents\GitHub')

df = readtable("C:\Users\johnr\Documents\GitHub\balloon-trajectory\Launches\pressure27.csv");
wind = double(pyrunfile("get_wind.py", "interpres", dataframe = df, target = [37.1970, -80.5786, 513, 1745762400], status = "ascent"))

