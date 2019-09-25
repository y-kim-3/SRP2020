% Leave-one-out cross-validation
% Calculates mean & stdev of R and p values after deleting each value
% (stats rows 1 - 4) plus the number of combinations in which the p value
% fell below significance (stats row 5)

%replace x and y_mat with data
x = zeros(10,1);
y_mat = zeros(10,5);

R = NaN(size(y_mat,1),size(y_mat,2));
p = NaN(size(y_mat,1),size(y_mat,2));
for i = 1:size(y_mat,2)
    y = y_mat(:,i);
    for a = 1:length(y_mat)
        y_sub = y;
        y_sub(a,:) = [];
        x_sub = x;
        x_sub(a,:) = [];
        [R(a,i),p(a,i)] = corr(x_sub,y_sub,'rows','complete');
    end
    stats(1,i) = nanmean(R(:,i));
    stats(2,i) = nanstd(R(:,i));
    stats(3,i) = nanmean(p(:,i));
    stats(4,i) = nanstd(p(:,i));
    stats(5,i) = sum(p(:,i) > 0.05);
end