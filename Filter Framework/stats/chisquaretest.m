function [pval, chi2stat] = chisquaretest(x,n)
%[p, chi2stat] = zproptest(x,n)
%  Computes chi-square text for two proportions
% x: [x1 x2]
% n: [n1 n2]


x1 = [repmat('a',n(1),1); repmat('b',n(2),1)];
x2 = [repmat(1,x(1),1); repmat(2,n(1)-x(1),1); repmat(1,x(2),1); repmat(2,n(2)-x(2),1)];
[tbl,chi2stat,pval] = crosstab(x1,x2);

