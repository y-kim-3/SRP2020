% smoothed = SMOOTHVECT(origsignal, filter)
%            convolves origsignal with filter, removes length(filter) - 1
%            points to produce a signal with the same length as origsignal, and
%            returns the result
function [s] = smoothvect(os, f)

initsize = size(os);
os = os(:)';
f = f(:)';

%sm = conv(os,f);
filterlen = length(f);
% the convolution returns a vector whose length is the sum of
% the length of the two arguments - 1
startp = floor(filterlen / 2);

startconv = (os(1:startp)*f(end-startp+1:end)')/sum(f(end-startp+1:end));
endconv = (os(end-startp+1:end)*f(1:startp)')/sum(f(1:startp));
% middleconv = conv(os,f,'valid')
os = [startconv*ones(1,startp) os endconv*ones(1,startp)];
sm = conv(os,f);

%endp = startp + length(os) - 1;
%s = sm(startp:endp);
if rem(filterlen,2)
    s = sm(filterlen:end-filterlen+1);
else
    s = sm(filterlen:end-filterlen);
end

s = reshape(s,initsize);