function out = flatten(in,discards)
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
if ~isempty(discards)
    discards = reshape(discards',[numel(discards) 1]);
    out(logical(discards)) = [];
end
out = out(~cellfun(@isempty, out));
out = cell2mat(out);
end