function [fields] = readCameraModulePositionFile(filename)  
%fields = readCameraModulePositionFile(filename)
%filename-- a string containing the name of the .videoPositionTracking file
%fields-- a structure of length n, where n is the number of data types in the
%file. Each entry has the following fields:
%
%fields(n).name -- the name of the data
%fields(n).type -- the data type (i.e., uint32, unt16, or double)
%fields(n).data -- the data, an n by 1 vector



clockRate = 1000*30;
fid = fopen(filename,'r');
headerText = fread(fid,200,'char');
headerText = headerText';
endHeaderLoc = strfind(headerText,'<End settings>');

%default fields in the binary data
fields(1).name = 'time';
fields(1).type = 'uint32';
fields(1).data = [];
bytesPerPacket = 4;


if (~isempty(endHeaderLoc))
    headersize = endHeaderLoc+14; %14
    
    %if the clock rate has been given, set it
    clockRateLoc  = strfind(headerText,'Clock rate:');
    if (~isempty(clockRateLoc))
        clockRate = str2num(char(strtok(headerText(clockRateLoc+12:end))));
    end
    
    %See if the file designates fields, and assign them
    fieldsLoc  = strfind(headerText,'Fields:');
    if (~isempty(fieldsLoc))
        bytesPerPacket = 0;
        fseek(fid, fieldsLoc+7, -1);
        fieldString = fgetl(fid);
        remainder = fieldString;
        currentFieldNum = 1;
        while (~isempty(remainder))
            %each field is encapsulated in < >
            [token, remainder] = strtok(remainder,'<>');
            if (~isempty(token))
                [tmpField rem] = strtok(token);
                fields(currentFieldNum).name = tmpField;
                fields(currentFieldNum).type = strtok(rem);
                if isequal(fields(currentFieldNum).type,'uint32')
                    bytesPerPacket = bytesPerPacket+4;
                elseif isequal(fields(currentFieldNum).type,'uint16')
                     bytesPerPacket = bytesPerPacket+2;
                end
                                
                currentFieldNum = currentFieldNum+1; 
            end                           
        end                
    end    
else
    headersize = 0;
end

%read in each field
byteOffset = 0;
for i = 1:length(fields)
    frewind(fid);
    
    junk = fread(fid,headersize+byteOffset,'char');
    skipBytes = 0;
    if isequal(fields(i).type,'uint32')
        skipBytes = bytesPerPacket-4;
        byteOffset = byteOffset+4; %4
            %for don07, tho01, r1_12_05, r1_12_08, r1_21_03, r1_23_02, r2_13_03, r2_22_01,
            %r2_27_01, r2_28_03, r2_37_02, r2_37_03, r3_02_01, r3_04_03,
            %r3_30_05, r3_46_01, r4_41_04, r4_44_04, r4_47_05, r4_54_05 change this line to +3
    elseif isequal(fields(i).type,'uint16')
        skipBytes = bytesPerPacket-2;
        byteOffset = byteOffset+2; %2
            %for tho01 r1_12_05, r2_13_03, r2_27_01, r3_30_05 change this line to +1
    end
    tmpData = fread(fid,inf,[fields(i).type,'=>',fields(i).type],skipBytes);
    %if the field is time, convert to seconds
    if isequal(fields(i).name,'time')
        tmpData = double(tmpData)/clockRate;
        fields(i).type = 'double';
    end
    fields(i).data = tmpData;
   
end
    

fclose(fid);


