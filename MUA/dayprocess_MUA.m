E3 = {'r1_01_', 'r1_12_', 'r1_18_', 'r1_21_', 'r1_29_', 'r1_33_', 'r1_34_',  'r1_39_',...
    'r2_06_', 'r2_17_', 'r2_28_',...
    'r3_02_', 'r3_11_'};
E4 = {'r1_05_', 'r1_24_', 'r1_31_', 'r1_35_', ...
    'r2_08_', 'r2_13_', 'r2_14_', 'r2_26_', 'r2_27_', 'r2_36_', 'r2_38_',...
    'r3_04_', 'r3_09_', 'r3_20_', 'r3_32_', 'r3_40_'};
animals = [E3 E4];

datadir = 'E:\\LFP Data\CRCNS\Cohort 1\Trodes Raw Data';
animalbasedir = 'E:\\LFP Data\CRCNS\Cohort 1\Preprocessed Data';

for a = 1:length(animals)
    prefix = animals{a};
    animaldir = [animalbasedir '/' prefix];
    
    taskname = sprintf('%s/%stask.mat',animaldir,prefix);
    load(taskname);
    for d = 1:length(task)
        for e = 1:length(task{d})
            if(~contains(lower(task{d}{e}.env), '*fail*') && ...
                    ~contains(lower(task{d}{e}.descript), '*fail*'))
                extract_spikes(datadir, animaldir, prefix, d, e);
            end
        end
    end
end