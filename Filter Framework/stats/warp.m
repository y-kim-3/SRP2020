function [warpSequence] = warp(sequence,anchorPts,warpPts)
%[warpSequence] = warp(sequence,anchorPts,warpPts)
%   Takes the numbers in the 'sequence' vector and remaps them by stretching/compressing each segment defined by 
%   'anchorPts' onto 'warpPts'.  Both 'anchorPts' and 'warpPts' must be ordered by increasing numbers, and must
%   be the same length.   

if ~(issorted(anchorPts) && issorted(warpPts))
    error('Anchor points and warp points must be in increasing order')
end
if (length(anchorPts)~=length(warpPts))
    error('anchorPts and warpPts must be the same length')
end

%sequence = sequence(:);
warpSequence = nan(size(sequence));
sequenceDiff = [];
for i = 1:length(anchorPts)
    %sequenceDiff = [sequenceDiff sequence-anchorPts(i)];
    sequenceDiff{i} = sequence-anchorPts(i);
end
for i = 1:(length(anchorPts)-1)
%     withinSegmentInd = find((sequenceDiff(:,i) >= 0) & (sequenceDiff(:,i+1) < 0));
%     tmpSequence = sequence(withinSegmentInd);
%     tmpSequence = (tmpSequence-anchorPts(i))/(anchorPts(i+1)-anchorPts(i));
%     tmpSequence = (tmpSequence*(warpPts(i+1)-warpPts(i)))+warpPts(i);
%     warpSequence(withinSegmentInd) = tmpSequence;

    withinSegmentInd = find((sequenceDiff{i} >= 0) & (sequenceDiff{i+1} < 0));
    tmpSequence = sequence(withinSegmentInd);
    tmpSequence = (tmpSequence-anchorPts(i))/(anchorPts(i+1)-anchorPts(i));
    tmpSequence = (tmpSequence*(warpPts(i+1)-warpPts(i)))+warpPts(i);
    warpSequence(withinSegmentInd) = tmpSequence;


end

