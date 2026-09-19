function [w_cross, K_crit] = calcImagCrossings(num, den, isNeg)
% CALCIMAGCROSSINGS 求解根轨迹与虚轴交点及临界稳定开环增益
%   [w_cross, K_crit] = calcImagCrossings(num, den, isNeg)
%   数学原理:
%     令特征方程 D(jω) ± K*N(jω) = 0
%     令其实部与虚部分别为 0，联立求解穿越频率 ω > 0 与临界增益 K_crit > 0。

w_cross = [];
K_crit = [];

try
    syms w K real
    s_val = 1i * w;
    D_s = poly2sym(den, s_val);
    N_s = poly2sym(num, s_val);
    if isNeg
        char_eq = D_s + K * N_s;
    else
        char_eq = D_s - K * N_s;
    end
    eq_r = real(expand(char_eq)) == 0;
    eq_i = imag(expand(char_eq)) == 0;
    sols = solve([eq_r, eq_i], [w, K]);
    w_vals = double(sols.w);
    k_vals = double(sols.K);
    for i = 1:length(w_vals)
        if k_vals(i) > 1e-5 && w_vals(i) > 1e-5
            w_cross(end+1) = w_vals(i); %#ok<AGROW>
            K_crit(end+1) = k_vals(i); %#ok<AGROW>
        end
    end
catch
end
end
