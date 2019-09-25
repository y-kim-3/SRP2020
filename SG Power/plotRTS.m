figopt = 2;
clear title

% ------------------------------
% plot ALL RTS for a mouse in correct layout
% ------------------------------
% Figure and Font Sizes
set(0,'defaultaxesfontweight','normal'); set(0,'defaultaxeslinewidth',2);
set(0,'defaultaxesfontsize',10);
tfont = 10; % title font
xfont = 10;
yfont = 10;
clr = {'b','r','g','c','m','y','k','r'};
% ---------------------------------------


for a = 1:length(f)  %should always be 1
    
    results = f(a).output.RTspecgram3.results;
    vehresults = fveh(a).output.RTspecgram3.results;
    for g = 1:length(results)  %iterate thru conditions
        for t = 1:size(results{1}{1}.trigindex,1)  %iterate thru trigchans
            %combine data over epochs for trig and probe
            
            for p = 1:size(results{1}{1}.probeindex,1) %iterate through probechans
                %iterate thru probe chans, combine eps, plot
                
                probe{t}{p} = [];
                for e = 1:length(results{g}) %epochs
                    if length(results{g}{e}.riptimes)>1
                        probe{t}{p} = cat(3,probe{t}{p},results{g}{e}.Sprobe{t}{p}(:,1:38,:));  %38 full spectrum, 1:11 SG
                        
                        times = results{g}{e}.times;
                        freqs = results{g}{e}.freqs(:); %38 full spectrum, 1:11 SG  %%%1:11
                    end
                end
                probemean{t}{p} = median(probe{t}{p},3);%mean
            end
            numevents = size(probe{t}{1},3);
            
            %plot all RTS
            figure;
            hold on;
            
            shank = size(results{1}{1}.probeindex,1);
            set(gcf,'Position',[1 1 1595 964]);
            for s = 1:shank
                chanpos = results{1}{1}.probeindex(s,3);
                
                subplot(4,8,chanpos)
                imagesc(times, freqs,probemean{t}{s}');
                colormap hot %jet
                set(gca, 'Clim', [0 4]);
                set(gca,'YDir','normal');
                details = sprintf('%d', chanpos);
                title(details, 'FontSize',10,'Fontweight','normal');
                %ylabel('Freq','FontSize',10,'Fontweight','normal');
                %xlabel('Time(s)','FontSize',10,'Fontweight','normal');
                set(gca,'XLim',[min(times) max(times)]);
                set(gca,'YLim',[min(freqs) max(freqs)]);
                % Plot Line at 0 ms - Start of ripple
                hold on
                ypts = freqs;
                xpts = 0*ones(size(ypts));
                plot(xpts , ypts, 'w--','Linewidth',2);
                colorbar;
                suptitle = sprintf('%s %drips trigggered off ch%d, 5SD',f(a).animal{3},numevents,results{g}{t}.trigindex(t,3));
                [ax,h]=suplabel(suptitle ,'t');
                tightfig;
            end
        end
    end
end