E3 = {'r1_01_', 'r1_12_', 'r1_18_', 'r1_21_', 'r1_29_', 'r1_33_', 'r1_34_',  'r1_39_',...
    'r2_06_', 'r2_17_', 'r2_28_',...
    'r3_02_', 'r3_11_'};
E4 = {'r1_05_', 'r1_24_', 'r1_31_', 'r1_35_', ...
    'r2_08_', 'r2_13_', 'r2_14_', 'r2_26_', 'r2_27_', 'r2_36_', 'r2_38_',...
    'r3_04_', 'r3_09_', 'r3_20_', 'r3_32_', 'r3_40_'};
animals = [E3 E4];

epochfilter = [];
datafilter = [];  %only works with single channel specified
datafilter{1} = {'chinfo','(~isequal($area,''dead''))'};
timefilter = [];
timefilter{1} = {'<function> get2dstate <argname> immobilecutoff <argval> 1','($immobilitytime > 30)'}; %sleep

trigcrit = '(isequal($area,''ca1'') && contains($layer,''**pyr 1**''))';
probecrit = trigcrit;

epochfilter{1} = {'task','(isequal($treatment, ''Veh'') && ~isequal($env,''FAIL''))'};
f = createfilter('animal', animals, 'epochs', epochfilter, 'data', datafilter, 'excludetime', timefilter);
f = setfilterfunction(f, 'RTMUA', {'mua','ripples','chinfo'},'minstd',3,'trig',trigcrit,'probe',probecrit);
f = runfilter(f);


%% PLOT
location = '(isequal($area,''ca1''))';

set(0,'defaultaxesfontweight','normal')
set(0,'defaultaxeslinewidth',2)
set(0,'defaultaxesfontsize',16)
set(0,'DefaultAxesFontName','Arial')
tfont = 20; % title font
xfont = 20;
yfont = 20;

animnames = [];
animgeno = [];
for a = 1:length(f)
    results = f(a).output.RTMUA.results;
    fullbaserate{a} = [];
    baserate{a} = [];
    sdfullbaserate{a} = [];
    sdbaserate{a} = [];
    psth{a} = [];
    timebase{a} = [];
    wave{a} = [];
    peakrate{a} = [];
    SWRrate{a} = [];
    normrate{a} = [];
    normpsth{a} = [];
    
    animinfo = animaldef(f(a).animal{1});%f(a).animal;
    infofile = sprintf('%s%schinfo.mat',animinfo{2},animinfo{3});
    load(infofile)
    temp = evaluatefilter(chinfo,location);
    sites{a} = unique(temp(:,3));
    [sites{a},siteinds] = intersect(results{1}{1}.probeindex(:,3),sites{a});
    
    for e = 1:length(results{1})  %iterate through epochs, combine counts
        if ~isempty(results{1}{e}.probeindex) && ~isempty(results{1}{e}.trigindex)
            for t = 1:length(results{1}{e}.baserate)
                for p = 1:length(siteinds)%1:length(results{1}{e}.baserate{t})
                    [sites{a},siteinds] = intersect(results{1}{e}.probeindex(:,3),sites{a});
                    fullbaserate{a} = [fullbaserate{a}; results{1}{e}.fullbaserate{t}{p}];
                    baserate{a} = [baserate{a}; results{1}{e}.baserate{t}{siteinds(p)}];
                    sdfullbaserate{a} = [sdfullbaserate{a}; results{1}{e}.sdfullbaserate{t}{p}];
                    sdbaserate{a} = [sdbaserate{a}; results{1}{e}.sdbaserate{t}{p}];
                    psth{a} = [psth{a}; results{1}{e}.psth{t}{p}];
                    normpsth{a} = [normpsth{a}; (results{1}{e}.psth{t}{p}-results{1}{e}.baserate{t}{p})./results{1}{e}.sdbaserate{t}{p}];
                    timebase{a} = [timebase{a}; results{1}{e}.psth{t}{p}(:,5)];
                    wave{a} = [wave{a}; results{1}{e}.wave{t}{p}];
                    peakrate{a} = [peakrate{a}; results{1}{e}.peakrate{t}{p}];%(:,1)
                    SWRrate{a} = [SWRrate{a}; results{1}{e}.SWRrate{t}{siteinds(p)}];
                    normrate{a} = [normrate{a}; results{1}{e}.normrate{t}{siteinds(p)}];                    
                end
            end
        end
    end
    animnames = [animnames; f(a).animal(3)];
    animgeno = [animgeno; f(a).animal(4)];
end