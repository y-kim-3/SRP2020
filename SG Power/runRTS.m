myCluster = parcluster('local');
myCluster.NumWorkers = 6;
saveProfile(myCluster);

E3 = {'r1_01_', 'r1_12_', 'r1_18_', 'r1_21_', 'r1_29_', 'r1_33_', 'r1_34_',  'r1_39_',...
    'r2_06_', 'r2_17_', 'r2_28_',...
    'r3_02_', 'r3_11_'};
E4 = {'r1_05_', 'r1_24_', 'r1_31_', 'r1_35_', ...
    'r2_08_', 'r2_13_', 'r2_14_', 'r2_26_', 'r2_27_', 'r2_36_', 'r2_38_',...
    'r3_04_', 'r3_09_', 'r3_20_', 'r3_32_', 'r3_40_'};
animals = [E3 E4];

analysisdir = 'E:\\LFP Data\CRCNS\Cohort 1\Preprocessed Data';
group = 'Cohort 1';

epochfilter = [];
epochfilter{1} = {'task','(~strcmp($env, ''FAIL'') && ~strcmp($descript, ''FAIL''))'};

datafilter = [];  % load all channels...use embedded filter in run function to get specific ones
datafilter{1} = {'chinfo','(~isequal($area,''dead''))'};

timefilter = [];
timefilter{1} = {'<function> get2dstate <argname> immobilecutoff <argval> 1','($immobilitytime > 30)'};

% set varargin for RTspecgram3 (channel filtering criteria)
trigcrit = '(isequal($area,''ca1'') && contains($layer,''**pyr 1**''))';
probecrit = '(~isequal($area,''dead''))';

for a = animals
    f = createfilter('animal', a{1}, 'epochs', epochfilter, 'data', datafilter, 'excludetime', timefilter);
    f = setfilterfunction(f, 'RTspecgram3', {'eeg','ripples','chinfo'},'minstd',3,'trig',trigcrit,'probe',probecrit,'slidingwin',[.1 .01]);
    f = runfilter(f);
    save(sprintf('%s/%s Smooth.mat', analysisdir, a{1}),'f', '-v7.3')
    plotRTS
end

f = createfilter('animal', animals, 'epochs', epochfilter, 'data', datafilter, 'excludetime', timefilter);
f = setfilterfunction(f, 'RTspecgram3', {'eeg','ripples','chinfo'},'minstd',3,'trig',trigcrit,'probe',probecrit,'slidingwin',[.1 .1]);
f = runfilter(f);
save(sprintf('%s/%s RTS Quant.mat', analysisdir, group),'f', '-v7.3');