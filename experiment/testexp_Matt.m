%stet experiment parameters
clear mmc
mmc.primaryPort = 'COM3';
mmc.displayPorts = {'COM4','COM5','COM6'};
rewardPos = 3;
startPos = 0;
num_trials = 30;
num_channels = 6; %number of data channels

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

exp.data = nan(num_trials,num_channels);
app = run_mmc;
exp.metadata = app.metadata;
           
% run experiment
for t = 1:num_trials
    %send stimulus to display at start and reward position
    write(mmc.displaySerial(startPos+1), [100, 0], 'uint8');
    write(mmc.displaySerial(rewardPos+1), [100, 0], 'uint8');

    %wait for poke at either reward or start position
    while mmc.primarySerial.NumBytesAvailable==0 || read(mmc.primarySerial,1,'uint8')~=10
        pause(0.01);
    end
    
    %give a reward at the poked position
    pokedPos = read(mmc.primarySerial,1,'uint8');
    write(mmc.primarySerial, [101, pokedPos], 'uint8');
   
    %send stimulus to reward position
    write(mmc.controller, [100, 3], 'uint8');
    
    %wait for poke at reward position (until timeout)
    while rewardPoke==0 && pokeDelay < 10 
        pokeDelay = toc;
        if mmc.controller.NumBytesAvailable>0 
            pokeLoc = read(mmc.controller,1,'uint8');
            if pokeLoc~=10
               exp.data.choicetime = datestr('now');
               exp.data.choiceLoc = pokeLoc;
               if pokeLoc == 13
                 write(mmc.controller, [101, 3], 'uint8');
               end
               rewardPoke=1;
            end
        end
        delay(0.01);
    end
    
    %calculate progress of the experiment and update GUI
    progress_text = ['Trial ' num2str(t) ' of ' num2str(num_trials)];
    app.ProgressTextLabel.Text = progress_text;
    progress = 100*t/num_trials;
    app.ph.XData = [0 progress progress 0]; 
    drawnow %update graphics    
end 
 
    %trial is now complete and can restart
    %in data struct, save timestamp at cue poke, timestamp at reward poke,
    %cue location, reward location, anything else? timestamp at incorrect poke(s)?


%save exp struct
save(exp.metadata.savedir,'exp');
