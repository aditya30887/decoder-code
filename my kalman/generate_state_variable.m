function [state_var] = generate_state_variable(variables_included_instate, posx, posy, adfreq, binsize, lag)
% this function generates the state variables utilized by the kalman code.
%
% INPUTS: variables_included_instate - the total number of variables that
% you can choose from include - posx, posy, velx, vely, accx, accy, sh_ang,
% el_ang default vars considered are - posx, posy, velx, vely. PLEASE
% MAINTAIN THE ORDER - POS first, VEL next followed by ACC and then SH and
% EL angles.
%
% posx and posy - cartesian X and Y co-ordinates. [t X 1] dimension for
% each. adfreq - sampling freq of the analog channels (pos channels)
% binsize - in msec. 
% lag - in msec. this is the lag between the neural data
% and the kinematics. lag will be applied before downsampling to allow non
% multiples of binsize as a possible lag.
%
% OUTPUTS: state_var = [dim X t]. State matrix which hasnt been downsampled
% yet to match the neural binning


% apply lag
if lag > 0
    posx = posx(lag : end);
    posy = posy(lag : end);
end

% downsample pos variable
posx = downsample(posx, adfreq/(1000/binsize));
posy = downsample(posy, adfreq/(1000/binsize));


if ~isempty(setdiff({'posx' 'posy' 'velx' 'vely'}, variables_included_instate)) % comparing to the default to see if any other requests have been made
    state_var = [];
    for i = 1 : length(variables_included_instate)
        if(exist(variables_included_instate{i},'var')) == 0 % check whether this variable exists in the workspace. if it doesnt then need to make it.
            switch variables_included_instate{i} % this switch logic assumes that at the very least you have posx, posy and filtang
                case 'velx'
                    velx = [0; diff(posx)]/(binsize/1000);
                case 'vely'
                    vely = [0; diff(posy)]/(binsize/1000);
                case 'accx'
                    accx = [0; 0; diff(diff(posx))]/((binsize/1000)^2);
                case 'accy'
                    accy = [0; 0; diff(diff(posy))]/((binsize/1000)^2);
                case 'sh_ang'
                    sh_ang = filtang(:,1);
                case 'el_ang'
                    el_ang = filtang(:,2);
            end
        end
        state_var = [state_var genvarname(variables_included_instate{i})];
    end
    state_var = [state_var ones(size(state_var,1),1)];
else
    velx = [0; diff(posx)]/(binsize/1000);
    vely = [0; diff(posy)]/(binsize/1000);
    state_var = [posx posy velx vely ones(length(posx),1)];
end
state_var = state_var'; % just so that the dimension is [dim X bins].

