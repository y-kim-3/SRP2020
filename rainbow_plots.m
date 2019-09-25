% Input: animkey = animal names for entire cohort sorted by a feature
% animnames = animal names for this expt
% x = data, where x(:,1) = feature & x(:,2-end) = behavior
% Output: scatterplots for all feature x behaviors
% Update points & axis sizes to match Illustrator files
% Manually update axes limits to match Illustrator files

% animnames = cell(1,1);
% animkey = cell(1,1);
% x = zeros(0,0);

rgb = colormap(jet(length(animkey)));
colorhash = containers.Map(animkey,1:length(animkey));

cmap = [];
for i = 1:length(animnames)
    cmap = [cmap; rgb(colorhash(animnames{i}),:)];
end

for i = 2:size(x,2)
    figure
    h = scatter(x(:,1),x(:,i),[],cmap,'filled'); %'s'
    h.SizeData = 20;
    b = [ones(length(x),1) x(:,1)]\x(:,i);
    hline = refline(b(2),b(1));
    hline.Color = 'k';
    hline.LineWidth = 1.2;
    set(gca,'xticklabel',[])
    set(gca,'yticklabel',[])
    %     set(gca,'Position',[0.1 0.1 1.17 1.17])
    set(gcf,'PaperPosition',[0.5 0.5 1.17 1.17]); %1.17 %1.43
    set(gca,'LooseInset',get(gca,'TightInset'));
    xlim([0 0.4])
    ylim([0 60])
%     xlim([0 1.2])
%     fitlm(x(:,1),x(:,i),'linear')
%     trainb = [ones(length(train),1) train(:,1)]\train(:,i);
%     refline(trainb(2),trainb(1))
%     xlim([-2 2])
%     ylim([-2 2])
    
end