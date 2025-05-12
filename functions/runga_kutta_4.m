function x = runga_kutta_4(state, t, h, p_i, V_i, C_d, m, T_i, df, h_b, lat0, lon0)
    x = zeros(length(t), length(state));
    x(1, :) = state;

     hWait = waitbar(0, 'Running Runge-Kutta Simulation...');
try
    for i = 1:length(t)
        offset = seconds(t(i));
        d = '2025-04-27 14:30:00';
        unix = convertTo(datetime(d,'InputFormat','yyyy-MM-dd HH:mm:ss')+offset,'posixtime');
        ta = unix;
        k_1 = EOM(      ta,           x(i, :)', p_i, V_i, C_d, m, T_i, df, lat0, lon0);
        k_2 = EOM(ta + h/2, x(i, :)' + h*k_1/2, p_i, V_i, C_d, m, T_i, df, lat0, lon0);
        k_3 = EOM(ta + h/2, x(i, :)' + h*k_2/2, p_i, V_i, C_d, m, T_i, df, lat0, lon0);
        k_4 = EOM(  ta + h,   x(i, :)' + h*k_3, p_i, V_i, C_d, m, T_i, df, lat0, lon0);
        
        phi = (k_1 + 2*k_2 + 2*k_3 + k_4)/6;

        x(i+1, :) = x(i, :) + phi';
        
         waitbar(i / length(t), hWait, sprintf('Simulating step %d of %d', i, length(t)));

        % Check for balloon burst
        if (h_b-x(i,3)) < 0
            disp("Balloon Burst!")
            x = x(1:i, :); % Remove points after burst
            close(hWait)
            break
        end

    end
catch ME
    rethrow(ME)
end
end