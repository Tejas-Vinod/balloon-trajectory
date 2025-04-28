% Rnunga Kutta 4 implementation
function x = runga_kutta_4(state, t, h, p_i, V_i, C_d, m, T_i, wind, h_b)
    x = zeros(length(t), length(state));
    x(1, :) = state;
    z = state(3);
try
    for i = 1:t(end)
        k_1 = EOM(      t(i),           x(i, :), p_i, V_i, C_d, m, T_i, wind);
        k_2 = EOM(t(i) + h/2, x(i, :)' + h*k_1/2, p_i, V_i, C_d, m, T_i, wind);
        k_3 = EOM(t(i) + h/2, x(i, :)' + h*k_2/2, p_i, V_i, C_d, m, T_i, wind);
        k_4 = EOM(  t(i) + h,   x(i, :)' + h*k_3, p_i, V_i, C_d, m, T_i, wind);
        
        phi = (k_1 + 2*k_2 + 2*k_3 + k_4)/6;

        x(i+1, :) = x(i, :) + phi';

        
        if (h_b-x(3)) < 0
            warning("ballon burst")
            break
        end

    end
catch ME
end
end