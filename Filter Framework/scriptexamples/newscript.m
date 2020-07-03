
animals = {'Agnes'};

epochfilter = [];
epochfilter{1} = {'task','$sess==1'};
%epochfilter{2} = {'task','isequal($env,''novel'')'};

datafilter = [];
datafilter{1} = {'chinfo','isequal($area, ''ca1'')'};


timefilter = [];
timefilter{1} =  {'pos', '($vel > 1)'};
%timefilter{1} = [];

%timefilter{1} = {'<function> get2dstate <argname> immobilecutoff <argval> 1','($immobilitytime > 5)'};

%filterfunction = {'calctotalmeanrate',{'spikes'},'appendindex',1};
f = createfilter('animal', animals, 'epochs', epochfilter, 'data', datafilter,'excludetime',timefilter);

%f = createfilter('animal', animals, 'epochs', epochfilter, 'data', datafilter, 'excludetime', timefilter,'function',filterfunction);
%f = runfilter(f);


% %Change the function and run again 
% f = setfilterfunction(f, 'dummy', {'eeg'});
% f = runfilter(f);




