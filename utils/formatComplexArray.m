function str = formatComplexArray(arr)
% FORMATCOMPLEXARRAY 将复数/实数数组格式化为易读的字符串形式
%   str = formatComplexArray(arr)
%   示例: formatComplexArray([-1, -2+3j, -2-3j]) -> "[-1.0000, -2.0000+3.0000j, -2.0000-3.0000j]"

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
