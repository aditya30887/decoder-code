function [n, t] = plexon_ts(plexon)
PL_WaitForServer(plexon, 10);
[n, t] = PL_GetTS(plexon);
end