% Kalman Filter
% x = Ax + w       meaning the state vector x evolves during one time
%                  step by premultiplying by the "state transition
%                  matrix" A. There is also
%                  gaussian process noise w.
% y = Cx + v       meaning the observation vector y is a linear function
%                  of the state vector, and this linear relationship is
%                  represented by premultiplication by "observation
%                  matrix" C. There is also gaussian measurement
%                  noise v.
% where w ~ N(0,Q) meaning w is gaussian noise with covariance Q
%       v ~ N(0,R) meaning v is gaussian noise with covariance R
% C,R change with different testing section in this function
% train is a structure
% train.O is Training Observation n*T matrix, T=time bins
% train.S is Training State  m*T matrix, T=time bins
% test is a structure
% test.O is Testing Observation, p*T matrix, T=time bins
% test.S is Testing State, q*T matrix, T=time bins
% alpha controls learing rate for C, alpha should between 0 and 1
% beta controls learing rate for R, beta should between 0 and 1
% window is window length for each testing section
% overlap
%
% Modified by Aditya Tarigoppula on 5/5/2015.
%
% Developed by Yao May, 2015.

function [pre,cc]=EnvoKal(train, test, algorithm_para)

default_paras = []; % list of para for whom default values are being used.

% check if there is atleast training and testing data.
% Default values for the algorithm parameters if these parameters are not
% assigned as inputs to this function.
switch nargin
    case 1 || 2
        error(['At the very minimum; train, test and algorithm_para.binsize should be provided'...
            'as inputs to the function in the requested format']);
        
    case 3
        if isfield(algorithm_para, 'alpha')
            alpha = algorithm_para.alpha;
        else
            alpha = 0.5;
            default_paras = [default_paras ' -alpha'];
        end
        
        if isfield(algorithm_para, 'beta')
            beta = algorithm_para.beta;
        else
            beta = 0.5;
            default_paras = [default_paras ' -beta'];
        end
        
        if isfield(algorithm_para, 'window_len')
            window_len = algorithm_para.window_len;
        else
            window_len = 50; % number of bins in one window.
            default_paras = [default_paras ' -window_len'];
        end
        
        if isfield(algorithm_para, 'jump');
            jump = algorithm_para.jump;
        else
            jump = floor(window_len/5); % number of bins the window jumps by
            default_paras = [default_paras ' -jump'];
        end
        
        if isfield(algorithm_para, 'binsize');
            binsize = algorithm_para.binsize;
        else
            error('field binsize in the struct algorithm_para is a required input');
        end
end

if ~isempty(default_paras)
    disp(['Using default values for parameters ', default_paras]);
end


% check the range of the learning rates. It should be between 0 and 1 and
% also check if the window_len and jump range makes sense logically.
if alpha > 1 || alpha < 0
    error('alpha should be between 0 and 1');
elseif beta > 1 || beta < 0
    error('beta should be between 0 and 1');
elseif jump > window_len 
    warning(['jump paramater cannot ony be less than or equal to parameter window_len'...
        '. Jumping instead by the size of paramter window_len']); 
    jump = window_len; 
end


% Get the initial estimates of the parameters.
NewPara=Kaltrain(train.O, train.S);

size_test_S = size(test.S);
size_train_O = size(train.O);

num_of_sections = floor(size_test_S(2)/window_len); % round the number of sections to the lowest integer


NewTrain.O=[zeros(size_train_O(1),window_len),train.O(:,size_train_O(2)-jump+1:size_train_O(2))];
NewTrain.S=[zeros(size_test_S(1),window_len),train.S(:,size_test_S(2)-jump+1:size_test_S(2))];
cc=zeros(s(1),section);

for i=1:section 
    
    % Get Testing Data
    NewTest.O(:,:) = test.O(:, 1+(i-1)*window_len:i*window_len);
    NewTest.S(:,:) = test.S(:, 1+(i-1)*window_len:i*window_len);
    
    %Testing
    [pre1,cc1] = Kaltest(NewPara, NewTest.O, NewTest.S, NewTest.S(:,1));
    
    pre(:, 1+(i-1)*window_len:i*window_len) = pre1;
    cc(:,i) = cc1;
    
    %Get new traing data
    NewTrain.O=[NewTrain.O, NewTest.O];
    NewTrain.O(:,1:window_len)=[];
    NewTrain.S=[NewTrain.S, NewTest.S];
    NewTrain.S(:,1:window_len)=[];
    
    %Training
    para1=Kaltrain(NewTrain);
    %Update parameters
    NewPara.C=NewPara.C .*alpha+para1.C .*(1-alpha);
    NewPara.R=NewPara.R .*beta+para1.R .*(1-beta);
end