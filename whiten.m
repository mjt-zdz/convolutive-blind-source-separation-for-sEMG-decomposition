function [x_wit, U, Landa] = whiten(x)
%{
Whitens the data using eigen value decomposition. 

A regularization procedure was applied to reduce the numerical instability of 
the solutions of the inverse problem. Regularizaion factor was set to be the 
average of the smallest half of the eigenvalues of the covariance matrix of 
the extended EMG signals. The eigen values that are smaller than the regularization 
factor are replaced by the regularization factor.

Arguments
    REQUIRED
    x: A 2D array in which rows represent variables and columns represent
    samples (observations). 
    The assumption is that x is centered (mean is subtracted).
    
Outputs
    x_wit: A 2D array containing the whitened data. Rows are variables and
    columns are samples.

    U: The eigen matrix (ordered descending based on the corresponding eigen values)

    Landa: A vector containing eigen values (ordered descending) 
%}

arguments
    x double
end

C = cov(x', 1);
[U, Landa] = eig(C);
eig_vals = diag(Landa);
[S,I] = sort(eig_vals,'descend');

reg_fac = mean(S((ceil((length(S)+1)/2)):end));
S(S<reg_fac) = reg_fac;

Landa = diag(S);
U = U(:,I);

x_wit = U*Landa^(-1/2)*U'*x;

end