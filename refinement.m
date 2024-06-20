function  [w_out, s_out, a_indices_out, sil_score, pnr_score , saved_cv] = refinement(w_in, z, fs, options)
%{
This function implements the refinement loop (second loop, Steps 4 and 5 in the pseudo code 
in the paper).
This loop includes estimating the activation pulse train with peak detection
and K-means++ classification and then improving the estimated source by an
attempt to minimize the variability of discharge (measure: coefficient of variation of inter-spike
intervals).


Inputs
    REQUIRED
    w_in: The separation vector (1D column vector) identified by the first loop (separation
    loop). This separation vector will be refined here. 

    z: The whitened extended observations (2D array). Rows represent
    channels and their extended versions. Columns are samples.
    
    OPTIONAL
    max_iter_ref (default = 20): The maximum allowed number of iterations
    before convergence happens in the refinement loop (second loop). Passing
    this number means not converging. 
    
    l_peaks (default = 31): The minimum one-sided distance between identifed peaks. 
    The motor unit spike train is estimated by a peak detection algorithm applied 
    to the squared of the source vector and then K-means classification (two classes) of the
    identified peaks.

    k_plot (default = false): If true, creates a figure showing the results
    of the K_means algorithm.
    The motor unit spike train is estimated by a peak detection algorithm applied 
    to the squared of the source vector and then K-means classification (two classes) of the
    identified peaks.
    In the proposed study (Negro 2016), in most cases, the   source vector contained the 
    contribution of relatively high peaks (A) and relatively small peaks
    (B).The class with the highest centroid was selected for the estimation of the discharge times.

    save_cv (default = false): If true the coefficient of variation (cv) of the 
    inter-spike intervals (isi) for all iterations will be saved in a row vector (saved_cv).
    Each element in the array corresponds to one iteration.
    
    verbose (default = false): If true additional information will be
    displayed in the command window. 

Outputs
    w_out: The refined separation vector (1D column vector). If the refinement loop does not
    converge, this variable will be equal to an empty array.

    s_out: The accepted source after the refinment process (1D row vector). If the refinement loop 
    does not converge, this variable will be equal to an empty array.
    
    a_indices_out: The spike train indices associated with the accepted
    source at the end of the refinement loop (1D vector). These are the
    high peaks after the peak detection and Kmeans are applied.
    If the refinement loop does not converge, this variable will be equal to an empty array.
    
    sil_score: The silhouette score (sil) related to the accepted source. The SIL was defined as 
    the difference between the within-cluster sums of point-to-centroid distances 
    and the same measure calculated between clusters. The measure was normalized dividing by the 
    maximum of the two values.
    
    pnr_score: The pulse to noise ration (pnr) related to the accepted source. 
    See here for more information about how PNR is calculated:
    
    Holobar A, Minetto M and Farina D 2014 Accurate identification of
    motor unit discharge patterns from high-density surface EMG
    and validation with a novel signal-based performance metric
    Journal of Neural Engineering 11 016008    
    
    saved_cv: An array containing the coefficient of variation of the
    inte-spike intervals for each iteration (1D vector).
    
%}
arguments
    w_in double
    z double
    fs double
    options.max_iter_ref double = 20
    options.l_peaks double = 31
    options.k_plot logical = false
    options.save_cv logical = false
    options.verbose logical = false
end

saved_cv = []; % this array will be filled with the coefficient of variation of inter-spike intervals in each iteration. 
cv_curr = Inf; % set to infinity to make sure the first iteration always executes
n = 0;  % while loop counter
w_curr = w_in; % the seperation vector to be refined 

while 1 % as MATLAB does not have a do-while structure, the loop condition is checked at the end with an if clause and
    % break command is used to terminate the loop. This is to make sure the loop executes at least once.
    n = n + 1; 
    w_curr = normal(w_curr); % normalizing the new estimates for seperation vector
    
    % step 5a. in the pseudo code
    s_curr = w_curr'*z; % calcuting the source associated with w_curr 

%     s_curr2 = s_curr.^2; % calculating the squared of the source 

    % step 5b. in the pseudo code
    % peak detection algorithm applied to the squared of the source vector
    % with a minimum peak distance of 2*l_peaks samples. These peaks will go
    % through a Kmeans classification algorithm to two clusters of high and
    % low peaks.
    [pks, locs] = findpeaks(s_curr, 'MinPeakDistance', options.l_peaks); 
    pks_curr = pks;
    % Kmeans++ algorithm applied to the peaks identified above to find to clusters, one for high peaks and one for low peaks. 
    % C contains the cluster centroids and idx contains the index of the cluster that each data point belongs to.
    [idx, C] = kmeans(pks',2); 
    idx_curr = idx;
    % find out which cluster contains the large peaks and which the small peaks
    [~, lrg_idx] = max(C);
    [~, sml_idx] = min(C);
    % Finds the indices of the high peaks and low peaks
    a_indices = locs(idx == lrg_idx);
    b_indices = locs(idx == sml_idx);
    % step 5c in the pseudo code 
    % save the coefficient of variation of ISIs from the previous
    % iteration in cv_prev
    cv_prev = cv_curr;
    % calculate the new cv of ISIs 
    isi = diff(a_indices/fs);
    cv_curr = variation(isi);
    % saves the calculated cv in an array if save_cv argument is true.
    if options.save_cv
        saved_cv(n) = cv_curr;
    end

    if isnan(cv_curr)
        w_out = [];
        s_out = [];
        a_indices_out = [];
        sil_score = [];
        pnr_score = [];

        warning("Spike detection failed.")
        break;
    end

    % If k_plot is true, the following code generates a figure with two
    % tiles for each iteration. The right tile depicts the squared of the
    % source vector with the detected peaks marked by crosses. The left
    % tile includes the projected peaks to a 1D axis and shows the result
    % of the Kmeans algorithm. Red and Blue are used to show the data on
    % the two clusters (high peaks (cluster a) and low peaks (cluster b))
    % The cluster centroids are marked by black crosses.
    if options.k_plot 

        figure("Name","Iteration " + string(n))
        tiledlayout(1,2, "TileSpacing","compact", Padding="compact")

        nexttile
        plot(ones(1,length(pks(idx==1))),pks(idx==1),'r.', 'MarkerSize', 12)
        hold on
        plot(0.5*ones(1,length(pks(idx==2))),pks(idx==2),'b.', 'MarkerSize', 12)
        plot([1 0.5], C, 'kx', 'MarkerSize', 15, 'LineWidth', 3)
        box off
        xlim([0 2])
        ylim([min(s_curr2) max(s_curr2)])
        lg = legend("Cluster 1; n= " + string(sum(idx==1)), "Cluster 2; n= " + string(sum(idx==2)), ...
            "Cluster Centers");
        lg.Box = 'off';
        lg.FontSize = 15;

        nexttile
        stem(s_curr2)
        hold on
        plot(locs, s_curr2(locs), 'rx')
        box off
        ylim([min(s_curr2) max(s_curr2)])

    end    

    % checks the loop termination condition. Checks if a local minimum for 
    % coefficient of variation of ISIs or is reached (success!) and if yes, terminates the while loop.  
    if (cv_curr >= cv_prev)  
        % filling the appropriate returning variables. 
        % The desired varaibles corresponding to the minimum cv score will be returned.
        w_out = w_prev;
        s_out = s_prev;
        a_indices_out = a_indices_prev; 
        b_indices_out = b_indices_prev;
        idx_out = idx_prev;
        pks_out = pks_prev;
        
        % calculates the sil and pnr measures to be returned
        sil_score = silhouette_score(s_out, a_indices_out, b_indices_out, version="ver2");
%         sil_score = mean(silhouette(pks_out', idx_out, "Euclidean")); % distance is optionable
        pnr_score = pnr(s_out, a_indices_out, b_indices_out, version="ver2");
        
        % prints a report of the refinement loop
        if options.verbose 
            disp("refinement process converged after " + string(n) + " iterations.")
            disp("saved cv scores: ")
            disp(saved_cv)
            disp("sil: " + num2str(sil_score))
            disp("pnr: " + num2str(abs(pnr_score)))
        end
        break;
    end
    
    % checks if the maximum number of allowed iteration has been reaches
    % and if yes terminates the while loop with a warning that the failure
    % happnned and the refinement loop did not converge.
    if (n == options.max_iter_ref)
        w_out = [];
        s_out = [];
        a_indices_out = [];
        sil_score = [];
        pnr_score = [];
        warning("refinement loop reached the max iteration.")
        
        % prints additional info if verbose = true
        if options.verbose
            disp("saved cv scores: ")
            disp(saved_cv)
        end
        break;
    end
    
    % saves the current desired variables to be used in the next iteration as previous variables.
    a_indices_prev = a_indices;
    b_indices_prev = b_indices;
    s_prev = s_curr;
    w_prev = w_curr;
    idx_prev = idx_curr;
    pks_prev = pks_curr;

    % step 5d.in the pseudo code
    w_curr = mean(z(:,a_indices), 2);

end

end