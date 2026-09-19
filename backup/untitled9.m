% =========================================================================
% 自动控制原理：频率特性与系统校正全面可视化 (含波特图对比与Nyquist图)
% =========================================================================
clear; clc; close all;

disp('======================================================');
disp('开启频域校正全景仪表盘...');
disp('正在生成 4 种典型校正方案的 Bode对比、Nyquist图 与 阶跃响应...');
disp('======================================================');

%% 案例 1：串联超前校正 (Lead Compensation)
s = tf('s');
G1 = 10 / (s * (0.1*s + 1) * (0.05*s + 1)); % 原系统
a1 = 4; T1 = 0.05; 
Gc1 = (1 + a1*T1*s) / (1 + T1*s);           % 超前校正装置

figure('Name', '案例1：超前校正 (Lead)', 'Color', 'w', 'Position', [50, 50, 1100, 650]);
% [1] 波特图综合对比 (左侧半屏)
subplot(2, 2, [1, 3]);
bode(G1, 'b-', Gc1, 'k--', Gc1*G1, 'r-', {0.1, 1000}); 
title('Bode 图综合对比 (幅值与相角)');
legend('原系统 G(s)', '校正装置 G_c(s) (提供正相角)', '校正后 G_c(s)G(s)', 'Location', 'southwest');
grid on;

% [2] 原系统 Nyquist 图 (右上角)
subplot(2, 2, 2);
nyquist(G1);
title('原系统 Nyquist 图');
axis([-2 0.5 -1.5 1.5]); % 限制坐标轴以便观察 (-1, j0) 点
grid on;

% [3] 阶跃响应对比 (右下角)
subplot(2, 2, 4);
step(feedback(G1, 1), 'b-', feedback(Gc1*G1, 1), 'r-');
title('闭环阶跃响应对比');
legend('校正前', '校正后', 'Location', 'northeast');
grid on;


%% 案例 2：串联迟后校正 (Lag Compensation)
G2 = 50 / (s * (0.1*s + 1) * (0.2*s + 1));  % 原系统 (增益极大)
b2 = 10; T2 = 4; 
Gc2 = (1 + T2*s) / (1 + b2*T2*s);           % 迟后校正装置

figure('Name', '案例2：迟后校正 (Lag)', 'Color', 'w', 'Position', [100, 100, 1100, 650]);
subplot(2, 2, [1, 3]);
bode(G2, 'b-', Gc2, 'k--', Gc2*G2, 'r-', {0.01, 100});
title('Bode 图综合对比 (幅值与相角)');
legend('原系统 G(s)', '校正装置 G_c(s) (高频幅值衰减)', '校正后 G_c(s)G(s)', 'Location', 'southwest');
grid on;

subplot(2, 2, 2);
nyquist(G2);
title('原系统 Nyquist 图 (穿越了 -1+j0 点左侧，不稳定)');
axis([-2 1 -2 2]); 
grid on;

subplot(2, 2, 4);
step(feedback(G2, 1), 10, 'b-'); hold on;
step(feedback(Gc2*G2, 1), 10, 'r-');
title('闭环阶跃响应对比');
legend('校正前 (发散)', '校正后 (稳定)', 'Location', 'northeast');
grid on;


%% 案例 3：迟后-超前校正 (Lag-Lead Compensation)
G3 = 100 / (s * (s + 1) * (0.2*s + 1));     % 原系统
Gc3_lag = (1 + 10*s) / (1 + 100*s);
Gc3_lead = (1 + 2*s) / (1 + 0.2*s);
Gc3 = Gc3_lag * Gc3_lead;                   % 迟后-超前校正装置

figure('Name', '案例3：迟后-超前校正 (Lag-Lead)', 'Color', 'w', 'Position', [150, 150, 1100, 650]);
subplot(2, 2, [1, 3]);
bode(G3, 'b-', Gc3, 'k--', Gc3*G3, 'r-', {0.001, 1000});
title('Bode 图综合对比 (幅值与相角)');
legend('原系统 G(s)', '校正装置 G_c(s) (V型幅值特性)', '校正后 G_c(s)G(s)', 'Location', 'southwest');
grid on;

subplot(2, 2, 2);
nyquist(G3);
title('原系统 Nyquist 图');
axis([-3 1 -3 3]); 
grid on;

subplot(2, 2, 4);
step(feedback(G3, 1), 5, 'b-'); hold on;
step(feedback(Gc3*G3, 1), 5, 'r-');
title('闭环阶跃响应对比');
legend('校正前 (发散)', '校正后 (稳定且快速)', 'Location', 'northeast');
grid on;


%% 案例 4：PID 控制 (频域视角)
G4 = 1 / ((s + 1) * (s + 2) * (s + 3));     % 原系统 (0型系统，有稳态误差)
Kp = 30; Ki = 20; Kd = 10;
Gc4 = Kp + Ki/s + Kd*s;                     % PID 控制器

figure('Name', '案例4：PID 校正', 'Color', 'w', 'Position', [200, 200, 1100, 650]);
subplot(2, 2, [1, 3]);
bode(G4, 'b-', Gc4, 'k--', Gc4*G4, 'r-', {0.01, 100});
title('Bode 图综合对比 (幅值与相角)');
legend('原系统 G(s)', '校正装置 PID (积分低频抬升，微分高频超前)', '校正后', 'Location', 'southwest');
grid on;

subplot(2, 2, 2);
nyquist(G4);
title('原系统 Nyquist 图');
axis([-0.05 0.2 -0.1 0.1]); 
grid on;

subplot(2, 2, 4);
step(feedback(G4, 1), 10, 'b-'); hold on;
step(feedback(Gc4*G4, 1), 10, 'r-');
title('闭环阶跃响应对比');
legend('校正前 (有静差)', '校正后 (无静差且快速)', 'Location', 'southeast');
grid on;

disp('所有图形已生成！注意观察黑色虚线 (校正装置) 是如何重塑蓝色实线 (原系统) 的。');