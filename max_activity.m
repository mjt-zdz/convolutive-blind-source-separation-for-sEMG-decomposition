function locs = max_activity(z, options)
%{

Sorts the squared summation of all whitened extended observation vector in
a descending order. The sqaured summation varibale is somehow a
representation of muscle activity level. The identified peaks are set to be
at least 63 samples apart.

Inputs
    REQUIRED
    z: The whitened extended observations. Each row represents a channel
    and its extended versions.
    OPTIONAL
    l (default = 31): The minimum one-sided distance between identifed peaks of the squared
    summation vector. 

Outputs
    locs: The indices of the squared summation vector's peaks. Peak indices
    are ordered in a descending order.

%}
arguments
    z double
    options.l double = 31
end

sq_sum = sum(z).^2; 
[~, locs] = findpeaks(sq_sum, 'SortStr', 'descend', 'MinPeakDistance', options.l);


    
end

