% Pre-processing
% Input: nex files, pos xls file in correct format, task struct, remapper
% Output: eeg files by day/ep/chan, rip files, rips files, pos files

clearvars
%making cells of the two genotypes
E3 = {'r1_01_', 'r1_12_', 'r1_18_', 'r1_21_', 'r1_29_', 'r1_33_', 'r1_34_',  'r1_39_',...
    'r2_06_', 'r2_17_', 'r2_28_',...
    'r3_02_', 'r3_11_'};
E4 = {'r1_05_', 'r1_24_', 'r1_31_', 'r1_35_', ...
    'r2_08_', 'r2_13_', 'r2_14_', 'r2_26_', 'r2_27_', 'r2_36_', 'r2_38_',...
    'r3_04_', 'r3_09_', 'r3_20_', 'r3_32_', 'r3_40_'};
%combines the cells - "pastes" them together
%brackets can also be used to combine things
animals = [E3 E4];

datadir = 'E:\\LFP Data\CRCNS\Cohort 1\Trodes Raw Data';
animalbasedir = 'E:\\LFP Data\CRCNS\Cohort 1\Preprocessed Data';
%1x5 matrix
days = 1:5;

%ignore
myCluster = parcluster('local');
myCluster.NumWorkers = 6;
saveProfile(myCluster);

for a = animals
    %base directory + inside specific animal file
    animaldir = sprintf('%s\\%s\\',animalbasedir,a{1});
    prefix = a{1};
    
    for d = days
        %can write to a file, or write to the output window
        fprintf('Processing: %s %d\n',prefix,d);
        
        %convert raw data into individual eeg files
        convertToFilterFramework_trodes_optimized(datadir,animaldir,prefix,d,1:32);
        
        %filter for ripple frequency band
        ej_rippledayprocess(animaldir, prefix, d);
        
        %extract ripple events >3SD
        ag_extractripples(animaldir, prefix, d, .015, 3);
        
        %plot ripple counts
        countripples(animaldir,prefix,d);
        
        %import, smooth position, calculate velocity
        pos_trodes(datadir, animaldir, prefix, d);
        
    end
    
end