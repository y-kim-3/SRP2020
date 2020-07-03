function f = createfilter(varargin)

f.animal = [];
f.epochs = [];
f.excludetime = [];
f.data = [];
f.function = [];
f.output = [];
f.arguments = [];


for option = 1:2:length(varargin)-1
    
    switch varargin{option}
        case 'animal'
            f = setfilteranimal(f,varargin{option+1});
        case 'epochs'
            f = setfilterepochs(f,varargin{option+1});          
        case 'excludetime'
            f = setfiltertime(f,varargin{option+1});
        case 'excludetimefilter'
            f = setfiltertime(f,varargin{option+1});
        case 'excludetimelist'
            f = setexcludetime(f,varargin{option+1});
        case 'data'
            f = setfilterdata(f,varargin{option+1});
        case 'cellpairs'
            f = setfiltercellpairs(f,varargin{option+1});
        case 'ntrodes'
            f = setfilterntrodes(f, varargin{option+1});
        case 'trials'
            f = setfiltertrials(f, varargin{option+1});
        case 'iterator'
            f = setfilteriterator(f, varargin{option+1});
        case 'function'
            f = setfilterfunction(f, varargin{option+1}{:});    
        otherwise
            error(['Input ''', varargin{option}, ''' not defined']);
    end
end
