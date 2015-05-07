classdef ros_interface < handle

% ROS_INTERFACE: Class that encapsulates ROS functionality. To use,
% just instantiate one of these objects. The member functions
% handle the specifics of getting the data from the ROS
% network. Add new functions to this class as needed.
%
% see example_offline.m for usage
    
    properties
        ros_master_ip
        tftree
        end_eff_frame
        goal_frame
        world_frame
        task_state
    end
    
    
    methods
        function obj = ros_interface(ros_master_ip, end_eff_frame, ...
                goal_frame, world_frame)
            
            % ROS init
            rosshutdown; % close any existing ROS sessions
            rosinit(ros_master_ip);      % register anew with ros master.
            
            % ROS tf stuff
            obj.tftree = rostf;     % tf tree for ros
            
            obj.end_eff_frame = end_eff_frame;
            obj.goal_frame = goal_frame;
            obj.world_frame = world_frame;
        end
        
        
        function [out] = get_task_state(obj)
            out = obj.task_state;
        end
        
        function [end_eff_position] = get_end_eff_position(obj)
            % get end-effector position from ROS
            waitForTransform(obj.tftree, obj.world_frame, obj.end_eff_frame);
            tfmsg = getTransform(obj.tftree, obj.world_frame, obj.end_eff_frame);
            
            translation = tfmsg.Transform.Translation;
            end_eff_position = [translation.X, translation.Y, translation.Z];
        end
        
        function [goal_position] = get_goal_position(obj)
            % get goal position from ROS
            waitForTransform(obj.tftree, obj.world_frame, obj.goal_frame);
            tfmsg = getTransform(obj.tftree, obj.world_frame, obj.goal_frame);
            translation = tfmsg.Transform.Translation;
            goal_position = [translation.X, translation.Y, translation.Z];
        end
        function [] = task_state_cb(obj, src, msg)
            obj.task_state = msg.Data;
        end
        

    end
  
end

        
        