classdef rate_plotter < handle
    
    properties
        hfig
        hax
        hsp
        buffer
        counter
        buflength
        clims
    end
    
    
    methods
        function p = rate_plotter(nunits, buflength)
            p.hfig = figure(3234);
            p.buflength = buflength;
            p.buffer = zeros(nunits, buflength);
            p.hax = imagesc(p.buffer);
            xlabel('Time (bin)');
            ylabel('Unit');
            p.hsp = gca;
            p.clims = [0, 1];
            pause(0.2);
            p.counter = 1;
        end
        
        function insert(p, r)
           p.buffer(:,p.counter) = r;
           
           if max(r) > p.clims(2)
               p.clims(2) = max(r);               
               caxis(p.hsp, p.clims);
           end
               
               
           set(p.hax, 'CData', p.buffer);
           
           pause(0.001);
           p.counter = mod(p.counter,p.buflength)+1; 
        end
    end
    
end