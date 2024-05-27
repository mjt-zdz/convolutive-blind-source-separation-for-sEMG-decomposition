function w_out = deflate(w_in, B)
%{
A source deflation procedure (the orthogonalization step 2.b in the pseudo
code) is used that favors the estimation of different sources at each completed iteration.
The proposed orthogonalization has limitations compared with the symmetric
orthogonalization, but it is superior in terms of computational complexity.

Inputs
    REQUIRED
    w_in: The separation vector that needs to be deflated. 
    
    B: The matrix that contains all the accepted separation vectors as
    columns. 
    
Outputs
    w_out: The deflated separation vector. 

%}

w_out = w_in - B*B'*w_in;

end