function w_curr = separation(z, w_init, B, options)
%{

This function implements the fixed-point algorithm to estimate the seperation vectors. 
This is the first loop described in the paper (step 2).

Related papers:

Hyvärinen A and Oja E 1997 A fast fixed-point algorithm for
independent component analysis Neural Comput. 9
1483–92

Thomas J, Deville Y and Hosseini S 2006 Time-domain fast fixedpoint
algorithms for convolutive ICA Signal Processing
Letters, IEEE 13 228–31


Inputs
    REQUIRED
    z: The whitened extended observations. Each row is a channel or the
    extended version of a channel.
    
    w_init: The initial separation vector to begin the loop with. This is
    set to be the whitened extended observation vecotor at a time instant
    that corresponds to a high acitivity. 
    
    B: A matrix that contains the accepted separation vectors as its columns.

    OPTIONAL
    tolx (default = 10e-4): The threshold for defining convergance. On each
    iteration a new separation vector is estimated and its Euclidean
    distance from the separatin vector from the previous loop is
    calculated. If the calculated distance is less than tolx, the loop ends
    and we announce convergance.

    cont_fun (default = "skew"): Determines which contrast function to be
    used. Originally, the fastICA's contrast functions were designed to maximize
    the non-Gaussianity and, indirectly, the independence of the estimated sources wi.T*z.
    In our case, the sources are supergaussian, i.e. sparse, thus the contrast
    functions G(x) are used as measures of sparseness rather than measures of independence.
    See the documentation of the apply_contrast function to see the
    available contrast functions to be used.

    max_iter_sep (default = 10): The maximum allowed number of iterations
    before convergence happens in the separation loop (first loop). Passing
    this number means not converging. 
    
    verbose (default = false): If true, additional information is printed
    in the command window during the run of the algorithm.

Outputs
    w_curr: The identified separation vector.
%}
arguments
    z double
    w_init double
    B double
    options.tolx double = 1e-4
    options.cont_fun string = "skew"
    options.max_iter_sep double = 10
    options.verbose logical = false
end

w_curr = normal(w_init); % current separation vector initialized to be the function argument w_init
w_prev = w_curr; % previous separation vector. This variable will hold the separatin vector 
                 % from the previous iteration.
n = 1; % loop count

if isempty(B) % if we are in the first iteration on them main loop, B will be empty and needs 
              % to be initialized to all zeros before proceeding inside the separation loop.
    B = zeros(size(z,1),1);
end

% Separation loop 
% The first condition checks convergence and the second one checks not converging. Either happens, the loop stops. 

while n <= options.max_iter_sep
    % Step 2a in pseudo code: Check paper for the formulas. g(x) and g'(x) are applied through the apply_contrast function.
    wz = w_prev'*z; 
    A = mean(apply_contrast(wz, options.cont_fun, "der_der"));
    w_curr = apply_contrast(wz, options.cont_fun, "der");
    w_curr = z.*w_curr;
    w_curr = mean(w_curr, 2);
    w_curr = w_curr - A*w_prev;
    % Step 2b: source deflation procedure
    w_curr = deflate(w_curr, B);
    % Step 2c: Normalization 
    w_curr = normal(w_curr); % L2
    
    distance = 1-abs(w_curr'*w_prev);
    w_prev = w_curr; % previous separation vector. This variable will hold the separatin vector from the previous iteration.
    if distance < options.tolx
        % Displaying the information in the command window
        if options.verbose
            disp("fixed-point algorithm converged after " + string(n) + " iterations.")
        end
        break;
    end
    n = n + 1;
end
if n > options.max_iter_sep
    w_curr = [];
    warning("Seperation loop reached the max iteration.")
end
end