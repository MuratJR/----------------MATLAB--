% ==========================================
% 自动控制原理：含有原点重极点的根轨迹绘制
% ==========================================
clear; clc; close all;

% 1. 传递函数定义
% 开环传递函数 G(s)H(s) = K^*(1+2s) / [s^2(s+2)(s+5)]
% 为了使用 rlocus 函数，我们将其化为标准形式：
% G(s)H(s) = 2K^*(s+0.5) / [s^2(s+2)(s+5)]
% 我们令等效增益 K_eq = 2K^*，绘制 K_eq 从 0 变到无穷的轨迹

num = [1, 0.5]; % 分子多项式：s + 0.5
% 分母多项式展开：s^2 * (s+2) * (s+5) = s^4 + 7s^3 + 10s^2
den = [1, 7, 10, 0, 0]; 

% 建立开环传递函数模型
sys = tf(num, den);

% 2. 绘制图表
figure('Name', '引入PD控制后的系统根轨迹', 'Color', 'w', 'Position', [100, 100, 1100, 550]);

% === 子图1：全局根轨迹视角 ===
subplot(1, 2, 1);
rlocus(sys);
title('全局根轨迹 (等效增益 K_{eq})', 'FontSize', 12);
hold on;
% 标注特征点
plot(0, 0, 'kx', 'MarkerSize', 10, 'LineWidth', 2); % 原点极点
plot(-2, 0, 'kx', 'MarkerSize', 10, 'LineWidth', 2);
plot(-5, 0, 'kx', 'MarkerSize', 10, 'LineWidth', 2);
plot(-0.5, 0, 'ko', 'MarkerSize', 8, 'LineWidth', 2); % 引入的零点
grid on;
axis([-7 3 -4 4]); % 设定全局坐标系范围

% === 子图2：原点局部放大视角 ===
subplot(1, 2, 2);
rlocus(sys);
title('原点处局部放大图 (观察起步趋势)', 'FontSize', 12);
hold on;
plot(0, 0, 'kx', 'MarkerSize', 12, 'LineWidth', 2); 
plot(-0.5, 0, 'ko', 'MarkerSize', 8, 'LineWidth', 2);

% 绘制虚轴和实轴参考线
yline(0, 'k-', 'Alpha', 0.3);
xline(0, 'k-', 'Alpha', 0.3);
grid on;
axis([-1 0.5 -1.5 1.5]); % 极限聚焦原点附近

% 添加文字标注说明出射角
text(0.1, 0.3, '\leftarrow \theta_d = +90^\circ', 'Color', 'b', 'FontSize', 11, 'FontWeight', 'bold');
text(0.1, -0.3, '\leftarrow \theta_d = -90^\circ', 'Color', 'b', 'FontSize', 11, 'FontWeight', 'bold');

sgtitle('改变反馈通路 H(s)=1+2s 后的闭环根轨迹', 'FontSize', 14, 'FontWeight', 'bold');