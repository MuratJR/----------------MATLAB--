% 清理工作区和图窗
clear; clc; close all;

% 定义传递函数 F1(s) = (s+9) / [(s+1)(s+10)]
% 分母展开为: s^2 + 11s + 10
num1 = [1, 9];
den1 = [1, 11, 10]; 
sys1 = tf(num1, den1);

% 定义传递函数 F2(s) = 1 / (s+1)
num2 = 0.9;
den2 = [1, 1];
sys2 = tf(num2, den2);

% 设置仿真时间为 0 到 8 秒
t = 0:0.01:8;

% 计算阶跃响应
[y1, t1] = step(sys1, t);
[y2, t2] = step(sys2, t);

% 创建图窗并绘制曲线
figure('Name', '单位阶跃响应对比', 'Color', 'w');
plot(t1, y1, 'b-', 'LineWidth', 2);
hold on;
plot(t2, y2, 'r--', 'LineWidth', 2);

% 添加稳态终值的参考基准线
yline(1.0, 'k:', '稳态终值=1.0', 'LineWidth', 1.5, 'LabelHorizontalAlignment', 'left');
yline(0.9, 'k:', '稳态终值=0.9', 'LineWidth', 1.5, 'LabelHorizontalAlignment', 'left');

% 图表格式化设置
grid on;
title('单位阶跃响应对比：偶极子对主导极点系统的影响');
xlabel('时间 t (s)');
ylabel('幅值 c(t)');
legend('F_1(s) = (s+9)/[(s+1)(s+10)]', 'F_2(s) = 1/(s+1)', 'Location', 'lower right');
ylim([0, 1.15]);
hold off;