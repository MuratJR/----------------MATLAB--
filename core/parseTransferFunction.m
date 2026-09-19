function [sys, num, den, factoredLatex, compSummaryStr, errMsg] = parseTransferFunction(params)
% PARSETRANSFERFUNCTION 系统传递函数综合解析器
%   支持三种输入模式:
%     1. 典型环节串联积 ('components')
%     2. 自由数学表达式 ('expression')
%     3. 多项式降幂系数 ('polynomial')
%
%   输出参数:
%     sys:            MATLAB tf 对象
%     num:            开环分子多项式降幂系数向量 (无前导零)
%     den:            开环分母多项式降幂系数向量 (无前导零)
%     factoredLatex:  因式分解形式的高清 LaTeX 渲染公式
%     compSummaryStr: 环节构成与阶数统计描述文本
%     errMsg:         错误信息 (若解析成功则为空)

errMsg = '';
factoredLatex = '';
compSummaryStr = '';
sys = tf(1, [1, 1]);
num = [1];
den = [1, 1];

if nargin < 1 || isempty(params) || ~isfield(params, 'mode')
    params.mode = 'components';
end

s = tf('s');

switch lower(params.mode)
    case 'components'
        try
            sys = tf(1, 1);
            num_latex_terms = {};
            den_latex_terms = {};
            
            % 1. 比例环节 K
            K = 1.0;
            if isfield(params, 'kGain') && isnumeric(params.kGain) && ~isnan(params.kGain)
                K = params.kGain;
            end
            sys = sys * K;
            if abs(K - 1.0) > 1e-6
                num_latex_terms{end+1} = sprintf('%g', K);
            end
            
            % 2. 积分环节 1/s^nu
            nu = 0;
            if isfield(params, 'hasIntegral') && params.hasIntegral
                if isfield(params, 'nu')
                    if ischar(params.nu) || isstring(params.nu)
                        nums_nu = regexp(char(params.nu), '^\d+', 'match');
                        if ~isempty(nums_nu), nu = str2double(nums_nu{1}); end
                    else
                        nu = double(params.nu);
                    end
                end
                if nu > 0
                    sys = sys / (s^nu);
                    if nu == 1
                        den_latex_terms{end+1} = 's';
                    else
                        den_latex_terms{end+1} = sprintf('s^{%d}', nu);
                    end
                end
            end
            
            % 3. 一阶微分环节 (τs+1) 或 (s+z)
            count_lead = 0;
            if isfield(params, 'hasLead') && params.hasLead
                lead_mode = '首1型 [零点z]';
                if isfield(params, 'leadMode'), lead_mode = params.leadMode; end
                leads = parseNumArray(params.leadVals);
                count_lead = length(leads);
                for i = 1:length(leads)
                    val = leads(i);
                    if contains(lead_mode, '尾1型')
                        sys = sys * (val * s + 1);
                    else
                        sys = sys * (s + val);
                    end
                end
                groupedLeads = formatFactorList(leads, lead_mode);
                for g = 1:length(groupedLeads)
                    num_latex_terms{end+1} = groupedLeads{g}; %#ok<AGROW>
                end
            end
            
            % 4. 二阶微分环节 (支持多组，分号分隔)
            count_osc_lead = 0;
            if isfield(params, 'hasOscLead') && params.hasOscLead
                osc_lead_mode = '标准型 [ζ, ωn]';
                if isfield(params, 'oscLeadMode'), osc_lead_mode = params.oscLeadMode; end
                cleanOscLead = regexprep(char(params.oscLeadVals), '[\[\]\(\)]', ' ');
                rows_lead = strsplit(cleanOscLead, ';');
                for i = 1:length(rows_lead)
                    nums = str2num(rows_lead{i}); %#ok<ST2NM>
                    if isempty(nums), continue; end
                    if contains(osc_lead_mode, '多项式')
                        if length(nums) == 2, nums = [1, nums]; end
                        if length(nums) >= 3
                            count_osc_lead = count_osc_lead + 1;
                            c_norm = ternary(nums(3) ~= 0, nums(3), 1);
                            sys = sys * tf(nums(1:3), [c_norm]);
                            if nums(1) == 1
                                num_latex_terms{end+1} = sprintf('(s^2 %+g s + %g)', nums(2), nums(3)); %#ok<AGROW>
                            else
                                num_latex_terms{end+1} = sprintf('(%gs^2 %+g s + %g)', nums(1), nums(2), nums(3)); %#ok<AGROW>
                            end
                        end
                    else % 标准型 [ζ, ωn]
                        if length(nums) == 2
                            count_osc_lead = count_osc_lead + 1;
                            zeta_z = nums(1); wn_z = nums(2);
                            poly_l = [1, 2*zeta_z*wn_z, wn_z^2];
                            sys = sys * tf(poly_l, [wn_z^2]);
                            num_latex_terms{end+1} = sprintf('(s^2 %+g s + %g)', 2*zeta_z*wn_z, wn_z^2); %#ok<AGROW>
                        elseif length(nums) >= 3
                            count_osc_lead = count_osc_lead + 1;
                            c_norm = ternary(nums(3) ~= 0, nums(3), 1);
                            sys = sys * tf(nums(1:3), [c_norm]);
                            if nums(1) == 1
                                num_latex_terms{end+1} = sprintf('(s^2 %+g s + %g)', nums(2), nums(3)); %#ok<AGROW>
                            else
                                num_latex_terms{end+1} = sprintf('(%gs^2 %+g s + %g)', nums(1), nums(2), nums(3)); %#ok<AGROW>
                            end
                        end
                    end
                end
            end
            
            % 5. 一阶惯性环节 1/(Ts+1) 或 1/(s+p)
            count_lag = 0;
            if isfield(params, 'hasLag') && params.hasLag
                lag_mode = '首1型 [极点p]';
                if isfield(params, 'lagMode'), lag_mode = params.lagMode; end
                lags = parseNumArray(params.lagVals);
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
            
            % 6. 二阶振荡环节 (支持多组，分号分隔)
            count_osc = 0;
            if isfield(params, 'hasOsc') && params.hasOsc
                osc_mode = '标准型 [ζ, ωn]';
                if isfield(params, 'oscMode'), osc_mode = params.oscMode; end
                cleanOsc = regexprep(char(params.oscVals), '[\[\]\(\)]', ' ');
                rows_osc = strsplit(cleanOsc, ';');
                for i = 1:length(rows_osc)
                    nums = str2num(rows_osc{i}); %#ok<ST2NM>
                    if isempty(nums), continue; end
                    if contains(osc_mode, '多项式')
                        if length(nums) == 2, nums = [1, nums]; end
                        if length(nums) >= 3
                            count_osc = count_osc + 1;
                            c_norm = ternary(nums(3) ~= 0, nums(3), 1);
                            sys = sys / tf(nums(1:3), [c_norm]);
                            if nums(1) == 1
                                den_latex_terms{end+1} = sprintf('(s^2 %+g s + %g)', nums(2), nums(3)); %#ok<AGROW>
                            else
                                den_latex_terms{end+1} = sprintf('(%gs^2 %+g s + %g)', nums(1), nums(2), nums(3)); %#ok<AGROW>
                            end
                        end
                    else % 标准型 [ζ, ωn]
                        if length(nums) == 2
                            count_osc = count_osc + 1;
                            zeta_o = nums(1); wn_o = nums(2);
                            poly_o = [1, 2*zeta_o*wn_o, wn_o^2];
                            sys = sys / tf(poly_o, [wn_o^2]);
                            den_latex_terms{end+1} = sprintf('(s^2 %+g s + %g)', 2*zeta_o*wn_o, wn_o^2); %#ok<AGROW>
                        elseif length(nums) >= 3
                            count_osc = count_osc + 1;
                            c_norm = ternary(nums(3) ~= 0, nums(3), 1);
                            sys = sys / tf(nums(1:3), [c_norm]);
                            if nums(1) == 1
                                den_latex_terms{end+1} = sprintf('(s^2 %+g s + %g)', nums(2), nums(3)); %#ok<AGROW>
                            else
                                den_latex_terms{end+1} = sprintf('(%gs^2 %+g s + %g)', nums(1), nums(2), nums(3)); %#ok<AGROW>
                            end
                        end
                    end
                end
            end
            
            % 7. 纯延迟环节 (采用 2 阶 Padé 近似)
            if isfield(params, 'hasDelay') && params.hasDelay
                tau_d = 0;
                if isfield(params, 'delayVal'), tau_d = double(params.delayVal); end
                if tau_d > 0
                    [p_num, p_den] = pade(tau_d, 2);
                    sys = sys * tf(p_num, p_den);
                    num_latex_terms{end+1} = sprintf('e^{-%gs}', tau_d);
                end
            end
            
            [numCell, denCell] = tfdata(sys, 'v');
            num = numCell;
            den = denCell;
            
            % 组装因式分解 LaTeX
            if isempty(num_latex_terms)
                str_num = '1';
            else
                str_num = strjoin(num_latex_terms, ' ');
            end
            if isempty(den_latex_terms)
                str_den = '1';
            else
                str_den = strjoin(den_latex_terms, ' ');
            end
            factoredLatex = sprintf('$$G(s)H(s) = \\frac{%s}{%s}$$', str_num, str_den);
            
            n_poles = length(den) - 1;
            m_zeros = length(num) - 1;
            compSummaryStr = sprintf('📊 环节统计: 惯性×%d, 微分×%d, 振荡×%d组 | 阶数: n=%d, 零点: m=%d, 型别: %d型', ...
                count_lag, count_lead, count_osc, n_poles, m_zeros, nu);
            
        catch ME
            errMsg = ME.message;
            sys = tf(1, [1, 1]); 
            num = [1]; 
            den = [1, 1];
        end
        
    case 'expression'
        try
            if iscell(params.exprStr)
                exprStr = strjoin(params.exprStr, ' ');
            else
                exprStr = char(params.exprStr);
            end
            sys = eval(exprStr);
            if ~isa(sys, 'tf')
                sys = tf(sys);
            end
            [numCell, denCell] = tfdata(sys, 'v');
            num = numCell;
            den = denCell;
            factoredLatex = sprintf('$$G(s)H(s) = %s$$', exprStr);
            compSummaryStr = sprintf('📊 自由表达式输入 | 阶数: n=%d, 零点: m=%d', length(den)-1, length(num)-1);
        catch ME
            errMsg = ME.message;
            sys = tf(1, [1, 1]); 
            num = [1]; 
            den = [1, 1];
        end
        
    case 'polynomial'
        try
            if ischar(params.num) || isstring(params.num)
                num = str2num(char(params.num)); %#ok<ST2NM>
            else
                num = double(params.num);
            end
            if ischar(params.den) || isstring(params.den)
                den = str2num(char(params.den)); %#ok<ST2NM>
            else
                den = double(params.den);
            end
            if isempty(num) || isempty(den)
                error('分子或分母系数向量解析为空');
            end
            sys = tf(num, den);
            factoredLatex = '';
            compSummaryStr = sprintf('📊 多项式系数输入 | 阶数: n=%d, 零点: m=%d', length(den)-1, length(num)-1);
        catch ME
            errMsg = ME.message;
            sys = tf(1, [1, 1]); 
            num = [1]; 
            den = [1, 1];
        end
end

% 清除多项式前导0
idx_n = find(num ~= 0, 1, 'first');
if ~isempty(idx_n), num = num(idx_n:end); end
idx_d = find(den ~= 0, 1, 'first');
if ~isempty(idx_d), den = den(idx_d:end); end

end

function arr = parseNumArray(inputVal)
if isnumeric(inputVal)
    arr = inputVal;
elseif ischar(inputVal) || isstring(inputVal)
    arr = str2num(char(inputVal)); %#ok<ST2NM>
else
    arr = [];
end
end
