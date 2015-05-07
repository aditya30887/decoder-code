function [rates_truth] = rates_from_file(bin, dummyfile, nchan, ncodes)

% RATES_FROM_FILE: extracts firing rate from a .plx
% file. Returns a matrix of firing rates for all possible units,
% whether they had timestamps or not. So for nchan channels and
% ncodes possible units per channel, the returned matrix is 
%  of size (number of bins, nchan*ncodes).
%
% see example_offline.m for usage.

first_ts = 0;
nunits = nchan*ncodes;

unit = 1;

has_timestamps = zeros(1, nunits);
max_timestamp = zeros(1, nunits);


timestamps(nunits).timestamps = [];
for ch = 1:nchan
    for co = 1:ncodes  % sorted units only
        [n, timestamps(unit).timestamps] = plx_ts(dummyfile, ch, co);
        has_timestamps(unit) = n > 0;
        if n > 0
            max_timestamp(unit) = max(timestamps(unit).timestamps);
        end
        unit = unit + 1;
    end
end

maxts = max(max_timestamp);

edges = 0:bin:maxts;
Ntruth = length(edges);

rates_truth = zeros(nunits, Ntruth);
for i = 1:nunits
   rates_truth(i,:) = 1/bin*histc(timestamps(i).timestamps - first_ts, edges);
end
rates_truth = rates_truth';
