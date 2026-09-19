function val = ternary(cond, a, b)
% TERNARY 简易三元条件运算符辅助函数
%   val = ternary(cond, a, b)
%   当 cond 为 true 时返回 a，否则返回 b。

if cond
    val = a;
else
    val = b;
end
end
