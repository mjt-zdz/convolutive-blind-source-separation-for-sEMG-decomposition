function y = center(x, axis)
%{
Subtracts the mean from the data to center it. 

Inputs
    REQUIRED
    x: An array containing the data
    axis: The axis along which the mean is calculated and then subtracted
        axis = 1 subtracts the mean along the columns
        axis = 2 subtracts the mean along the rows

Outputs
    y: The centered data

%}
arguments
    x double
    axis double {mustBeMember(axis, [1 2])} = 1
end
    
    switch axis
        case 1
            y = x - mean(x,1);
        case 2
            y = x - mean(x,2);
    end
    
end