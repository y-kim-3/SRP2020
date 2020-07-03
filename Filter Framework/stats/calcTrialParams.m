function [out] = calcTrialParams(trialstruct,trialMatrix,decay)

%trialstruct is the trial structure for one behavior session, i.e trialstruct = trials{day}{1}
%trialmatrix is a matrix with columns [time(sec) tone(1/2) error(2)/accept(1)/rej(0) reward(0/1)] 


if (~isempty(trialstruct))
    trialMatrix = [];
    numtrials = length(trialstruct.finalinittype);
    decay = .15;
    for i = 1:numtrials
        if ~(trialstruct.error(i))
            tmpmatrix = trialstruct.inittypes{i};
            tmpmatrix(:,3) = 0;
            tmpmatrix(:,4) = 0;
            tmpmatrix(end,3) = 1;
            tmpmatrix(end,4) = trialstruct.rewarded(i);
            tmpmatrix(:,5) = trialstruct.rewardProb1(i);
            tmpmatrix(:,6) = trialstruct.rewardProb2(i);
            trialMatrix = [trialMatrix; tmpmatrix];
        else
            tmpmatrix = trialstruct.inittypes{i};
            tmpmatrix(:,3) = 0;
            tmpmatrix(:,4) = 0;
            tmpmatrix(end,3) = 2;
            tmpmatrix(end,4) = trialstruct.rewarded(i);
            tmpmatrix(:,5) = trialstruct.rewardProb1(i);
            tmpmatrix(:,6) = trialstruct.rewardProb2(i);
            trialMatrix = [trialMatrix; tmpmatrix];
        end
    end
end
out.rewardProbs = trialMatrix(:,5:6);
trialMatrix = trialMatrix(:,1:4);

side1matrix = trialMatrix(find((trialMatrix(:,2) == 1)&((trialMatrix(:,3) < 2))),:);
side2matrix = trialMatrix(find((trialMatrix(:,2) == 2)&((trialMatrix(:,3) < 2))),:);
acceptancematrix = trialMatrix(find(trialMatrix(:,3) == 1),:);
out.time = trialMatrix(:,1);
gomatrix = trialMatrix(find(trialMatrix(:,3) > 0),:);

out.trialMatrix = trialMatrix;
%----------------------------------------------------------------
%decay = .05;
tmp = trialMatrix(find(trialMatrix(:,3)<3),[1 3]);
filteredtmp = [];
for L = 1:size(tmp,1); 
    filteredtmp(L,1) = (exp(-decay*([1:L]-1))*(tmp(L:-1:1,2)==0) )/sum(exp(-decay*([1:L]-1)));
end
%filteredtmp = smoothvect((tmp(:,2)==0),gaussian(6,53));
out.totalRejectProb = filteredtmp(lookup(out.time,tmp(:,1)));

%-------------------------------------------------------------------
tmp = trialMatrix(find(trialMatrix(:,3)<3),[1 3]);
filteredtmp = [];
filteredtmp = smoothvect((tmp(:,2)==0),gaussian(4,54));
out.totalRejectProbGaussian = filteredtmp(lookup(out.time,tmp(:,1)));
%-------------------------------------------------------------------



%decay = .15;
tmp = trialMatrix(find(trialMatrix(:,3)==1),[1 4]);
filteredtmp = [];
for L = 1:size(tmp,1); 
    filteredtmp(L,1) = (exp(-decay*([1:L]-1))*(tmp(L:-1:1,2)==1) )/sum(exp(-decay*([1:L]-1)));
end
out.totalRewardProb = filteredtmp(lookup(out.time,tmp(:,1)));
%out.unsmoothedOutcome = tmp(lookup(out.time,tmp(:,1)),2);
%---------------------------------------------------------------------

%decay = .15;
tmp = gomatrix(:,[1 3]);
tmp(:,2) = tmp(:,2)-1;
filteredtmp = [];
for L = 1:size(tmp,1); 
    filteredtmp(L,1) = (exp(-decay*([1:L]-1))*(tmp(L:-1:1,2)==1) )/sum(exp(-decay*([1:L]-1)));
end
out.errorProb = filteredtmp(lookup(out.time,tmp(:,1)));
%-----------------------------------------------------------------------


%decay = .15;
%tmp = gomatrix(:,[1 2]);
tmp = trialMatrix(find(trialMatrix(:,3)==1),[1 2]);
tmp(:,2) = tmp(:,2)-1;
filteredtmp = [];
for L = 1:size(tmp,1); 
    filteredtmp(L,1) = (exp(-decay*([1:L]-1))*(tmp(L:-1:1,2)==1) )/sum(exp(-decay*([1:L]-1)));
end
out.choiceProb = filteredtmp(lookup(out.time,tmp(:,1)));
%out.unsmoothedChoice = tmp(lookup(out.time,tmp(:,1)),2);
%---------------------------------------------------------------------
tmp = trialMatrix(find(trialMatrix(:,3)==1),[1 2]);
tmp(:,2) = tmp(:,2)-1;
filteredtmp = [];
filteredtmp = smoothvect(tmp(:,2),gaussian(3,54));
out.choiceProbGaussian = filteredtmp(lookup(out.time,tmp(:,1)));
%---------------------------------------



%decay = .15;
tmp = side1matrix(:,3);
filteredtmp = [];
for L = 1:size(tmp,1); 
    filteredtmp(L,1) = (exp(-decay*([1:L]-1))*(tmp(L:-1:1,1)==1) )/sum(exp(-decay*([1:L]-1)));
end
%filteredtmp = smoothvect(tmp,gaussian(3,27));
out.side1AccepProb = filteredtmp(lookup(out.time,side1matrix(:,1)));

tmp = side1matrix(find(side1matrix(:,3) == 1),[1 4]);
filteredtmp = [];
for L = 1:size(tmp,1); 
    filteredtmp(L,1) = (exp(-decay*([1:L]-1))*(tmp(L:-1:1,2)==1) )/sum(exp(-decay*([1:L]-1)));
end
out.side1RewardProb = filteredtmp(lookup(out.time,tmp(:,1)));
%----------------------------------------------------------------------

tmp = side2matrix(:,3);
filteredtmp = [];
for L = 1:size(tmp,1); 
    filteredtmp(L,1) = (exp(-decay*([1:L]-1))*(tmp(L:-1:1,1)==1) )/sum(exp(-decay*([1:L]-1)));
end
%filteredtmp = smoothvect(tmp,gaussian(3,27));
out.side2AccepProb = filteredtmp(lookup(out.time,side2matrix(:,1)));

tmp = side2matrix(find(side2matrix(:,3) == 1),[1 4]);
filteredtmp = [];
for L = 1:size(tmp,1); 
    filteredtmp(L,1) = (exp(-decay*([1:L]-1))*(tmp(L:-1:1,2)==1) )/sum(exp(-decay*([1:L]-1)));
end
out.side2RewardProb = filteredtmp(lookup(out.time,tmp(:,1)));
%------------------------------------------------------------------------

