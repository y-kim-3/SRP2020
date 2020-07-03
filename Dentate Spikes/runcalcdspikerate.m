%% Construct filter
%Note: this script only works with a single gc channel labeled in the chinfo
E3 = {'r1_01_', 'r1_12_', 'r1_18_', 'r1_21_', 'r1_29_', 'r1_33_', 'r1_34_',  'r1_39_',...
    'r2_06_', 'r2_17_', 'r2_28_',...
    'r3_02_', 'r3_11_'};
E4 = {'r1_05_', 'r1_24_', 'r1_31_', 'r1_35_', ...
    'r2_08_', 'r2_13_', 'r2_14_', 'r2_26_', 'r2_27_', 'r2_36_', 'r2_38_',...
    'r3_04_', 'r3_09_', 'r3_20_', 'r3_32_', 'r3_40_'};
animals = [E3 E4];

epochfilter = [];
epochfilter{1} = {'task','(~isequal($descript, ''FAIL'') && ~isequal($env,''FAIL''))'};

datafilter = [];  %only works with single channel specified
datafilter{1} = {'chinfo','isequal($area,''dg'') && contains($layer,''mua'')'};
%%%%MODIFY LATER TO ACCOMODATE MULTIPLE DG CHANNELS

timefilter = [];
% timefilter{1} = {'pos', '($vel < 1)'};
timefilter{1} = {'<function> get2dstate <argname> immobilecutoff <argval> 1','($immobilitytime > 30)'};

f = createfilter('animal', animals, 'epochs', epochfilter, 'data', datafilter, 'excludetime', timefilter);

binrange = [5 50];

%Specify function and run
f = setfilterfunction(f, 'calcdspikerate', {'dspikes'},'appendindex',2);
f = runfilter(f);

figopt=1;

%% Plot results

%clearvars -except figopt f f1 f2 gnames gindex

%ONLY WORKS WITH ONE CHANNEL PER MOUSE
% ------------------------------
% Figure and Font Sizes
set(0,'defaultaxesfontweight','normal'); set(0,'defaultaxeslinewidth',2);
set(0,'defaultaxesfontsize',16);
set(0,'DefaultAxesFontName','Arial')
tfont = 20; % title font
xfont = 20;
yfont = 20;

% load('E:\LFP Data\EKO Paper\colormap_ekopaper.mat')

if figopt==1   % PLOT RIPRATES by indiv and group
    %aggregate data over animals
    binnum = length(binrange)-1;
    animnames = [];
    animgeno = [];
    cols = [];
    for a = 1:length(f)
        if ~isempty(f(a).output)
            results = f(a).output.calcdspikerate.results;
            for g = 1:length(results)  %iterate thru conditions
                totaldur = 0;
                rates{a} = [];
                sizes{a} = [];
                for e = 1:length(results{g})  %iterate through sessions & epochs, combine counts
                    %fprintf('%s\t%d\t%f\n', f(a).animal{1}, e, mean(results{g}{e}.rates(1:binnum,:)));
                    totaldur = totaldur + results{g}{e}.validdur;
                    rates{a} = [rates{a} results{g}{e}.rates(1:binnum,:)];  %get rid of extra row (all zeros)
                    sizes{a} = [sizes{a}; results{g}{e}.sizes];
                end
                
            end
        else
            totaldur = 0;
            rates{a} = 0;
            sizes{a} = 0;
        end
        animnames = [animnames; f(a).animal(3) ];
        cols = [cols; f(a).animal{5} ];
        animgeno = [animgeno; f(a).animal(4)];
    end
    
    
%     temp = [];
%     for g = 1:length(gnames)
%         match = regexp(animgeno,gnames(g));
%         temp=[temp g*(~cellfun(@isempty,match))];
%     end
%     groupnum = sum(temp,2);
    
    % plot by individual animal
    for s = 1:binnum
        figure
        for a = 1:length(f)
            avgrate(a) = mean(rates{a}(s,:));
            semrate(a) = std(rates{a}(s,:))/sqrt(length(rates{a}));
        end   
    end
    avgrate'
    
%     [gmeans,gstds,gsems] = grpstats(avgrate',groupnum,{'mean','std','sem'});
%     
%     figure
%     for g = 1:length(gnames)
%         hold on
%         h = bar(g-.25,gmeans(g));
%         set(h,'FaceColor',colors(gindex(g),:))
%         h = errorbar(g-.25,gmeans(g),gsems(g),'.');
%         set(h,'Color','k')
%     end
%     set(gca, 'xtick', [])
%     text(.75:length(gnames)-.25,repmat(min(ylim)-.02,length(gnames),1),gnames,'horizontalalignment','center','FontSize',18)
%     xmax = length(gnames) + 0.5;
%     xlim([0 xmax])
%     ylabel('SWR Abundance (Hz)')
%     fig = gcf;
%     %saveas(fig, 'E:\LFP Data\EKO Paper\Fig 1e SWR Abundance bars.pdf')
%     
%     for i = 1:length(gnames)-1
%         for j = i+1:length(gnames)
%             [h,p,ci,stats] = ttest2(avgrate(groupnum==i), avgrate(groupnum==j));
%             fprintf('SWR abundance: %s = %f uV, %s = %f uV, t-test p-val = %f\n',...
%                 char(gnames(i)),gmeans(i),char(gnames(j)),gmeans(j),p);
%         end
%     end
        
    
%% plot baseline and SD for rip detection
elseif figopt==2
    
    animnames = [];
    animgeno = [];
    cols = [];
    
    for a = 1:length(f)
        if ~isempty(f(a).output)
            results = f(a).output.calcriprates2.results;
            for g = 1:length(results)  %iterate thru conditions
                baseline{a} = [];
                sd{a} = [];
                for e = 1:length(results{g})  %iterate through epochs, combine counts
                    baseline{a} = [baseline{a} results{g}{e}.baseline];
                    sd{a} = [sd{a} results{g}{e}.std];
                end
            end
        else
            baseline{a} = [];
            sd{a} = [];
        end
        animnames = [animnames; f(a).animal(3) ];
        cols = [cols; f(a).animal{5} ];
        animgeno = [animgeno; f(a).animal(4)];
    end
    
    temp = [];
    for g = 1:length(gnames)
        match = regexp(animgeno,gnames(g));
        temp=[temp g*(~cellfun(@isempty,match))];
    end
    groupnum = sum(temp,2);
    
    meanbaselines = cellfun(@mean,baseline);
    [gbase,gbstds,gbsems] = grpstats(meanbaselines',groupnum,{'mean','std','sem'});
    meansds = cellfun(@mean,sd);
    [gsd,gsdstds,gsdsems] = grpstats(meansds',groupnum,{'mean','std','sem'});
    
    figure
    for g = 1:length(gnames)
        hold on
        h = bar(g-.25,gbase(g));
        set(h,'FaceColor',colors(g,:))
        h = errorbar(g-.25,gbase(g),gbsems(g),'.');
        set(h,'Color','k')
    end
    set(gca, 'xtick', [])
    text(.75:length(gnames)-.25,repmat(min(ylim)-2,length(gnames),1),gnames,'horizontalalignment','center','FontSize',18)
    xlim([0 7.5])
    ylabel('Basline (uV)')
    fig = gcf;
    %saveas(fig, 'E:\LFP Data\EKO Paper\SWR Baseline bars 19Apr.pdf')
    
    figure
    for g = 1:length(gnames)
        hold on
        h = bar(g-.25,gsd(g));
        set(h,'FaceColor',colors(g,:))
        h = errorbar(g-.25,gsd(g),gsdsems(g),'.');
        set(h,'Color','k')
    end
    set(gca, 'xtick', [])
    text(.75:length(gnames)-.25,repmat(min(ylim)-1,length(gnames),1),gnames,'horizontalalignment','center','FontSize',18)
    xlim([0 7.5])
    ylabel('SD (uV)')
    fig = gcf;
    %saveas(fig, 'E:\LFP Data\EKO Paper\SWR SD bars 19Apr.pdf')

    groups = unique(groupnum);
    for i = 1:length(groups)-1
        for j = i+1:length(groups)
            [h,p,ci,stats] = ttest2(meanbaselines(groupnum==groups(i)), meanbaselines(groupnum==groups(j)));
            fprintf('Baseline amplitude: %s = %f uV, %s = %f uV, t-test p-val = %f\n',...
            char(gnames(groups(i))),gbase(groups(i)),char(gnames(groups(j))),gbase(groups(j)),p);
            [h,p,ci,stats] = ttest2(meansds(groupnum==groups(i)), meansds(groupnum==groups(j)));
            fprintf('Size of 1 SD: %s = %f uV, %s = %f uV, t-test p-val = %f\n',...
            char(gnames(groups(i))),gsd(groups(i)),char(gnames(groups(j))),gsd(groups(j)),p);
        end
    end
    
end