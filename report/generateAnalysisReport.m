function lines = generateAnalysisReport(K, isNeg, num, den, cl_poles, sys_cl, G_open)
% GENERATEANALYSISREPORT 生成自控原理全要素综合指标分析报告
%   lines = generateAnalysisReport(K, isNeg, num, den, cl_poles, sys_cl, G_open)
%   返回包含四大核心章节的文本行元胞数组，可直接赋值给 uitextarea

lines = {};
lines{end+1} = '========================================================================================';
lines{end+1} = '                《自动控制原理》系统全要素综合分析与计算报告                ';
lines{end+1} = sprintf('  生成时间: %s  |  开环增益 K* = %.4f  |  反馈模式: %s', ...
    datestr(now, 'yyyy-mm-dd HH:MM:SS'), K, ternary(isNeg, '负反馈 (180°根轨迹)', '正反馈 (0°根轨迹)'));
lines{end+1} = '========================================================================================';
lines{end+1} = '';

%% 【一、 开环系统结构特性与传递函数】
lines{end+1} = '【一、 开环系统结构特性与传递函数】';
lines{end+1} = sprintf('  • 开环分子多项式 N(s):  %s', poly2str_custom(num));
lines{end+1} = sprintf('  • 开环分母多项式 D(s):  %s', poly2str_custom(den));

p_o = roots(den);
z_o = roots(num);
lines{end+1} = sprintf('  • 开环极点数 n = %d, 极点分布: %s', length(p_o), formatComplexArray(p_o));
if isempty(z_o)
    lines{end+1} = '  • 开环零点数 m = 0 (无有限远开环零点)';
else
    lines{end+1} = sprintf('  • 开环零点数 m = %d, 零点分布: %s', length(z_o), formatComplexArray(z_o));
end

origin_poles = sum(abs(p_o) < 1e-6);
typeStr = sprintf('%d 型系统', origin_poles);
lines{end+1} = sprintf('  • 系统积分环节数 (型别): 包含 %d 个原点积分极点 -> 【%s】', origin_poles, typeStr);

if origin_poles == 0
    Kp_val = polyval(num, 0) / polyval(den, 0) * K;
    lines{end+1} = sprintf('  • 静态位置误差系数 K_p = %.4f (阶跃稳态误差 e_ss = 1/(1+Kp) = %.4f)', Kp_val, 1/(1+Kp_val));
    lines{end+1} = '  • 静态速度误差系数 K_v = 0 (斜坡稳态误差 e_ss = ∞)';
elseif origin_poles == 1
    den_reduced = deconv(den, [1, 0]);
    Kv_val = polyval(num, 0) / polyval(den_reduced, 0) * K;
    lines{end+1} = '  • 静态位置误差系数 K_p = ∞ (阶跃稳态误差 e_ss = 0)';
    lines{end+1} = sprintf('  • 静态速度误差系数 K_v = %.4f (斜坡稳态误差 e_ss = 1/Kv = %.4f)', Kv_val, 1/Kv_val);
else
    lines{end+1} = '  • 静态位置误差系数 K_p = ∞ (阶跃稳态误差 e_ss = 0)';
    lines{end+1} = '  • 静态速度误差系数 K_v = ∞ (斜坡稳态误差 e_ss = 0)';
end
lines{end+1} = '';

%% 【二、 根轨迹几何作图特征参数】
lines{end+1} = '【二、 根轨迹几何作图特征参数】';
n = length(p_o);
m = length(z_o);
lines{end+1} = sprintf('  • 根轨迹分支总数: %d 条', n);
lines{end+1} = sprintf('  • 趋向无穷远的分支数: n - m = %d - %d = %d 条', n, m, n-m);
if n > m
    sigma_a = (sum(p_o) - sum(z_o)) / (n - m);
    if isNeg
        angles_deg = ((2*(0:(n-m-1)) + 1) * 180) / (n - m);
    else
        angles_deg = (2*(0:(n-m-1)) * 180) / (n - m);
    end
    lines{end+1} = sprintf('  • 渐近线实轴交点 (质心): σ_a = (Σp - Σz)/(n-m) = %.4f', real(sigma_a));
    lines{end+1} = sprintf('  • 渐近线与实轴正向夹角: φ_a = [ %s ]°', num2str(angles_deg, '%.1f  '));
end

[bp, bg, ~] = calcBreakawayPoints(num, den, isNeg);
if ~isempty(bp)
    lines{end+1} = '  • 实轴有效分离/会合点及对应临界增益:';
    for k = 1:length(bp)
        lines{end+1} = sprintf('      - 分离点 d_%d = %8.4f,  对应增益 K* = %8.4f', k, bp(k), bg(k));
    end
else
    lines{end+1} = '  • 实轴有效分离点: 本系统在对应反馈法则下无实轴分离/会合点。';
end

[w_cross, K_crit] = calcImagCrossings(num, den, isNeg);
if ~isempty(w_cross)
    lines{end+1} = '  • 根轨迹与虚轴交点 (临界稳定点):';
    for k = 1:length(w_cross)
        lines{end+1} = sprintf('      - 穿越频率 ω_%d = ±%.4f rad/s,  临界增益 K_crit = %.4f', k, w_cross(k), K_crit(k));
    end
else
    lines{end+1} = '  • 根轨迹与虚轴交点: 无有限正实数交点 (系统增益变化不越过虚轴或无正实数解)。';
end
lines{end+1} = '';

%% 【三、 当前增益 K* 下的闭环极点分布与稳定性】
lines{end+1} = sprintf('【三、 当前增益 K*=%.2f 下的闭环极点分布与稳定性】', K);
lines{end+1} = sprintf('  • 闭环特征多项式:  %s = 0', ...
    poly2str_custom(den + ternary(isNeg, 1, -1)*K*[zeros(1, length(den)-length(num)), num]));
lines{end+1} = '  • 闭环极点明细 (实部, 虚部, 阻尼比 ζ, 自然角频率 ωn):';
for k = 1:length(cl_poles)
    pk = cl_poles(k);
    wn_k = abs(pk);
    zeta_k = -real(pk) / max(wn_k, 1e-12);
    lines{end+1} = sprintf('      p_%d = %8.4f %+8.4fj  |  ζ = %6.4f,  ωn = %7.4f rad/s', ...
        k, real(pk), imag(pk), zeta_k, wn_k);
end

isStable = all(real(cl_poles) < -1e-6);
if isStable
    lines{end+1} = '  • 劳斯稳定性判定: 【系统稳定】 (所有闭环极点实部均严格小于零)';
    if ~isempty(sys_cl)
        try
            s_info = stepinfo(sys_cl);
            lines{end+1} = sprintf('  • 上升时间 t_r:        %8.4f s', s_info.RiseTime);
            lines{end+1} = sprintf('  • 峰值时间 t_p:        %8.4f s', s_info.PeakTime);
            lines{end+1} = sprintf('  • 调节时间 t_s (2%%):   %8.4f s', s_info.SettlingTime);
            lines{end+1} = sprintf('  • 最大超调量 σ%%:       %8.2f %%', s_info.Overshoot);
            lines{end+1} = sprintf('  • 稳态响应终值 y_ss:   %8.4f', dcgain(sys_cl));
        catch
        end
    end
else
    lines{end+1} = '  • 劳斯稳定性判定: 【⚠️ 系统不稳定】 (存在实部大于等于零的极点，阶跃响应发散)';
end
lines{end+1} = '';

%% 【四、 开环频域裕度指标 (Bode & Nyquist)】
lines{end+1} = '【四、 开环频域裕度指标 (Bode & Nyquist)】';
try
    warnState = warning('off', 'all');
    [Gm, Pm, Wcg, Wcp] = margin(G_open);
    warning(warnState);
    Gm_dB = 20*log10(Gm);
    lines{end+1} = sprintf('  • 剪切频率 (截止频率) ω_c:    %8.4f rad/s', Wcp);
    lines{end+1} = sprintf('  • 相位裕度 (相角裕度) γ (P_m): %8.2f°', Pm);
    lines{end+1} = sprintf('  • 相位穿越频率 ω_g:           %8.4f rad/s', Wcg);
    lines{end+1} = sprintf('  • 幅值裕度 (增益裕度) K_g (G_m): %8.4f (对应 %8.2f dB)', Gm, Gm_dB);
    if Pm > 0 && Gm_dB > 0
        lines{end+1} = '  • 频域稳定性结论: 裕度充足 (Pm > 0 且 Gm > 0dB)，闭环系统具备良好的相对稳定性。';
    else
        lines{end+1} = '  • 频域稳定性结论: ⚠️ 稳定裕度不足或为负值，可能导致系统产生持续剧烈振荡或失稳。';
    end
catch
    lines{end+1} = '  • 频域裕度计算: 系统未出现有效的 0dB 穿越或 -180° 穿越频率。';
end

end
