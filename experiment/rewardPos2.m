global exp

%set experiment parameters
rewardPos = 2;
% startPos = 1;
num_trials = 30;
num_channels = 6; %number of data channels
trial_timeout = 30; 

%connect to setup
[controller, display1, display2, display3, display4] = mmc_connect();

%create data and metadata struct
exp.data = nan(num_trials,num_channels);
           
% run experiment
expstarttime = clock;
trial_timestamps = nan(num_trials,2);

for t = 1:num_trials
    if exp.stop==0
        trial_timestamps(t,1) = now; %log pre trial start timestamp
        
        %calculate progress of the experiment and update GUI
        progress_text = ['Trial ' num2str(t) ' of ' num2str(num_trials)];
        app.ProgressTextLabel.Text = progress_text;
        progress = 100*t/num_trials;
        app.ph.XData = [0 progress progress 0]; 
        drawnow %update graphics    

        pretrialstarttime = clock;

        %send stimulus to display at start position
        mmc_send_command(display1, 'Display-rectangle', 'middle rectangle');

        %read sensors indefinitely
        param.duration = 0; 
        mmc_send_command(controller, 'Read-sensors', param);

        %check for pokes
        end_cond = 0;
        while end_cond==0
            controller = mmc_read_serial(controller);

            for i = length(controller.log)
                if etime(datevec(controller.log(i).datenum), pretrialstarttime)>0
                    if strcmp(controller.log(i).commandname,'sensor read')
                        if controller.log(i).sensor==1
                            end_cond = 1;
                            give_reward = 1;
                        end
                    end
                end
            end
            if exp.stop==1
                end_cond = 1;
                stop_trial = t;
            end
        end

        %after port 1 poke: stop display and sensor reads; give reward
        mmc_send_command(display1, 'Stop');
        mmc_send_command(controller, 'Stop');
        if give_reward==1
            param.duration = 1; param.relay = 1; 
            mmc_send_command(controller, 'Toggle-relay', param);
        end

        trialstarttime = clock;
    end
    
    if exp.stop==0
        trial_timestamps(t,2) = now; %log reward trial start timestamp
        %send stimulus to display at all possible reward position
        mmc_send_command(display2, 'Display-rectangle', 'middle rectangle');
        mmc_send_command(display3, 'Display-rectangle', 'middle rectangle');
        mmc_send_command(display4, 'Display-rectangle', 'middle rectangle');

        %read sensors indefinitely
        param.duration = 0; 
        mmc_send_command(controller, 'Read-sensors', param);

        %check for pokes or trial
        end_cond = 0;
        give_reward = 0;
        while end_cond==0
            controller = mmc_read_serial(controller);

            for i = length(controller.log)
                if etime(datevec(controller.log(i).datenum),trialstarttime)>0
                    if strcmp(controller.log(i).commandname,'sensor read')
                        if controller.log(i).sensor==rewardPos
                            end_cond = 1;
                            give_reward = 1;
                        end
                    end
                end
            end
            if etime(clock,trialstarttime)>trial_timeout
                end_cond = 1;
            end
        end

        %after port 3 poke or timeout: stop display and sensor reads; give reward
        mmc_send_command(display2, 'Stop');
        mmc_send_command(display3, 'Stop');
        mmc_send_command(display4, 'Stop');
        mmc_send_command(controller, 'Stop');
        if give_reward==1
            param.duration = 1; param.relay = rewardPos; 
            mmc_send_command(controller, 'Toggle-relay', param);
        end
    else
        progress_text = ['Experiment stopped at trial ' num2str(stop_trial)];
        app.ProgressTextLabel.Text = progress_text;
        progress = 100*stop_trial/num_trials;
        app.ph.XData = [0 progress progress 0]; 
        drawnow %update graphics    
    end
end 
 
%save exp struct
exp.controller = controller;
exp.display1 = display1;
exp.display2 = display2;
exp.display3 = display3;
exp.display4 = display4;
exp.trial_timestamps = trial_timestamps;
save(exp.metadata.savedir,'exp');
