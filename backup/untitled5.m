% ==========================================
% 自动控制原理：正反馈与负反馈根轨迹全面对比分析
% ==========================================
clear; clc; close all;

%% 1. 系统定义
% 开环传递函数 G(s) = K*(s+1) / [s^2(s+2)(s+4)]
num = [1, 1];
% 分母展开: s^2*(s^2+6s+8) = s^4 + 6s^3 + 8s^2
den = [1, 6, 8, 0, 0]; 
sys = tf(num, den);

disp('===============================================');
disp('【1. 实轴分离点/会合点求解】');
% 根据 dK/ds = 0 等价于 N'(s)D(s) - N(s)D'(s) = 0
num_der = polyder(num);
den_der = polyder(den);

% 补齐多项式长度以便相减
p1 = conv(num_der, den);
p2 = conv(num, den_der);
len = max(length(p1), length(p2));
p1 = [zeros(1, len-length(p1)), p1];
p2 = [zeros(1, len-length(p2)), p2];

eq_break = p1 - p2; 
d_sols = roots(eq_break);

% 提取实数解
tol = 1e-6;
real_d = real(d_sols(abs(imag(d_sols)) < tol));

for i = 1:length(real_d)
    d = real_d(i);
    % 利用幅值条件计算增益 K = |D(d)/N(d)|
    % 通过极性判断属于正反馈还是负反馈
    % 负反馈特征方程：D(s) + K*N(s) = 0 => K_nf = -D(s)/N(s)
    K_nf_val = -polyval(den, d) / polyval(num, d);
    
    if abs(K_nf_val) < tol
        fprintf('d = %8.4f ---> 起点 (原点重极点), K* = 0\n', d);
    elseif K_nf_val > 0
        fprintf('d = %8.4f ---> 属于【负反馈】根轨迹的分离/会合点, K* = %.4f\n', d, K_nf_val);
    else
        fprintf('d = %8.4f ---> 属于【正反馈】根轨迹的分离/会合点, K* = %.4f\n', d, abs(K_nf_val));
    end
end
disp(' ');

%% 2. 求与虚轴的交点 (临界稳定点)
disp('【2. 虚轴交点求解 (临界稳定状态)】');
syms w K_star real
D_jw = (1i*w)^4 + 6*(1i*w)^3 + 8*(1i*w)^2;
N_jw = (1i*w) + 1;

% --- 负反馈 (180° 根轨迹) ---
disp('>>> 负反馈系统 (180° 根轨迹) <<<');
eq_nf = D_jw + K_star * N_jw;
sols_nf = solve([real(expand(eq_nf))==0, imag(expand(eq_nf))==0], [w, K_star]);
w_nf = double(sols_nf.w);
K_nf = double(sols_nf.K_star);

valid_nf = false;
for i = 1:length(w_nf)
    if K_nf(i) > tol
        fprintf('交点: w = ±%.4f rad/s, 临界增益 K* = %.4f\n', abs(w_nf(i)), K_nf(i));
        valid_nf = true;
    end
end
if ~valid_nf
    disp('无大于0的有效 K* 虚轴交点。');
end
disp(' ');

% --- 正反馈 (0° 根轨迹) ---
disp('>>> 正反馈系统 (0° 根轨迹) <<<');
eq_pf = D_jw - K_star * N_jw; % 正反馈特征方程为 1 - G(s) = 0
sols_pf = solve([real(expand(eq_pf))==0, imag(expand(eq_pf))==0], [w, K_star]);
w_pf = double(sols_pf.w);
K_pf = double(sols_pf.K_star);

valid_pf = false;
for i = 1:length(w_pf)
    if K_pf(i) > tol
        fprintf('交点: w = ±%.4f rad/s, 临界增益 K* = %.4f\n', abs(w_pf(i)), K_pf(i));
        valid_pf = true;
    end
end
if ~valid_pf
    disp('无大于0的有效 K* 虚轴交点 (除原点外始终在右半平面)。');
end
disp('===============================================');

%% 3. 绘制根轨迹图
figure('Name', '系统正/负反馈根轨迹对比', 'Color', 'w', 'Position', [100, 100, 1000, 500]);

% 负反馈图
subplot(1, 2, 1);
rlocus(sys);
title('负反馈系统 (180° 根轨迹)', 'FontSize', 14);
axis([-6 2 -4 4]);
grid on;
xline(0, 'k-', 'Alpha', 0.5); yline(0, 'k-', 'Alpha', 0.5);

% 正反馈图
subplot(1, 2, 2);
rlocus(-sys); % 传递函数前加负号，MATLAB 会自动绘制 0° 根轨迹 (正反馈)
title('正反馈系统 (0° 根轨迹)', 'FontSize', 14);
axis([-6 2 -4 4]);
grid on;
xline(0, 'k-', 'Alpha', 0.5); yline(0, 'k-', 'Alpha', 0.5);

sgtitle('开环传递函数 G(s) = K^*(s+1) / [s^2(s+2)(s+4)]', 'FontSize', 16, 'FontWeight', 'bold');