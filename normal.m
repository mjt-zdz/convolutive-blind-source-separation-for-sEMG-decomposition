function vec_norm = normal(vec)
%{
Normalizes a vector by dividing it to its Euclidean norm.

Inputs
    REQUIRED
    vec: A row or column vector (1D array)
    
Outputs
    vec_norm: The normalized vector.
%}

arguments
    vec double {mustBeVector}
end

    vec_norm = vec/norm(vec);
    
end