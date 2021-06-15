function testFun(timer_function, start_time, start_delay)
    elapsed_time = etime(clock, start_time);
    if elapsed_time>3
        disp('finished');
    else
        disp('still_waiting')
        test_timer = timer('TimerFcn', timer_function,'StartDelay',start_delay);
        start(test_timer);
    end
end