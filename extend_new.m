function y = extend_new(x, r)

arguments
    x double 
    r double {mustBeScalarOrEmpty, mustBeInteger, SizeCheck(r, x)}
end

SizeCheck(r,x);

y = [];
for i = 1:size(x,1)
    
    row = x(i,:);
    row_extended = row;
    for j = 1:r
        delayed = [row zeros(1,j)];
        delayed = delayed(j+1:end);
        row_extended = [row_extended; delayed];
    end
    
    y = [y; row_extended];

end
y = y(:,1:size(y,2)-r);
end


function SizeCheck(a,b)
% a scalar
% b matrix
    if a > size(b, 2)-1
        eid = 'Size:notProper';
        msg = 'Extension factor cannot be bigger than the number of samples in a signal';
        throwAsCaller(MException(eid,msg))
    end
end