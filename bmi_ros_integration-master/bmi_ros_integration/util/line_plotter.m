classdef line_plotter < handle
    
    properties
        hfig
        hax
        hsp
        buffer
        nunits
        counter
        buflength
        clims
    end
    
    
    methods
        function p = line_plotter(nunits, buflength)
            p.hfig = figure(3235);
            p.nunits = nunits;
            p.buflength = buflength;
            p.buffer = zeros(nunits, buflength);
            for i = 1:nunits
                p.hax(i) = plot(1:buflength, p.buffer(i,:)');
                hold all;
            end
            hold off;
            xlabel('Time (bin)');
            p.hsp = gca;
            pause(0.2);
            p.counter = 1;
            p.clims = [0,0.001];
        end
        
        function insert(p, r)
           p.buffer(:,p.counter) = r;
           
           if max(r) > p.clims(2)
               p.clims(2) = max(r);               
               ylim(p.hsp, p.clims);
           end
           
           if min(r) < p.clims(1)
               p.clims(1) = min(r);               
               ylim(p.hsp, p.clims);               
           end
           
           for i = 1:p.nunits    
               set(p.hax(i), 'YData', p.buffer(i,:)');
           end
           
           pause(0.0001);
           p.counter = mod(p.counter,p.buflength)+1; 
        end
    end
    
end