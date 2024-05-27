function cv = variation(a)
%{
Calculates the coefficient of variation of the data in a.

cv = standard deviation/mean
Note: standard deviation is calculated by normalizing to N

Inputs
    REQUIRED
    a: A vector (1D array)

Outputs
    cv: Coefficient of variation of a
    
%}

cv = std(a,1)/mean(a);

end