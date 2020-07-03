% function [corr] = windowcorr(x,y,nwin)
% %UNTITLED4 Summary of this function goes here
% %   Detailed explanation goes here
% 
% n=length(x); % 15 seconds long signal
% %nwin=round(n/3); % 5 seconds long signal
% moving_window = [1:nwin]';
% 
% % 4.5 second overlap to get 0.5 second time steps.
% %noverlap=floor(0.9*nwin);
% noverlap = nwin-1;
% k=floor((n-noverlap)/(nwin-noverlap));
% index=1:nwin;
% for j=1:k
%       temp=corrcoef(x(index),y(index));
%       %temp=cov(x(index),y(index));
%       corr(j) = temp(1,2);
%       index=index+(nwin-noverlap);
% end
% 
% corr= corr';
% 
% end

function [corr] = windowcorr(x, nwin)
%Sliding window correlation
%Each column is an observation, each row is a variable

n=size(x,1); % 15 seconds long signal
%nwin=round(n/3); % 5 seconds long signal
moving_window = [1:nwin]';

% 4.5 second overlap to get 0.5 second time steps.
%noverlap=floor(0.9*nwin);
noverlap = nwin-1;
k=floor((n-noverlap)/(nwin-noverlap));
index=1:nwin;
corr = [];
for j=1:k
      temp=corrcoef(x(index,:));
      temp(find(isnan(temp))) = 0;
      %temp=cov(x(index),y(index));
      corr(1:size(temp,1),1:size(temp,2),j) = temp;
      %corr(j) = temp(1,2);
      index=index+(nwin-noverlap);
end

%corr= corr';

