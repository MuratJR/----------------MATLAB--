% ==========================================
% 空间站方位控制系统根轨迹分析与振荡范围求解
% ==========================================
clear; clc; close all;

%% 1. 系统定义与绘制概略根轨迹
% 开环传递函数 G(s) = K*(s+20) / [s*(s^2+24s+144)]
% 展开分母: s*(s+12)^2 = s^3 + 24s^2 + 144s

num = [1, 20];             % 增加 K* 前的分子多项式
den = [1, 24, 144, 0];     % 分母多项式

% 建立开环传递函数模型
sys = tf(num, den);

% 绘制概略根轨迹图
figure('Name', '空间站方位控制系统根轨迹', 'Color', 'w', 'Position', [100, 100, 800, 600]);
rlocus(sys);
title('系统开环传递函数 G(s) 的闭环根轨迹图', 'FontSize', 14);
xlabel('实轴', 'FontSize', 12);
ylabel('虚轴', 'FontSize', 12);
grid on;

%% 2. 求解分离点与临界振荡增益
disp('【计算系统产生振荡的 K* 取值范围】');
disp('------------------------------------------');

% 根据闭环特征方程: D(s) + K*N(s) = 0
% 等价于: s^3 + 24s^2 + 144s + K*(s+20) = 0
% 得: K* = -(s^3 + 24s^2 + 144s) / (s + 20)
% 设 P_num(s) = s^3 + 24s^2 + 144s, P_den(s) = s + 20
% 求分离点条件 dK/ds = 0，即: P_num'(s)*P_den(s) - P_num(s)*P_den'(s) = 0

P_num = den; 
P_den = num; 

% 求导
der_P_num = polyder(P_num);
der_P_den = polyder(P_den);

% 计算多项式乘积
term1 = conv(der_P_num, P_den);
term2 = conv(P_num, der_P_den);

% 补齐阶数以便相减
len = max(length(term1), length(term2));
term1 = [zeros(1, len-length(term1)), term1];
term2 = [zeros(1, len-length(term2)), term2];

% 构造分离点方程并求根
eq_break = term1 - term2;
s_break = roots(eq_break);

% 筛选位于实轴根轨迹上的有效分离点
% 根据奇偶法则，本系统的实轴根轨迹为 [-20, 0]
tol = 1e-6;
valid_s = [];
for i = 1:length(s_break)
    s_val = s_break(i);
    % 剔除虚部、并限制在 [-20, 0] 区间内
    if abs(imag(s_val)) < tol && real(s_val) <= 0 && real(s_val) >= -20
        valid_s = [valid_s, real(s_val)];
    end
end

% 系统在 s = -12 处有一个双重极点，初始状态下(K=0)根向两侧移动
% 真正导致进入复平面的分离点位于 0 到 -12 之间
breakaway_point = valid_s(valid_s > -12 & valid_s < 0);

% 计算临界增益 K*
K_star_critical = -polyval(P_num, breakaway_point) / polyval(P_den, breakaway_point);

fprintf('求解分离点方程得出，有效分离点为: s = %.4f\n', breakaway_point);
fprintf('将分离点代入幅值条件，求得临界增益: K* = %.4f\n\n', K_star_critical);
disp('【结论】');
disp('当 K* 超过该临界值时，位于实轴的闭环极点相撞并折入复平面。');
disp('系统由过阻尼变为欠阻尼状态，响应开始产生振荡。');
fprintf('因此，使系统产生振荡的取值范围为: K* > %.4f\n', K_star_critical);
disp('------------------------------------------');

% 在图表上高亮标注该分离点
hold on;
plot(breakaway_point, 0, 'rp', 'MarkerSize', 12, 'MarkerFaceColor', 'y', 'DisplayName', '复平面分离点');
text(breakaway_point + 0.8, 1.5, sprintf('分离点 s=%.2f\n此时 K*=%.2f', breakaway_point, K_star_critical), ...
    'Color', 'r', 'FontSize', 11, 'FontWeight', 'bold');
legend('Location', 'best');