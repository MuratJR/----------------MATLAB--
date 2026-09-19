function [Gm, Pm, Wcg, Wcp] = renderBodePlot(axBode, G_open, K)
% RENDERBODEPLOT 绘制开环对数频率特性 Bode 图并计算幅值与相位裕度
%   [Gm, Pm, Wcg, Wcp] = renderBodePlot(axBode, G_open, K)
%   输出裕度指标:
%     Gm: 幅值裕度 (线性倍数)
%     Pm: 相位裕度 (度数)
%     Wcg: 相位穿越频率 (rad/s)
%     Wcp: 幅值穿越频率 (剪切频率, rad/s)

Gm = NaN; Pm = NaN; Wcg = NaN; Wcp = NaN;
cla(axBode);

try
    margin(axBode, G_open);
    title(axBode, sprintf('开环对数频率特性 Bode 图 (K* = %.2f)', K), 'FontSize', 12, 'FontWeight', 'bold');
    grid(axBode, 'on');
    
    warnState = warning('off', 'all');
    [Gm, Pm, Wcg, Wcp] = margin(G_open);
    warning(warnState);
catch
    bode(axBode, G_open);
    title(axBode, sprintf('开环对数频率特性 Bode 图 (K* = %.2f)', K), 'FontSize', 12, 'FontWeight', 'bold');
    grid(axBode, 'on');
end

end
