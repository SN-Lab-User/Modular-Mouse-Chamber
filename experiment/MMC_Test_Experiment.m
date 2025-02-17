%connect to displays and controller
[controller, display1, display2, display3, display4] = mmc_connect();

%%
%show a pattern on display 1
mmc_send_command(display1, 'Display-rectangle', 'middle rectangle');
pause(5); %wait 5 seconds
mmc_send_command(display1, 'Stop');
pause(1);
display1 = mmc_read_serial(display1);

%% 
%show a custom rectangle on display 1
pattern.color1 = [0 0 1];
pattern.backgroundcolor = [0 0 0];
pattern.position = [160 120 120 120];
pattern.frequency = 1; 
pattern.duration = 0;
pattern.predelay = 0;
pattern.trigger = 0;

mmc_send_command(display1, 'Display-rectangle', pattern);
pause(5); %wait 5 seconds
mmc_send_command(display1, 'Stop');
pause(1); %wait 5 seconds
display1 = mmc_read_serial(display1);