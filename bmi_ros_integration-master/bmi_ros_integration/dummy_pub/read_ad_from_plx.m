function [ad, Fs, num_samples, first_ts] = ...
    read_ad_from_plx(filename, channels)


% [tscounts, wfcounts, evcount] = plx_info(filename, 0);
% 
% 
% [n_freqs, freqs] = plx_adchan_freqs(filename);
% [n_gains, gains] = plx_adchan_gains(filename);
% [n_names, adchan_names] = plx_adchan_names(filename);
% [n_sc, samplecounts] = plx_adchan_samplecounts(filename);
% clear n_freqs;
% clear n_gains;
% clear n_sc;
% clear n_names;

% max_ad_chan = 33; % 0 based

% num_ad_chans = sum(samplecounts > 0);
% ad_structs(num_ad_chans).ad = 0;
% ad_structs(num_ad_chans).ad = [];

n = 0;
for i = 1:length(channels)
    
    [Fs, num_samples, ts, fn, adc] = plx_ad_v(filename, channels(i));
    if n == 0
       ad = zeros(num_samples, length(channels));    
    end
    ad(:, i) = adc;
    n=n+1;
end

first_ts = ts;

% events
%     [n, ts, sv] = plx_event_ts(filename, 2);
% %     data_struct.ev_timestamps = ts;
% 
% [n, ev_timestamps, strobes] = plx_event_ts(filename, 257);
% data_struct.ev_timestamps = ev_timestamps;
% data_struct.strobes = strobes;
% data_struct.timestamps = timestamp_structs;
% data_struct.ad = ad_structs;
