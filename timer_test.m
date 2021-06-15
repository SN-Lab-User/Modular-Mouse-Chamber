start_time = clock;

timer_function = 'testFun(timer_function, start_time, start_delay)';
start_delay = 0.5;
test_timer = timer('TimerFcn', timer_function,'StartDelay',start_delay);
start(test_timer);
