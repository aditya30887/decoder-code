% clear all;

% extracting the gains of the analog data channels.
function [adts, c3dstruct,filtang,posx,posy,adfreq] = pos_extraction_manual(plxfile, c3dfile)
[n,gains] = plx_adchan_gains(plxfile);

% gains = ones(8,1);
%
% adfreq = 2000;
%
% n = length(AD01);
%
% ad = [AD01, AD02, AD03, AD04, AD05, AD06, AD07(1:n,1), AD08]*1000;



for i=1:2
    
    
    [adfreq, n, ts, fn, ad(:,i)] = plx_ad_v(plxfile, i-1); % zero based indexing
    
    
    filtang(:,i) = modi_filter_dblpass(ad(:,i),'enhanced','fc',10,'fs',adfreq);
    
    
    filtang(:,i) = (filtang(:,i)*gains(i))/1000; % 1000 is probably the gain set up on the amplifier
    
    
    % filtang(:,i) = (ad*gains(i))/1000;
    
    
end

filtang = filtang/1.5; % divide with pre-treatment of angular gains; no angular offset to subtract

adts = (0:n-1)'/adfreq;  %analog data time stamps...extracted with the help of sampling freq

c3dstruct = c3d_load(c3dfile);

ShoPosX = c3dstruct.CALIBRATION.RIGHT_SHO_X;

ShoPosY = c3dstruct.CALIBRATION.RIGHT_SHO_Y;

L1 = c3dstruct.CALIBRATION.RIGHT_L1;

L2 = c3dstruct.CALIBRATION.RIGHT_L2;

L2PtrOffset =  c3dstruct.CALIBRATION.RIGHT_PTR_ANTERIOR;



% decide whether to use actual arm or bmi arm

intang = filtang;

%intang = filtbmiang;



% find the end-point velocities and classify them in 8 directional groups

posx = (ShoPosX+L1*cos(intang(:,1))+L2*cos(intang(:,1)+intang(:,2))+L2PtrOffset*cos(intang(:,1)+intang(:,2)+pi/2))*100; % to convert it into cm

posy = (ShoPosY+L1*sin(intang(:,1))+L2*sin(intang(:,1)+intang(:,2))+L2PtrOffset*sin(intang(:,1)+intang(:,2)+pi/2))*100; % to convert it into cm


%%

% plxfile ='H:\plexondata March 2011 onwards\201109\zee20110920\MAP1nhp09202011003.plx';

% stb = getstrobedword(plxfile);

% save('stbzee20110920003.mat', 'stb');

% stb=[ts, states, TP loadon];



% stb_ind = find(stb(:,2) == 3| stb(:,2) ==4 |stb(:,2) ==5);

% req_stb = stb(stb_ind,:);

