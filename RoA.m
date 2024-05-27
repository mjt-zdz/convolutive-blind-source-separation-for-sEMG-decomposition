function [roa,cj] = RoA(MUPulses1, MUPulses2, fs1, fs2, tol)
%{
Rate of agreement (RoA) is used as a measure to validate the accuracy of
decomposition algorithm. It is a measure that compares the results of two
different algorithms. We assume one of the two sets of results be the gold
standard and measure how close it is to the other set of results. RoA is
calculated as below:

RoA = cj/(cj + Aj + Bj)

where cj is the number of discharges of the jth motor unit
spike train that was identified by both decompositions
(tolerance in discharge timing±0.5 ms), Aj the number of
discharges identified only by one of the two decompositions,
and Bj the number of discharges identified only by the other
decomposition.

See Negro et al 2016 paper for more info.

Inputs
    REQUIRED
    MUPulses1 & MUPulses2: cell arrays containing the discharge indices for
    each motor unit 
    
    fs1 and fs2: sampling frequencies of the two sets of results being compared
    
    tol: the allowed error (in ± ms) to identify two discharge times the same 

Outputs
    roa: If there are n number of motor units identified in the first
    set of results and m number of motor units in the second set of
    results, roa will be an nbym matrix. E.G. The element at fifth row and
    seventh column of the roa matrix is the result of comparing the fifth
    identified motor unit in the first set of results to the seventh
    identified motor unit in the second set of results.
%}

roa = zeros(numel(MUPulses1), numel(MUPulses2));
cj = zeros(numel(MUPulses1), numel(MUPulses2));

% A, B and C are used with the same definition they have in the formula for
% RoA 
for i = 1:numel(MUPulses1)
    for j = 1:numel(MUPulses2)

        Aidx = MUPulses1{i}; % the firing indices of the first identifed MU in the first dataset
        Bidx = MUPulses2{j}; % the firing indices of the first identified MU in the second dataset
        
        timeA = ((Aidx-1)*1000)/fs1;
        timeB = ((Bidx-1)*1000)/fs2;

        A_common_indices = [];
        B_common_indices = [];
        
        for k = 1: length(timeA)
            
            % calculate the range of time to look for a common firing in
            % the other spike train
            low = timeA(k) - tol;
            high = timeA(k) + tol;
            
            % finds the indices of the common firing indices between A and
            % B
            commonB = find((timeB > low) & (timeB < high));
            
            % saves the common indices
            if length(commonB) == 1
                B_common_indices = [B_common_indices commonB];
                A_common_indices = [A_common_indices k];
            elseif length(commonB) > 1
                commonB = commonB(1);
                warning("two common indices were found. i = " + string(i) + " j = " + string(j) + " k = " + string(k))
            end
        
        end
        
        if length(A_common_indices) ~= length(B_common_indices)
            error("common indices in A and B do not have the same length")
        else 
            C = length(A_common_indices);
        end
        
        A = length(Aidx) - length(A_common_indices);
        B = length(Bidx) - length(B_common_indices);
        
        roaTemp = 100*(C/(A+B+C));
        roa(i,j) = roaTemp;
        cj(i,j) = C/max(length(Aidx),length(Bidx));
    end
end
end