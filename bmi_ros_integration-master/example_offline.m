function example_offline
% EXAMPLE_OFFLINE: A very minimal BMI that initializes BMI parameters, polls the 
% plexon server for rates, gets new data from a (simulated) ROS network,
% and predicts kinematic output. This is "offline" in the sense that it does
% not require you to be connected to a remote Linux ROS master. It instead
% creates a local ROS master inside matlab, and creates a couple of bullshit
% publishers.
%
%  To run this example:
%     1. Start Plexon SoftServer, load a .plx file, start Data Pump
%     2. Make sure the dummyfile name (see environment block below) is set
%        to the same file that you are playing in SoftServer. 
%     3. Run this script.

%% simulation environment
addpath(genpath(pwd));

dummyfile = 'data\MAP1Zee03252010001.plx'; % for offline only.
c3dfile = 'data\Z6_2667_01_Z6_Mar06NewF25cart4cmR50_20100323_01_02_01.c3d';

%% parameters

ros_master_ip = 'localhost'; % for offline simulation
end_eff_frame = 'wam/hand/bhand_grasp_link'; % tf frame for end-effector
goal_frame = 'goal'; % tf frame for end-effector
world_frame = 'arena';                       % tf frame for middle of arena
task_state_topic = '/task_state_code';

nchans = 128; % number of plexon recording channels
ncodes = 4;   % max number of sort codes per channel (typically 4)
bin = 50e-3; % bin size (seconds)

n_gamma_taps = 6;
gamma = 0.4;

% load model parameters (if they exist)
                                                 
%% init dynamic plotting objects.

% rplot = rate_plotter(nchans*ncodes, 50); % rate plotter
% kplot = line_plotter(6, 100); % line plotter
pos_state_view = position_view( [0,0,0], [0,0,0], [0,0,0], [-0.07, 0.07, -0.07, 0.07]);


%% initialization

% ros handle and subscriber
ros_handle = ros_interface(ros_master_ip, end_eff_frame, goal_frame, ...
                 world_frame);             
rossubscriber(task_state_topic, rostype.std_msgs_Int16, ...
               @ros_handle.task_state_cb);

        
% only for offline
dummy = dummy_publisher(bin, dummyfile, c3dfile, end_eff_frame,...
                        goal_frame, world_frame);    

% BMI model           
bmi_model = lms_gamma_bmi_model(nchans*ncodes,bin, n_gamma_taps, gamma);

% rates = rates_from_file(bin, dummyfile, nchans, ncodes);
% save('temp_rates', 'rates');
load('temp_rates');

bmi_model.train_batch(dummy.cart_pos, rates);  % pre-training BMI

                    
% plexon interface, firing rate streamer
plexon = init_plexon(); % plexon handle
rate = rate_stream( @()plexon_ts(plexon), nchans, ncodes, bin); % stream of spike rates 
                                                 % for nchans*ncodes units


% miscellaneous
obj = onCleanup(@()close_everything(plexon)); % graceful ctrl-c handler 


%% main BMI loop

while 1
    
    [r, t]= rate.next_sample(); % get firing rate at current bin
                                %  note: this is a blocking call
                                    
    dummy.publish(t); % (offline only) simulates an external node that 
                      %  sends us the transforms
                                        
    end_eff_position = ros_handle.get_end_eff_position();   % new ros data                   
    goal_position = ros_handle.get_goal_position();
    task_state = ros_handle.get_task_state();
    
    % update bmi parameters
%     pos_pred_bmi_model.update(r,end_eff_position); % update + predict
    
    % predict using bmi
    pos_pred = bmi_model.predict_and_step(r); % predict without update

    % send bmi command
    
    
%%%%% dynamic plots (slow)
%     rplot.insert(r);
%     kplot.insert([end_eff_position, goal_position]);
    pos_state_view.update(end_eff_position, pos_pred, goal_position, task_state);
    
    
end



end

function close_everything(p)
PL_Close(p);
rosshutdown;
disp('Stopping');
end