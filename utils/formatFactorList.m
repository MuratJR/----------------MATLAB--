function terms = formatFactorList(vals, mode)
% FORMATFACTORLIST 将相同数值的一阶因子聚合成幂次 (如 (s+2)^2) 并格式化为 LaTeX 项
%   terms = formatFactorList(vals, mode)
%   mode 可为 '尾1型 [T]' 或 '首1型 [极点p]' 等

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
