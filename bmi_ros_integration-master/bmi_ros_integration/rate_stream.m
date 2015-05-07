classdef rate_stream < handle
    % RATE_STREAM: A convenience class that polls a Plexon or TDT server for 
    % new spike times and lets users extract the spike rate from the latest
    % completely-populated bin. A bin is "completely populated" if the
    % latest server query returned timestamps that were all at least 
    % buf_delay bins beyond it. By default, buf_delay is set to 1. 
    % 
    % The constructor requires a function handle to a (blocking)
    % getTimestamps function that returns the number of new spikes and the
    % associated spike data i.e. the timestamp, channel and unit code.
    %
    % The stream works by maintaining a queue of rate vectors and 
    % incrementing these vectors when new timestamps arrive.
    %
    % Written by John Choi 2015
    
    properties
        rate_buffer
        head
        tail
        ready
        buflength
        bufdelay
        bin
        cur_time
        nchans
        ncodes
        nunits
        plexon
        no_data_yet
        first_ts
        getTimestamps
    end
    
    
    methods
        function obj = rate_stream(getTimestamps, nchans, ncodes, bin, buflength, bufdelay)
            if nargin ==4
                buflength = 200; % defaults
                bufdelay = 1;  
            end
            obj.nunits = nchans*ncodes;
            obj.buflength = buflength;
            obj.rate_buffer = zeros(obj.nunits, buflength);
            obj.nchans = nchans;
            obj.ncodes = ncodes;
            obj.nunits = nchans*ncodes;
            obj.bin = bin;
            obj.head = 1;
            obj.tail = 1;
            obj.ready = zeros(1, buflength);
            obj.getTimestamps = getTimestamps;
            obj.cur_time = 0;
            obj.no_data_yet = 1;
            obj.bufdelay = bufdelay;
        end
        function [rate_vector, t_current] = next_sample(obj)
            while obj.head >= obj.tail-obj.bufdelay+1
                obj.poll_new_ts();
            end
            rate_vector = 1./obj.bin.*obj.rate_buffer(:,one_mod(obj.head, obj.buflength));
            t_current = obj.cur_time;
            obj.rate_buffer(:,one_mod(obj.head, obj.buflength)) = 0;
            obj.head = obj.head + 1;
            obj.cur_time = obj.cur_time + obj.bin;
        end
        
        function [] = poll_new_ts(obj)
            
%             PL_WaitForServer(obj.plexon, 10);
%             [n, t] = PL_GetTS(obj.plexon);
            [n, t] = obj.getTimestamps();
            
            
            if n > 0
                neuron = t(:,1) == 1; % only neuron events
                channel_numbers = t(:,2);
                unit_numbers = t(:,3);
                timestamps = t(:,4);
                sorted = t(:,3) > 0; % only sorted units
                
                use = sorted & neuron;
                
                if obj.no_data_yet || max(timestamps) < obj.cur_time
                    obj.cur_time = min(timestamps);
                    obj.first_ts = obj.cur_time;
                    obj.no_data_yet = 0;
                end
                
                if sum(use) > 0
                    obj.add_new_ts(channel_numbers(use),...
                        unit_numbers(use),...
                        timestamps(use));
                end
            end
        end
        
        function [] = add_new_ts(obj, chans, codes, timestamps)
            iu = obj.iu_from_chan_code(chans, codes);
            ts = timestamps - obj.cur_time;
            
            ts_bin = max(1,ceil(ts./obj.bin));
            if any(ts_bin > obj.buflength)
                % buffer over-flow detected
                error('OVERFLOW!')
            end
            
            obj.rate_buffer(:,...
                one_mod(obj.tail:obj.tail+obj.buflength-1, obj.buflength))...
                = obj.rate_buffer(:,...
                one_mod(obj.tail:obj.tail+obj.buflength-1, obj.buflength))...
                + accumarray([iu,ts_bin], 1, [obj.nunits, obj.buflength]);
            
            % progress tail to the minimum timestamp bin
            min_ts_bin = floor(min(ts)/obj.bin);
            obj.tail = obj.head + min_ts_bin;
        end
        
        function [iu] = iu_from_chan_code(obj,chans, codes)
            iu = (chans-1)*obj.ncodes+codes;
        end
        
        
    end
    
end
function [amodb] = one_mod(a, b)
amodb = mod(a-1, b)+1;
end