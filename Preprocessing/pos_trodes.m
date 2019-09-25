function posfile = pos_trodes(datadir, animaldir, prefix, session, varargin)


%% load task file and trodes data
%load task file
newtrodes = 0;
pix2cm = 0;

%added EJ 1/12/18 to accomodate track runs
for option = 1:2:length(varargin)-1
    if ischar(varargin{option})
        switch(varargin{option})
            case 'newtrodes' %newer versions of trodes allow multiple video streams
                newtrodes = 1;
            otherwise
                error(['Option ',varargin{option},' unknown.']);
        end
    else
        error('Options must be strings, followed by the variable');
    end
end

load(sprintf('%s/%stask.mat',animaldir, prefix));
nepochs = length(task{session});

posfilt = gaussian(30*0.5, 60);

for e = 1:nepochs
    if(~contains(lower(task{session}{e}.descript), '*fail*') && ...
        ~contains(lower(task{session}{e}.descript), '*not run*'))
        
        %load trodes pos file
        if(nepochs>1)
            sessstr = sprintf('%s%02d-%02d',prefix,session,e);
        else
            sessstr = sprintf('%s%02d',prefix,session);
        end
        if newtrodes %newer version of trodes
            filename = sprintf('%s/%s/%s.1.videoPositionTracking',datadir,sessstr,sessstr);
        else
            filename = sprintf('%s/%s.videoPositionTracking',datadir,sessstr);
        end
        posraw = readCameraModulePositionFile(filename);
        
%         %janky fix for timestamps bug
%         frame = (posraw(1).data(end) - posraw(1).data(1))/length(posraw(1).data);
%         indices = [1:length(posraw(1).data)];
%         posraw(1).data = posraw(1).data(1) + frame*(indices'-1);
        
        %Emerald camera starting recording in different dimensions than Cobalt in
        %October 2015; this corrects for that
        %also upgraded to higher resolution camera in December 2017
        fileinfo = dir(filename);
        if pix2cm==0 %if not set from track info
            if (fileinfo.date > datetime(2015,10,1) && fileinfo.date < datetime(2015,11,30)...
                    && task{session}{1}.env == 'E')
                pix2cm = 26/450;
            elseif fileinfo.date > datetime(2017,12,15)
                pix2cm = 40/535;
            else
                pix2cm = 26/235;
            end
        end
        
        
        %% create struct in correct format
        
        %rawpos{session}{e}.data = [];
        starttemp = task{session}{e}.start/1000;
        endtemp = task{session}{e}.end/1000;
        startidx = lookup(starttemp,posraw(1).data);
        endidx = lookup(endtemp,posraw(1).data);
        
        %store variables and convert from pixels to cm   .data = [time, x, y]
        rawpos{session}{e}.data = [posraw(1).data(startidx:endidx), double(posraw(2).data(startidx:endidx))*pix2cm, double(posraw(3).data(startidx:endidx))*pix2cm];
        rawpos{session}{e}.fields = 'time xpos ypos';
        
        %janky fix for timestamps bug: not all frames are the same time apart
        %moved to after start/end acquired from task struct 1/8/18 EJ
        frame = (rawpos{session}{e}.data(end,1) - rawpos{session}{e}.data(1,1))/length(rawpos{session}{e}.data);
        indices = 1:length(rawpos{session}{e}.data(:,1));
        rawpos{session}{e}.data(:,1) = rawpos{session}{e}.data(1,1) + frame*(indices'-1);
        
        if(max(rawpos{session}{e}.data(:,2)) - min(rawpos{session}{e}.data(:,2)) < 20)
            fprintf('%s session %d epoch %d may have a byte error.\n',prefix,session,e)
        end
        
        %% remove points outside the arena
%         figure
%         plot(rawpos{session}{e}.data(:,2),rawpos{session}{e}.data(:,3),'.');
%         disp('click upper left / lower right bounds');
%         coords = ginput(2);
%         
%         for i = 1:length(rawpos{session}{e}.data)
%             if rawpos{session}{e}.data(i,2) < coords(1,1) || rawpos{session}{e}.data(i,2) > coords(2,1)
%                 rawpos{session}{e}.data(i,2) = 0;
%                 rawpos{session}{e}.data(i,3) = 0;
%                 
%             elseif rawpos{session}{e}.data(i,3) > coords(1,2) || rawpos{session}{e}.data(i,3) < coords(2,2)
%                 rawpos{session}{e}.data(i,3) = 0;
%                 rawpos{session}{e}.data(i,2) = 0;
%                 
%             end
%         end
        
        %% smooth and derive velocity
        
        %calculate velocity and smooth
        pos{session}{e} = ag_posinterp(rawpos{session}{e});
        pos{session}{e} = rawpos{session}{e};
        pos{session}{e} = ag_addvelocity(pos{session}{e}, posfilt);
        
        % convert to DF2.0 format (convert data to individual fields)
        pos{session}{e}.time = pos{session}{e}.data(:,1);
        pos{session}{e}.x = pos{session}{e}.data(:,2);
        pos{session}{e}.y = pos{session}{e}.data(:,3);
        pos{session}{e}.vel = pos{session}{e}.data(:,4);
        
        pos{session}{e} = rmfield(pos{session}{e},'data');
        pos{session}{e} = rmfield(pos{session}{e},'fields');
        
        
        %% Plot coordinates and velocity to check
%         figure
%         plot(pos{session}{e}.x,pos{session}{e}.y)
%         title(sprintf('%s %d %d',prefix,session,e))
        
%          figure
%          for e = 1:length(pos{session})
%         
%             plot(pos{session}{e}.time,pos{session}{e}.vel)%, cols(e)
%             hold on
%          end
        
    end
end

if exist('pos')
    save(sprintf('%s/%spos%02d.mat', animaldir, prefix, session), 'pos');
end