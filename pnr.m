function score = pnr(s_i, a_indices, b_indices, options)
%{
This functions calculates two versions of PNR score (pulse to noise ratio) for an idetified motor unit.
PNR is used as measure for the quality of the identified source.
See the paper below for more details on PNR measure

Holobar A, Minetto M and Farina D 2014 Accurate identification of
motor unit discharge patterns from high-density surface EMG
and validation with a novel signal-based performance metric
Journal of Neural Engineering 11 016008

Inputs
    REQUIRED
    s_i: The sqaured of the identified source
    
    a_indices: The pulse train indices. In other words, the indices of samples at
    which a spike happens for the identified motor unit. 

    b_indices: The small peaks identified during the peak detection
    algorithm. Please see the documentation for the refinement function for
    more information about a_indices and b_indices.
    
    OPTIONAL
    version (default = "ver2"): The version of the PNR score to be calculated specified as an
    string.
        "ver1": The pulse is defined to be the  k_means
        classified large peaks (cluster a) and noise is defined to be 
        the k_means classified small peaks (cluster b)

        "ver2": The pulse is defined to be the  k_means
        classified large peaks (cluster a) and noise is defined to be 
        the rest of the data points in the source (cluster c)
   
Outputs
    score: The calculated PNR score.
%}
arguments 
    s_i double
    a_indices double
    b_indices double
    options.version string = "ver2"
end
    
cluster_a = s_i(a_indices);

cluster_b = s_i(b_indices); 

cluster_c = s_i;
cluster_c(a_indices) = [];

peak_cluster = cluster_a;
switch options.version
    case "ver1"
        noise_cluster = cluster_b;
    case "ver2"
        noise_cluster = cluster_c;
end

score = 10*log10(mean(peak_cluster)/mean(noise_cluster));

end

