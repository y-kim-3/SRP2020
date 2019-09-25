function countripples(dir, prefix, day, epoch)

%% counts numbers of ripples on each channel by day and epoch
% output is count array:  each row is a channel, column 1 is 3sd ripples,
% col2 is 5sd ripples, col3 is 7sd ripples

file = sprintf('%s/%sripples%02d.mat',dir, prefix, day);

if(exist(file))
    load(file)
    
    for i = 1:length(ripples{day}{epoch})
        count(i,1) = length(ripples{day}{epoch}{i}.startind);
        
        index5 = 0;
        for r = 1:length(ripples{day}{epoch}{i}.startind)
            if ripples{day}{epoch}{i}.maxthresh(r) > 5
                index5 = index5+1;
            end
        end
        count(i,2) = index5;
        
        index7 = 0;
        for r = 1:length(ripples{day}{epoch}{i}.startind)
            if ripples{day}{epoch}{i}.maxthresh(r) > 7
                index7 = index7+1;
            end
        end
        count(i,3) = index7;
        
    end
    figure
    plot(count(:,1),'-rx')  % all ripples
    hold on
    plot(count(:,2), '-*') %over stdev 5
    plot(count(:,3), '-ko') %over stdev 7
    legend('3sd', '5sd', '7sd');
    title(sprintf('%sripcounts%02d-%02d',prefix,day,epoch));
end

% %% plots ripple mean power and variance across sites
% channels=1:31;
% sitemap=[(1:15)' [16:22 24:31]'];
% %sitemap = [(1:8)' (9:16)' (17:24)' (25:32)'];  % 4 shank!!
%
% % first load filtered eeg (for ripples)
%
% ripple=loadeegstruct(dir,prefix,'ripple',day,epoch,channels);
%
%
% % plot power
% for s=day
%     for e=epoch
%         rms=zeros(size(sitemap));
%         variance=zeros(size(sitemap));
%         for c=channels
%             site=find(c==sitemap);
%             rms(site)=sqrt(mean(ripple{s}{e}{c}.data(:,1).^2));
%             variance(site)=var(double(ripple{s}{e}{c}.data(:,1)));
%         end
%         figure
%         subplot(1,2,1)
%             imagesc(rms)   ;  colormap(copper)    ; colorbar ; title([prefix ' ripple power']) ;
%         subplot(1,2,2)
%             imagesc(variance) ;  colormap(copper)    ; colorbar ; title([prefix ' variance']) ;
%     end
% end


