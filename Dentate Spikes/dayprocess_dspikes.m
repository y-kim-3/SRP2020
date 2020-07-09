%cell arrays detailing which rats have which genotype
E3 = {'r1_01_', 'r1_12_', 'r1_18_', 'r1_21_', 'r1_29_', 'r1_33_', 'r1_34_',  'r1_39_',...
    'r2_06_', 'r2_17_', 'r2_28_',...
    'r3_02_', 'r3_11_'};
E4 = {'r1_05_', 'r1_24_', 'r1_31_', 'r1_35_', ...
    'r2_08_', 'r2_13_', 'r2_14_', 'r2_26_', 'r2_27_', 'r2_36_', 'r2_38_',...
    'r3_04_', 'r3_09_', 'r3_20_', 'r3_32_', 'r3_40_'};
%animals = [E3 E4];
animals = {'r1_01_'};

%guide to access rat files - point this at E3 and E4 separately
animalbasedir = 'D:/Cohort 1/E3KI/';
days = 3;
%a=array iterates through all the elements in the array
%note: in loops you must specify the range not just the ending point
for a = animals
    %finding a specific file for each animal
    %sprintf formates data into string + adds / between each element
    animaldir = sprintf('%s/%s/',animalbasedir,a{1});
    prefix = a{1};
    
    for d = days
        %calls on a function to extract dentate spikes, with inputs in ()
        ag_extractdspikes(animaldir, prefix, d, .015, 3)
%         ej_extractdspikes(animaldir, prefix, d, .015, 3)
        plotdspikes
        %plotfiltereddata_dspikes
        pause
        close all
    end
end