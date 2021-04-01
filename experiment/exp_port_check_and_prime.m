%stet experiment parameters
clear mmc
pause(1);
mmc.primaryPort = 'COM3';
mmc.displayPorts = {'COM4','COM5','COM7','COM6'}; %ports 1,2,3,4
run_without_app = 1;

%open connections to controllers 
mmc.primarySerial = serialport(mmc.primaryPort,9600);
numDisplayPorts = length(mmc.displayPorts);
for p = 1:numDisplayPorts
    mmc.displaySerial(p) = serialport(mmc.displayPorts{p},9600);
end

%create data and metadata struct
script_path = mfilename('fullpath');
exp_dir = fileparts(script_path);
app_dir = fileparts(exp_dir);
cd(app_dir);

exp.data = [];
if run_without_app==0
    app = run_mmc;
    exp.metadata = app.metadata;
end

finished = 0;
while finished==0
    %check for pokes
    while mmc.primarySerial.NumBytesAvailable==0 || read(mmc.primarySerial,1,'uint8')~=10
        pause(0.01);
    end
    tic
    pokedPos = read(mmc.primarySerial,1,'uint8');
    
    %check for 2nd poke within 0.3 s
    while toc<0.3
        if mmc.primarySerial.NumBytesAvailable>0 && read(mmc.primarySerial,1,'uint8')==10 && read(mmc.primarySerial,1,'uint8')~=pokedPos
            finished=1;
        end
        pause(0.01)
    end
            
    if finished==0
        %give a reward at the poked position
        write(mmc.primarySerial, [101, pokedPos], 'uint8');
        
        %display position number at poked position
        write(mmc.displaySerial(pokedPos), [151 pokedPos], 'uint8');
        %display stimulus at poked position
% % %         vs = teensyComm(vs, 'Start-Pattern', param)
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

%close serial connections
clear mmc

%save exp struct
if run_without_app==0
    save(exp.metadata.savedir,'exp');
end
