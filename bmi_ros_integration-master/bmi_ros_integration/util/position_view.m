classdef position_view < handle
% POSITION_VIEW: a dynamically updated plot that shows the
% predicted and actual 2d positions of a cursor along with a
% string, perhaps to indicate the task state. To use, just
% instantiate it with some initial positions. To update the plot,
% call the "update" member function
%
% See example_offline.m for usage
    
    properties
        f
        current_pos_plot
        current_pos_pred_plot
        goal_pos_plot
        axes
        htext
        offset
    end
    
    methods
        function obj = position_view(current_pos_init, current_pos_pred_init, goal_pos_init, axes)
            obj.axes = axes;
           obj.f = figure(93823);
           state_text = 'hello';
           
           obj.current_pos_plot = plot(current_pos_init(:,1), current_pos_init(:,2), 'k.', 'MarkerSize', 20);
           hold on;
           obj.current_pos_pred_plot = plot(current_pos_pred_init(:,1), current_pos_pred_init(:,2), 'r+', 'MarkerSize', 20);
           
           
           obj.goal_pos_plot = plot(goal_pos_init(:,1), goal_pos_init(:,2), 'bo', 'MarkerSize', 60);
           obj.offset = repmat(axes(2)/10, 1, 2);
           obj.htext = text(current_pos_init(:,1) + obj.offset(1), ...
               current_pos_init(:,2) + obj.offset(2), ...
               state_text);
           hold off;
           xlabel('x (meters)');
           ylabel('y (meters)');
           
           axis(obj.axes);
           pause(0.2);
        end
        
        function [] = update(obj,current_pos, current_pos_pred, goal_pos, task_state)
            set(obj.current_pos_plot, 'XData', current_pos(1))
            set(obj.current_pos_plot, 'YData', current_pos(2))
            set(obj.current_pos_pred_plot, 'XData', current_pos_pred(1));
            set(obj.current_pos_pred_plot, 'YData', current_pos_pred(2));

            set(obj.goal_pos_plot, 'XData', goal_pos(1))
            set(obj.goal_pos_plot, 'YData', goal_pos(2))
            
            if nargin > 3
            set(obj.htext, 'String', task_state);
            set(obj.htext, 'Position', current_pos(1:2) + obj.offset);
            end

            pause(0.001);
        end
        
    end
    
end