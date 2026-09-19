function str = poly2str_custom(p)
% POLY2STR_CUSTOM 将多项式降幂系数向量转换为格式优美的数学多项式字符串
%   str = poly2str_custom(p)
%   示例: poly2str_custom([1, 4, 16]) -> "s^2 + 4s + 16"

str = '';
n = length(p) - 1;
for i = 1:length(p)
    c = p(i);
    pow = n - i + 1;
    if abs(c) < 1e-10, continue; end
    
    signStr = '+';
    if c < 0
        signStr = '-'; 
        c = abs(c); 
    end
    if isempty(str) && strcmp(signStr, '+')
        signStr = ''; 
    end
    
    if pow == 0
        term = sprintf('%g', c);
    elseif pow == 1
        if c == 1
            term = 's'; 
        else
            term = sprintf('%gs', c); 
        end
    else
        if c == 1
            term = sprintf('s^%d', pow); 
        else
            term = sprintf('%gs^%d', c, pow); 
        end
    end
    
    if isempty(str)
        if strcmp(signStr, '-')
            str = ['-' term]; 
        else
            str = term; 
        end
    else
        str = [str ' ' signStr ' ' term];
    end
end

if isempty(str)
    str = '0'; 
end
end
