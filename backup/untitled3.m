% ==========================================
% 自动控制原理：复杂系统 180° 根轨迹综合求解与绘制
% ==========================================
clear; clc; close all;

%% 1. 系统定义
% 定义开环极点
p1 = 0;
p2 = -1;
p3 = -3.5;
p4 = -3 + 2i;
p5 = -3 - 2i;
poles = [p1, p2, p3, p4, p5];
zeros_sys = []; % 无开环零点

% 构造零极点模型 (开环增益设为 1)
sys = zpk(zeros_sys, poles, 1);

%% 2. 求分离点 (Breakaway Points)
disp('【1. 分离点求解】');
% 分离点满足 dK/ds = 0。对于只有极点的系统，等价于极点多项式求导为 0
% 获取分母多项式 D(s) 的系数
den_coeffs = poly(poles); 
% 对 D(s) 求导，得到 dD(s)/ds
der_coeffs = polyder(den_coeffs); 
% 求导数多项式的根
d_sols = roots(der_coeffs);

% 提取实数根 (剔除由于计算误差产生的极小虚部)
tol = 1e-6;
real_break_points = real(d_sols(abs(imag(d_sols)) < tol));

% 输出实数分离点
for i = 1:length(real_break_points)
    bp = real_break_points(i);
    % 根据奇数法则，判断该点是否在实轴根轨迹上 [-1, 0] 或 [-inf, -3.5]
    if (bp < 0 && bp > -1) || (bp < -3.5)
        fprintf('有效分离点: d = %8.4f\n', bp);
    else
        fprintf('无效分离点 (属于零度根轨迹): d = %8.4f\n', bp);
    end
end
disp(' ');

%% 3. 求复数极点的出射角 (Departure Angle)
disp('【2. 出射角求解 (以 p = -3+j2 为例)】');
target_p = p4; % 选定目标复数极点
other_p = [p1, p2, p3, p5]; % 其他极点集合

sum_angles = 0;
% 计算其他极点到目标极点的相角之和 (MATLAB 的 angle 函数自动处理象限)
for i = 1:length(other_p)
    sum_angles = sum_angles + angle(target_p - other_p(i)); 
end

% 运用出射角公式：θ = 180° - Σ相角
theta_d_rad = pi - sum_angles;
theta_d_deg = rad2deg(theta_d_rad);

% 归一化角度到 -180° ~ 180° 范围内
theta_d_deg = mod(theta_d_deg + 180, 360) - 180; 

fprintf('极点 -3+j2 的出射角为: %8.2f°\n\n', theta_d_deg);

%% 4. 求与虚轴的交点 (Imaginary Axis Intersections)
disp('【3. 与虚轴的交点 (临界稳定点)】');
% 特征方程展开后为: s^5 + 10.5s^4 + 43.5s^3 + 79.5s^2 + 45.5s + K = 0
% 令 s = jw，分离虚部方程: w^5 - 43.5w^3 + 45.5w = 0 
% 提出 w 后，解多项式方程: w^4 - 43.5w^2 + 45.5 = 0
imag_part_coeffs = [1, 0, -43.5, 0, 45.5]; 
w_sols = roots(imag_part_coeffs);

% 筛选正实数 w (即物理意义上的角频率)
w_real = real(w_sols(abs(imag(w_sols)) < tol & real(w_sols) > tol));

for i = 1:length(w_real)
    w = w_real(i);
    % 代入实部方程求 K*: 10.5w^4 - 79.5w^2 + K = 0  =>  K = -10.5w^4 + 79.5w^2
    K_star = -10.5*w^4 + 79.5*w^2;
    if K_star >= 0
        fprintf('有效交点: w = ±%.4f rad/s, 此时临界增益 K* = %.4f\n', w, K_star);
    end
end
disp('==========================================');

%% 5. 绘制根轨迹图
figure('Name', '系统闭环根轨迹', 'Color', 'w', 'Position', [100, 100, 700, 600]);
rlocus(sys);
title('系统 G(s) 闭环根轨迹图', 'FontSize', 14);

hold on;
% 标注原开环极点
plot(real(poles), imag(poles), 'kx', 'MarkerSize', 10, 'LineWidth', 2);

% 标注有效分离点
plot(-0.4029, 0, 'kp', 'MarkerSize', 12, 'MarkerFaceColor', 'y', 'DisplayName', '有效分离点');

% 标注与虚轴交点
plot(0, 1.0356, 'ks', 'MarkerSize', 10, 'MarkerFaceColor', 'g', 'DisplayName', '虚轴交点');
plot(0, -1.0356, 'ks', 'MarkerSize', 10, 'MarkerFaceColor', 'g');

% 格式化图表
grid on;
ax = gca;
ax.XAxisLocation = 'origin';
ax.YAxisLocation = 'origin';
axis([-5 2 -4 4]); % 限定坐标轴范围以便观察全貌
xlabel('实轴 (Real Axis)', 'Position', [1.8, -0.3], 'FontSize', 11);
ylabel('虚轴 (Imaginary Axis)', 'Position', [-0.3, 3.8], 'FontSize', 11);
legend('根轨迹', '开环极点', '分离点 (-0.40)', '虚轴交点 (±j1.04)', 'Location', 'southeast', 'FontSize', 11);
hold off;