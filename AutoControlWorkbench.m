function varargout = AutoControlWorkbench()
% =========================================================================
% 自动控制原理综合可视化分析工作台 (AutoControl Workbench)
% 适用环境: MATLAB R2020a 及以上 (已在 R2026a 深度适配)
%
% 工程架构说明 (模块化解耦体系):
%   - AutoControlWorkbench.m : 主程序入口与 GUI 交互控制中枢
%   - core/                  : 自控原理核心算法 (传函解析、分离点、虚轴交点、防发散视界)
%   - plot/                  : 四大核心图表专业绘制引擎 (Root Locus, Bode, Nyquist, Step)
%   - report/                : 理论分析与报告生成 (全要素指标综合报告)
%   - presets/               : 经典教材与工程预设题库
%   - utils/                 : 通用辅助工具箱 (多项式字符串、因式聚合、复数格式化)
% =========================================================================

%% 0. 自动注册工程模块搜索路径
projectRoot = fileparts(mfilename('fullpath'));
if ~isempty(projectRoot)
    addpath(fullfile(projectRoot, 'core'));
    addpath(fullfile(projectRoot, 'plot'));
    addpath(fullfile(projectRoot, 'report'));
    addpath(fullfile(projectRoot, 'presets'));
    addpath(fullfile(projectRoot, 'utils'));
end

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

% 9 项排列，精确高度分配，杜绝空白与堆叠
leftLayout = uigridlayout(leftPanel, [9, 1]);
leftLayout.RowHeight = {24, 32, 305, 34, 40, 22, 44, 32, 115};
leftLayout.Padding = [10, 8, 10, 10];
leftLayout.RowSpacing = 8;

% --- 2.1 预设案例选择 ---
uilabel(leftLayout, 'Text', '📚 经典预设案例库 (点击快速载入):', 'FontWeight', 'bold', 'FontSize', 11);
presetDropDown = uidropdown(leftLayout, ...
    'Items', getPresetLibrary('names'), ...
    'Value', '案例2: 四阶条件稳定系统 [(s+1) / ((s-1)(s+4)(s^2+4s+16))]', ...
    'FontSize', 11);

% --- 2.2 输入架构选项卡 (TabGroup 隔离各输入模式) ---
inputTabGroup = uitabgroup(leftLayout);

% Tab A: 典型环节串联积 (选配，支持任意多个环节)
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

% (3) 一阶惯性环节 1/(Ts+1) 或 1/(s+p)
cbLag = uicheckbox(compLayout, 'Text', '③ 一阶惯性环节', 'Value', true, 'FontWeight', 'bold', 'FontSize', 11);
lagModeDropDown = uidropdown(compLayout, 'Items', {'尾1型 [T]', '首1型 [极点p]'}, 'Value', '首1型 [极点p]', 'FontSize', 10);
lagValsField = uieditfield(compLayout, 'text', 'Value', '[-1, 4]', ...
    'Placeholder', '支持多个，如 [0.1, 0.05] 或 [1, 2, 4]', 'FontSize', 10);

% (4) 一阶微分环节 (τs+1) 或 (s+z)
cbLead = uicheckbox(compLayout, 'Text', '④ 一阶微分/超前', 'Value', true, 'FontWeight', 'bold', 'FontSize', 11);
leadModeDropDown = uidropdown(compLayout, 'Items', {'尾1型 [τ]', '首1型 [零点z]'}, 'Value', '首1型 [零点z]', 'FontSize', 10);
leadValsField = uieditfield(compLayout, 'text', 'Value', '[1]', ...
    'Placeholder', '支持多个，如 [0.5, 0.2] 或 [1, 2]', 'FontSize', 10);

% (5) 二阶振荡环节
cbOsc = uicheckbox(compLayout, 'Text', '⑤ 二阶振荡环节', 'Value', true, 'FontWeight', 'bold', 'FontSize', 11);
uilabel(compLayout, 'Text', '多组分号隔开:', 'HorizontalAlignment', 'right', 'FontSize', 9, 'FontColor', [0.35, 0.35, 0.35]);
oscValsField = uieditfield(compLayout, 'text', 'Value', '0.5, 4', ...
    'Placeholder', '如 [ζ, ωn] 或多项式 [a, b, c]', 'FontSize', 10);

% (6) 二阶微分环节
cbOscLead = uicheckbox(compLayout, 'Text', '⑥ 二阶微分环节', 'Value', false, 'FontWeight', 'bold', 'FontSize', 11);
uilabel(compLayout, 'Text', '多组分号隔开:', 'HorizontalAlignment', 'right', 'FontSize', 9, 'FontColor', [0.35, 0.35, 0.35]);
oscLeadValsField = uieditfield(compLayout, 'text', 'Value', '0.7, 2', ...
    'Placeholder', '如 [ζ, ωn] 或多项式 [a, b, c]', 'FontSize', 10, 'Enable', 'off');

% (7) 纯延迟环节 e^(-tau*s)
cbDelay = uicheckbox(compLayout, 'Text', '⑦ 纯延迟环节 e^(-τs)', 'Value', false, 'FontWeight', 'bold', 'FontSize', 11);
uilabel(compLayout, 'Text', '延时 τ(s):', 'HorizontalAlignment', 'right', 'FontSize', 10, 'FontColor', [0.35, 0.35, 0.35]);
delayValField = uieditfield(compLayout, 'numeric', 'Value', 0.1, 'FontSize', 10, 'Enable', 'off');

% (8) 环节数量与阶数实时统计徽章
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

%% 3. 右侧展示面板 (顶部 LaTeX 看板 + 多视图 Tabs)
rightContainer = uigridlayout(mainLayout, [2, 1]);
rightContainer.RowHeight = {135, '1x'};
rightContainer.Padding = [0, 0, 0, 0];
rightContainer.RowSpacing = 8;

% --- 3.1 顶部 LaTeX 公式实时渲染看板 ---
latexCard = uipanel(rightContainer, 'Title', '📐 系统数学模型 (LaTeX 高清实时渲染看板)', ...
    'FontWeight', 'bold', 'FontSize', 12, ...
    'BackgroundColor', [0.98, 0.99, 1.0], 'ForegroundColor', [0.1, 0.25, 0.55], ...
    'Scrollable', 'on');
latexCardLayout = uigridlayout(latexCard, [2, 1]);
latexCardLayout.Padding = [12, 4, 12, 4];
latexCardLayout.RowHeight = {52, 44};
latexCardLayout.RowSpacing = 2;

lblLatexGH = uilabel(latexCardLayout, ...
    'Text', '$$G(s)H(s) = \frac{s + 1}{(s-1)(s+4)(s^2+4s+16)}$$', ...
    'Interpreter', 'latex', 'FontSize', 16, 'FontColor', [0.05, 0.2, 0.55]);

lblLatexChar = uilabel(latexCardLayout, ...
    'Text', '$$\text{闭环特征方程: } D(s) + K N(s) = 0$$', ...
    'Interpreter', 'latex', 'FontSize', 13, 'FontColor', [0.2, 0.25, 0.35]);

% --- 3.2 下部可视化图表选项卡 ---
rightTabGroup = uitabgroup(rightContainer);

% Tab 1: 根轨迹图
tabRL = uitab(rightTabGroup, 'Title', '📈 根轨迹分析 (Root Locus)');
layoutRL = uigridlayout(tabRL, [1, 1]);
layoutRL.Padding = [10, 10, 10, 10];
axRL = uiaxes(layoutRL);
grid(axRL, 'on');

% Tab 2: Bode 对数频率特性
tabBode = uitab(rightTabGroup, 'Title', '📊 对数频率特性 (Bode)');
layoutBode = uigridlayout(tabBode, [1, 1]);
layoutBode.Padding = [10, 10, 10, 10];
axBode = uiaxes(layoutBode);
grid(axBode, 'on');

% Tab 3: 奈奎斯特幅相特性
tabNyquist = uitab(rightTabGroup, 'Title', '🧭 幅相特性 (Nyquist)');
layoutNyquist = uigridlayout(tabNyquist, [3, 1]);
layoutNyquist.RowHeight = {30, '1x', 76};
layoutNyquist.Padding = [10, 8, 10, 8];
layoutNyquist.RowSpacing = 6;

% 顶部视角与频段切换工具条
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
    'BackgroundColor', [0.92, 0.98, 0.92], 'FontColor', [0.1, 0.5, 0.2], ...
    'ButtonPushedFcn', @(btn, event) setNyquistView('focusCurve'));

btnNyqWide = uibutton(nyqToolBar, 'Text', '🌐 广域全景', ...
    'BackgroundColor', [0.96, 0.96, 0.96], 'FontColor', [0.3, 0.3, 0.3], ...
    'ButtonPushedFcn', @(btn, event) setNyquistView('wide'));

chkNyqCircle = uicheckbox(nyqToolBar, 'Text', '单位圆 |s|=1', 'Value', true, ...
    'FontWeight', 'bold', 'FontSize', 10, 'FontColor', [0.55, 0.35, 0.1], ...
    'ValueChangedFcn', @(cb, event) toggleNyquistUnitCircle(cb.Value));

axNyquist = uiaxes(layoutNyquist);
grid(axNyquist, 'on');

% 奈奎斯特稳定判据实时解析卡片
nyquistInfoPanel = uitextarea(layoutNyquist, ...
    'Value', {'【奈奎斯特稳定判据解析】: 正在分析开环极点与包围圈数...'}, ...
    'Editable', 'off', 'FontSize', 10, 'FontName', 'Consolas', ...
    'BackgroundColor', [0.98, 0.99, 1.0], 'FontColor', [0.1, 0.2, 0.4]);

% Tab 4: 闭环时域阶跃响应
tabStep = uitab(rightTabGroup, 'Title', '⏱️ 闭环时域响应 (Step)');
layoutStep = uigridlayout(tabStep, [1, 1]);
layoutStep.Padding = [10, 10, 10, 10];
axStep = uiaxes(layoutStep);
grid(axStep, 'on');

% Tab 5: 综合指标全景看板
tabReport = uitab(rightTabGroup, 'Title', '📋 综合指标全景看板 (Dashboard)');
layoutReport = uigridlayout(tabReport, [1, 1]);
layoutReport.Padding = [10, 10, 10, 10];
reportArea = uitextarea(layoutReport, ...
    'Value', {'正在生成系统全面综合指标分析报告...'}, ...
    'Editable', 'off', 'FontSize', 11, 'FontName', 'Consolas', ...
    'BackgroundColor', [0.99, 0.99, 0.99]);

%% 4. 数据模型与运行状态
appData.G_base = tf(1, [1, 1]);
appData.num = [1];
appData.den = [1, 1];
appData.currentK = 28.0;
appData.isNegative = true;
appData.kMax = 60.0;
appData.showSGrid = false;
appData.polePlotHandle = [];
appData.factoredLatex = '';
appData.nyquistViewMode = 'auto';
appData.showNyquistUnitCircle = true;
appData.nyquistOmegaRange = 'full';

%% 5. 核心逻辑调度控制
    function [sys, num, den, factoredLatex, errMsg] = parseCurrentInput()
        currTab = inputTabGroup.SelectedTab;
        if isequal(currTab, tabComp)
            params.mode = 'components';
            params.kGain = kGainField.Value;
            params.hasIntegral = cbIntegral.Value;
            params.nu = nuDropDown.Value;
            params.hasLag = cbLag.Value;
            params.lagMode = lagModeDropDown.Value;
            params.lagVals = lagValsField.Value;
            params.hasLead = cbLead.Value;
            params.leadMode = leadModeDropDown.Value;
            params.leadVals = leadValsField.Value;
            params.hasOsc = cbOsc.Value;
            params.oscVals = oscValsField.Value;
            params.hasOscLead = cbOscLead.Value;
            params.oscLeadVals = oscLeadValsField.Value;
            params.hasDelay = cbDelay.Value;
            params.delayVal = delayValField.Value;
        elseif isequal(currTab, tabExpr)
            params.mode = 'expression';
            params.exprStr = exprEditField.Value;
        else
            params.mode = 'polynomial';
            params.num = numField.Value;
            params.den = denField.Value;
        end
        
        [sys, num, den, factoredLatex, compSummaryStr, errMsg] = parseTransferFunction(params);
        if ~isempty(compSummaryStr)
            lblCompSummary.Text = compSummaryStr;
        end
    end

    function updateAllPlots(fullRedraw)
        if nargin < 1, fullRedraw = true; end
        
        K = appData.currentK;
        isNeg = appData.isNegative;
        G_base = appData.G_base;
        num = appData.num;
        den = appData.den;
        
        G_open = K * G_base;
        if isNeg
            G_rl = G_base;
            sys_cl = feedback(G_open, 1);
        else
            G_rl = -G_base;
            sys_cl = feedback(G_open, -1);
        end
        
        % 闭环特征多项式与闭环极点
        pad_num = [zeros(1, length(den) - length(num)), num];
        char_poly = den + ternary(isNeg, 1, -1) * K * pad_num;
        cl_poles = roots(char_poly);
        
        % 0. 更新顶部高清 LaTeX 公式
        try
            s_sym = sym('s');
            N_sym = poly2sym(num, s_sym);
            D_sym = poly2sym(den, s_sym);
            if ~isempty(appData.factoredLatex) && contains(appData.factoredLatex, 'frac')
                lblLatexGH.Text = appData.factoredLatex;
            else
                lblLatexGH.Text = sprintf('$$G(s)H(s) = \\frac{%s}{%s}$$', latex(N_sym), latex(D_sym));
            end
            
            char_sym = poly2sym(char_poly, s_sym);
            signStr = ternary(isNeg, '+', '-');
            lblLatexChar.Text = sprintf('$$\\text{闭环特征方程: } D(s) %s K N(s) = %s = 0$$', signStr, latex(char_sym));
        catch ME
            lblLatexGH.Text = '$$G(s)H(s) = \text{多项式模型}$$';
            lblLatexChar.Text = sprintf('$$\\text{特征方程: } %s = 0$$', poly2str_custom(char_poly));
        end
        
        % 1. 绘制根轨迹
        appData.polePlotHandle = renderRootLocus(axRL, G_rl, num, den, K, isNeg, ...
            cl_poles, appData.showSGrid, fullRedraw, appData.polePlotHandle);
        
        % 2. 绘制 Bode 图
        [Gm, Pm, Wcg, Wcp] = renderBodePlot(axBode, G_open, K);
        
        % 3. 绘制 Nyquist 图与稳定判据
        nyquistAnalysisStr = renderNyquistPlot(axNyquist, G_open, den, cl_poles, isNeg, ...
            appData.nyquistOmegaRange, appData.nyquistViewMode, appData.showNyquistUnitCircle);
        nyquistInfoPanel.Value = nyquistAnalysisStr;
        
        % 4. 绘制闭环阶跃响应
        renderStepResponse(axStep, sys_cl, cl_poles, K);
        
        % 5. 更新左侧状态卡片
        isStable = all(real(cl_poles) < -1e-6);
        isMarginal = any(abs(real(cl_poles)) <= 1e-6) && all(real(cl_poles) <= 1e-6);
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
        
        if ~isnan(Pm) && ~isnan(Gm)
            lblMargins.Text = sprintf('裕度: Pm = %.1f° (at %.2f rad/s), Gm = %.1fdB', Pm, Wcp, 20*log10(Gm));
        else
            lblMargins.Text = '裕度: 无法直接计算或不存在穿越点';
        end
        
        % 6. 生成全要素综合指标报告
        reportArea.Value = generateAnalysisReport(K, isNeg, num, den, cl_poles, sys_cl, G_open);
    end

%% 6. 回调函数与交互事件处理
presetDropDown.ValueChangedFcn = @(src, event) onPresetSelected(src.Value);
    function onPresetSelected(choice)
        if strcmp(choice, '自定义输入 (Custom)'), return; end
        cfg = getPresetLibrary(choice);
        inputTabGroup.SelectedTab = tabComp;
        
        kGainField.Value = cfg.kGain;
        cbIntegral.Value = cfg.hasIntegral;
        nuDropDown.Value = cfg.nu;
        cbLag.Value = cfg.hasLag;
        lagModeDropDown.Value = cfg.lagMode;
        lagValsField.Value = cfg.lagVals;
        cbLead.Value = cfg.hasLead;
        leadModeDropDown.Value = cfg.leadMode;
        leadValsField.Value = cfg.leadVals;
        cbOsc.Value = cfg.hasOsc;
        oscValsField.Value = cfg.oscVals;
        cbOscLead.Value = cfg.hasOscLead;
        oscLeadValsField.Value = cfg.oscLeadVals;
        cbDelay.Value = cfg.hasDelay;
        delayValField.Value = cfg.delayVal;
        rbNegative.Value = cfg.isNegative;
        
        gainSlider.Limits = [0.1, cfg.kMax];
        gainSlider.Value = cfg.kDefault;
        gainEdit.Value = cfg.kDefault;
        appData.kMax = cfg.kMax;
        btnZoomK.Text = sprintf('🔍 增益量程: 0-%.0f', cfg.kMax);
        
        updateComponentControlsEnable();
        onAnalyzeClicked();
    end

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

inputTabGroup.SelectionChangedFcn = @(s, e) onAnalyzeClicked();
btnAnalyze.ButtonPushedFcn = @(src, event) onAnalyzeClicked();

    function onAnalyzeClicked()
        [sys, num, den, factoredLatex, errMsg] = parseCurrentInput();
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

feedbackBtnGroup.SelectionChangedFcn = @(s, e) onFeedbackChanged();
    function onFeedbackChanged()
        appData.isNegative = rbNegative.Value;
        updateAllPlots(true);
    end

gainSlider.ValueChangedFcn = @(src, event) onGainSliderChanged(src.Value);
    function onGainSliderChanged(val)
        gainEdit.Value = val;
        appData.currentK = val;
        updateAllPlots(false);
    end

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

btnSGrid.ButtonPushedFcn = @(src, event) onSGridToggled();
    function onSGridToggled()
        appData.showSGrid = ~appData.showSGrid;
        updateAllPlots(true);
    end

    function setNyquistView(mode)
        appData.nyquistViewMode = mode;
        btnNyqAuto.FontWeight = ternary(strcmp(mode, 'auto'), 'bold', 'normal');
        btnNyqCrit.FontWeight = ternary(strcmp(mode, 'focusCrit'), 'bold', 'normal');
        btnNyqCurve.FontWeight = ternary(strcmp(mode, 'focusCurve'), 'bold', 'normal');
        btnNyqWide.FontWeight = ternary(strcmp(mode, 'wide'), 'bold', 'normal');
        updateAllPlots(false);
    end

    function toggleNyquistUnitCircle(val)
        appData.showNyquistUnitCircle = val;
        updateAllPlots(false);
    end

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
