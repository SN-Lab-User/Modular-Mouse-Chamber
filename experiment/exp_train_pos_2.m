%stet experiment parameters
clear mmc
clear vs
pause(1);
mmc.port = 'COM3'; %serial port for modular-mouse-chamber arduino
%serial ports for displays 1,2,3,4
vs(1).port = 'COM4';
vs(2).port = 'COM5';
vs(3).port = 'COM7';
vs(4).port = 'COM6'; 
rewardPos = 3;
startPos = 1;
%open connections to controllers 
mmc.controller = serialport(mmc.port,9600);
vs = arduinoVisComm(vs, 'Connect');
vs = arduinoVisComm(vs, 'Backlight-Off');

%create data and metadata struct
script_path = mfilename('fullpath');
exp_dir = fileparts(script_path);
app_dir = fileparts(exp_dir);
cd(app_dir);

exp.data = [];
%check if "run_mmc" app is running
apphandle = findall(0,'Tag','run_mmc');
if isempty(apphandle)
    run_without_app = 1;
else
    run_without_app = 0;
    app = run_mmc;
    exp.metadata = app.metadata;
end

finished = 0;
num_trials = 0;
while finished==0
    %check for poke at start pos
    trial_start = 0;
    while trial_start==0
        %show visual cue at startPos
        vs(startPos) = arduinoVisComm(vs(startPos), 'Backlight-On');
        
        while mmc.controller.NumBytesAvailable==0 || read(mmc.controller,1,'uint8')~=10
            pause(0.01);
        end
        pokedPos = read(mmc.controller,1,'uint8');
        if pokedPos==startPos
            %reward startPos
            write(mmc.controller, [101, startPos], 'uint8');
            trial_start = 1;
        end
    end
    vs(startPos) = arduinoVisComm(vs(startPos), 'Backlight-Off');
        
    tic
    num_trials = num_trials+1;
    
    %check for 2nd poke within 0.25 s (to manually end session early)
    while toc<0.25
        if mmc.controller.NumBytesAvailable>0 && read(mmc.controller,1,'uint8')==10 && read(mmc.controller,1,'uint8')~=pokedPos
            finished=1;
        end
        pause(0.01)
    end
            
    if finished==0
        trial_stop = 0;
        %show visual cue at rewardPos
        vs(rewardPos) = arduinoVisComm(vs(rewardPos), 'Backlight-On');
        while trial_stop==0
            while mmc.controller.NumBytesAvailable==0 || read(mmc.controller,1,'uint8')~=10
                pause(0.01);
            end
            pokedPos = read(mmc.controller,1,'uint8');
            if pokedPos==rewardPos
                %reward startPos
                write(mmc.controller, [101, rewardPos], 'uint8');
                trial_stop = 1;
            end
        end
        
        %stop stimulus at reward position
        vs(rewardPos) = arduinoVisComm(vs(rewardPos), 'Backlight-Off');
    end
    
    % update GUI
    if finished==1
        progress_text = 'experiment ended';
    else
        progress_text = ['Position ' num2str(pokedPos) ' poked and rewarded'];
    end
    if run_without_app==0
        app.ProgressTextLabel.Text = progress_text;
        progress = 100*finished;
        app.ph.XData = [0 progress progress 0]; 
        drawnow %update graphics 
    else
        fprintf([progress_text '\n']);
    end
end 
 
pause(1);

%save exp struct
if run_without_app==0
    save(exp.metadata.savedir,'exp','vs','mmc');
end

%close serial connections
clear mmc
clear vs
