% Construct filter
 figopt=2;
 clearvars -except figopt f

E3 = {'r1_01_', 'r1_12_', 'r1_18_', 'r1_21_', 'r1_29_', 'r1_33_', 'r1_34_',  'r1_39_',...
    'r2_06_', 'r2_17_', 'r2_28_',...
    'r3_02_', 'r3_11_'};
E4 = {'r1_05_', 'r1_24_', 'r1_31_', 'r1_35_', ...
    'r2_08_', 'r2_13_', 'r2_14_', 'r2_26_', 'r2_27_', 'r2_36_', 'r2_38_',...
    'r3_04_', 'r3_09_', 'r3_20_', 'r3_32_', 'r3_40_'};
animals = [E3 E4];

epochfilter = [];
epochfilter{1} = {'task','(~strcmp($env, ''FAIL'') && ~strcmp($descript, ''FAIL''))'};

datafilter = [];  %only works with single channel specified
datafilter{1} = {'chinfo','(isequal($area,''ca1'') && contains($layer,''*pyr 1*''))'};

timefilter = [];
timefilter{1} = {'<function> get2dstate <argname> immobilecutoff <argval> 1','($immobilitytime > 30)'};

binrange = [5 50];
f = createfilter('animal', animals, 'epochs', epochfilter, 'data', datafilter, 'excludetime', timefilter);

%Specify function and run
f = setfilterfunction(f, 'calcriprates2', {'ripples'},'appendindex',2,'bins',binrange);
f = runfilter(f);

%% Plot results

%ONLY WORKS WITH ONE CHANNEL PER MOUSE
% ------------------------------
% Figure and Font Sizes
set(0,'defaultaxesfontweight','normal'); set(0,'defaultaxeslinewidth',2);
set(0,'defaultaxesfontsize',16);
set(0,'DefaultAxesFontName','Arial')
tfont = 20; % title font
xfont = 20;
yfont = 20;

if figopt==1   % PLOT RIPRATES by indiv and group
    %aggregate data over animals
    binnum = length(binrange)-1;
    animnames = [];
    animgeno = [];
    cols = [];
    ratemat = nan(length(f),5);
    for a = 1:length(f)
        if ~isempty(f(a).output)
            results = f(a).output.calcriprates2.results;
            for g = 1:length(results)  %iterate thru conditions
                totaldur = 0;
                durs{a} = [];
                rates{a} = [];
                sizes{a} = [];
                counts{a} = [];
                for e = 1:length(results{g})  %iterate through sessions & epochs, combine counts
                    %fprintf('%s\t%d\t%f\n', f(a).animal{1}, e, mean(results{g}{e}.rates(1:binnum,:)));
                    totaldur = totaldur + results{g}{e}.validdur;
                    durs{a} = [durs{a}; results{g}{e}.validdur];
                    counts{a} = [counts{a}; results{g}{e}.counts(1:binnum,:)];
                    rates{a} = [rates{a} results{g}{e}.rates(1:binnum,:)];  %get rid of extra row (all zeros)
                    ratemat(a,e) = results{g}{e}.rates(1:binnum,:);
                    sizes{a} = [sizes{a}; results{g}{e}.sizes];
                end
                
            end
        else
            totaldur = 0;
            rates{a} = 0;
            sizes{a} = 0;
        end
        animnames = [animnames; f(a).animal(3) ];
%         cols = [cols; f(a).animal{5} ];
        animgeno = [animgeno; f(a).animal(4)];
    end
    
    for s = 1:binnum
        for a = 1:length(f)
            avgrate(a) = mean(rates{a}(s,:));
        end      
    end
    avgrate'   
    
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
    
    b = [];
    for a = 1:length(f)
        b(a) = mean(baseline{a});
    end
    b'
    for a = 1:length(f)
        b(a) = mean(sd{a});
    end
    b'
end
