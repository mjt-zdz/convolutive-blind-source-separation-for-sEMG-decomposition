function [x_wit, U, Landa] = whiten(x, options)
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
    options.method string = 'zca'
    options.pcs int64 = size(x, 1)
end

if strcmp(options.method, 'zca')
    %% evd    
    C = cov(x', 1); % Compute covariance matrix
    [U, Lamda] = eig(C); 
    W = U * sqrtm(inv(Lamda + 1e-6 * eye(size(Lamda)))) * U';
    x_wit = W * x;
    
    %% svd
    %{
    [U, S, ~] = svd(x');
    U = U * sign(U(1));
    W = U * diag(1 ./ sqrt(diag(S)+1e-6)) * U';
    x_wit = W * x;
    %}
end

if strcmp(options.method, 'pca')
    C = cov(x', 1); % Compute covariance matrix
    [U, Lamda] = eig(C); 
    [S, I] = sort(diag(Lamda), 'descend');
    Lamda = diag(S(1:options.pcs));
    U = U(:, I(1:options.pcs));
    W = U * sqrtm(inv(Lamda + 1e-6 * eye(size(Lamda)))) * U';
    x_wit = W * x;
end

end