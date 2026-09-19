function renderStepResponse(axStep, sys_cl, cl_poles, K)
% RENDERSTEPRESPONSE 绘制闭环系统单位阶跃时域响应曲线
%   renderStepResponse(axStep, sys_cl, cl_poles, K)
%   特性:
%     1. 自动根据极点分布区分稳定系统、临界稳定(等幅振荡)与发散不稳定系统
%     2. 稳定系统自动标注稳态终值线 y_ss 与 ±2% 动态调节时间容限带

cla(axStep);
hold(axStep, 'on');

isStable = all(real(cl_poles) < -1e-6);
isMarginal = any(abs(real(cl_poles)) <= 1e-6) && all(real(cl_poles) <= 1e-6);

if isStable && ~isempty(sys_cl)
    [y, t] = step(sys_cl);
    plot(axStep, t, y, 'b-', 'LineWidth', 2);
    y_final = dcgain(sys_cl);
    if ~isnan(y_final) && ~isinf(y_final)
        yline(axStep, y_final, 'k--', sprintf('稳态值 y_{ss} = %.3f', y_final), 'LineWidth', 1.2);
        yline(axStep, y_final*1.02, 'g:', 'LineWidth', 0.8);
        yline(axStep, y_final*0.98, 'g:', 'LineWidth', 0.8);
    end
    title(axStep, sprintf('闭环系统单位阶跃响应 (系统稳定, K* = %.2f)', K), 'FontSize', 12, 'FontWeight', 'bold');
elseif isMarginal && ~isempty(sys_cl)
    [y, t] = step(sys_cl, 20);
    plot(axStep, t, y, 'm-', 'LineWidth', 2);
    title(axStep, sprintf('闭环系统单位阶跃响应 (系统临界稳定/等幅振荡, K* = %.2f)', K), 'FontSize', 12, 'FontWeight', 'bold');
else
    try
        [y, t] = step(sys_cl, 5);
        plot(axStep, t, y, 'r-', 'LineWidth', 2);
    catch
        text(axStep, 0.5, 0.5, '系统发散，无法绘制稳定阶跃响应', 'FontSize', 14, 'Color', 'r');
    end
    title(axStep, sprintf('闭环系统单位阶跃响应 (⚠️ 系统不稳定/发散, K* = %.2f)', K), 'FontSize', 12, 'FontWeight', 'bold', 'Color', [0.8, 0, 0]);
end

xlabel(axStep, '时间 t (seconds)');
ylabel(axStep, '响应幅值 c(t)');
grid(axStep, 'on');
hold(axStep, 'off');

end
