classdef dummy_publisher < handle
    
    properties
 
        bin
        dummyfile
        cart_pos
        first_ts
        Fs_og
        num_samples
        num_bins
        pub
        tfmsg
        tftree
        filtang
        c3dstruct
        stb
        z
        home_pos
        target_positions
        task_state_signal
        goal_pos
        tf_current_pos
        tf_goal_pos
        state_pub
        state_msg
    end
    
    methods
        
        
        function obj = dummy_publisher(bin, dummyfile, c3dfile,...
                                       child_frame_id, goal_frame_id, frame_id)
            % some conveniences
            obj.bin = bin;
            obj.z = 0.1;
            
            % end effector cartesian position
            [adts, obj.c3dstruct, obj.filtang, px, py,obj.Fs_og] ...
                = pos_extraction_manual(dummyfile, c3dfile); 
            obj.first_ts = adts(1);
            obj.cart_pos = zeros(length(px), 3);
            obj.cart_pos = [px, py, obj.z*ones(length(px),1)];
  
            % goal positions
            [obj.home_pos, obj.target_positions] = obj.get_goal_positions();
            
            % centering around home_pos
            obj.cart_pos = bsxfun(@minus, obj.cart_pos, ...
                                   obj.home_pos);
            obj.target_positions = bsxfun(@minus, obj.target_positions, ...
                                          obj.home_pos);
            obj.home_pos = [0, 0, 0];
            
            % converting from cm to meters
            obj.home_pos = obj.home_pos./100;
            obj.target_positions = obj.target_positions./100;
            obj.cart_pos = obj.cart_pos./100;
            
            % strobed words
            obj.stb = getstrobedword(dummyfile);             
   
            % resampling recorded ad signals
            obj.cart_pos =  resample(obj.cart_pos,  1/bin, obj.Fs_og); 
            obj.filtang = resample(obj.filtang, 1/bin, obj.Fs_og);
            obj.num_bins = size(obj.cart_pos,1);
   
            % task_state as a signal
            obj.task_state_signal = obj.create_task_state_signal();
            
            % goal_position as a signal
            obj.goal_pos = obj.create_goal_position_signal();
            
            
            % ROS tf message for representing current position
            tfStampedMsg = rosmessage('geometry_msgs/TransformStamped');
            tfStampedMsg.ChildFrameId = child_frame_id;
            tfStampedMsg.Header.FrameId = frame_id;
            obj.tf_current_pos = tfStampedMsg;
               
            % ROS tf message for representing current position
            tfStampedMsg = rosmessage('geometry_msgs/TransformStamped');
            tfStampedMsg.ChildFrameId = goal_frame_id;
            tfStampedMsg.Header.FrameId = frame_id;
            obj.tf_goal_pos = tfStampedMsg;
            
            
            % ROS publisher for task state
            obj.state_pub = rospublisher('/task_state_code', rostype.std_msgs_Int16);
            obj.state_msg = rosmessage(obj.state_pub);
            pause(2);
            
            % ROS tf tree
            obj.tftree = rostf;
          
            
            
        end
        
        
        function [] = publish(obj,t)
            
            % "current_position": where the hand is right now
            %                    (tf frame in gripmove
            %                       'wam/hand/bhand_grasp_link' )
            %
            % "goal_position": where the subject wants to be, 
            %                    like a target, home position, etc 
            %                    (not implemented in gripmove yet)
            %
            % "task_state" signal: state codes (aka "scene" code in gripmove)
            
            obj.publish_current_position(t);
            obj.publish_goal_position(t);
            obj.publish_task_state(t);
        end

        function [task_state_signal] = create_task_state_signal(obj)
            
            ts = obj.stb(:,1);
            its = min(max(1, round(ts./obj.bin)), obj.num_bins);
            dits = diff([1; its]);
            
            states = obj.stb(:,2);
            
            task_state_signal = zeros(obj.num_bins, 1);
            
            ind = 1;
            for i = 1:length(its)
               task_state_signal(ind:ind+dits(i)-1) = states(i);
               ind=ind+dits(i);
            end
            task_state_signal(ind:obj.num_bins) = 0;
            
        end
        
        function [goal_pos] = create_goal_position_signal(obj)
            ts = obj.stb(:,1);
            its = min(max(1, round(ts./obj.bin)), obj.num_bins);
            dits = diff([1; its]);
            
            TP = obj.stb(:,3);
            states = obj.stb(:,2);
            
            % filter ones where the goal position woudl have changed
            % namely states 6, 7 --> change to TP 1
            %        states 4 --> change to which ever TP is active
            
           
            goal_pos = repmat(obj.home_pos, obj.num_bins, 1);
            
            ind = 1;
            for i = 1:length(its)
                
                if any(ismember([4 5 6 7] , states(i))) 
                    tpc = TP(i);
                    goal = obj.target_positions(tpc, :);
                else
                    goal = obj.home_pos;
                end
                
                
                goal_pos(ind:ind+dits(i)-1, :) = repmat(goal, dits(i), 1);
               
               
               ind=ind+dits(i);
            end
            
            
        end
        
        
        function [home_pos, target_positions] = get_goal_positions(obj)
            X = obj.c3dstruct.TARGET_TABLE.X_GLOBAL(1:9);
            Y = obj.c3dstruct.TARGET_TABLE.Y_GLOBAL(1:9);            
            home_pos = [X(1), Y(1), obj.z];
            target_positions = [X(2:9), Y(2:9), obj.z*ones(8,1)];
        end
        
        function [] = publish_goal_position(obj,t)
            i = one_mod(ceil(t/obj.bin), obj.num_bins);
            obj.send_position(obj.goal_pos(i,:), obj.tf_goal_pos);
        end
        
        function [] = publish_task_state(obj,t)
            i = one_mod(ceil(t/obj.bin), obj.num_bins);
            obj.state_msg.Data = obj.task_state_signal(i);
      
            send(obj.state_pub, obj.state_msg);
        end
        
        function [] = publish_current_position(obj, t)
            i = one_mod(ceil(t/obj.bin), obj.num_bins);
            obj.send_position(obj.cart_pos(i,:), obj.tf_current_pos);
        end
    
        function [] = send_position(obj, x, tfmsg)
            tfmsg.Transform.Translation.X = x(1);
            tfmsg.Transform.Translation.Y = x(2);
            tfmsg.Transform.Translation.Z = x(3);
            
            quatrot = axang2quat([1 0 0 deg2rad(0)]);
            tfmsg.Transform.Rotation.W = quatrot(1);
            tfmsg.Transform.Rotation.X = quatrot(2);
            tfmsg.Transform.Rotation.Y = quatrot(3);
            tfmsg.Transform.Rotation.Z = quatrot(4);
            
            tfmsg.Header.Stamp = rostime('now');
            sendTransform(obj.tftree, tfmsg);
         
        end
        
        
    end
    
    
end
function [c] = one_mod(a,b)
c = mod(a-1,b)+1;
end