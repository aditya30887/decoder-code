function [rvalue] = rval(a, b)
cc = corrcoef(a, b);
rvalue = cc(1, 2);
end