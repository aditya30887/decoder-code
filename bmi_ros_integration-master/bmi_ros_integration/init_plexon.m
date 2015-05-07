function [s] = init_plexon()

s = PL_InitClient(1);
if s == 0 
    error('Could not connect to Plexon server');
    return
end
end