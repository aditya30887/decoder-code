classdef lms_gamma_bmi_model < handle
    
    % model of the form
    %   vel = W*(rate_history - mu)
    %       = W*rate_history + b
    properties
        W
        b
        A
        B
        x
        n
        p
        bin
        prev_pos
        nunits
        lrate
        reg_factor
        first_ts
        cart_pos
    end
    
    methods
        function obj = lms_gamma_bmi_model(nunits, bin, n_gamma_taps, gamma)
            [A,B] = getGammaSS(n_gamma_taps, gamma);
            obj.A = A; % note, these are the system mats for a single input
            obj.B = B;
            obj.n = size(A,1);
            obj.bin = bin;
            obj.x = zeros(n_gamma_taps, nunits);
            
            obj.nunits = nunits;
            obj.b = [0;0;0];
            obj.W = zeros(3, n_gamma_taps*nunits);
            obj.prev_pos = [0;0;0];
            
            obj.reg_factor = 1e-7;
            obj.lrate = 0.5e-4;
            
            
        end
        
        function [pos_pred] = predict_and_step(obj, rate)
            % update state
            obj.step_state(rate);
            pos_pred = obj.W*obj.x(:) + obj.b;
        end
        
        function [] = step_state(obj, rate)
            obj.x = obj.A*obj.x + obj.B*rate';
            
            
        end
        
        function [] = train_batch(obj, cart_pos, rates)
            disp('batch training position model');
            [N,nunits] = size(rates);
            n = obj.n;
            X = zeros(N,n*nunits);
            for i = 1:nunits
                X(:, (i-1)*n+1:i*n ) = ltitr(obj.A, obj.B, rates(:, i));
            end
            
            
            wt = myridge([ones(N,1), X],cart_pos, obj.reg_factor);
            cart_pos_pred = [ones(N,1), X]*wt;
            
            W = wt';
            
            obj.W = W(:, 2:end);
            obj.b = W(:, 1);
            
            fprintf('batch training: rvalue = %f\n',   rval(cart_pos, cart_pos_pred));
            pause(1.0);
            
        end
        
        function [pos_pred] = get_pos_pred(obj)
            pos_pred = obj.W*obj.x(:) + obj.b;
        end
        
        function [] = update(obj, rate, pos)
            obj.step_state(rate);
            
            pos_pred = obj.W*obj.x(:) + obj.b;
            
            e = pos_pred - pos';
            gW =  e*obj.x(:)';
            gb =  e;
            
            obj.W = obj.W - obj.lrate*gW - obj.reg_factor*obj.W;
            obj.b = obj.b - obj.lrate*gb - obj.reg_factor*obj.b;
            
            %            imagesc(obj.W);
            %            pause(0.001);
            
        end
        
    end
    
end