function x = runga_kutta_4(state, t, h, p_i, V_i, C_d, m, T_i, wind, h_b, lat0, lon0)
    x = zeros(length(t), length(state));
    x(1, :) = state;
try
    for i = 1:t(end)
        k_1 = EOM(      t(i),           x(i, :)', p_i, V_i, C_d, m, T_i, wind, lat0, lon0);
        k_2 = EOM(t(i) + h/2, x(i, :)' + h*k_1/2, p_i, V_i, C_d, m, T_i, wind, lat0, lon0);
        k_3 = EOM(t(i) + h/2, x(i, :)' + h*k_2/2, p_i, V_i, C_d, m, T_i, wind, lat0, lon0);
        k_4 = EOM(  t(i) + h,   x(i, :)' + h*k_3, p_i, V_i, C_d, m, T_i, wind, lat0, lon0);
        
        phi = (k_1 + 2*k_2 + 2*k_3 + k_4)/6;

        x(i+1, :) = x(i, :) + phi';

        % Check for balloon burst
        if (h_b-x(i,3)) < 0
            disp("Balloon Burst!")
            x = x(1:i, :); % Remove points after burst
            break
        end

    end
catch ME
    rethrow(ME)
end
end