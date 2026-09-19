% =========================================================================
% 交互式根轨迹分析工具 (完全解耦双窗口版)
% 窗口 1: 静态根轨迹全貌 (仅供参考，不受影响)
% 窗口 2: 独立的 K* 控制面板 + 独立的坐标系 (实时观察极点移动)
% =========================================================================

clear; clc; close all;

%% 1. 参数设置
% 自定义开环零点 (默认为题目上的值 -1)
custom_zero = -1; 
num = [1, -custom_zero];
den1 = [1, -1, 0];
den2 = [1, 4, 16];
% 卷积求得多项式乘积 (开环分母)
den = conv(den1, den2);
% 生成传递函数对象
G = tf(num, den);

%% 2. 创建【图窗 1】：纯净的静态根轨迹主窗口
fig_static = figure('Name', '图窗 1: 静态根轨迹全貌 (参考)', 'Position', [50, 200, 600, 500], 'Color', 'w');
ax_static = axes('Parent', fig_static);
rlocus(ax_static, G);
title(ax_static, sprintf('静态根轨迹全貌 (开环零点 Z = %g)', custom_zero), 'FontSize', 12);
xlabel(ax_static, '实轴');
ylabel(ax_static, '虚轴');

% 提取图窗 1 的坐标轴范围，为了稍后让图窗 2 的坐标系与它保持一致，方便对比
xl = ax_static.XLim;
yl = ax_static.YLim;

%% 3. 创建【图窗 2】：带有独立坐标系和滑块的动态观察窗口
fig_dynamic = figure('Name', '图窗 2: 动态闭环极点观察面板', 'Position', [680, 200, 600, 650], 'Color', 'w');

% --- 3.1 建立图窗 2 专属的坐标系 ---
ax_dynamic = axes('Parent', fig_dynamic, 'Position', [0.1, 0.35, 0.8, 0.55]);
hold(ax_dynamic, 'on'); 
grid(ax_dynamic, 'on');
title(ax_dynamic, '独立坐标系：闭环极点随 K* 的动态变化', 'FontSize', 12);
xlabel(ax_dynamic, '实轴');
ylabel(ax_dynamic, '虚轴');

% 画出坐标轴的 0 刻度线，增强视觉基准
plot(ax_dynamic, xl, [0 0], 'k-', 'LineWidth', 0.5);
plot(ax_dynamic, [0 0], yl, 'k-', 'LineWidth', 0.5);

% 强制锁定图窗 2 的视场范围与图窗 1 绝对一致
ax_dynamic.XLim = xl;
ax_dynamic.YLim = yl;

% --- 3.2 在图窗 2 中绘制参考点 (开环极点和零点) ---
open_poles = roots(den);
open_zeros = roots(num);
plot(ax_dynamic, real(open_poles), imag(open_poles), 'x', 'MarkerSize', 10, 'Color', 'b', 'LineWidth', 2);
plot(ax_dynamic, real(open_zeros), imag(open_zeros), 'o', 'MarkerSize', 8, 'Color', 'b', 'LineWidth', 2);

% --- 3.3 初始化动态元素 (红色星星) ---
initial_K = 0;
padded_num = [zeros(1, length(den) - length(num)), num];
p_closed = roots(den + initial_K * padded_num); % K=0 时的初始闭环极点
% 绘制初始极点并保存句柄 (保存在 ax_dynamic 中)
pole_plot = plot(ax_dynamic, real(p_closed), imag(p_closed), 'p', ...
    'MarkerSize', 12, 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k');

% --- 3.4 添加交互式 UI 控件 ---
K_max = 60; % K* 的最大滑动范围

% 动态 K* 值文字显示
txt_K = uicontrol('Parent', fig_dynamic, 'Style', 'text', ...
    'Position', [50, 160, 500, 25], ...
    'String', sprintf('当前 K* = %.2f', initial_K), ...
    'FontSize', 14, 'FontWeight', 'bold', 'BackgroundColor', 'w', 'HorizontalAlignment', 'center');

% 创建滑块控件
slider = uicontrol('Parent', fig_dynamic, 'Style', 'slider', ...
    'Position', [50, 130, 500, 20], ...
    'value', initial_K, 'min', 0, 'max', K_max, ...
    'BackgroundColor', [0.9 0.9 0.9]);

% 提示文字
uicontrol('Parent', fig_dynamic, 'Style', 'text', ...
    'Position', [50, 75, 500, 30], ...
    'String', '【系统稳定范围】: 23.315 < K* < 35.685', ...
    'FontSize', 12, 'ForegroundColor', 'b', 'BackgroundColor', 'w', 'HorizontalAlignment', 'center');
uicontrol('Parent', fig_dynamic, 'Style', 'text', ...
    'Position', [50, 50, 500, 20], ...
    'String', '拖动滑块，观察上方坐标系中的红星是否全部进入左半平面（图窗1作为静态参考不发生改变）', ...
    'FontSize', 9, 'ForegroundColor', [0.4 0.4 0.4], 'BackgroundColor', 'w', 'HorizontalAlignment', 'center');

%% 4. 绑定滑块回调函数
slider.Callback = @(es, ed) updatePoles(es, txt_K, pole_plot, num, den);

%% ========================================================================
% 回调函数定义 (必须放在脚本文件的最末尾)
% =========================================================================
function updatePoles(slider_obj, text_obj, plot_obj, num, den)
    % 安全检查：如果用户手动关闭了图窗或者删除了绘图对象，直接返回，避免报错
    if ~isvalid(plot_obj)
        return;
    end
    
    % 1. 获取滑块数值
    K_val = slider_obj.Value;
    
    % 2. 更新面板文字
    text_obj.String = sprintf('当前 K* = %.2f', K_val);
    
    % 3. 多项式求根计算新的闭环极点位置
    padded_num = [zeros(1, length(den) - length(num)), num];
    char_poly = den + K_val * padded_num;
    p = roots(char_poly);
    
    % 4. 仅更新图窗 2 中红星的 X 和 Y 坐标，不影响图窗 1
    set(plot_obj, 'XData', real(p), 'YData', imag(p));
end