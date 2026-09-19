% ==========================================
% 自动控制原理：根轨迹参数全解析
% 包含：1. 角度求解 2. 分离点求解 3. 虚轴交点求解
% ==========================================
clear; clc;

%% --- 第一张图：方程 1 (角度求解) ---
disp('【1. 角度出射角/入射角求解】');

theta_rad = pi - pi/2 - atan(2/0.5) - atan(2/2) - atan(2/3);
theta_deg = rad2deg(theta_rad);

fprintf('计算结果 (弧度制): %.4f rad\n', theta_rad);
fprintf('计算结果 (角度制): %.4f°\n\n', theta_deg);


%% --- 第二张图：方程 2 (分离点方程求解) ---
disp('【2. 根轨迹分离点特征方程求解】');

syms d;
eq_breakaway = 1/d + 1/(d+1) + 1/(d+3.5) + 1/(d+3+2i) + 1/(d+3-2i) == 0;
d_sols = double(solve(eq_breakaway, d));

tol = 1e-10; 
real_roots = d_sols(abs(imag(d_sols)) < tol);

disp('位于实轴上的根（实数解）为：');
for k = 1:length(real_roots)
    fprintf('d%d = %8.4f\n', k, real(real_roots(k)));
end
disp(' ');


%% --- 第三张图：方程 3 (与虚轴交点 K* 和 w 求解) ---
disp('【3. 特征方程实部与虚部分离求解 (临界稳定点)】');

% 声明实数符号变量 w (即 ω) 和 K_star (即 K*)
% 必须声明为 real，否则 MATLAB 无法正确拆分复数的实虚部
syms w K_star real

% 定义特征方程 D(jw)
% 注意：在 MATLAB 中虚数单位必须写为 1i
D_jw = 1i*w * (1i*w + 1) * (1i*w + 3.5) * (1i*w + 3 + 2i) * (1i*w + 3 - 2i) + K_star;

% 将多项式展开，强制分离实部和虚部
D_jw_expanded = expand(D_jw);
eq_real = real(D_jw_expanded) == 0;
eq_imag = imag(D_jw_expanded) == 0;

disp('提取出的实部方程为:');
disp(eq_real);
disp('提取出的虚部方程为:');
disp(eq_imag);

% 联立求解实部和虚部方程，求取 w 和 K*
sols = solve([eq_real, eq_imag], [w, K_star]);

% 将符号解转换为双精度数值格式
w_vals = double(sols.w);
K_vals = double(sols.K_star);

disp(' ');
disp('求得的全部精确数值解 [ω, K*] 为：');
for k = 1:length(w_vals)
    % 控制工程中，常规 180° 根轨迹要求 K* >= 0
    if K_vals(k) >= 0
        fprintf('解 %d [有效交点]: ω = %7.4f rad/s, K* = %8.4f\n', k, w_vals(k), K_vals(k));
    else
        fprintf('解 %d [非物理交点]: ω = %7.4f rad/s, K* = %8.4f (K*<0，为零度根轨迹交点)\n', k, w_vals(k), K_vals(k));
    end
end
disp('==========================================');