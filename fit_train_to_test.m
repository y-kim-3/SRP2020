%Input: train & test data, where the first column is the feature (ephys)
%and the other columns are the thing being predicted (behavior)
%Output: F statistic & p val for how well lin reg from train data fits test
%data

% train = zeros(16,6);
% test = zeros(11,6);

for i = 2:size(train,2) 
    % [b, dev, stats] = glmfit(train(:,1),train(:,i));
    b = [ones(length(train),1) train(:,1)]\train(:,i);
    yfit = glmval(b,test(:,1),'identity');
    SSE_F = sum((test(:,i) - yfit).^2); % full model SSE
    SSE_R = sum((test(:,i) - mean(test(:,i))).^2); % reduced model SSE
    DR = length(test)-1;
    
    DFn = length(test)-2; %n-p
    MSR = (SSE_R - SSE_F) / (DR - DFn);
    MSE = SSE_F/DFn;
    F = MSR/MSE;
    p_val = 1-fcdf(F,1,DFn);
    fprintf('Metric %d: F(1,%d) = %f, p = %f\n', i, DFn, F, p_val);
    
    figure
    h = scatter(yfit,test(:,2),[],cmap);
    h.SizeData = 20;
%     hline = refline(1,0);
%     hline.LineWidth = 1.2;
    
    fitlm(yfit,test(:,i),'linear')
    b = [ones(length(test),1) yfit]\test(:,i);
    hline = refline(b(2),b(1));
    hline.Color = 'k';
    hline.LineWidth = 1.2;
    
    set(gca,'xticklabel',[])
    set(gca,'yticklabel',[])
    set(gcf,'PaperPosition',[0.5 0.5 1.17 1.17]); %1.7488
    set(gca,'LooseInset',get(gca,'TightInset'));
    xlim([-2 2])
    ylim([-2 2])
end