function out = flatten_interp(in,discards)
%{

Takes the raw EMG cell array, removes empty channels and reshapes it
into a new array.

Arguments
    REQUIRED
    in: A cell array containing the raw EMG data. Each cell represents a channel and needs to contain
    a row vector.

Outputs
    out: A 2D array with rows representing channels and columns
    representing samples

%}
% arguments
%     in cell
%     options.discards double
% end
out = reshape(in',[numel(in) 1]);
out = out(~cellfun(@isempty, out));
out = cell2mat(out);
if ~isempty(discards)
    discards = reshape(discards',[numel(discards) 1]);
    discards = discards(2:end);
    index_miss = find(discards);
    index_data = find(~discards);
    for index = index_miss
        data = out(index_data, :);
        out(index,:) = interp1(index_data, data, index, 'spline');
    end
end

end