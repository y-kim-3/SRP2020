function animalinfo = animaldef(animalname)

switch lower(animalname)
    
        %The Mighty Mischief
        %change to be where data is stored for each animal
    case 'r1_01_'
        animalinfo = {'r1_01_','D:/Cohort 1/E3KI/r1_01_/','r1_01_','E3','b'}; %18
    case 'r1_12_'
        animalinfo = {'r1_12_','D:/Cohort 1/E3KI/r1_12_/','r1_12_','E3','b'}; %18
    case 'r1_21_'
        animalinfo = {'r1_21_','D:/Cohort 1/E3KI/r1_21_/','r1_21_','E3','b'}; %18
    case 'r1_29_'
        animalinfo = {'r1_29_','D:/Cohort 1/E3KI/r1_29_/','r1_29_','E3','b'}; %18
    case 'r1_33_'
        animalinfo = {'r1_33_','D:/Cohort 1/E3KI/r1_33_/','r1_33_','E3','b'}; %18
    case 'r1_05_'
        animalinfo = {'r1_05_','D:/Cohort 1/E4KI/r1_05_/','r1_05_','E4','r'}; %18
    case 'r1_24_'
        animalinfo = {'r1_24_','D:/Cohort 1/E4KI/r1_24_/','r1_24_','E4','r'}; %18
    case 'r1_31_'
        animalinfo = {'r1_31_','D:/Cohort 1/E4KI/r1_31_/','r1_31_','E4','r'}; %18
    case 'r1_35_'
        animalinfo = {'r1_35_','D:/Cohort 1/E4KI/r1_35_/','r1_35_','E4','r'}; %18
    case 'r1_18_'
        animalinfo = {'r1_18_','D:/Cohort 1/E3KI/r1_18_/','r1_18_','E3','b'}; %16
    case 'r1_34_'
        animalinfo = {'r1_34_','D:/Cohort 1/E3KI/r1_34_/','r1_34_','E3','b'}; %16
    case 'r1_39_'
        animalinfo = {'r1_39_','D:/Cohort 1/E3KI/r1_39_/','r1_39_','E3','b'}; %16
    case 'r2_26_'
        animalinfo = {'r2_26_','D:/Cohort 1/E4KI/r2_26_/','r2_26_','E4','r'}; %16
    case 'r2_36_'
        animalinfo = {'r2_36_','D:/Cohort 1/E4KI/r2_36_/','r2_36_','E4','r'}; %16
    case 'r2_38_'
        animalinfo = {'r2_38_','D:/Cohort 1/E4KI/r2_38_/','r2_38_','E4','r'}; %16
    case 'r2_28_'
        animalinfo = {'r2_28_','D:/Cohort 1/E3KI/r2_28_/','r2_28_','E3','b'}; %14
    case 'r2_06_'
        animalinfo = {'r2_06_','D:/Cohort 1/E3KI/r2_06_/','r2_06_','E3','b'}; %14
    case 'r2_17_'
        animalinfo = {'r2_17_','D:/Cohort 1/E3KI/r2_17_/','r2_17_','E3','b'}; %14
    case 'r2_08_'
        animalinfo = {'r2_08_','D:/Cohort 1/E4KI/r2_08_/','r2_08_','E4','r'}; %14
    case 'r2_13_'
        animalinfo = {'r2_13_','D:/Cohort 1/E4KI/r2_13_/','r2_13_','E4','r'}; %14
    case 'r2_14_'
        animalinfo = {'r2_14_','D:/Cohort 1/E4KI/r2_14_/','r2_14_','E4','r'}; %14
    case 'r2_27_'
        animalinfo = {'r2_27_','D:/Cohort 1/E4KI/r2_27_/','r2_27_','E4','r'}; %14
    case 'r3_32_'
        animalinfo = {'r3_32_','D:/Cohort 1/E4KI/r3_32_/','r3_32_','E4','r'}; %14
    case 'r3_02_'
        animalinfo = {'r3_02_','D:/Cohort 1/E3KI/r3_02_/','r3_02_','E3','b'}; %12
    case 'r3_11_'
        animalinfo = {'r3_11_','D:/Cohort 1/E3KI/r3_11_/','r3_11_','E3','b'}; %12
    case 'r3_04_'
        animalinfo = {'r3_04_','D:/Cohort 1/E4KI/r3_04_/','r3_04_','E4','r'}; %12
    case 'r3_09_'
        animalinfo = {'r3_09_','D:/Cohort 1/E4KI/r3_09_/','r3_09_','E4','r'}; %12
    case 'r3_20_'
        animalinfo = {'r3_20_','D:/Cohort 1/E4KI/r3_20_/','r3_20_','E4','r'}; %12
    case 'r3_40_'
        animalinfo = {'r3_40_','D:/Cohort 1/E4KI/r3_40_/','r3_40_','E4','r'}; %12
    
    otherwise
        error(['Animal ',animalname, ' not defined.']);
        
end