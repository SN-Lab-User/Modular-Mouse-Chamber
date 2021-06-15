function mmc_run_setup1()

global setup1

switch setup1.step
    case 'start'
        %run start functions from protocol
        for i=1:length(setup1.protocol(setup1.rep).startfunction)
            eval(setup1.protocol(setup1.rep).startfunction{i});
        end

        %set up timer to check in 0.5 seconds
        setup1.step = 'check';
        timer_function = 'mmc_run_setup1()';
        setup1_timer = timer('TimerFcn', timer_function,'StartDelay',0.5);
        start(setup1_timer);

        %calculate progress of the experiment and update GUI
        progress_text = ['Trial ' num2str(setup1.rep) ' of ' num2str(setup1.protocol(1).reps)];
        app.ProgressTextLabel.Text = progress_text;
        progress = 100*setup1.rep/setup1.protocol(1).reps;
        app.ph.XData = [0 progress progress 0]; 
        drawnow %update graphics    

    case 'check'
        end_cond=0;
        
        %check if duration condition is reached
        if etime(clock, setup1.starttime)>=setup1.protocol(setup1.rep).endduration
            end_cond=1;
        end
        
        %check if poke condition is reached
        setup1.controller = mmc_read_serial(setup1.controller);
        for i = length(setup1.controller.log)
            if etime(clock, datevec(setup1.controller.log(i).datenum))>0
                if strcmp(setup1.controller.log(i).commandname,'sensor read')
                    if setup1.controller.log(i).sensor==setup1.protocol(setup1.rep).endpoke
                        end_cond=1;
                    end
                end
            end
        end
        
        if end_cond==1
            setup1.step = 'end';
            mmc_run_setup1();
        else
            %set up timer to check in 0.5 seconds
            timer_function = 'mmc_run_setup1()';
            setup1_timer = timer('TimerFcn', timer_function,'StartDelay',0.5);
            start(setup1_timer);
        end
        
    case 'end'
        %run end functions
        for i=1:length(setup1.protocol(1).endfunction)
            eval(setup1.protocol(1).endfunction{i});
        end
       
        %increment reps
        setup1.rep = setup1.rep+1;

        %start next trial, or end experiment
        if setup1.rep>setup1.protocol(1).reps %end experiment
            %calculate progress of the experiment and update GUI
            progress_text = 'Experiment complete.';
            app.ProgressTextLabel.Text = progress_text;
            progress = 100;
            app.ph.XData = [0 progress progress 0]; 
            drawnow %update graphics  

            %save everything
            save_dir = [setup1.metadata.timestamp '.mat'];
            experiment = setup1;
            save(save_dir,'experiment');
            
        else %start next trial
            setup1.step = 'start';
            setup1.starttime = clock;
            mmc_run_setup1();
        end
        
end
    