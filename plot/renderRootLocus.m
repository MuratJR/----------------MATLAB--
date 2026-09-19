function polePlotHandle = renderRootLocus(axRL, G_rl, num, den, K, isNeg, cl_poles, showSGrid, fullRedraw, polePlotHandle)
% RENDERROOTLOCUS 渲染根轨迹图及动态闭环极点
%   polePlotHandle = renderRootLocus(axRL, G_rl, num, den, K, isNeg, cl_poles, showSGrid, fullRedraw, polePlotHandle)
%   支持全量重绘模式与轻量级极点动态刷新模式 (保障滑块极速响应)

if nargin < 9, fullRedraw = true; end
if nargin < 10, polePlotHandle = []; end

if fullRedraw
    cla(axRL);
    hold(axRL, 'on');
    rlocus(axRL, G_rl);
    title(axRL, sprintf('系统开环根轨迹 (%s, 当前 K* = %.2f)', ...
        ternary(isNeg, '负反馈 180°', '正反馈 0°'), K), 'FontSize', 12, 'FontWeight', 'bold');
    xlabel(axRL, '实轴 (Real Axis)');
    ylabel(axRL, '虚轴 (Imaginary Axis)');
    
    xLimits = axRL.XLim;
    yLimits = axRL.YLim;
    plot(axRL, xLimits, [0, 0], 'k-', 'LineWidth', 0.6, 'Color', [0.6, 0.6, 0.6], 'HandleVisibility', 'off');
    plot(axRL, [0, 0], yLimits, 'k-', 'LineWidth', 0.6, 'Color', [0.6, 0.6, 0.6], 'HandleVisibility', 'off');
    
    [bp, ~, ~] = calcBreakawayPoints(num, den, isNeg);
    if ~isempty(bp)
        plot(axRL, bp, zeros(size(bp)), 'p', 'MarkerSize', 11, ...
            'MarkerFaceColor', [1, 0.8, 0.1], 'MarkerEdgeColor', [0.8, 0.5, 0], ...
            'DisplayName', '实轴分离/会合点');
    end
    
    p_open = roots(den);
    z_open = roots(num);
    plot(axRL, real(p_open), imag(p_open), 'bx', 'MarkerSize', 10, 'LineWidth', 2, 'DisplayName', '开环极点');
    if ~isempty(z_open)
        plot(axRL, real(z_open), imag(z_open), 'bo', 'MarkerSize', 8, 'LineWidth', 2, 'DisplayName', '开环零点');
    end
    
    if showSGrid
        sgrid(axRL, [0.1, 0.2, 0.4, 0.6, 0.707, 0.9], []);
    end
    grid(axRL, 'on');
end

% 动态闭环极点绘制或位置更新
if isempty(polePlotHandle) || ~isvalid(polePlotHandle) || fullRedraw
    hold(axRL, 'on');
    polePlotHandle = plot(axRL, real(cl_poles), imag(cl_poles), 'rp', ...
        'MarkerSize', 13, 'MarkerFaceColor', [1, 0.2, 0.2], 'MarkerEdgeColor', [0.2, 0.2, 0.2], ...
        'LineWidth', 1.2, 'DisplayName', sprintf('当前闭环极点 (K*=%.2f)', K));
else
    set(polePlotHandle, 'XData', real(cl_poles), 'YData', imag(cl_poles), ...
        'DisplayName', sprintf('当前闭环极点 (K*=%.2f)', K));
    title(axRL, sprintf('系统开环根轨迹 (%s, 当前 K* = %.2f)', ...
        ternary(isNeg, '负反馈 180°', '正反馈 0°'), K), 'FontSize', 12, 'FontWeight', 'bold');
end
hold(axRL, 'off');

end
