function out = readTrodesFileConfig_optimized(filename)
%Reads the configuration section of a Trodes (.rec) file

%Update 11/29/2017 for newest TrodestoMatlab release (06-30-2017): int8
%instead of char

fid = fopen(filename,'r');
if (fid == -1)
    error('Error opening file.');
end

%changed from 20000 & char
junk = fread(fid,1000000,'uint8');
headersize = strfind(junk','</Configuration>')+16;
frewind(fid);

headerText = fread(fid,headersize,'char');
fclose(fid);

fid = fopen('tmpheaderfile.xml','w');
fwrite(fid,headerText);

fclose(fid);

tree = xmlread('tmpheaderfile.xml');
try
   headerStruct = parseChildNodes(tree);
catch
   error('Unable to parse XML');
end
delete('tmpheaderfile.xml');

globalOptionsInd = [];
spikeInd = [];
headerInd = [];

%additions for Sept Trodes release
globalConfigInd = [];
hardwareConfigInd = [];

out = [];
out.configSize = headersize;
out.configText = junk(1:headersize);
for i = 1:length(headerStruct.Children)
    if isequal(headerStruct.Children(i).Name, 'GlobalOptions')
        globalOptionsInd = i;
    elseif isequal(headerStruct.Children(i).Name, 'HeaderDisplay') || isequal(headerStruct.Children(i).Name, 'AuxDisplayConfiguration')
        headerInd = i;
    elseif isequal(headerStruct.Children(i).Name, 'SpikeConfiguration')
        spikeInd = i;
    %additions for Sept Trodes release
    elseif isequal(headerStruct.Children(i).Name, 'GlobalConfiguration')
        globalConfigInd = i;
    elseif isequal(headerStruct.Children(i).Name, 'HardwareConfiguration')
        hardwareConfigInd = i;
    end
end

if (~isempty(globalOptionsInd))
    tmp = headerStruct.Children(globalOptionsInd).Attributes;
    for i = 1:length(tmp)
        out = setfield(out,tmp(i).Name,tmp(i).Value);
    end
end

if (~isempty(spikeInd))
    out.nTrodes = [];
    nTrodeStruct = headerStruct.Children(spikeInd).Children;
    currentTrode = 0;
    for i = 1:length(nTrodeStruct)
        if (isequal(nTrodeStruct(i).Name,'SpikeNTrode'))
            currentTrode = currentTrode+1;
            out.nTrodes(currentTrode).channelInfo = [];
            tmp = nTrodeStruct(i).Attributes;
            for j = 1:length(tmp)
                out.nTrodes = setfield(out.nTrodes,{currentTrode},tmp(j).Name,tmp(j).Value);
            end
            currentChannel = 0;
            for k = 1:length(nTrodeStruct(i).Children)
                if (isequal(nTrodeStruct(i).Children(k).Name,'SpikeChannel'))
                    currentChannel = currentChannel+1;
                    tmp = nTrodeStruct(i).Children(k).Attributes;
                    for l = 1:length(tmp)
                        out.nTrodes(currentTrode).channelInfo = setfield(out.nTrodes(currentTrode).channelInfo,{currentChannel},tmp(l).Name,tmp(l).Value);
                    end
                end
                    
            end
        end
    end
end

if (~isempty(headerInd))
    out.headerChannels = [];
    headerInfo = headerStruct.Children(headerInd).Children;
    currentChannel = 0;
    for i = 1:length(headerInfo)
        if (isequal(headerInfo(i).Name,'HeaderChannel'))
            
            currentChannel = currentChannel+1;
            tmp = headerInfo(i).Attributes;
            for l = 1:length(tmp)
                out.headerChannels = setfield(out.headerChannels,{currentChannel},tmp(l).Name,tmp(l).Value);
            end

            
        end
    end
end

%additions for Sept Trodes release
if (~isempty(globalConfigInd))
    tmp = headerStruct.Children(globalConfigInd).Attributes;
    for i = 1:length(tmp)
        out = setfield(out,tmp(i).Name,tmp(i).Value);
    end
end
if (~isempty(hardwareConfigInd))
    tmp = headerStruct.Children(hardwareConfigInd).Attributes;
    for i = 1:length(tmp)
        if(strcmp(tmp(i).Name,'sampingRate'))
            tmp(i).Name='samplingRate'; %f-ing typos!
        end
        out = setfield(out,tmp(i).Name,tmp(i).Value);
    end
end


%--------------------------------------------------------------------

% ----- Local function PARSECHILDNODES -----
function children = parseChildNodes(theNode)
% Recurse over node children.
children = [];
if theNode.hasChildNodes
   childNodes = theNode.getChildNodes;
   numChildNodes = childNodes.getLength;
   allocCell = cell(1, numChildNodes);

   children = struct(             ...
      'Name', allocCell, 'Attributes', allocCell,    ...
      'Data', allocCell, 'Children', allocCell);

    for count = 1:numChildNodes
        theChild = childNodes.item(count-1);
        children(count) = makeStructFromNode(theChild);
    end
end

% ----- Local function MAKESTRUCTFROMNODE -----
function nodeStruct = makeStructFromNode(theNode)
% Create structure of node info.

nodeStruct = struct(                        ...
   'Name', char(theNode.getNodeName),       ...
   'Attributes', parseAttributes(theNode),  ...
   'Data', '',                              ...
   'Children', parseChildNodes(theNode));

if any(strcmp(methods(theNode), 'getData'))
   nodeStruct.Data = char(theNode.getData); 
else
   nodeStruct.Data = '';
end

% ----- Local function PARSEATTRIBUTES -----
function attributes = parseAttributes(theNode)
% Create attributes structure.

attributes = [];
if theNode.hasAttributes
   theAttributes = theNode.getAttributes;
   numAttributes = theAttributes.getLength;
   allocCell = cell(1, numAttributes);
   attributes = struct('Name', allocCell, 'Value', ...
                       allocCell);

   for count = 1:numAttributes
      attrib = theAttributes.item(count-1);
      attributes(count).Name = char(attrib.getName);
      attributes(count).Value = char(attrib.getValue);
   end
end

