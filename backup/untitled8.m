% ==========================================
% 补充计算：精确求解实轴分离点
% ==========================================
clear; clc;

% 定义分子分母多项式 (已展开)
num = [1, 4, 4]; % (s+2)^2
den = [1, 111.5, 1171.25, 2187.5, 6250]; % (s+10)(s+100)(s^2+1.5s+6.25)

% 求导: P'(s) 和 Q'(s)
der_num = polyder(num);
der_den = polyder(den);

% 构造分离点方程: P'(s)Q(s) - P(s)Q'(s) = 0
term1 = conv(der_den, num);
term2 = conv(den, der_num);

% 补齐阶数对齐后相减
len = max(length(term1), length(term2));
term1 = [zeros(1, len-length(term1)), term1];
term2 = [zeros(1, len-length(term2)), term2];
eq_break = term1 - term2;

% 求取分离点方程的所有根
s_break = roots(eq_break);
disp('分离点方程的所有根为:');
disp(s_break);

% 筛选位于实轴根轨迹 [-100, -10] 区间内的有效分离点
tol = 1e-6;
valid_s = [];
for i = 1:length(s_break)
    s_val = s_break(i);
    % 判断：虚部为0，且在 -100 到 -10 之间
    if abs(imag(s_val)) < tol && real(s_val) <= -10 && real(s_val) >= -100
        valid_s = [valid_s, real(s_val)];
    end
end

% 输出最终结果并计算该点处的临界增益
if ~isempty(valid_s)
    breakaway_point = valid_s(1);
    % 利用幅值条件计算 K (K = -D(s)/N(s))
    K_break = -polyval(den, breakaway_point) / polyval(num, breakaway_point);

    fprintf('\n>>> 筛选出的有效实数分离点为: s = %.4f <<<\n', breakaway_point);
    fprintf('>>> 此时对应的系统总增益为: K = %.4f <<<\n', K_break);
else
    disp('未找到实轴上 [-100, -10] 区间的有效分离点。');
end