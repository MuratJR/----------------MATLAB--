% ==========================================
% 未来超音速客机自动飞行控制系统综合解析 (已修正)
% ==========================================
clear; clc; close all;

%% 1. 模型建立与第一问：绘制根轨迹
disp('【第一问：开环系统分析与根轨迹】');
% 分子多项式: (s+2)^2 = s^2 + 4s + 4
num_G = [1, 4, 4]; 

% 分母多项式展开: 
% D1 = (s+10)(s+100) = s^2 + 110s + 1000
% D2 = s^2 + 1.5s + 6.25 (这里已修正为 +6.25)
den_D1 = [1, 110, 1000];
den_D2 = [1, 1.5, 6.25];
den_G = conv(den_D1, den_D2); 

% 创建系统
sys = tf(num_G, den_G);

% 绘制根轨迹
figure('Name', '超音速客机飞行控制系统根轨迹', 'Color', 'w', 'Position', [100, 100, 800, 600]);
rlocus(sys);
title('总增益 K 变化时的系统闭环根轨迹', 'FontSize', 14);
% 绘制 0.707 的等阻尼线方便直观观察
sgrid(0.707, []); 
axis([-110 10 -60 60]);
grid on;
hold on;

%% 2. 第二问：求解中等重量巡航时的 K2
disp('------------------------------------------');
disp('【第二问：求解巡航状态的 K2 (\zeta = 0.707)】');

% 利用符号计算求解特征方程
syms a K real
% 阻尼比 0.707 对应极点 s = -a + j*a
s_sub = -a + 1i*a; 

% 特征方程 D(s) + K*N(s) = 0
char_eq = poly2sym(den_G, s_sub) + K * poly2sym(num_G, s_sub);

% 令实部和虚部均等于 0
eq_real = real(char_eq) == 0;
eq_imag = imag(char_eq) == 0;

% 联立求解 a 和 K
sols = solve([eq_real, eq_imag], [a, K]);
a_vals = double(sols.a);
K_vals = double(sols.K);

% 筛选出位于左半平面(a>0)且具有物理意义(K>0)的主导极点解
valid_idx = find(a_vals > 0 & K_vals > 0);

% 取出第一个有效解，确保提取出来的是标量
a_target = a_vals(valid_idx(1));
K_target = K_vals(valid_idx(1));

fprintf('解得满足 ζ=0.707 的主导极点位置为: s = %.4f ± j%.4f\n', -a_target, a_target);
fprintf('此时所需的系统总增益为: K = %.2f\n', K_target);

% 已知中等重量巡航时 K1 = 0.02
K1_mid = 0.02;
K2_ans = K_target / K1_mid;
fprintf('因此，控制器的增益 K2 = %.2f\n', K2_ans);

% 在根轨迹图上标出该主导极点
plot(-a_target, a_target, 'rp', 'MarkerSize', 12, 'MarkerFaceColor', 'y', 'DisplayName', '\zeta=0.707 主导极点');
plot(-a_target, -a_target, 'rp', 'MarkerSize', 12, 'MarkerFaceColor', 'y');
legend('Location', 'best');

%% 3. 第三问：求解轻重量降落时的阻尼比
disp('------------------------------------------');
disp('【第三问：轻重量降落状态下的阻尼比】');

% 保持 K2 不变，K1 变为 0.2
K1_light = 0.2;
K_new = K1_light * K2_ans;
fprintf('降落时 K1=0.2，新的总增益变为: K_new = %.2f\n', K_new);

% 构建新的闭环特征方程多项式
pad_num_G = [0, 0, num_G]; % 补齐前导0
cl_den = den_G + K_new * pad_num_G; 

% 求新的闭环极点
new_poles = roots(cl_den);
disp('新的闭环极点分布为:');
disp(new_poles);

% 提取实部为负且有虚部的共轭极点
complex_poles = new_poles(abs(imag(new_poles)) > 1e-3 & real(new_poles) < 0);

% 智能筛选主导极点（实部最大的那一个，也就是最靠近虚轴的）
[~, max_idx] = max(real(complex_poles));
dom_pole = complex_poles(max_idx);

% 计算新的阻尼比
new_zeta = cos(atan(abs(imag(dom_pole)) / abs(real(dom_pole))));
fprintf('降落状态下的新主导极点为: s = %.4f ± j%.4f\n', real(dom_pole), abs(imag(dom_pole)));
fprintf('>>> 此时系统的主导阻尼比变为: \zeta = %.4f <<<\n', new_zeta);

disp('==========================================');