function [finalXLim, finalYLim] = calcNyquistLimits(G_open, critPoint, viewMode)
% CALCNYQUISTLIMITS 智能滤除发散采样点，为奈奎斯特图计算最优显示视界
%   [finalXLim, finalYLim] = calcNyquistLimits(G_open, critPoint, viewMode)
%   输入参数:
%     G_open:    当前开环传递函数 (tf 对象)
%     critPoint: 临界判据点实部 (-1 代表负反馈，+1 代表正反馈)
%     viewMode:  视角模式 ('auto', 'focusCrit', 'focusCurve', 'wide')
%   核心原理:
%     自动滤除虚轴或原点极点在 ω 接近奇点时导致的巨大发散采样值 (|G| > 40)，
%     并自动包含临界点与单位圆，防止坐标系被拉伸到 ±10^22。

if nargin < 3 || isempty(viewMode)
    viewMode = 'auto'; 
end

try
    [re_raw, im_raw] = nyquist(G_open);
    re_v = squeeze(re_raw); 
    im_v = squeeze(im_raw);
    
    % 过滤发散点
    mag_v = hypot(re_v, im_v);
    valid_idx = isfinite(re_v) & isfinite(im_v) & (mag_v < 40);
    if sum(valid_idx) < 5
        valid_idx = isfinite(re_v) & isfinite(im_v) & (mag_v < 150);
    end
    
    if sum(valid_idx) >= 5
        r_valid = re_v(valid_idx);
        i_valid = im_v(valid_idx);
        all_re = [r_valid; critPoint; 0; -1.2; 1.2];
        all_im = [i_valid; 0; -1.2; 1.2];
        
        x_min = min(all_re); x_max = max(all_re);
        y_min = min(all_im); y_max = max(all_im);
        
        x_pad = max((x_max - x_min) * 0.15, 0.4);
        y_pad = max((y_max - y_min) * 0.15, 0.4);
        
        xlim_calc = [max(x_min - x_pad, -80), min(x_max + x_pad, 50)];
        ylim_calc = [max(y_min - y_pad, -60), min(y_max + y_pad, 60)];
    else
        xlim_calc = [-6, 3];
        ylim_calc = [-4.5, 4.5];
    end
    
    % 根据当前视角模式选定最终视界
    switch viewMode
        case 'focusCrit'
            finalXLim = [critPoint - 1.8, critPoint + 1.8];
            finalYLim = [-1.8, 1.8];
        case 'focusCurve'
            if sum(valid_idx) >= 5
                r_c = re_v(valid_idx); 
                i_c = im_v(valid_idx);
                finalXLim = [min(r_c)-0.5, max(r_c)+0.5];
                finalYLim = [min(i_c)-0.5, max(i_c)+0.5];
            else
                finalXLim = xlim_calc; 
                finalYLim = ylim_calc;
            end
        case 'wide'
            finalXLim = [min(xlim_calc(1)*2.5, -40), max(xlim_calc(2)*2.5, 30)];
            finalYLim = [min(ylim_calc(1)*2.5, -35), max(ylim_calc(2)*2.5, 35)];
        otherwise % 'auto'
            finalXLim = xlim_calc;
            finalYLim = ylim_calc;
    end
catch
    finalXLim = [-6, 3];
    finalYLim = [-4.5, 4.5];
end
end
