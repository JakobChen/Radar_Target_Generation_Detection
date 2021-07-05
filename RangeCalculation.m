%
% The radar maximum range = 300m
% The range resolution = 1m
% The speed of light c = 3*10^8

% TODO : Find the Bsweep of chirp for 1 m resolution

c = 3 * 10^8; 

delta_r = 1;

Bsweep = c / (2 * delta_r);
% TODO : Calculate the chirp time based on the Radar's Max Range
Rmax = 300;
Ts = 5.5 * 2 * Rmax /  c;

% TODO : define the frequency shifts 
fb = [0, 1.1e6, 13e6, 24e6];

calculated_range = c * fb * Ts / (2*Bsweep);
% Display the calculated range
disp(calculated_range);
