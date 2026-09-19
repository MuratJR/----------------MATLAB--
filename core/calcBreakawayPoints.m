function [breakPoints, breakGains, invalidPoints] = calcBreakawayPoints(num, den, isNeg)
% CALCBREAKAWAYPOINTS 精确求解根轨迹在实轴上的分离点与会合点
%   [breakPoints, breakGains, invalidPoints] = calcBreakawayPoints(num, den, isNeg)
%   数学原理:
%     根据闭环特征方程 D(s) ± K*N(s) = 0 => K = ∓ D(s)/N(s)
%     令 dK/ds = 0 <=> N'(s)D(s) - N(s)D'(s) = 0
%     筛选求得的实数根并代入 K 计算表达式，K > 0 者为有效分离/会合点。

breakPoints = [];
breakGains = [];
invalidPoints = [];

try
    d_num = polyder(num);
    d_den = polyder(den);
    p1 = conv(d_num, den);
    p2 = conv(num, d_den);
    maxL = max(length(p1), length(p2));
    p1 = [zeros(1, maxL - length(p1)), p1];
    p2 = [zeros(1, maxL - length(p2)), p2];
    eq_roots = roots(p1 - p2);
    
    tol = 1e-5;
    real_candidates = eq_roots(abs(imag(eq_roots)) < tol);
    for i = 1:length(real_candidates)
        d = real(real_candidates(i));
        valN = polyval(num, d);
        valD = polyval(den, d);
        if abs(valN) < 1e-12, continue; end
        
        if isNeg
            K_val = -valD / valN;
        else
            K_val = valD / valN;
        end
        
        if K_val > 1e-6
            breakPoints(end+1) = d; %#ok<AGROW>
            breakGains(end+1) = K_val; %#ok<AGROW>
        else
            invalidPoints(end+1) = d; %#ok<AGROW>
        end
    end
catch
end
end
