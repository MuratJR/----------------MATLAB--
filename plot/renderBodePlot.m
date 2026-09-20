function [Gm, Pm, Wcg, Wcp] = renderBodePlot(axBode, G_open, sys_cl, K, bodeMode)
% RENDERBODEPLOT 绘制对数频率特性 Bode 图 (支持开环与闭环切换)
%   [Gm, Pm, Wcg, Wcp] = renderBodePlot(axBode, G_open, sys_cl, K, bodeMode)
%   输入参数:
%     axBode   : 目标坐标区 (uiaxes)
%     G_open   : 开环传递函数模型 (tf / zpk / ss)
%     sys_cl   : 闭环传递函数模型 (tf / zpk / ss)
%     K        : 当前根轨迹增益倍数 K*
%     bodeMode : 'open' (默认, 开环对数频率特性) 或 'closed' (闭环对数频率特性)
%   输出裕度指标 (始终基于开环系统返回):
%     Gm: 幅值裕度 (线性倍数)
%     Pm: 相位裕度 (度数)
%     Wcg: 相位穿越频率 (rad/s)
%     Wcp: 幅值穿越频率 (剪切频率, rad/s)

if nargin < 3 || isempty(sys_cl)
    sys_cl = feedback(G_open, 1);
    K = 1.0;
    bodeMode = 'open';
elseif nargin == 3
    if ischar(sys_cl) || isstring(sys_cl)
        bodeMode = char(sys_cl);
        sys_cl = feedback(G_open, 1);
        K = 1.0;
    elseif isnumeric(sys_cl)
        K = sys_cl;
        sys_cl = feedback(G_open, 1);
        bodeMode = 'open';
    else
        K = 1.0;
        bodeMode = 'open';
    end
elseif nargin == 4
    if ischar(K) || isstring(K)
        bodeMode = char(K);
        K = 1.0;
    else
        bodeMode = 'open';
    end
elseif nargin < 5 || isempty(bodeMode)
    bodeMode = 'open';
end

Gm = NaN; Pm = NaN; Wcg = NaN; Wcp = NaN;
try
    warnState = warning('off', 'all');
    [Gm, Pm, Wcg, Wcp] = margin(G_open);
    warning(warnState);
catch
end

cla(axBode);

if strcmpi(bodeMode, 'closed')
    % --- 绘制闭环对数频率特性 (Closed-Loop Bode) ---
    try
        bode(axBode, sys_cl);
        grid(axBode, 'on');
        
        wb = NaN; Mr_dB = NaN; wr = NaN;
        try
            wb = bandwidth(sys_cl);
        catch
        end
        try
            [mag, ~, w] = bode(sys_cl);
            [max_mag, idx] = max(squeeze(mag));
            if max_mag > 1.001
                Mr_dB = 20*log10(max_mag);
                wr = w(idx);
            end
        catch
        end
        
        if ~isnan(wb) && ~isnan(Mr_dB)
            title(axBode, sprintf('闭环对数频率特性 Bode 图 [Φ(s)] (K* = %.2f | 带宽 ω_b = %.2f rad/s, 峰值 M_r = %.2f dB @ ω_r = %.2f rad/s)', ...
                K, wb, Mr_dB, wr), 'FontSize', 12, 'FontWeight', 'bold');
        elseif ~isnan(wb)
            title(axBode, sprintf('闭环对数频率特性 Bode 图 [Φ(s)] (K* = %.2f | 截止频率/带宽 ω_b = %.2f rad/s)', ...
                K, wb), 'FontSize', 12, 'FontWeight', 'bold');
        else
            title(axBode, sprintf('闭环对数频率特性 Bode 图 [Φ(s)] (K* = %.2f)', K), 'FontSize', 12, 'FontWeight', 'bold');
        end
    catch ME
        title(axBode, sprintf('闭环对数频率特性绘制失败: %s', ME.message), 'FontSize', 11, 'FontColor', 'r');
    end
else
    % --- 绘制开环对数频率特性 (Open-Loop Bode) ---
    try
        margin(axBode, G_open);
        title(axBode, sprintf('开环对数频率特性 Bode 图 [G(s)H(s)] (K* = %.2f)', K), 'FontSize', 12, 'FontWeight', 'bold');
        grid(axBode, 'on');
    catch
        bode(axBode, G_open);
        title(axBode, sprintf('开环对数频率特性 Bode 图 [G(s)H(s)] (K* = %.2f)', K), 'FontSize', 12, 'FontWeight', 'bold');
        grid(axBode, 'on');
    end
end

end
