%print chinfos in an Excel-friendly format
animals = {'Adobo_LT', 'Caraway_LT', 'Chives_LT', ...
    'Cinnamon_LT', 'Coriander_LT', 'Fenugreek_LT', 'GaramMasala_LT', 'Salt_LT', ...
    'Baharat_LT', 'Cardamom_LT', 'Jerk_LT', 'Mace_LT', 'Mustard_LT', ...
    'Tarragon_LT', 'Vanilla_LT',...
    'Basil_LT', 'Cumin_LT', 'Dill_LT', 'Nutmeg_LT', 'Paprika_LT', 'Parsley_LT', 'Sumac_LT',... 
    'Pepper_LT', 'Sage_LT', 'Anise_LT', 'Thyme_LT', 'OldBay_LT', 'Rosemary_LT',...
    'Provence_LT', 'Saffron_LT'};

animalbasedir = '\\hub.gladstone.internal\HuangLab-LFP\Emily\DREADDs WMaze\LT Postop\Preprocessed Data/';

for a = 1:length(animals)
    prefix = animals{a};
    load(sprintf('%s/%s/%schinfo.mat',animalbasedir,prefix,prefix))
	fprintf('%s\n',prefix)
	c = chinfo{1}{1};
	for i = 1:8
		fprintf('%d %s %s\t%d %s %s\t%d %s %s\t%d %s %s\n',i,c{i}.area,c{i}.layer,i+8,c{i+8}.area,c{i+8}.layer,i+16,c{i+16}.area,c{i+16}.layer,i+24,c{i+24}.area,c{i+24}.layer)
	end
end