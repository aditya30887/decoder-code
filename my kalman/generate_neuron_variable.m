function [neuron] = generate_neuron_variable(Data_ts, binsize, Duration, square_root_transform, normalize_each_unit)
% This function generates the variable neuron containing normalized firing
% rate (normalized for each unit) if requested. The matrix could possibly
% be square root transformed is requested.
% 
% INPUTS: Data_ts - time stamps for each unit. structure of size [1 X
% units]. Has three elements. Data_ts.ts - timestamps of size [timestamps X
% 1]; Data_ts.chan and Data_ts.unit are the channels number and unit of
% that channel respectively. binsize - in msec. Duration - Duration of the
% file (dataset/recording) square_root_transform -  Square root transform
% will be performed on the binned data so bring the distribution closer to
% a normal distribution. yes or no are the options. normalize_each_unit -
% this will normalize each unit to itself and restrict the range of each
% unit between 0 and 1 yes or no are the options.
% 
% OUTPUTS: 
% neuron - of size [units X bins]. 

neuron = binning(Data_ts, binsize, Duration); % bins the neural data at the specified binsize.
% output is bincount per bin of size binsize.

neuron = neuron * (1000/binsize); % to convert the bincount into Hz. 

% perform square root transform to bring the distribution closer to a
% normal distribution.
if strcmp(square_root_transform, 'yes')
    neuron = sqrt(neuron); 
end 

% Normalize each unit such that the max and the min value for each unit is
% between 0 and 1.
if strcmp(normalize_each_unit, 'yes')
    for i = 1 : size(neuron, 1) 
        neuron(i,:) = (neuron(i,:) - min(neuron(i,:)))/ (max(neuron(i,:)) - min(neuron(i,:))); 
    end
end