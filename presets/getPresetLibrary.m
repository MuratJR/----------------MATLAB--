function result = getPresetLibrary(query)
% GETPRESETLIBRARY 自动控制原理经典教材与工程预设题库
%   items = getPresetLibrary('names') 返回预设案例列表
%   cfg = getPresetLibrary(caseName)   返回指定案例的参数配置结构体

presetNames = { ...
    '自定义输入 (Custom)', ...
    '案例1: 典型二阶欠阻尼系统 [16 / (s^2 + 4s + 16)]', ...
    '案例2: 四阶条件稳定系统 [(s+1) / ((s-1)(s+4)(s^2+4s+16))]', ...
    '案例3: 原点二重极点+PD控制 [2(s+0.5) / (s^2(s+2)(s+5))]', ...
    '案例4: 正/负反馈典型对比 [(s+1) / (s^2(s+2)(s+4))]', ...
    '案例5: 空间站方位控制系统 [(s+20) / (s(s+12)^2)]', ...
    '案例6: 超音速客机俯仰角控制 [(s+2)^2 / ((s+10)(s+100)(s^2+1.5s+6.25))]' ...
};

if nargin < 1 || isempty(query) || strcmp(query, 'names')
    result = presetNames;
    return;
end

% 默认配置模板
cfg.kGain = 1.0;
cfg.hasIntegral = false;
cfg.nu = '0 (0型 / 无积分)';
cfg.hasLag = false;
cfg.lagMode = '首1型 [极点p]';
cfg.lagVals = '[]';
cfg.hasLead = false;
cfg.leadMode = '首1型 [零点z]';
cfg.leadVals = '[]';
cfg.hasOsc = false;
cfg.oscVals = '';
cfg.hasOscLead = false;
cfg.oscLeadVals = '';
cfg.hasDelay = false;
cfg.delayVal = 0.1;
cfg.isNegative = true;
cfg.kMax = 50;
cfg.kDefault = 1.0;

switch query
    case '案例1: 典型二阶欠阻尼系统 [16 / (s^2 + 4s + 16)]'
        cfg.kGain = 1.0;
        cfg.hasOsc = true;
        cfg.oscVals = '0.5, 4';
        cfg.kMax = 20;
        cfg.kDefault = 1.0;
        
    case '案例2: 四阶条件稳定系统 [(s+1) / ((s-1)(s+4)(s^2+4s+16))]'
        cfg.kGain = 1.0;
        cfg.hasLead = true;
        cfg.leadMode = '首1型 [零点z]';
        cfg.leadVals = '[1]';
        cfg.hasLag = true;
        cfg.lagMode = '首1型 [极点p]';
        cfg.lagVals = '[-1, 4]';
        cfg.hasOsc = true;
        cfg.oscVals = '0.5, 4';
        cfg.kMax = 60;
        cfg.kDefault = 28.0;
        
    case '案例3: 原点二重极点+PD控制 [2(s+0.5) / (s^2(s+2)(s+5))]'
        cfg.kGain = 2.0;
        cfg.hasIntegral = true;
        cfg.nu = '2 (2型 / 1/s^2)';
        cfg.hasLead = true;
        cfg.leadMode = '首1型 [零点z]';
        cfg.leadVals = '[0.5]';
        cfg.hasLag = true;
        cfg.lagMode = '首1型 [极点p]';
        cfg.lagVals = '[2, 5]';
        cfg.kMax = 50;
        cfg.kDefault = 5.0;
        
    case '案例4: 正/负反馈典型对比 [(s+1) / (s^2(s+2)(s+4))]'
        cfg.kGain = 1.0;
        cfg.hasIntegral = true;
        cfg.nu = '2 (2型 / 1/s^2)';
        cfg.hasLead = true;
        cfg.leadMode = '首1型 [零点z]';
        cfg.leadVals = '[1]';
        cfg.hasLag = true;
        cfg.lagMode = '首1型 [极点p]';
        cfg.lagVals = '[2, 4]';
        cfg.kMax = 80;
        cfg.kDefault = 15.0;
        
    case '案例5: 空间站方位控制系统 [(s+20) / (s(s+12)^2)]'
        cfg.kGain = 1.0;
        cfg.hasIntegral = true;
        cfg.nu = '1 (1型 / 1/s)';
        cfg.hasLead = true;
        cfg.leadMode = '首1型 [零点z]';
        cfg.leadVals = '[20]';
        cfg.hasLag = true;
        cfg.lagMode = '首1型 [极点p]';
        cfg.lagVals = '[12, 12]';
        cfg.kMax = 100;
        cfg.kDefault = 25.0;
        
    case '案例6: 超音速客机俯仰角控制 [(s+2)^2 / ((s+10)(s+100)(s^2+1.5s+6.25))]'
        cfg.kGain = 1.0;
        cfg.hasLead = true;
        cfg.leadMode = '首1型 [零点z]';
        cfg.leadVals = '[2, 2]';
        cfg.hasLag = true;
        cfg.lagMode = '首1型 [极点p]';
        cfg.lagVals = '[10, 100]';
        cfg.hasOsc = true;
        cfg.oscVals = '0.3, 2.5';
        cfg.kMax = 500;
        cfg.kDefault = 120.0;
end

result = cfg;
end
