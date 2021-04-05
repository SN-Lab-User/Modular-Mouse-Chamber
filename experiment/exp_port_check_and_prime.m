%stet experiment parameters
clear mmc
pause(1);
mmc.port = 'COM3'; %serial port for modular-mouse-chamber arduino
vs.port = {'COM4','COM5','COM7','COM6'}; %serial port for displays 1,2,3,4

%open connections to controllers 
mmc.controller = serialport(mmc.port,9600);
vs = arduinoVisComm(vs, 'Connect');

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
while finished==0
    %check for pokes
    while mmc.controller.NumBytesAvailable==0 || read(mmc.controller,1,'uint8')~=10
        pause(0.01);
    end
    tic
    pokedPos = read(mmc.controller,1,'uint8');
    
    %check for 2nd poke within 0.3 s
    while toc<0.3
        if mmc.controller.NumBytesAvailable>0 && read(mmc.controller,1,'uint8')==10 && read(mmc.controller,1,'uint8')~=pokedPos
            finished=1;
        end
        pause(0.01)
    end
            
    if finished==0
        %give a reward at the poked position
        write(mmc.controller, [101, pokedPos], 'uint8');
        
        %display stimulus at poked position
        param = create_stimulus('vertical gratings 1 Hz');
        vs{pokedPos} = arduinoVisComm(vs{pokedPos}, 'Start-Pattern', param);
        
        pause(1);
        
        %stop stimulus at poked position
        vs{pokedPos} = arduinoVisComm(vs{pokedPos}, 'Stop-Pattern');
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
vs = arduinoVisComm(vs, 'Disconnect');
