%% Developed by Aditya Tarigoppula, April 2015. 

clear all;
clc; close all force;

file = uigetfile('*.mat'); % select a .mat file, right now it only does it for one file
% these .mat files are generate using the 'batch_datats_withlfp.m' stored
% in the matlab code folder in the main folder 'Adi'. 

% Assign variables values... 
binsize = 70; % in msec
normalize_each_unit = 'no'; % this will normalize each unit to itself and restrict the range of each unit between 0 and 1 
% yes or no are the options.
square_root_transform = 'no'; % Square root transform will be performed on the binned data so bring the distribution closer
% to a normal distribution. yes or no are the options. 
variables_included_instate = {'posx' 'posy' 'velx' 'vely'}; % the total number of variables that you can choose
% from include - posx, posy, velx, vely, accx, accy, sh_ang, el_ang
% default vars considered are - posx, posy, velx, vely. 
% PLEASE MAINTAIN THE ORDER - POS first, VEL next followed by ACC and then SH and EL angles. 
lag = 140; % in msec. this is the lag between the neural data and the kinematics.
% 0 lag means no lag...

% Percentage of the file duration that you would like to use for training
% vs. testing. 
training_per = 0.6; % normalized percentage. number should be between 0 and 1. testing will be performed on (1 - training)%

load(file); % load the variables from the requested .mat file into the workspace.

% generate appropriate neuron matrix. size [units X bins]
[neuron] = generate_neuron_variable(Data_ts, binsize, Duration, square_root_transform, normalize_each_unit);

% generate appropriate state matrix. size [units X bins]
[state_var] = generate_state_variable(variables_included_instate, posx, posy, adfreq, binsize, lag); 


% Check if the time dimensions of neuron and state_var are the same length
if size(state_var, 2) ~= size(neuron, 2) 
    disp('Warning! The sizes of state_var and neuron doesnt match. Correcting for the error.'); 
     
    min_size = min(size(state_var, 2), size(neuron, 2)); 
    state_var(:, min_size + 1 : end) = []; 
    neuron(:, min_size + 1 : end) = []; 
    clear min_size;
end

train.O = neuron(:, 1 : round(training_per * size(neuron,2)));
train.S = state_var(:, 1 : round(training_per * size(neuron,2))); 

test.O = neuron(:, round(training_per * size(neuron,2))+1 : end); 
test.S = state_var(:, round(training_per * size(neuron,2))+1 : end); 

algorithm_para.alpha = 0.1;
algorithm_para.beta = 0.1;
algorithm_para.binsize = binsize;

[pre,cc]=EnvoKal(train,test,algorithm_para)
% % Yao's code of kalman where physics is modelled. Training part. 
% [para]=KaltrainP(neuron(:, 1 : round(training_per * size(neuron,2))), state_var(:, 1 : round(training_per * size(neuron,2))), binsize/1000);
% 
% % Yao's code for testing. 
% [pre,CC]=Kaltest(para, neuron(:, round(training_per * size(neuron,2))+1 : end), state_var(:, round(training_per * size(neuron,2))+1 : end),state_var(:, round(training_per * size(neuron,2))+1));



