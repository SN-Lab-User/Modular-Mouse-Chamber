function param = create_stimulus(name)

switch name
    case 'vertical gratings 1 Hz'
        param.patterntype = 1; %1 = square-gratings, 2 = sine-gratings, 3 = flicker
        param.bar1color = [0 0 30]; %RGB color values of bar 1 [R=0-31, G=0-63, B=0-31]
        param.bar2color = [0 0 0]; %RGB color values of bar 2
        param.backgroundcolor = [0 0 15]; %RGB color values of background
        param.barwidth = 20; % width of each bar (pixels) (1 pixel ~= 0.58 degrees)
        param.numgratings = 2; % number of bright/dark bars in grating
        param.angle = 0; % angle of grating (degrees) [0=drifting right, positive angles rotate clockwise]
        param.frequency = 1; % temporal frequency of grating (Hz) [0.1-25]
        param.position = [0, 0]; % x,y position of grating relative to display center (pixels)
        param.predelay = 0; % delay after start command sent before grating pattern begins (s) [0.1-25.5]
        param.duration = 20; % duration that grating pattern is shown (s) [0.1-25.5]
        param.trigger = 0; % tells the teensy whether to wait for an input trigger signal (TTL) to start or not
        
    case 'vertical gratings 8 Hz'
        param.patterntype = 1; %1 = square-gratings, 2 = sine-gratings, 3 = flicker
        param.bar1color = [0 0 30]; %RGB color values of bar 1 [R=0-31, G=0-63, B=0-31]
        param.bar2color = [0 0 0]; %RGB color values of bar 2
        param.backgroundcolor = [0 0 15]; %RGB color values of background
        param.barwidth = 40; % width of each bar (pixels) (1 pixel ~= 0.58 degrees)
        param.numgratings = 4; % number of bright/dark bars in grating
        param.angle = 0; % angle of grating (degrees) [0=drifting right, positive angles rotate clockwise]
        param.frequency = 8; % temporal frequency of grating (Hz) [0.1-25]
        param.position = [0, 0]; % x,y position of grating relative to display center (pixels)
        param.predelay = 0; % delay after start command sent before grating pattern begins (s) [0.1-25.5]
        param.duration = 10; % duration that grating pattern is shown (s) [0.1-25.5]
        param.trigger = 0; % tells the teensy whether to wait for an input trigger signal (TTL) to start or not

    case 'backlight flicker 1.5 Hz'
        param.patterntype = 5; %1 = square-gratings, 2 = sine-gratings, 3 = flicker
        param.bar1color = [0 0 30]; %RGB color values of bar 1 [R=0-31, G=0-63, B=0-31]
        param.bar2color = [0 0 0]; %RGB color values of bar 2
        param.backgroundcolor = [0 0 15]; %RGB color values of background
        param.barwidth = 10; % width of each bar (pixels) (1 pixel ~= 0.58 degrees)
        param.numgratings = 1; % number of bright/dark bars in grating
        param.angle = 0; % angle of grating (degrees) [0=drifting right, positive angles rotate clockwise]
        param.frequency = 1; % temporal frequency of grating (Hz) [0.1-25]
        param.position = [0, 0]; % x,y position of grating relative to display center (pixels)
        param.predelay = 0; % delay after start command sent before grating pattern begins (s) [0.1-25.5]
        param.duration = 10; % duration that grating pattern is shown (s) [0.1-25.5]
        param.trigger = 0; % tells the teensy whether to wait for an input trigger signal (TTL) to start or not

    otherwise
        fprintf(['stimulus name "' name '" not recognized, defaulting to 1 Hz vertical gratings\n']);
        param.patterntype = 1; %1 = square-gratings, 2 = sine-gratings, 3 = flicker
        param.bar1color = [0 0 30]; %RGB color values of bar 1 [R=0-31, G=0-63, B=0-31]
        param.bar2color = [0 0 0]; %RGB color values of bar 2
        param.backgroundcolor = [0 0 15]; %RGB color values of background
        param.barwidth = 40; % width of each bar (pixels) (1 pixel ~= 0.58 degrees)
        param.numgratings = 4; % number of bright/dark bars in grating
        param.angle = 0; % angle of grating (degrees) [0=drifting right, positive angles rotate clockwise]
        param.frequency = 1; % temporal frequency of grating (Hz) [0.1-25]
        param.position = [0, 0]; % x,y position of grating relative to display center (pixels)
        param.predelay = 0; % delay after start command sent before grating pattern begins (s) [0.1-25.5]
        param.duration = 10; % duration that grating pattern is shown (s) [0.1-25.5]
        param.trigger = 0; % tells the teensy whether to wait for an input trigger signal (TTL) to start or not
end
