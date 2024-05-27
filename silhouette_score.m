function sil = silhouette_score(s_i, a_indices, b_indices, options)

%{
This functions calculates two versions of SIL score (silhouette score) for an idetified motor unit.
SIL is used as measure for the quality of the identified source.

The SIL was defined as the difference between the within-cluster sums of point-to-centroid distances 
and the same measure calculated between clusters. The measure was normalized dividing by the 
maximum of the two values.

Inputs
    REQUIRED
    s_i: The sqaured of the identified source
    
    a_indices: The pulse train indices. In other words, the indices of samples at
    which a spike happens for the identified motor unit. 

    b_indices: The small peaks identified during the peak detection and
    Kmeans algorithms. Please see the documentation for the refinement function for
    more information about a_indices and b_indices.
    
    OPTIONAL
    version (default = "ver2"): The version of the SIL score to be calculated specified as an
    string.
        "ver1": The pulse is defined to be the  k_means
        classified large peaks (cluster a) and noise is defined to be 
        the k_means classified small peaks (cluster b)

        "ver2": The pulse is defined to be the  k_means
        classified large peaks (cluster a) and noise is defined to be 
        the rest of the data points in the source (cluster c)
   
Outputs
    score: The calculated SIL score.
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

peak_centroid = mean(peak_cluster);
noise_centroid = mean(noise_cluster);

intra_sums = sum(abs(noise_cluster - noise_centroid)) + sum(abs(peak_cluster - peak_centroid));
inter_sums = sum(abs(noise_cluster - peak_centroid)) + sum(abs(peak_cluster - noise_centroid));

sil = (inter_sums - intra_sums)/max([intra_sums inter_sums]);

end