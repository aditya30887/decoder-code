function stb = getstrobedword(plxfile)
%plxfile = 'MAP1Zee03252010001.plx';

[tscounts, wfcounts, evcounts] = plx_info(plxfile, 1);
clear tscounts wfcounts;

% if evcounts(257)
    
[n, ts, sv] = plx_event_ts(plxfile, 257);

    if n>1
    bin = dec2bin(sv, 15); %convert strobed event values into binary that is at least 15 bits
    states = bin2dec(bin(:,4:7)); %first four bits of strobed word
    TP = bin2dec(bin(:, 9:13))+1; %next seven bits
    cursor = bin2dec(bin(:, 14)); %12th bit
    loadon = bin2dec(bin(:, 8))+1; %13th bit
    stb=[ts, states, TP loadon];
    %defining target assuming that state 3 turns the peripheral target ON
%     if any(sv)
%         disptarget = c3d.TP_TABLE.StartTarget(TP).*(state<3)+c3d.TP_TABLE.EndTarget(TP).*(states>=3);
%     else
%         disptarget = 0;
%     end
%     else
%         error('only one strobed word in entire file');
%     end
% else
%     error('only one strobed word in entire file');
%     ts, sv, TP, states, disptarget, cursor, loadon = 0;
%     else
%         stb = [0 0 0 0];
end    
%stb.ts = ts;
%stb.word = sv;
%stb.tp = TP;
%stb.state = states;
%stb.disptar = disptarget;
% stb.visfb = cursor;
%stb.loadon = loadon;
%stb.frame = ts*0;
%stb.trial = ts*0;
%stb.trialts = ts([false; diff(stb.state)<0]);
% save sv ts;
%stb.all = [ts, states, TP, sv];
% stb=[ts, states, TP loadon];

%so I might need to go inside the paradigm and create a new function/block
%that records the state every 100ms
%so, write now, make 100ms out of strobed word, if no info for that 100ms,
%make it the previous state in that time window
%{
%switch 
%     case 3
%     case 7
%     case 11
    case 15
    otherwise
    
end

%}
end
