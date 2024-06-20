function results = decompose(x, r, options)
%{
This function starts running the EMG decomposition algorithm proposed by
Negro et al. (2016)
Link to the paper: https://iopscience.iop.org/article/10.1088/1741-2560/13/2/026027/meta

Arguments
    REQUIRED
    x: A cell array containing the raw EMG data. Each cell represents a channel and needs to contain
    a row vector.

    r: Extenstion factor as explained in the paper

    OPTIONAL
    discard: Discards the specified channel. Use it to remove channles that
    are corrupted.

    bandpass (default = true): If true applies a dual pass butterworth bandpass filter to the raw
    data.
    
    fs (default = 2048): Sampling frequency of the EMG signals.
    
    low_cut (default = 10): The lower cutoff frequency of the bandpass
    filter mentioned above.
    
    high_cut (default = 900): The higher cutoff frequency of the bandpass
    filter mentioned above.

    filt_order (default = 6): The order of the dual pass bandpass filter.
    This number will be divided by two to be used by the filtfilt function.

    center (default = true): Centers all the EMG channels around zero by
    subtracting the mean.

    M (default = 64): Number of iterations of the whole algorithm. 
    
    l_peaks (default = 31): Half of the length of action potentials (L as
    in paper) in samples. 
    If l_peaks = 31 --> The action potentials will have a length of 63
    samples.

    tolx (default = 10e-4): The threshold for defining convergance in the
    seperation loop (first loop).
    
    max_iter_sep (default = 10): The maximum allowed number of iterations
    before convergence happens in the separation loop (first loop). Passing
    this number means not converging. 
    
    verbose (default = false): If true, additional information is printed
    in the command window during the run of the algorithm.

    cont_fun (default = "skew"): Determines which contrast function to be
    used in the separation loop.
    See the documentation of the apply_contrast function for all the available contrast 
    functions to be used.

    max_iter_ref (default = 20): The maximum allowed number of iterations
    before convergence happens in the refinement loop (second loop). Passing
    this number means not converging. 

    check_pnr and pnr_th (default = true & 30): If check_pnr = true, the algorithm checks the 
    pulse-to-noise (pnr) score of the identified source and only accepts it if
    the pnr score is higher than the threshold (pnr_th).
    Check this for more information about the PNR measure: 
    https://iopscience.iop.org/article/10.1088/1741-2560/11/1/016008

    check_pnr and pnr_th (default = true & 30 dB): If check_pnr = true, the algorithm checks the 
    pulse-to-noise (pnr) score of the identified source and only accepts it if
    the pnr score is higher than the threshold (pnr_th).
    
    check_sil and sil_th (default = true & 0.9): If check_sil = true, the algorithm checks the 
    silhouette score (sil) of the identified source after the second loop and only accepts it if
    the sil score is higher than the threshold (sil_th).
    
Outputs
    results: A strcuture containing the results of the decomposition
    algorithm. The fields of this structure array are as follows:
    
        x_flat_dis_fil_cr: The raw EMG signals after the going through
        pre-processing. Each row contains a channel. The pre-processing
        steps include: flatten --> discrad --> filter --> center

        z: The x_flat_dis_fil_cr after being extended by a factor of r and
        being whitenned. 
        
        B: The final separation vectors (omegas in the paper). Each column represents a separation 
        vector (omegas).
        
        MUPulses: A cell array containing the firing indices of the
        identified sources. Each cell corresponds to a source. Each cell
        contains a row vector with the firing indices of the identified
        source.

        sil_all: A row vector containing the silhouette scores for all of
        the identified sources. 

        pnr_all: A row vector containing the pulse-to-noise scores for all
        of the identified sources.

%}
arguments
    x cell
    r double
    options.discard double = []
    options.bandpass logical = true
    options.fs double = 2048
    options.low_cut double = 10
    options.high_cut double = 900
    options.filt_order double = 6
    options.center logical = true
    options.M double = 64
    options.l_peaks double = 31
    options.tolx double = 10e-4
    options.max_iter_sep double = 50
    options.verbose logical = false
    options.cont_fun string = "skew" % exp_sqr,log_cosh
    options.max_iter_ref double = 50
    options.check_pnr logical = true
    options.check_sil logical = true
    options.pnr_th double = 30
    options.sil_th double = 0.9
end

%% flatten and discard
% if isfield(options, 'discard')
%     discard = options.discard;
x = flatten(x,options.discard);
disp("Flattened and discarded")
% x(:,[1:start*options.fs,stop*options.fs:end])=0;
% else
%     x = flatten(x);
% end
%% discard
% if isfield(options, 'discard')
%     x(options.discard,:) = []; % removes the row that is requested to be discarded.
%     disp("Discarded rows: " + string(options.discard))
% end
%% bandpass filter
% halves the order specified by the user, because it is a dual-pass filter.
if options.bandpass
    [b,a] = butter(options.filt_order/2, ...
        [options.low_cut/(options.fs/2) options.high_cut/(options.fs/2)],'bandpass');
    x = (filtfilt(b,a,x'))';
    disp("Band-pass filtered between " + string(options.low_cut) + ...
        " and " + string(options.high_cut))
end
% x(:,[1:start*options.fs,stop*options.fs:end])=0;
%% center
% subtracts the mean from each channel to center the data.
if options.center
    x = center(x, 2);
%     x = x(:,[1:start*options.fs,stop*options.fs:end]) - mean(x(:,[1:start*options.fs,stop*options.fs:end]),2);
    disp("Centered")
end
results.x_flat_dis_fil_cr = x;
%% extend
% extends the observations by a factor of r. For more info see the Negro
% 2016 paper.
x = extend(x, r);
disp("Extended the observations by a factor of R = " + string(r))
if options.center
    x = center(x, 2);
%     x = x(:,[1:start*options.fs,stop*options.fs:end]) - mean(x(:,[1:start*options.fs,stop*options.fs:end]),2);
    disp("Centered")
end
%% whiten
z = whiten(x);
disp("Whitened")
results.z = z;

%% find the maximum activity indices
peak_act_indxs = max_activity(z, l=options.l_peaks);

%% initialize the variables used for saving the output

B = []; % matrix that contains the final separation vectors as its columns

sources = []; % matrix that contains the final source vectors as its columns

sil_all = []; % A row vector containing the silhouette scores for all of
% the identified sources.

pnr_all = []; % A row vector containing the pulse-to-noise scores for all
% of the identified sources.

MUPulses = {};  % A cell array containing the firing indices of the
% identified sources. Each cell corresponds to a source. Each cell
% contains a row vector with the firing indices of the identified
% source.

% Main loop begins and goes on for M iterations
for i = 1:options.M

    if options.verbose
        disp("====================================== ")
        disp("       ======= Loop #" + string(i) + " ======= ")
    end

    w_init = z(:,peak_act_indxs(i)); % initializes the separation vector to be the
    % whitened extended observation vector
    % at the time instant
    % corresponding to next available maximum muscle
    % activity

    % Separation loop begins and ends inside the separation function. This is
    % the loop that implements the fixed-point algorithm.
    % Step 2 in the pseudo code in the paper.
    w_i = separation(z, w_init, B,...
        cont_fun=options.cont_fun,...
        tolx=options.tolx, ...
        max_iter_sep=options.max_iter_sep, ...
        verbose=options.verbose);

    % An empty array returned by the separation functino means that the
    % separation loop did not converge, so we can skip this iteration on
    % the main loop and try again.
    if isempty(w_i)
        continue
    end

    % Refinement loop begins and ends inside the refinement function. This is
    % the loop that further refines the estimated source from the seperation
    % loop above.
    % Step 4 and 5 in the pseudo code in the paper.
    [w_i, s_i, peak_indices, sil_score, pnr_score , saved_cv] = refinement(w_i, z, ...
        max_iter_ref=options.max_iter_ref, ...
        l_peaks=options.l_peaks, ...
        verbose=options.verbose, ...
        k_plot=false, ...
        save_cv=true);

    % Check the quality of the identified source by looking at the SIL and PNR
    % measures. If either SIL or PNR or both of them, depending on what the user chooses,
    % pass a threshold, we will accept the identifed source and save
    % the associated output variables.
    pnr_cond = pnr_score > options.pnr_th;
    sil_cond = sil_score > options.sil_th;
    if (options.check_pnr) && (options.check_sil)
        check = all(pnr_cond) && all(sil_cond);
    elseif options.check_pnr
        check = pnr_cond;
    elseif options.check_sil
        check = sil_cond;
    else
        warning("At least one of the two arguments check_pnr and check_sil should be true.")
    end

    if check && ~isempty(w_i)
        B = [B w_i];
        sources = [sources s_i];
        sil_all = [sil_all sil_score];
        pnr_all = [pnr_all pnr_score];
        MUPulses = [MUPulses peak_indices];
        fprintf("Source identified at loop number " + string(i) + "\n")
    end

    if options.verbose
        disp("====================================== ")
    end


end

% Save all the desired outputs of the algorithm into a structure with fields
% being the desired output variables
results.B = B;
results.sources = sources;
results.MUPulses = MUPulses;
results.sil_all = sil_all;
results.pnr_all = pnr_all;

% Save the output structure as a .mat file
% save("results\results.mat",'results')

end