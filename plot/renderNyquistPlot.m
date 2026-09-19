function nyquistAnalysisStr = renderNyquistPlot(axNyquist, G_open, den, cl_poles, isNeg, omegaRange, viewMode, showUnitCircle)
% RENDERNYQUISTPLOT 绘制奈奎斯特幅相特性曲线与稳定判据几何要素
%   nyquistAnalysisStr = renderNyquistPlot(axNyquist, G_open, den, cl_poles, isNeg, omegaRange, viewMode, showUnitCircle)
%   特性:
%     1. 智能抗发散自适应视界 (基于 calcNyquistLimits 杜绝虚轴极点撑爆坐标)
%     2. 支持三档频域绘制:
%        - 'pos':  正频域 ω: 0 → +∞
%        - 'neg':  负频域 ω: 0 → -∞ (通过 G(-s) 完美镜像呈现)
%        - 'full': 全频域 ω: -∞ → +∞ (完整闭合轮廓)
%     3. 醒目标注临界判据点 (-1, j0) 或 (+1, j0)、单位圆 |s|=1 及负实轴穿越点
%     4. 实时输出严谨的奈奎斯特稳定判据 Z = P - 2N 推导结论

if nargin < 6 || isempty(omegaRange), omegaRange = 'full'; end
if nargin < 7 || isempty(viewMode),   viewMode = 'auto';   end
if nargin < 8 || isempty(showUnitCircle), showUnitCircle = true; end

cla(axNyquist);
hold(axNyquist, 'on');

critPoint = ternary(isNeg, -1, 1);

try
    [finalXLim, finalYLim] = calcNyquistLimits(G_open, critPoint, viewMode);
    
    optNyq = nyquistoptions;
    optNyq.XLim = {finalXLim};
    optNyq.YLim = {finalYLim};
    
    switch omegaRange
        case 'pos'
            G_target = G_open;
            optNyq.ShowFullContour = 'off';
            freqLabel = '正频域 ω: 0 → +∞';
        case 'neg'
            [n_g, d_g] = tfdata(G_open, 'v');
            n_neg = n_g .* ((-1) .^ (length(n_g)-1 : -1 : 0));
            d_neg = d_g .* ((-1) .^ (length(d_g)-1 : -1 : 0));
            G_target = tf(n_neg, d_neg);
            optNyq.ShowFullContour = 'off';
            freqLabel = '负频域 ω: 0 → -∞';
        otherwise % 'full'
            G_target = G_open;
            optNyq.ShowFullContour = 'on';
            freqLabel = '全频域 ω: -∞ → +∞';
    end
    
    optNyq.Title.String = sprintf('开环幅相特性 Nyquist 图 [%s] (%s临界基准)', ...
        freqLabel, ternary(isNeg, '负反馈 -1', '正反馈 +1'));
    optNyq.XLabel.String = '实轴 (Real Axis)';
    optNyq.YLabel.String = '虚轴 (Imag Axis)';
    
    nyquist(axNyquist, G_target, optNyq);
catch
    try, nyquist(axNyquist, G_open); catch, end
end

% 绘制中心十字轴线
x_curr = axNyquist.XLim;
y_curr = axNyquist.YLim;
plot(axNyquist, x_curr, [0, 0], 'k:', 'LineWidth', 0.6, 'Color', [0.65, 0.65, 0.65], 'HandleVisibility', 'off');
plot(axNyquist, [0, 0], y_curr, 'k:', 'LineWidth', 0.6, 'Color', [0.65, 0.65, 0.65], 'HandleVisibility', 'off');

% 绘制单位圆 (|s| = 1)
if showUnitCircle
    theta_uc = linspace(0, 2*pi, 200);
    plot(axNyquist, cos(theta_uc), sin(theta_uc), '--', 'Color', [0.75, 0.45, 0.15], ...
        'LineWidth', 1.0, 'DisplayName', '单位圆 |G|=1');
end

% 醒目标注临界点 (+/-1, 0)
plot(axNyquist, critPoint, 0, 'r+', 'MarkerSize', 15, 'LineWidth', 2.8, 'DisplayName', '临界判据点');
plot(axNyquist, critPoint, 0, 'ro', 'MarkerSize', 10, 'LineWidth', 1.8, 'HandleVisibility', 'off');
text(axNyquist, critPoint, max(y_curr(2)*0.08, 0.35), sprintf(' 临界点 (%+d, j0)', critPoint), ...
    'Color', [0.85, 0.1, 0.1], 'FontWeight', 'bold', 'FontSize', 10);
    
% 标注负实轴穿越点 (相位穿越频率与幅值裕度参考)
try
    warnState = warning('off', 'all');
    [Gm_temp, ~, Wcg_temp, ~] = margin(G_open);
    warning(warnState);
    if ~isnan(Gm_temp) && ~isinf(Gm_temp) && Gm_temp > 0
        cross_re = -1 / Gm_temp;
        if cross_re >= x_curr(1) && cross_re <= x_curr(2)
            plot(axNyquist, cross_re, 0, 'ms', 'MarkerSize', 9, 'LineWidth', 2, ...
                'MarkerFaceColor', [0.9, 0.2, 0.8], 'DisplayName', sprintf('穿越点 (ωg=%.2f)', Wcg_temp));
        end
    end
catch
end

grid(axNyquist, 'on');
hold(axNyquist, 'off');

% 奈奎斯特稳定判据严谨推导
p_rhp = sum(real(roots(den)) > 1e-5);
p_imag = sum(abs(real(roots(den))) <= 1e-5);
z_rhp = sum(real(cl_poles) > 1e-5);
z_imag = sum(abs(real(cl_poles)) <= 1e-5);

if isNeg
    encircle_N = (p_rhp - z_rhp) / 2;
else
    encircle_N = p_rhp - z_rhp;
end

if z_imag > 0
    nyqVerdict = '⚠️ 闭环系统在虚轴上存在极点，属于【临界稳定】！';
elseif z_rhp == 0
    nyqVerdict = sprintf('✅ 闭环不稳定极点数 Z = 0，闭环系统【完全渐进稳定】！(圈数 N=%.1f 满足稳定要求)', encircle_N);
else
    nyqVerdict = sprintf('❌ 闭环不稳定极点数 Z = %d > 0，闭环系统【不稳定】！(圈数 N=%.1f 不足以抵消不稳定极点)', z_rhp, encircle_N);
end

imagNote = '';
if p_imag > 0
    imagNote = sprintf(' (含 %d 个虚轴/原点极点，已由智能视界自动避开发散奇点)', p_imag);
end

rangeDescr = '全频域 ω ∈ (-∞, +∞) [正负频率完整闭合轮廓]';
if strcmp(omegaRange, 'pos')
    rangeDescr = '正频域 ω ∈ [0, +∞) [传统幅相特性主曲线]';
elseif strcmp(omegaRange, 'neg')
    rangeDescr = '负频域 ω ∈ (-∞, 0] [实轴对称共轭镜像轨迹]';
end

nyquistAnalysisStr = sprintf(['【奈奎斯特稳定判据解析】:\n', ...
    '• 当前绘制频段: %s\n', ...
    '• 开环右半平面不稳定极点数 P = %d%s\n', ...
    '• 闭环临界稳定判据点: (%+d, j0)\n', ...
    '• 稳定充要判据: Z = P - 2N = 0 (当前闭环不稳定极点 Z = %d, 全轮廓逆时针包围圈数 N = %.1f)\n', ...
    '• 判定结论: %s'], ...
    rangeDescr, p_rhp, imagNote, critPoint, z_rhp, encircle_N, nyqVerdict);

end
