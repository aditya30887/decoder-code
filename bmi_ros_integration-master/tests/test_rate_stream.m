function test_rate_stream


%% simulation environment
addpath(genpath(pwd));

dummyfile = 'data\MAP1Zee03252010001.plx'; % for offline only.
c3dfile = 'data\Z6_2667_01_Z6_Mar06NewF25cart4cmR50_20100323_01_02_01.c3d';

%% parameters

ntest = 200;     % how many bins to collect before checking
nchan_test = 20; % checks only these many channels

nchans = 128; % number of plexon recording channels
ncodes = 4;   % max number of sort codes per channel (typically 4)
bin = 50e-3; % bin size (seconds)

% load model parameters (if they exist)
                                                 
%% init dynamic plotting objects.

% rplot = rate_plotter(nchans*ncodes, 50); % rate plotter

%% initialization

% plexon interface, firing rate streamer
plexon = init_plexon(); % plexon handle                         
rate = rate_stream(@()plexon_ts(plexon), nchans, ncodes, bin); % stream of spike rates 
                                                 % for nchans*ncodes units


% miscellaneous
obj = onCleanup(@()close_everything(plexon)); % graceful ctrl-c handler 


%% main BMI loop
nunits = nchans*ncodes;

r = zeros(nunits, ntest);
t = zeros(1, ntest);
fprintf('running test for %5.1f seconds\n', ntest*bin);
for i = 1:ntest
    
    [r(:, i), t(i)]= rate.next_sample(); % get firing rate at current bin
                                         %  note: this is a blocking call
             
end


%% check that rates were 

percent_correct = check_rates(r(1:nchan_test*ncodes, :), bin, dummyfile, nchan_test, ncodes, t(1));

percent_correct
end

function close_everything(p)
PL_Close(p);
disp('Stopping');
end