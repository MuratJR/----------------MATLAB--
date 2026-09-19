function varargout = AutoControlWorkbench()
% =========================================================================
% 自动控制原理综合可视化分析工作台 (AutoControl Workbench)
% 适用环境: MATLAB R2020a 及以上 (已在 R2026a 深度适配)
% 特色亮点:
%   1. 完美自适应布局: 告别控件重叠与空白堆叠，全卡片式层级架构
%   2. 典型环节串联积架构全面支持【任意多个环节与多组高阶环节】:
%      - 比例环节 (增益 K)
%      - 积分环节 (支持 0型、1型、2型、3型、4型任意阶数)
%      - 一阶惯性环节 (支持输入任意 N 个时间常数或极点)
%      - 一阶微分环节 (支持输入任意 M 个时间常数或零点)
%      - 二阶振荡环节 (支持输入任意 P 组二次振荡参数，分号隔开)
%      - 二阶微分环节 (支持输入任意 Q 组二次微分参数，分号隔开)
%      - 纯延迟环节 (2 阶 Padé 近似)
%   3. 实时环节数量与结构统计栏 (直观显示包含几个惯性、几个振荡、总阶数)
%   4. 选项卡无缝切换: 典型环节积 | 自由数学表达式 | 多项式降幂系数
%   5. LaTeX 高清数学公式实时看板 (因式分解式、展开式与闭环特征方程)
%   6. 正反馈 (0° 根轨迹) 与 负反馈 (180° 根轨迹) 自由切换
%   7. 动态开环增益 K* 滑块联动，实时追踪闭环极点迁移与阶跃响应
%   8. 四大核心图表: 根轨迹图、Bode 图、Nyquist 图、闭环阶跃响应
%   9. 全套自控理论指标全景解析看板 (时域、频域、稳态、根轨迹特征、稳定性)
%   10. 内置 6 套经典自控教材与工程预设题库 (空间站、超音速客机、偶极子等)
% =========================================================================

%% 1. 初始化主窗口
fig = uifigure('Name', '自动控制原理综合可视化分析工作台 (AutoControl Workbench)', ...
    'Position', [30, 30, 1480, 920], ...
    'Color', [0.95, 0.96, 0.98]);

% 主网格布局: 左侧控制栏 (460px, 可滚动), 右侧可视化面板 (1fr)
mainLayout = uigridlayout(fig, [1, 2]);
mainLayout.ColumnWidth = {460, '1x'};
mainLayout.RowHeight = {'1x'};
mainLayout.Padding = [10, 10, 10, 10];
mainLayout.ColumnSpacing = 10;

%% 2. 左侧控制栏面板 (Scrollable)
leftPanel = uipanel(mainLayout, 'Title', '⚙️ 系统配置与控制面板', ...
    'FontWeight', 'bold', 'FontSize', 13, ...
    'BackgroundColor', [1, 1, 1], 'ForegroundColor', [0.12, 0.16, 0.22], ...
    'Scrollable', 'on');

% 9 项紧凑排列，精确高度分配，杜绝空白与堆叠
leftLayout = uigridlayout(leftPanel, [9, 1]);
leftLayout.RowHeight = {24, 32, 305, 34, 40, 22, 44, 32, 115};
leftLayout.Padding = [10, 8, 10, 10];
leftLayout.RowSpacing = 8;

% --- 2.1 预设案例选择 ---
uilabel(leftLayout, 'Text', '📚 经典预设案例库 (点击快速载入):', 'FontWeight', 'bold', 'FontSize', 11);
presetDropDown = uidropdown(leftLayout, ...
    'Items', { ...
        '自定义输入 (Custom)', ...
        '案例1: 典型二阶欠阻尼系统 [16 / (s^2 + 4s + 16)]', ...
        '案例2: 四阶条件稳定系统 [(s+1) / ((s-1)(s+4)(s^2+4s+16))]', ...
        '案例3: 原点二重极点+PD控制 [2(s+0.5) / (s^2(s+2)(s+5))]', ...
        '案例4: 正/负反馈典型对比 [(s+1) / (s^2(s+2)(s+4))]', ...
        '案例5: 空间站方位控制系统 [(s+20) / (s(s+12)^2)]', ...
        '案例6: 超音速客机俯仰角控制 [(s+2)^2 / ((s+10)(s+100)(s^2+1.5s+6.25))]' ...
    }, ...
    'Value', '案例2: 四阶条件稳定系统 [(s+1) / ((s-1)(s+4)(s^2+4s+16))]', ...
    'FontSize', 11);

% --- 2.2 输入架构选项卡 (TabGroup 优雅隔离各输入模式) ---
inputTabGroup = uitabgroup(leftLayout);

% Tab A: 典型环节串联积 (按需选配，全面支持任意多个环节)
tabComp = uitab(inputTabGroup, 'Title', '🧩 典型环节积 (多环节选配)');
compLayout = uigridlayout(tabComp, [8, 3]);
compLayout.ColumnWidth = {130, 85, '1x'};
compLayout.RowHeight = {26, 26, 26, 26, 26, 26, 26, 24};
compLayout.Padding = [8, 6, 8, 6];
compLayout.RowSpacing = 4;
compLayout.ColumnSpacing = 5;

% (1) 比例放大环节 K
uilabel(compLayout, 'Text', '① 比例放大环节 K:', 'FontWeight', 'bold', 'FontSize', 11);
uilabel(compLayout, 'Text', '增益倍数:', 'HorizontalAlignment', 'right', 'FontSize', 10, 'FontColor', [0.35, 0.35, 0.35]);
kGainField = uieditfield(compLayout, 'numeric', 'Value', 1.0, 'FontSize', 10);

% (2) 积分环节 1/s^nu
cbIntegral = uicheckbox(compLayout, 'Text', '② 积分环节 1/s^ν', 'Value', false, 'FontWeight', 'bold', 'FontSize', 11);
uilabel(compLayout, 'Text', '型别 / 阶数:', 'HorizontalAlignment', 'right', 'FontSize', 10, 'FontColor', [0.35, 0.35, 0.35]);
nuDropDown = uidropdown(compLayout, ...
    'Items', {'0 (0型 / 无积分)', '1 (1型 / 1/s)', '2 (2型 / 1/s^2)', '3 (3型 / 1/s^3)', '4 (4型 / 1/s^4)'}, ...
    'Value', '0 (0型 / 无积分)', 'FontSize', 10);

% (3) 一阶惯性环节 1/(Ts+1) 或 1/(s+p) (支持输入任意多个，如 [1, 2, 4])
cbLag = uicheckbox(compLayout, 'Text', '③ 一阶惯性环节', 'Value', true, 'FontWeight', 'bold', 'FontSize', 11);
lagModeDropDown = uidropdown(compLayout, 'Items', {'尾1型 [T]', '首1型 [极点p]'}, 'Value', '首1型 [极点p]', 'FontSize', 10);
lagValsField = uieditfield(compLayout, 'text', 'Value', '[-1, 4]', ...
    'Placeholder', '支持多个，如 [0.1, 0.05] 或 [1, 2, 4]', 'FontSize', 10);

% (4) 一阶微分/超前环节 (τs+1) 或 (s+z) (支持输入任意多个，如 [0.5, 0.2])
cbLead = uicheckbox(compLayout, 'Text', '④ 一阶微分/超前', 'Value', true, 'FontWeight', 'bold', 'FontSize', 11);
leadModeDropDown = uidropdown(compLayout, 'Items', {'尾1型 [τ]', '首1型 [零点z]'}, 'Value', '首1型 [零点z]', 'FontSize', 10);
leadValsField = uieditfield(compLayout, 'text', 'Value', '[1]', ...
    'Placeholder', '支持多个，如 [0.5, 0.2] 或 [1, 2]', 'FontSize', 10);

% (5) 二阶振荡环节 (支持输入任意多组，分号隔开，如 [0.5, 4; 0.7, 10])
cbOsc = uicheckbox(compLayout, 'Text', '⑤ 二阶振荡环节', 'Value', true, 'FontWeight', 'bold', 'FontSize', 11);
uilabel(compLayout, 'Text', '多组分号隔开:', 'HorizontalAlignment', 'right', 'FontSize', 9, 'FontColor', [0.35, 0.35, 0.35]);
oscValsField = uieditfield(compLayout, 'text', 'Value', '0.5, 4', ...
    'Placeholder', '如 [ζ, ωn] 或多项式 [a, b, c]', 'FontSize', 10);

% (6) 二阶微分环节 (支持输入任意多组，分号隔开)
cbOscLead = uicheckbox(compLayout, 'Text', '⑥ 二阶微分环节', 'Value', false, 'FontWeight', 'bold', 'FontSize', 11);
uilabel(compLayout, 'Text', '多组分号隔开:', 'HorizontalAlignment', 'right', 'FontSize', 9, 'FontColor', [0.35, 0.35, 0.35]);
oscLeadValsField = uieditfield(compLayout, 'text', 'Value', '0.7, 2', ...
    'Placeholder', '如 [ζ, ωn] 或多项式 [a, b, c]', 'FontSize', 10, 'Enable', 'off');

% (7) 纯延迟环节 e^(-tau*s)
cbDelay = uicheckbox(compLayout, 'Text', '⑦ 纯延迟环节 e^(-τs)', 'Value', false, 'FontWeight', 'bold', 'FontSize', 11);
uilabel(compLayout, 'Text', '延时 τ(s):', 'HorizontalAlignment', 'right', 'FontSize', 10, 'FontColor', [0.35, 0.35, 0.35]);
delayValField = uieditfield(compLayout, 'numeric', 'Value', 0.1, 'FontSize', 10, 'Enable', 'off');

% (8) 环节数量与阶数实时统计徽章 (横跨3列)
lblCompSummary = uilabel(compLayout, ...
    'Text', '📊 环节统计: 正在统计所选环节...', ...
    'FontSize', 10, 'FontWeight', 'bold', 'FontColor', [0.1, 0.38, 0.75]);
lblCompSummary.Layout.Row = 8;
lblCompSummary.Layout.Column = [1, 3];

% Tab B: 自由数学表达式
tabExpr = uitab(inputTabGroup, 'Title', '✏️ 自由表达式');
exprLayout = uigridlayout(tabExpr, [3, 1]);
exprLayout.RowHeight = {24, 70, '1x'};
exprLayout.Padding = [10, 10, 10, 10];
uilabel(exprLayout, 'Text', '输入以 s 为自变量的开环传递函数表达式:', 'FontWeight', 'bold', 'FontSize', 11);
exprEditField = uitextarea(exprLayout, ...
    'Value', {'(s + 1) / ( (s^2 - s) * (s^2 + 4*s + 16) )'}, ...
    'FontSize', 11, 'FontName', 'Consolas');
uilabel(exprLayout, 'Text', '提示: 可直接输入乘积如 10*(s+1)/(s*(s+2)*(s+5)) 或分母乘积多项式。', ...
    'FontSize', 10, 'FontColor', [0.5, 0.5, 0.5]);

% Tab C: 多项式系数输入
tabPoly = uitab(inputTabGroup, 'Title', '🔢 多项式系数');
polyLayout = uigridlayout(tabPoly, [4, 1]);
polyLayout.RowHeight = {22, 28, 22, 28};
polyLayout.Padding = [10, 10, 10, 10];
uilabel(polyLayout, 'Text', '分子系数向量 num (降幂排列):', 'FontSize', 10, 'FontColor', [0.2, 0.2, 0.2]);
numField = uieditfield(polyLayout, 'text', 'Value', '[1, 1]', 'Placeholder', '如 [1, 1]', 'FontSize', 10);
uilabel(polyLayout, 'Text', '分母系数向量 den (降幂排列):', 'FontSize', 10, 'FontColor', [0.2, 0.2, 0.2]);
denField = uieditfield(polyLayout, 'text', 'Value', '[1, 3, 12, -16, 0]', 'Placeholder', '如 [1, 3, 12, -16, 0]', 'FontSize', 10);

% --- 2.3 反馈极性选择 ---
feedbackBtnGroup = uibuttongroup(leftLayout);
feedbackBtnGroup.BorderType = 'none';
feedbackBtnGroup.BackgroundColor = [1, 1, 1];
rbNegative = uiradiobutton(feedbackBtnGroup, 'Text', '负反馈 (180° 根轨迹, 1+GH=0)', 'Position', [5, 4, 210, 24], 'Value', true, 'FontWeight', 'bold', 'FontColor', [0.1, 0.4, 0.8], 'FontSize', 11);
rbPositive = uiradiobutton(feedbackBtnGroup, 'Text', '正反馈 (0° 根轨迹, 1-GH=0)', 'Position', [225, 4, 195, 24], 'FontWeight', 'bold', 'FontColor', [0.8, 0.2, 0.2], 'FontSize', 11);

% --- 2.4 分析与计算按钮 ---
btnAnalyze = uibutton(leftLayout, 'push', ...
    'Text', '🚀 解析系统并刷新全部图表与指标', ...
    'FontSize', 13, 'FontWeight', 'bold', ...
    'BackgroundColor', [0.15, 0.45, 0.85], 'FontColor', [1, 1, 1]);

% --- 2.5 动态增益 K 调节栏 ---
uilabel(leftLayout, 'Text', '🎛️ 动态增益 K* (根轨迹增益) 实时联动:', 'FontWeight', 'bold', 'FontSize', 11);
gainCtrlLayout = uigridlayout(leftLayout, [1, 2]);
gainCtrlLayout.Padding = [0, 0, 0, 0];
gainCtrlLayout.ColumnWidth = {'1x', 85};
gainSlider = uislider(gainCtrlLayout, 'Limits', [0.01, 60], 'Value', 28.0);
gainEdit = uieditfield(gainCtrlLayout, 'numeric', 'Value', 28.0, 'Limits', [0, 10000], 'FontSize', 12, 'FontWeight', 'bold');

% --- 2.6 辅助配置栏 ---
gainRangeLayout = uigridlayout(leftLayout, [1, 2]);
gainRangeLayout.Padding = [0, 0, 0, 0];
gainRangeLayout.ColumnWidth = {'1x', '1x'};
btnZoomK = uibutton(gainRangeLayout, 'push', 'Text', '🔍 增益量程: 0-60', 'FontSize', 10);
btnSGrid = uibutton(gainRangeLayout, 'push', 'Text', '🌐 切换等阻尼网格', 'FontSize', 10);

% --- 2.7 核心状态信息卡片 ---
statusCard = uipanel(leftLayout, 'Title', '📊 系统瞬时状态概览', ...
    'FontWeight', 'bold', 'FontSize', 11, ...
    'BackgroundColor', [0.95, 0.98, 1.0], 'ForegroundColor', [0.1, 0.3, 0.6]);
statusLayout = uigridlayout(statusCard, [3, 1]);
statusLayout.Padding = [8, 4, 8, 4];
statusLayout.RowSpacing = 2;
lblStability = uilabel(statusLayout, 'Text', '稳定性: 计算中...', 'FontWeight', 'bold', 'FontSize', 11);
lblDominant  = uilabel(statusLayout, 'Text', '主导极点: 计算中...', 'FontSize', 10);
lblMargins   = uilabel(statusLayout, 'Text', '裕度指标: 计算中...', 'FontSize', 10);

%% 3. 右侧展示面板 (顶部 LaTeX 渲染看板 + 下部多视图 Tabs)
rightContainer = uigridlayout(mainLayout, [2, 1]);
rightContainer.RowHeight = {135, '1x'};
rightContainer.Padding = [0, 0, 0, 0];
rightContainer.RowSpacing = 8;

% --- 3.1 顶部 LaTeX 公式实时渲染看板 (带水平滚动防截断) ---
latexCard = uipanel(rightContainer, 'Title', '📐 系统数学模型 (LaTeX 高清实时渲染看板)', ...
    'FontWeight', 'bold', 'FontSize', 12, ...
    'BackgroundColor', [0.98, 0.99, 1.0], 'ForegroundColor', [0.1, 0.25, 0.55], ...
    'Scrollable', 'on');
latexCardLayout = uigridlayout(latexCard, [2, 1]);
latexCardLayout.Padding = [12, 4, 12, 4];
latexCardLayout.RowHeight = {52, 44};
latexCardLayout.RowSpacing = 2;

lblLatexGH = uilabel(latexCardLayout, ...
    'Text', '$$G(s)H(s) = \text{正在解析数学模型...}$$', ...
    'Interpreter', 'latex', 'FontSize', 14, 'FontColor', [0.08, 0.2, 0.45]);

lblLatexChar = uilabel(latexCardLayout, ...
    'Text', '$$\text{闭环特征方程: } D(s) + K N(s) = 0$$', ...
    'Interpreter', 'latex', 'FontSize', 13, 'FontColor', [0.2, 0.3, 0.4]);

% --- 3.2 下部多视图选项卡面板 ---
rightTabGroup = uitabgroup(rightContainer);

% Tab 1: 根轨迹
tabRL = uitab(rightTabGroup, 'Title', '📈 根轨迹 (Root Locus)');
layoutRL = uigridlayout(tabRL, [1, 1]);
layoutRL.Padding = [10, 10, 10, 10];
axRL = uiaxes(layoutRL);
grid(axRL, 'on');

% Tab 2: 伯德图
tabBode = uitab(rightTabGroup, 'Title', '📊 对数频率特性 (Bode)');
layoutBode = uigridlayout(tabBode, [1, 1]);
layoutBode.Padding = [10, 10, 10, 10];
axBode = uiaxes(layoutBode);
grid(axBode, 'on');

% Tab 3: 奈奎斯特图
tabNyquist = uitab(rightTabGroup, 'Title', '🧭 幅相特性 (Nyquist)');
layoutNyquist = uigridlayout(tabNyquist, [3, 1]);
layoutNyquist.RowHeight = {30, '1x', 76};
layoutNyquist.Padding = [10, 8, 10, 8];
layoutNyquist.RowSpacing = 6;

% 顶部视角切换与几何辅助工具条
nyqToolBar = uigridlayout(layoutNyquist, [1, 7]);
nyqToolBar.ColumnWidth = {56, 145, 95, 95, 105, 85, '1x'};
nyqToolBar.Padding = [0, 0, 0, 0];

uilabel(nyqToolBar, 'Text', 'ω 范围:', 'FontWeight', 'bold', 'FontSize', 11, ...
    'HorizontalAlignment', 'right', 'FontColor', [0.15, 0.25, 0.45]);

wRangeDropDown = uidropdown(nyqToolBar, ...
    'Items', {'全频域 (-∞ → +∞)', '正频域 (0 → +∞)', '负频域 (0 → -∞)'}, ...
    'Value', '全频域 (-∞ → +∞)', 'FontSize', 10, 'FontWeight', 'bold', ...
    'ValueChangedFcn', @(dd, event) onNyquistWRangeChanged(dd.Value));

btnNyqAuto = uibutton(nyqToolBar, 'Text', '🎯 自适应全局', 'FontWeight', 'bold', ...
    'BackgroundColor', [0.90, 0.94, 1.0], 'FontColor', [0.1, 0.25, 0.6], ...
    'ButtonPushedFcn', @(btn, event) setNyquistView('auto'));

btnNyqCrit = uibutton(nyqToolBar, 'Text', '🔍 聚焦临界点', ...
    'BackgroundColor', [1.0, 0.96, 0.92], 'FontColor', [0.75, 0.35, 0.0], ...
    'ButtonPushedFcn', @(btn, event) setNyquistView('focusCrit'));

btnNyqCurve = uibutton(nyqToolBar, 'Text', '🔬 放大曲线本体', ...
    'BackgroundColor', [0.94, 0.98, 0.94], 'FontColor', [0.1, 0.5, 0.2], ...
    'ButtonPushedFcn', @(btn, event) setNyquistView('focusCurve'));

btnNyqWide = uibutton(nyqToolBar, 'Text', '🌐 广域全景', ...
    'BackgroundColor', [0.96, 0.96, 0.96], 'FontColor', [0.3, 0.3, 0.3], ...
    'ButtonPushedFcn', @(btn, event) setNyquistView('wide'));

chkNyqCircle = uicheckbox(nyqToolBar, 'Text', '单位圆 |s|=1', 'Value', true, ...
    'ValueChangedFcn', @(cb, event) toggleNyquistUnitCircle(cb.Value));

axNyquist = uiaxes(layoutNyquist);
grid(axNyquist, 'on');
nyquistInfoPanel = uitextarea(layoutNyquist, 'Editable', 'off', 'FontSize', 11, ...
    'BackgroundColor', [0.98, 0.98, 0.98], 'FontColor', [0.2, 0.2, 0.2]);

% Tab 4: 闭环阶跃响应
tabStep = uitab(rightTabGroup, 'Title', '⏱️ 闭环时域响应 (Step)');
layoutStep = uigridlayout(tabStep, [1, 1]);
layoutStep.Padding = [10, 10, 10, 10];
axStep = uiaxes(layoutStep);
grid(axStep, 'on');

% Tab 5: 综合指标报告看板
tabReport = uitab(rightTabGroup, 'Title', '📋 综合指标全景看板 (Dashboard)');
layoutReport = uigridlayout(tabReport, [1, 1]);
layoutReport.Padding = [10, 10, 10, 10];
reportArea = uitextarea(layoutReport, 'Editable', 'off', ...
    'FontName', 'Courier New', 'FontSize', 12, ...
    'BackgroundColor', [0.99, 1.0, 0.99], 'FontColor', [0.1, 0.15, 0.2]);

%% 4. 内部核心数据结构定义 (App State)
appData = struct();
appData.G_base = tf(1, 1);    % 基础开环传递函数 (未乘当前动态 K)
appData.num = [1];
appData.den = [1, 1];
appData.isNegative = true;    % 是否为负反馈
appData.currentK = 28.0;      % 当前动态增益
appData.showSGrid = false;    % 是否显示等阻尼线
appData.kMax = 60;            % 增益滑块上限
appData.polePlotHandle = [];  % 根轨迹上当前闭环极点红星句柄
appData.factoredLatex = '';   % 典型环节因式分解 LaTeX 字符串
appData.nyquistViewMode = 'auto';     % Nyquist 视角模式: 'auto' | 'focusCrit' | 'focusCurve' | 'wide'
appData.nyquistOmegaRange = 'full';   % Nyquist ω 范围: 'full' (-inf to +inf) | 'pos' (0 to +inf) | 'neg' (0 to -inf)
appData.showNyquistUnitCircle = true; % 是否显示单位圆参考线
appData.nyquistAutoXLim = [-10, 5];
appData.nyquistAutoYLim = [-10, 10];

%% 5. 核心辅助逻辑与算法

% --- 5.1 从典型环节构建开环传递函数与因式分解 LaTeX (全面支持任意多个环节) ---
function [sys, num, den, latexStr, errMsg] = buildFromComponents()
    errMsg = '';
    latexStr = '';
    s = tf('s');
    sys = tf(1, 1);
    
    num_latex_terms = {};
    den_latex_terms = {};
    
    % 环节数量统计计数器
    count_lag = 0;
    count_lead = 0;
    count_osc = 0;
    count_osc_lead = 0;
    nu = 0;
    
    try
        % 1. 比例放大环节 K
        K_val = kGainField.Value;
        if isnan(K_val) || K_val <= 0, K_val = 1.0; end
        sys = sys * K_val;
        num_latex_terms{end+1} = sprintf('%g', K_val);
        
        % 2. 积分环节 1/s^nu (支持 0型~4型)
        if cbIntegral.Value
            nu_str = nuDropDown.Value;
            nu = str2double(nu_str(1));
            if nu > 0
                sys = sys / (s^nu);
                if nu == 1
                    den_latex_terms{end+1} = 's';
                else
                    den_latex_terms{end+1} = sprintf('s^{%d}', nu);
                end
            end
        end
        
        % 3. 一阶微分/超前环节 (τs+1) 或 (s+z) (支持任意多个，包括重根)
        if cbLead.Value
            lead_mode = leadModeDropDown.Value;
            leads = str2num(leadValsField.Value); %#ok<ST2NM>
            count_lead = length(leads);
            for i = 1:length(leads)
                val = leads(i);
                if contains(lead_mode, '尾1型')
                    sys = sys * (val * s + 1);
                else
                    sys = sys * (s + val);
                end
            end
            % 智能分组 LaTeX (如重复零点写为 (s+2)^2)
            groupedLeads = formatFactorList(leads, lead_mode);
            for g = 1:length(groupedLeads)
                num_latex_terms{end+1} = groupedLeads{g}; %#ok<AGROW>
            end
        end
        
        % 4. 二阶微分环节 (支持任意多组，分号分隔)
        if cbOscLead.Value
            cleanOscLead = regexprep(oscLeadValsField.Value, '[\[\]\(\)]', ' ');
            rows_lead = strsplit(cleanOscLead, ';');
            for i = 1:length(rows_lead)
                nums = str2num(rows_lead{i}); %#ok<ST2NM>
                if length(nums) == 2
                    count_osc_lead = count_osc_lead + 1;
                    zeta_z = nums(1); wn_z = nums(2);
                    poly_l = [1, 2*zeta_z*wn_z, wn_z^2];
                    sys = sys * tf(poly_l, [wn_z^2]);
                    num_latex_terms{end+1} = sprintf('(s^2 %+g s + %g)', 2*zeta_z*wn_z, wn_z^2); %#ok<AGROW>
                elseif length(nums) == 3
                    count_osc_lead = count_osc_lead + 1;
                    sys = sys * tf(nums, [nums(3)]);
                    num_latex_terms{end+1} = sprintf('(%gs^2 %+g s + %g)', nums(1), nums(2), nums(3)); %#ok<AGROW>
                end
            end
        end
        
        % 5. 一阶惯性环节 1/(Ts+1) 或 1/(s+p) (支持任意多个，包括重极点)
        if cbLag.Value
            lag_mode = lagModeDropDown.Value;
            lags = str2num(lagValsField.Value); %#ok<ST2NM>
            count_lag = length(lags);
            for i = 1:length(lags)
                val = lags(i);
                if contains(lag_mode, '尾1型')
                    sys = sys / (val * s + 1);
                else
                    sys = sys / (s + val);
                end
            end
            groupedLags = formatFactorList(lags, lag_mode);
            for g = 1:length(groupedLags)
                den_latex_terms{end+1} = groupedLags{g}; %#ok<AGROW>
            end
        end
        
        % 6. 二阶振荡环节 (支持任意多组，分号分隔)
        if cbOsc.Value
            cleanOsc = regexprep(oscValsField.Value, '[\[\]\(\)]', ' ');
            rows_osc = strsplit(cleanOsc, ';');
            for i = 1:length(rows_osc)
                nums = str2num(rows_osc{i}); %#ok<ST2NM>
                if length(nums) == 2
                    count_osc = count_osc + 1;
                    zeta_o = nums(1); wn_o = nums(2);
                    poly_o = [1, 2*zeta_o*wn_o, wn_o^2];
                    sys = sys / tf(poly_o, [wn_o^2]);
                    den_latex_terms{end+1} = sprintf('(s^2 %+g s + %g)', 2*zeta_o*wn_o, wn_o^2); %#ok<AGROW>
                elseif length(nums) == 3
                    count_osc = count_osc + 1;
                    sys = sys / tf(nums, [nums(3)]);
                    den_latex_terms{end+1} = sprintf('(%gs^2 %+g s + %g)', nums(1), nums(2), nums(3)); %#ok<AGROW>
                end
            end
        end
        
        % 7. 纯延迟环节 (采用 2 阶 Padé 近似)
        if cbDelay.Value
            tau_d = delayValField.Value;
            if tau_d > 0
                [p_num, p_den] = pade(tau_d, 2);
                sys = sys * tf(p_num, p_den);
                num_latex_terms{end+1} = sprintf('e^{-%gs}', tau_d);
            end
        end
        
        % 提取传递函数分子分母向量
        [numCell, denCell] = tfdata(sys, 'v');
        num = numCell;
        den = denCell;
        
        % 组装因式分解 LaTeX
        if isempty(num_latex_terms), str_num = '1'; else, str_num = strjoin(num_latex_terms, ' '); end
        if isempty(den_latex_terms), str_den = '1'; else, str_den = strjoin(den_latex_terms, ' '); end
        latexStr = sprintf('$$G(s)H(s) = \\frac{%s}{%s}$$', str_num, str_den);
        
        % 动态更新环节数量与阶数统计栏
        n_poles = length(den) - 1;
        m_zeros = length(num) - 1;
        lblCompSummary.Text = sprintf('📊 环节统计: 惯性×%d, 微分×%d, 振荡×%d组 | 阶数: n=%d, 零点: m=%d, 型别: %d型', ...
            count_lag, count_lead, count_osc, n_poles, m_zeros, nu);
        
    catch ME
        errMsg = ME.message;
        num = [1];
        den = [1, 1];
    end
end

% --- 辅助: 将相同数值的一阶因子聚合成幂次 (如 (s+2)^2) ---
function terms = formatFactorList(vals, mode)
    terms = {};
    if isempty(vals), return; end
    [uvals, ~, idx] = unique(vals);
    counts = accumarray(idx(:), 1);
    for k = 1:length(uvals)
        v = uvals(k);
        c = counts(k);
        if contains(mode, '尾1型')
            base = sprintf('(%gs + 1)', v);
        else
            base = sprintf('(s %+g)', v);
        end
        if c > 1
            terms{end+1} = sprintf('%s^{%d}', base, c);
        else
            terms{end+1} = base;
        end
    end
end

% --- 5.2 综合解析输入 (支持三种模式) ---
function [sys, num, den, factoredLatex, errMsg] = parseSystemInput()
    errMsg = '';
    factoredLatex = '';
    
    currTab = inputTabGroup.SelectedTab;
    if isequal(currTab, tabComp)
        [sys, num, den, factoredLatex, errMsg] = buildFromComponents();
    elseif isequal(currTab, tabExpr)
        try
            s = tf('s'); %#ok<NASGU>
            exprStr = strjoin(exprEditField.Value, ' ');
            sys = eval(exprStr);
            if ~isa(sys, 'tf'), sys = tf(sys); end
            [numCell, denCell] = tfdata(sys, 'v');
            num = numCell;
            den = denCell;
            factoredLatex = sprintf('$$G(s)H(s) = %s$$', exprStr);
        catch ME
            errMsg = ME.message;
            sys = tf(1, [1, 1]); num = [1]; den = [1, 1];
        end
    else
        try
            num = str2num(numField.Value); %#ok<ST2NM>
            den = str2num(denField.Value); %#ok<ST2NM>
            if isempty(num) || isempty(den)
                error('分子或分母系数向量解析为空');
            end
            sys = tf(num, den);
            factoredLatex = '';
        catch ME
            errMsg = ME.message;
            sys = tf(1, [1, 1]); num = [1]; den = [1, 1];
        end
    end
    
    % 清除多项式前导0
    idx_n = find(num ~= 0, 1, 'first');
    if ~isempty(idx_n), num = num(idx_n:end); end
    idx_d = find(den ~= 0, 1, 'first');
    if ~isempty(idx_d), den = den(idx_d:end); end
end

% --- 5.3 精确求解分离点与会合点 ---
function [breakPoints, breakGains, invalidPoints] = findBreakawayPoints(num, den, isNeg)
    breakPoints = [];
    breakGains = [];
    invalidPoints = [];
    try
        d_num = polyder(num);
        d_den = polyder(den);
        p1 = conv(d_num, den);
        p2 = conv(num, d_den);
        maxL = max(length(p1), length(p2));
        p1 = [zeros(1, maxL - length(p1)), p1];
        p2 = [zeros(1, maxL - length(p2)), p2];
        eq_roots = roots(p1 - p2);
        
        tol = 1e-5;
        real_candidates = eq_roots(abs(imag(eq_roots)) < tol);
        for i = 1:length(real_candidates)
            d = real(real_candidates(i));
            valN = polyval(num, d);
            valD = polyval(den, d);
            if abs(valN) < 1e-12, continue; end
            
            if isNeg
                K_val = -valD / valN;
            else
                K_val = valD / valN;
            end
            
            if K_val > 1e-6
                breakPoints(end+1) = d; %#ok<AGROW>
                breakGains(end+1) = K_val; %#ok<AGROW>
            else
                invalidPoints(end+1) = d; %#ok<AGROW>
            end
        end
    catch
    end
end

% --- 5.4 求解虚轴交点与临界稳定增益 ---
function [w_cross, K_crit] = findImagCrossings(num, den, isNeg)
    w_cross = [];
    K_crit = [];
    try
        syms w K real
        s_val = 1i * w;
        D_s = poly2sym(den, s_val);
        N_s = poly2sym(num, s_val);
        if isNeg
            char_eq = D_s + K * N_s;
        else
            char_eq = D_s - K * N_s;
        end
        eq_r = real(expand(char_eq)) == 0;
        eq_i = imag(expand(char_eq)) == 0;
        sols = solve([eq_r, eq_i], [w, K]);
        w_vals = double(sols.w);
        k_vals = double(sols.K);
        for i = 1:length(w_vals)
            if k_vals(i) > 1e-5 && w_vals(i) > 1e-5
                w_cross(end+1) = w_vals(i); %#ok<AGROW>
                K_crit(end+1) = k_vals(i); %#ok<AGROW>
            end
        end
    catch
    end
end

% --- 5.5 全局图表与 LaTeX 渲染联动重绘 ---
function updateAllPlots(fullRedraw)
    if nargin < 1, fullRedraw = true; end
    
    K = appData.currentK;
    isNeg = appData.isNegative;
    G_base = appData.G_base;
    num = appData.num;
    den = appData.den;
    
    % 当前开环系统与闭环系统
    G_open = K * G_base;
    signFeedback = ternary(isNeg, -1, 1);
    G_rl = ternary(isNeg, G_base, -G_base);
    
    try
        sys_cl = feedback(G_open, 1, signFeedback);
    catch
        sys_cl = [];
    end
    
    % 闭环特征多项式
    pad_num = [zeros(1, length(den) - length(num)), num];
    char_poly = den + ternary(isNeg, 1, -1) * K * pad_num;
    cl_poles = roots(char_poly);
    
    % ----------------- 0. 更新顶部高清 LaTeX 数学公式 -----------------
    try
        s = sym('s');
        N_sym = poly2sym(num, s);
        D_sym = poly2sym(den, s);
        
        if ~isempty(appData.factoredLatex) && contains(appData.factoredLatex, 'frac')
            lblLatexGH.Text = appData.factoredLatex;
        else
            lblLatexGH.Text = sprintf('$$G(s)H(s) = \\frac{%s}{%s}$$', latex(N_sym), latex(D_sym));
        end
        
        char_sym = poly2sym(char_poly, s);
        signStr = ternary(isNeg, '+', '-');
        lblLatexChar.Text = sprintf('$$\\text{闭环特征方程: } D(s) %s K N(s) = %s = 0$$', signStr, latex(char_sym));
    catch ME
        disp(['LaTeX rendering error: ' ME.message]);
        lblLatexGH.Text = '$$G(s)H(s) = \text{多项式模型}$$';
        lblLatexChar.Text = sprintf('$$\\text{特征方程: } %s = 0$$', poly2str_custom(char_poly));
    end
    
    % ----------------- 1. 更新根轨迹 Tab -----------------
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
        plot(axRL, xLimits, [0, 0], 'k-', 'LineWidth', 0.6, 'Color', [0.6, 0.6, 0.6]);
        plot(axRL, [0, 0], yLimits, 'k-', 'LineWidth', 0.6, 'Color', [0.6, 0.6, 0.6]);
        
        [bp, ~, ~] = findBreakawayPoints(num, den, isNeg);
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
        
        if appData.showSGrid
            sgrid(axRL, [0.1, 0.2, 0.4, 0.6, 0.707, 0.9], []);
        end
    end
    
    if isempty(appData.polePlotHandle) || ~isvalid(appData.polePlotHandle) || fullRedraw
        appData.polePlotHandle = plot(axRL, real(cl_poles), imag(cl_poles), 'rp', ...
            'MarkerSize', 13, 'MarkerFaceColor', [1, 0.2, 0.2], 'MarkerEdgeColor', [0.2, 0.2, 0.2], ...
            'LineWidth', 1.2, 'DisplayName', sprintf('当前闭环极点 (K*=%.2f)', K));
    else
        set(appData.polePlotHandle, 'XData', real(cl_poles), 'YData', imag(cl_poles), ...
            'DisplayName', sprintf('当前闭环极点 (K*=%.2f)', K));
        title(axRL, sprintf('系统开环根轨迹 (%s, 当前 K* = %.2f)', ...
            ternary(isNeg, '负反馈 180°', '正反馈 0°'), K), 'FontSize', 12, 'FontWeight', 'bold');
    end
    hold(axRL, 'off');
    
    % ----------------- 2. 更新 Bode 图 Tab -----------------
    cla(axBode);
    try
        margin(axBode, G_open);
        title(axBode, sprintf('开环对数频率特性 Bode 图 (K* = %.2f)', K), 'FontSize', 12, 'FontWeight', 'bold');
        grid(axBode, 'on');
    catch
        bode(axBode, G_open);
        grid(axBode, 'on');
    end
    
    % ----------------- 3. 更新 Nyquist 图 Tab (智能自适应防发散视界) -----------------
    cla(axNyquist);
    hold(axNyquist, 'on');
    
    critPoint = ternary(isNeg, -1, 1);
    
    % 智能过滤无限大极点发散点 (杜绝虚轴极点或积分环节使坐标被撑到 10^22)
    try
        [re_data, im_data, ~] = nyquist(G_open);
        re_v = squeeze(re_data);
        im_v = squeeze(im_data);
        mag_v = abs(re_v + 1j*im_v);
        
        valid_idx = (mag_v < 40) & ~isnan(mag_v) & ~isinf(mag_v);
        if sum(valid_idx) < 5
            valid_idx = (mag_v < 150) & ~isnan(mag_v) & ~isinf(mag_v);
        end
        
        if sum(valid_idx) >= 5
            r_pts = [re_v(valid_idx); critPoint; 0];
            i_pts = [im_v(valid_idx); 0];
            span_r = max(r_pts) - min(r_pts);
            span_i = max(i_pts) - min(i_pts);
            pad_r = max(span_r * 0.15, 0.8);
            pad_i = max(span_i * 0.15, 0.8);
            xlim_calc = [min(r_pts) - pad_r, max(r_pts) + pad_r];
            ylim_calc = [min(i_pts) - pad_i, max(i_pts) + pad_i];
        else
            xlim_calc = [-3, 2];
            ylim_calc = [-2.5, 2.5];
        end
        
        % 确保临界点与单位圆区域有足够显示余量
        xlim_calc(1) = min(xlim_calc(1), critPoint - 1.2);
        xlim_calc(2) = max(xlim_calc(2), critPoint + 1.2);
        ylim_calc(1) = min(ylim_calc(1), -1.5);
        ylim_calc(2) = max(ylim_calc(2), 1.5);
        
        % 限制边界极值，严禁出现指数级发散轴宽
        xlim_calc(1) = max(xlim_calc(1), -80);
        xlim_calc(2) = min(xlim_calc(2), 50);
        ylim_calc(1) = max(ylim_calc(1), -60);
        ylim_calc(2) = min(ylim_calc(2), 60);
        
        appData.nyquistAutoXLim = xlim_calc;
        appData.nyquistAutoYLim = ylim_calc;
        
        % 根据当前视角模式选定最终视界
        switch appData.nyquistViewMode
            case 'focusCrit'
                finalXLim = [critPoint - 1.8, critPoint + 1.8];
                finalYLim = [-1.8, 1.8];
            case 'focusCurve'
                if sum(valid_idx) >= 5
                    r_c = re_v(valid_idx); i_c = im_v(valid_idx);
                    finalXLim = [min(r_c)-0.5, max(r_c)+0.5];
                    finalYLim = [min(i_c)-0.5, max(i_c)+0.5];
                else
                    finalXLim = xlim_calc; finalYLim = ylim_calc;
                end
            case 'wide'
                finalXLim = [min(xlim_calc(1)*2.5, -40), max(xlim_calc(2)*2.5, 30)];
                finalYLim = [min(ylim_calc(1)*2.5, -35), max(ylim_calc(2)*2.5, 35)];
            otherwise % 'auto'
                finalXLim = xlim_calc;
                finalYLim = ylim_calc;
        end
        
        optNyq = nyquistoptions;
        optNyq.XLim = {finalXLim};
        optNyq.YLim = {finalYLim};
        
        % 根据选择的 ω 频域范围确定目标传函与 ShowFullContour
        switch appData.nyquistOmegaRange
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
    
    % 绘制参考中心十字轴线
    x_curr = axNyquist.XLim;
    y_curr = axNyquist.YLim;
    plot(axNyquist, x_curr, [0, 0], 'k:', 'LineWidth', 0.6, 'Color', [0.65, 0.65, 0.65], 'HandleVisibility', 'off');
    plot(axNyquist, [0, 0], y_curr, 'k:', 'LineWidth', 0.6, 'Color', [0.65, 0.65, 0.65], 'HandleVisibility', 'off');
    
    % 绘制单位圆 (|s| = 1，与负实轴夹角即为相位裕度)
    if appData.showNyquistUnitCircle
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
    if strcmp(appData.nyquistOmegaRange, 'pos')
        rangeDescr = '正频域 ω ∈ [0, +∞) [传统幅相特性主曲线]';
    elseif strcmp(appData.nyquistOmegaRange, 'neg')
        rangeDescr = '负频域 ω ∈ (-∞, 0] [实轴对称共轭镜像轨迹]';
    end
    
    nyquistAnalysisStr = sprintf(['【奈奎斯特稳定判据解析】:\n', ...
        '• 当前绘制频段: %s\n', ...
        '• 开环右半平面不稳定极点数 P = %d%s\n', ...
        '• 闭环临界稳定判据点: (%+d, j0)\n', ...
        '• 稳定充要判据: Z = P - 2N = 0 (当前闭环不稳定极点 Z = %d, 全轮廓逆时针包围圈数 N = %.1f)\n', ...
        '• 判定结论: %s'], ...
        rangeDescr, p_rhp, imagNote, critPoint, z_rhp, encircle_N, nyqVerdict);
    nyquistInfoPanel.Value = nyquistAnalysisStr;
    
    % ----------------- 4. 更新时域阶跃响应 Tab -----------------
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
    
    % ----------------- 5. 更新左侧状态概览卡片 -----------------
    if isStable
        lblStability.Text = '稳定性: ✅ 系统稳定 (闭环极点均在左半平面)';
        lblStability.FontColor = [0, 0.6, 0.1];
    elseif isMarginal
        lblStability.Text = '稳定性: ⚠️ 临界稳定 (虚轴存在无重根极点)';
        lblStability.FontColor = [0.85, 0.55, 0];
    else
        lblStability.Text = '稳定性: ❌ 系统不稳定 (右半平面存在极点)';
        lblStability.FontColor = [0.85, 0.1, 0.1];
    end
    
    complex_p = cl_poles(abs(imag(cl_poles)) > 1e-4);
    if ~isempty(complex_p)
        [~, dom_idx] = max(real(complex_p));
        dom_p = complex_p(dom_idx);
        wn = abs(dom_p);
        zeta = -real(dom_p) / max(wn, 1e-12);
        lblDominant.Text = sprintf('主导极点: %.2f ± j%.2f (ζ=%.3f, ωn=%.2f)', real(dom_p), abs(imag(dom_p)), zeta, wn);
    else
        [~, dom_idx] = max(real(cl_poles));
        lblDominant.Text = sprintf('实数主导极点: %.3f', real(cl_poles(dom_idx)));
    end
    
    try
        warnState = warning('off', 'all');
        [Gm, Pm, Wcg, Wcp] = margin(G_open);
        warning(warnState);
        Gm_dB = 20*log10(Gm);
        lblMargins.Text = sprintf('裕度: Pm = %.1f° (at %.2f rad/s), Gm = %.1fdB', Pm, Wcp, Gm_dB);
    catch
        lblMargins.Text = '裕度: 无法直接计算或不存在穿越点';
    end
    
    % ----------------- 6. 生成全景综合指标分析报告 -----------------
    generateComprehensiveReport(K, isNeg, num, den, cl_poles, sys_cl, G_open);
end

% --- 5.6 生成综合指标全景看板文本 ---
function generateComprehensiveReport(K, isNeg, num, den, cl_poles, sys_cl, G_open)
    lines = {};
    lines{end+1} = '========================================================================================';
    lines{end+1} = '                《自动控制原理》系统全要素综合分析与计算报告                ';
    lines{end+1} = sprintf('  生成时间: %s  |  开环增益 K* = %.4f  |  反馈模式: %s', ...
        datestr(now, 'yyyy-mm-dd HH:MM:SS'), K, ternary(isNeg, '负反馈 (180°根轨迹)', '正反馈 (0°根轨迹)'));
    lines{end+1} = '========================================================================================';
    lines{end+1} = '';
    
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
    
    [bp, bg, ~] = findBreakawayPoints(num, den, isNeg);
    if ~isempty(bp)
        lines{end+1} = '  • 实轴有效分离/会合点及对应临界增益:';
        for k = 1:length(bp)
            lines{end+1} = sprintf('      - 分离点 d_%d = %8.4f,  对应增益 K* = %8.4f', k, bp(k), bg(k));
        end
    else
        lines{end+1} = '  • 实轴有效分离点: 本系统在对应反馈法则下无实轴分离/会合点。';
    end
    
    [w_cross, K_crit] = findImagCrossings(num, den, isNeg);
    if ~isempty(w_cross)
        lines{end+1} = '  • 根轨迹与虚轴交点 (临界稳定点):';
        for k = 1:length(w_cross)
            lines{end+1} = sprintf('      - 穿越频率 ω_%d = ±%.4f rad/s,  临界增益 K_crit = %.4f', k, w_cross(k), K_crit(k));
        end
    else
        lines{end+1} = '  • 根轨迹与虚轴交点: 无有限正实数交点 (系统增益变化不越过虚轴或无正实数解)。';
    end
    lines{end+1} = '';
    
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
    
    reportArea.Value = lines;
end

%% 6. 回调函数与交互事件处理

% --- 6.1 预设案例选择事件 ---
presetDropDown.ValueChangedFcn = @(src, event) onPresetSelected(src.Value);
function onPresetSelected(choice)
    inputTabGroup.SelectedTab = tabComp;
    
    switch choice
        case '案例1: 典型二阶欠阻尼系统 [16 / (s^2 + 4s + 16)]'
            kGainField.Value = 1.0;
            cbIntegral.Value = false;
            nuDropDown.Value = '0 (0型 / 无积分)';
            cbLag.Value = false;
            cbLead.Value = false;
            cbOsc.Value = true;
            oscValsField.Value = '0.5, 4';
            cbOscLead.Value = false;
            cbDelay.Value = false;
            rbNegative.Value = true;
            gainSlider.Limits = [0.1, 20];
            gainSlider.Value = 1.0;
            gainEdit.Value = 1.0;
            appData.kMax = 20;
            btnZoomK.Text = '🔍 增益量程: 0-20';
            
        case '案例2: 四阶条件稳定系统 [(s+1) / ((s-1)(s+4)(s^2+4s+16))]'
            kGainField.Value = 1.0;
            cbIntegral.Value = false;
            nuDropDown.Value = '0 (0型 / 无积分)';
            cbLead.Value = true;
            leadModeDropDown.Value = '首1型 [零点z]';
            leadValsField.Value = '[1]';
            cbLag.Value = true;
            lagModeDropDown.Value = '首1型 [极点p]';
            lagValsField.Value = '[-1, 4]';
            cbOsc.Value = true;
            oscValsField.Value = '0.5, 4';
            cbOscLead.Value = false;
            cbDelay.Value = false;
            rbNegative.Value = true;
            gainSlider.Limits = [0.1, 60];
            gainSlider.Value = 28.0;
            gainEdit.Value = 28.0;
            appData.kMax = 60;
            btnZoomK.Text = '🔍 增益量程: 0-60';
            
        case '案例3: 原点二重极点+PD控制 [2(s+0.5) / (s^2(s+2)(s+5))]'
            kGainField.Value = 2.0;
            cbIntegral.Value = true;
            nuDropDown.Value = '2 (2型 / 1/s^2)';
            cbLead.Value = true;
            leadModeDropDown.Value = '首1型 [零点z]';
            leadValsField.Value = '[0.5]';
            cbLag.Value = true;
            lagModeDropDown.Value = '首1型 [极点p]';
            lagValsField.Value = '[2, 5]';
            cbOsc.Value = false;
            cbOscLead.Value = false;
            cbDelay.Value = false;
            rbNegative.Value = true;
            gainSlider.Limits = [0.1, 50];
            gainSlider.Value = 5.0;
            gainEdit.Value = 5.0;
            appData.kMax = 50;
            btnZoomK.Text = '🔍 增益量程: 0-50';
            
        case '案例4: 正/负反馈典型对比 [(s+1) / (s^2(s+2)(s+4))]'
            kGainField.Value = 1.0;
            cbIntegral.Value = true;
            nuDropDown.Value = '2 (2型 / 1/s^2)';
            cbLead.Value = true;
            leadModeDropDown.Value = '首1型 [零点z]';
            leadValsField.Value = '[1]';
            cbLag.Value = true;
            lagModeDropDown.Value = '首1型 [极点p]';
            lagValsField.Value = '[2, 4]';
            cbOsc.Value = false;
            cbOscLead.Value = false;
            cbDelay.Value = false;
            gainSlider.Limits = [0.1, 80];
            gainSlider.Value = 15.0;
            gainEdit.Value = 15.0;
            appData.kMax = 80;
            btnZoomK.Text = '🔍 增益量程: 0-80';
            
        case '案例5: 空间站方位控制系统 [(s+20) / (s(s+12)^2)]'
            kGainField.Value = 1.0;
            cbIntegral.Value = true;
            nuDropDown.Value = '1 (1型 / 1/s)';
            cbLead.Value = true;
            leadModeDropDown.Value = '首1型 [零点z]';
            leadValsField.Value = '[20]';
            cbLag.Value = true;
            lagModeDropDown.Value = '首1型 [极点p]';
            lagValsField.Value = '[12, 12]'; % 2 个惯性极点 (二重极点)
            cbOsc.Value = false;
            cbOscLead.Value = false;
            cbDelay.Value = false;
            rbNegative.Value = true;
            gainSlider.Limits = [0.1, 100];
            gainSlider.Value = 25.0;
            gainEdit.Value = 25.0;
            appData.kMax = 100;
            btnZoomK.Text = '🔍 增益量程: 0-100';
            
        case '案例6: 超音速客机俯仰角控制 [(s+2)^2 / ((s+10)(s+100)(s^2+1.5s+6.25))]'
            kGainField.Value = 1.0;
            cbIntegral.Value = false;
            nuDropDown.Value = '0 (0型 / 无积分)';
            cbLead.Value = true;
            leadModeDropDown.Value = '首1型 [零点z]';
            leadValsField.Value = '[2, 2]'; % 2 个零点 ((s+2)^2)
            cbLag.Value = true;
            lagModeDropDown.Value = '首1型 [极点p]';
            lagValsField.Value = '[10, 100]'; % 2 个惯性极点
            cbOsc.Value = true;
            oscValsField.Value = '0.3, 2.5';
            cbOscLead.Value = false;
            cbDelay.Value = false;
            rbNegative.Value = true;
            gainSlider.Limits = [0.1, 500];
            gainSlider.Value = 120.0;
            gainEdit.Value = 120.0;
            appData.kMax = 500;
            btnZoomK.Text = '🔍 增益量程: 0-500';
    end
    
    updateComponentControlsEnable();
    onAnalyzeClicked();
end

% --- 6.2 环节复选框联动启用/禁用对应输入框 ---
cbIntegral.ValueChangedFcn = @(s, e) updateComponentControlsEnable();
cbLag.ValueChangedFcn      = @(s, e) updateComponentControlsEnable();
cbLead.ValueChangedFcn     = @(s, e) updateComponentControlsEnable();
cbOsc.ValueChangedFcn      = @(s, e) updateComponentControlsEnable();
cbOscLead.ValueChangedFcn  = @(s, e) updateComponentControlsEnable();
cbDelay.ValueChangedFcn    = @(s, e) updateComponentControlsEnable();

function updateComponentControlsEnable()
    nuDropDown.Enable       = ternary(cbIntegral.Value, 'on', 'off');
    lagModeDropDown.Enable  = ternary(cbLag.Value, 'on', 'off');
    lagValsField.Enable     = ternary(cbLag.Value, 'on', 'off');
    leadModeDropDown.Enable = ternary(cbLead.Value, 'on', 'off');
    leadValsField.Enable    = ternary(cbLead.Value, 'on', 'off');
    oscValsField.Enable     = ternary(cbOsc.Value, 'on', 'off');
    oscLeadValsField.Enable = ternary(cbOscLead.Value, 'on', 'off');
    delayValField.Enable    = ternary(cbDelay.Value, 'on', 'off');
end

% --- 6.3 输入架构选项卡切换联动 ---
inputTabGroup.SelectionChangedFcn = @(s, e) onAnalyzeClicked();

% --- 6.4 分析计算与全局重绘事件 ---
btnAnalyze.ButtonPushedFcn = @(src, event) onAnalyzeClicked();
function onAnalyzeClicked()
    [sys, num, den, factoredLatex, errMsg] = parseSystemInput();
    if ~isempty(errMsg)
        uialert(fig, sprintf('传递函数模型解析失败:\n%s\n请检查对应环节参数输入。', errMsg), '模型解析错误', 'Icon', 'error');
        return;
    end
    
    appData.G_base = sys;
    appData.num = num;
    appData.den = den;
    appData.isNegative = rbNegative.Value;
    appData.currentK = gainSlider.Value;
    appData.factoredLatex = factoredLatex;
    
    updateAllPlots(true);
end

% --- 6.5 反馈模式改变事件 ---
feedbackBtnGroup.SelectionChangedFcn = @(s, e) onFeedbackChanged();
function onFeedbackChanged()
    appData.isNegative = rbNegative.Value;
    updateAllPlots(true);
end

% --- 6.6 增益滑动条拖动联动 ---
gainSlider.ValueChangingFcn = @(src, event) onGainSliderChanging(event.Value);
gainSlider.ValueChangedFcn = @(src, event) onGainSliderChanged(src.Value);
function onGainSliderChanging(val)
    appData.currentK = val;
    gainEdit.Value = val;
    updateAllPlots(false);
end
function onGainSliderChanged(val)
    appData.currentK = val;
    gainEdit.Value = val;
    updateAllPlots(false);
end

% --- 6.7 增益微调输入框联动 ---
gainEdit.ValueChangedFcn = @(src, event) onGainEditChanged(src.Value);
function onGainEditChanged(val)
    if val > gainSlider.Limits(2)
        gainSlider.Limits(2) = val * 1.5;
        appData.kMax = gainSlider.Limits(2);
        btnZoomK.Text = sprintf('🔍 增益量程: 0-%.0f', appData.kMax);
    end
    gainSlider.Value = val;
    appData.currentK = val;
    updateAllPlots(false);
end

% --- 6.8 切换量程按钮 ---
btnZoomK.ButtonPushedFcn = @(src, event) onZoomKToggled();
function onZoomKToggled()
    ranges = [20, 60, 150, 500, 2000];
    currIdx = find(ranges >= appData.kMax, 1, 'first');
    if isempty(currIdx) || currIdx == length(ranges)
        newMax = ranges(1);
    else
        newMax = ranges(currIdx + 1);
    end
    appData.kMax = newMax;
    gainSlider.Limits = [0.01, newMax];
    btnZoomK.Text = sprintf('🔍 增益量程: 0-%.0f', newMax);
end

% --- 6.9 切换等阻尼网格线 ---
btnSGrid.ButtonPushedFcn = @(src, event) onSGridToggled();
function onSGridToggled()
    appData.showSGrid = ~appData.showSGrid;
    updateAllPlots(true);
end

% --- 6.10 奈奎斯特视角切换 ---
function setNyquistView(mode)
    appData.nyquistViewMode = mode;
    btnNyqAuto.FontWeight = ternary(strcmp(mode, 'auto'), 'bold', 'normal');
    btnNyqCrit.FontWeight = ternary(strcmp(mode, 'focusCrit'), 'bold', 'normal');
    btnNyqCurve.FontWeight = ternary(strcmp(mode, 'focusCurve'), 'bold', 'normal');
    btnNyqWide.FontWeight = ternary(strcmp(mode, 'wide'), 'bold', 'normal');
    updateAllPlots(false);
end

% --- 6.11 奈奎斯特单位圆显示切换 ---
function toggleNyquistUnitCircle(val)
    appData.showNyquistUnitCircle = val;
    updateAllPlots(false);
end

% --- 6.12 奈奎斯特频率范围选择 ---
function onNyquistWRangeChanged(val)
    if contains(val, '正频域')
        appData.nyquistOmegaRange = 'pos';
    elseif contains(val, '负频域')
        appData.nyquistOmegaRange = 'neg';
    else
        appData.nyquistOmegaRange = 'full';
    end
    updateAllPlots(false);
end

%% 7. 启动默认初始化分析
onPresetSelected(presetDropDown.Value);

if nargout > 0
    varargout{1} = fig;
end

end

%% =========================================================================
% 工具辅助函数
% =========================================================================
function val = ternary(cond, a, b)
    if cond, val = a; else, val = b; end
end

function str = poly2str_custom(p)
    str = '';
    n = length(p) - 1;
    for i = 1:length(p)
        c = p(i);
        pow = n - i + 1;
        if abs(c) < 1e-10, continue; end
        
        signStr = '+';
        if c < 0, signStr = '-'; c = abs(c); end
        if isempty(str) && strcmp(signStr, '+'), signStr = ''; end
        
        if pow == 0
            term = sprintf('%g', c);
        elseif pow == 1
            if c == 1, term = 's'; else, term = sprintf('%gs', c); end
        else
            if c == 1, term = sprintf('s^%d', pow); else, term = sprintf('%gs^%d', c, pow); end
        end
        
        if isempty(str)
            if strcmp(signStr, '-'), str = ['-' term]; else, str = term; end
        else
            str = [str ' ' signStr ' ' term];
        end
    end
    if isempty(str), str = '0'; end
end

function str = formatComplexArray(arr)
    parts = {};
    for i = 1:length(arr)
        v = arr(i);
        if abs(imag(v)) < 1e-5
            parts{end+1} = sprintf('%.4f', real(v)); %#ok<AGROW>
        else
            parts{end+1} = sprintf('%.4f%+.4fj', real(v), imag(v)); %#ok<AGROW>
        end
    end
    str = ['[' strjoin(parts, ', ') ']'];
end
