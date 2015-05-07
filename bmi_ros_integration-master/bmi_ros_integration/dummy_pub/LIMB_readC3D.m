function c3d = LIMB_readC3D(FullFileName, varargin)

% LIMB_readC3D:	Getting 3D coordinate/analog data from a C3D file
%
% Input:	FullFileName - file (including path) to be read
%
% Output:   Data structure called 'c3d' with these fields:
%
% c3d.Markers            3D-marker data [Nmarkers x NvideoFrames x Ndim(=3)]
% c3d.VideoFrameRate     Frames/sec
% c3d.AnalogSignals      Analog signals [Nsignals x NanalogSamples ]
% c3d.AnalogFrameRate    Samples/sec
% c3d.Event              Event(Nevents).time ..value  ..name
% c3d.ParameterGroup     ParameterGroup(Ngroups).Parameters(Nparameters).data ..etc.
% c3d.CameraInfo         MarkerRelated CameraInfo [Nmarkers x NvideoFrames]
% c3d.ResidualError      MarkerRelated ErrorInfo  [Nmarkers x NvideoFrames]
%
% LIMB LAB
%   - altered the code to correctly read in the Markers and AnalogSignals 
%   and the speed difference was very noticable.  I also added the FileName to the
%   c3d structure.
%   - Also altered the way HandX,Y,Z data came back.
%   - Changed code to read EndFrame as uint instead of int
%
% AUTHOR(S) AND VERSION-HISTORY
% Ver. 1.0 Creation (Alan Morris, Toronto, October 1998) [originally named "getc3d.m"]
% Ver. 2.0 Revision (Jaap Harlaar, Amsterdam, april 2002)
% LIMB Lab specifics (Jon Swaine, Kingston, December 2005)
%
% BKIN updates (Ian Brown, Kingston, July 2007)
% Force little endian (all KINARM systems save data on x86 processors)
% add .c3d extension if missing
%
% Feb 2008.  Changed precision of fread for 
% c3d.ParameterGroup(GroupNumber).Parameter(ParameterNumber).description
% length from int8 to uint8, to allow descriptions longer than 128
% characters

c3d.Markers=[];
c3d.VideoFrameRate=0;
c3d.AnalogSignals=[];
c3d.AnalogFrameRate=0;
c3d.Event=[];
c3d.ParameterGroup=[];
c3d.CameraInfo=[];
c3d.ResidualError=[];
% Added FileName to structure --JS
c3d.FileName = [];

enable_waitbar = 0;

% ###############################################
% ##                                           ##
% ##    open the file                          ##
% ##                                           ##
% ###############################################

if isempty(findstr('.c3d', FullFileName))
	if isempty(findstr('.', FullFileName))
		FullFileName = [FullFileName '.c3d'];
	else
		disp(['WARNING!!! - ' FullFileName ' is not a c3d file']);
		return;
	end
end


ind=findstr(FullFileName,'\');
if ind>0
    c3d.FileName=FullFileName(ind(length(ind))+1:length(FullFileName));
else
    c3d.FileName=FullFileName;
end

% assume that data was saved on x86 processor (using IEEE little endian format)
fid=fopen(FullFileName,'r','l');

if fid==-1,
    disp(['File: ',FullFileName,' could not be opened.']);
    if isempty(findstr('.c3d', FullFileName))
        disp('You must include the .c3d extension.');
    end
    return;
end

NrecordFirstParameterblock=fread(fid,1,'int8');     % Reading record number of parameter section
key=fread(fid,1,'int8');                           % key = 80;

if key~=80,
    h=errordlg(['File: ',FileName,' does not comply to the C3D format'],'application error');
    uiwait(h)
    fclose(fid)
    return
end


fseek(fid,512*(NrecordFirstParameterblock-1)+3,'bof'); % jump to processortype - field
proctype=fread(fid,1,'int8')-83;                       % proctype: 1(INTEL-PC); 2(DEC-VAX); 3(MIPS-SUN/SGI)

if proctype==2,
    fclose(fid);
    fid=fopen(FullFileName,'r','d'); % DEC VAX D floating point and VAX ordering
end

% ###############################################
% ##                                           ##
% ##    read header                            ##
% ##                                           ##
% ###############################################

%NrecordFirstParameterblock=fread(fid,1,'int8');     % Reading record number of parameter section
%key1=fread(fid,1,'int8');                           % key = 80;

fseek(fid,2,'bof');

Nmarkers=fread(fid,1,'int16');			        %number of markers
NanalogSamplesPerVideoFrame=fread(fid,1,'int16');			%number of analog channels x #analog frames per video frame
StartFrame=fread(fid,1,'int16');		        %# of first video frame
EndFrame=fread(fid,1,'uint16');			        %# of last video frame

% Value not used
MaxInterpolationGap=fread(fid,1,'int16');		%maximum interpolation gap allowed (in frame)

Scale=fread(fid,1,'float32');			        %floating-point scale factor to convert 3D-integers to ref system units

NrecordDataBlock=fread(fid,1,'int16');			%starting record number for 3D point and analog data

NanalogFramesPerVideoFrame=fread(fid,1,'int16');
if NanalogFramesPerVideoFrame > 0,
    NanalogChannels=NanalogSamplesPerVideoFrame/NanalogFramesPerVideoFrame;
else
    NanalogChannels=0;
end

c3d.VideoFrameRate=fread(fid,1,'float32');
c3d.AnalogFrameRate=c3d.VideoFrameRate*NanalogFramesPerVideoFrame;

% ###############################################
% ##                                           ##
% ##    read events                            ##
% ##                                           ##
% ###############################################

fseek(fid,298,'bof');
EventIndicator=fread(fid,1,'int16');
if EventIndicator==12345,
    Nevents=fread(fid,1,'int16');
    fseek(fid,2,'cof'); % skip one position/2 bytes
    if Nevents>0,
        for i=1:Nevents,
            c3d.Event(i).time=fread(fid,1,'float');
        end
        fseek(fid,188*2,'bof');
        for i=1:Nevents,
            c3d.Event(i).value=fread(fid,1,'int8');
        end
        fseek(fid,198*2,'bof');
        for i=1:Nevents,
            c3d.Event(i).name=cellstr(char(fread(fid,4,'char')'));
        end
    end
end


% ###############################################
% ##                                           ##
% ##    read 1st parameter block               ##
% ##                                           ##
% ###############################################

fseek(fid, 512*(NrecordFirstParameterblock-1), 'bof');

dat1=fread(fid,1,'int8');
key2=fread(fid,1,'int8');                   % key = 80;
NparameterRecords=fread(fid,1,'int8');
proctype=fread(fid,1,'int8')-83;            % proctype: 1(INTEL-PC); 2(DEC-VAX); 3(MIPS-SUN/SGI)


Ncharacters=fread(fid,1,'int8');   			% characters in group/parameter name
GroupNumber=fread(fid,1,'int8');				% id number -ve=group / +ve=parameter


while Ncharacters > 0 % The end of the parameter record is indicated by <0 characters for group/parameter name

    if GroupNumber<0 % Group data
        GroupNumber=abs(GroupNumber);
        GroupName=fread(fid,[1,Ncharacters],'char');
        c3d.ParameterGroup(GroupNumber).name=cellstr(char(GroupName));	%group name
        offset=fread(fid,1,'int16');							%offset in bytes
        deschars=fread(fid,1,'int8');							%description characters
        GroupDescription=fread(fid,[1,deschars],'char');
        c3d.ParameterGroup(GroupNumber).description=cellstr(char(GroupDescription)); %group description

        ParameterNumberIndex(GroupNumber)=0;
        fseek(fid,offset-3-deschars,'cof');


    else % parameter data
        clear dimension;
        ParameterNumberIndex(GroupNumber)=ParameterNumberIndex(GroupNumber)+1;
        ParameterNumber=ParameterNumberIndex(GroupNumber);              % index all parameters within a group

        ParameterName=fread(fid,[1,Ncharacters],'char');				% name of parameter

        % read parameter name
        if size(ParameterName)>0
            c3d.ParameterGroup(GroupNumber).Parameter(ParameterNumber).name=cellstr(char(ParameterName));	%save parameter name
        end

        % read offset
        offset=fread(fid,1,'int16');							%offset of parameters in bytes
        filepos=ftell(fid);										%present file position
        nextrec=filepos+offset(1)-2;							%position of beginning of next record


        % read type
        type=fread(fid,1,'int8');     % type of data: -1=char/1=byte/2=integer*2/4=real*4
        c3d.ParameterGroup(GroupNumber).Parameter(ParameterNumber).datatype=type;


        % read number of dimensions
        dimnum=fread(fid,1,'int8');
        if dimnum==0
            datalength=abs(type);								%length of data record
        else
            mult=1;
            for j=1:dimnum
                dimension(j)=fread(fid,1,'int8');
                mult=mult*dimension(j);
                c3d.ParameterGroup(GroupNumber).Parameter(ParameterNumber).dim(j)=dimension(j);  %save parameter dimension data
            end
            datalength=abs(type)*mult;							%length of data record for multi-dimensional array
        end


        if type==-1 %datatype=='char'

            wordlength=dimension(1);	%length of character word
            if dimnum==2 && datalength>0 %& parameter(idnumber,index,2).dim>0
                for j=1:dimension(2)
                    data=fread(fid,[1,wordlength],'char');	%character word data record for 2-D array
                    c3d.ParameterGroup(GroupNumber).Parameter(ParameterNumber).data(j)=cellstr(char(data));
                end

            elseif dimnum==1 && datalength>0
                data=fread(fid,[1,wordlength],'char');		%numerical data record of 1-D array
                c3d.ParameterGroup(GroupNumber).Parameter(ParameterNumber).data=cellstr(char(data));
            end

        elseif type==1    %1-byte for boolean

            Nparameters=datalength/abs(type);
            data=fread(fid,Nparameters,'int8');
            c3d.ParameterGroup(GroupNumber).Parameter(ParameterNumber).data=data;

        elseif type==2 && datalength>0			%integer

            Nparameters=datalength/abs(type);
            data=fread(fid,Nparameters,'int16');
            if dimnum>1
                c3d.ParameterGroup(GroupNumber).Parameter(ParameterNumber).data=reshape(data,dimension);
            else
                c3d.ParameterGroup(GroupNumber).Parameter(ParameterNumber).data=data;
            end

        elseif type==4 && datalength>0

            Nparameters=datalength/abs(type);
            data=fread(fid,Nparameters,'float');
            if dimnum>1
                c3d.ParameterGroup(GroupNumber).Parameter(ParameterNumber).data=reshape(data,dimension);
            else
                c3d.ParameterGroup(GroupNumber).Parameter(ParameterNumber).data=data;
            end
        else
            % error
        end

%%%        deschars=fread(fid,1,'int8');							%description characters
% in order to handle descriptions longer than 128 characters, change 'int8'
% to uint8.
        deschars=fread(fid,1,'uint8');							%description characters
        if deschars>0
           description=fread(fid,[1,deschars],'char');
           c3d.ParameterGroup(GroupNumber).Parameter(ParameterNumber).description=cellstr(char(description));
        end
        %moving ahead to next record
        fseek(fid,nextrec,'bof');
    end

    % check group/parameter characters and idnumber to see if more records present
    Ncharacters=fread(fid,1,'int8');   			% characters in next group/parameter name
    GroupNumber=fread(fid,1,'int8');			% id number -ve=group / +ve=parameter
end


% ###############################################
% ##                                           ##
% ##    read data block                        ##
% ##                                           ##
% ###############################################
%  Get the coordinate and analog data

fseek(fid,(NrecordDataBlock-1)*512,'bof');

if enable_waitbar
    h = waitbar(0,[FileName,' is loading...']);
end

NvideoFrames = EndFrame - StartFrame + 1;
% Get the number of analog signals (usually 22);
num_anasigs = c3d.ParameterGroup(2).Parameter(end).dim(2);
num_matrix_columns = (9 + num_anasigs - 1);

% This part of the original code was far too slow as the binary freads were
% being done in a loop up to 60000 times.  So I altered the code to read it
% all in in one big chunk and after that, the data is reorganized.  The
% speed difference was enormous.  --JS
if Scale < 0
    % Read all signals in and then deal with them.
    % 1 - Right Hand X
    % 2 - Right Hand Y
    % 3 - Right Hand Z
    % 4 - Right Hand CAMERA INFO (NOT NEEDED)
    % 5 - Right Hand X
    % 6 - Right Hand Y
    % 7 - Right Hand Z
    % 8 - Right Hand CAMERA INFO (NOT NEEDED)
    % 9 - 30 - Analog Signals (listed in order in ParameterGroup(2))

    % Start after reading hand info (9) and get all analog signals.
    data_matrix = reshape(fread(fid, num_matrix_columns*NvideoFrames, 'float32'), num_matrix_columns, NvideoFrames)';

    c3d.Hand.RightX = data_matrix(:,1);
    c3d.Hand.RightY = data_matrix(:,2);
    c3d.Hand.RightZ = data_matrix(:,3);
    % 4th column is not needed
    c3d.Hand.LeftX = data_matrix(:,5);
    c3d.Hand.LeftY = data_matrix(:,6);
    c3d.Hand.LeftZ = data_matrix(:,7);
    % 8th column is not needed
    c3d.AnalogSignals = data_matrix(:,9:num_matrix_columns);

else
    for i=1:NvideoFrames
        for j=1:Nmarkers
            c3d.Markers(i,j,1:3)=fread(fid,3,'float32')'.*Scale;
            c3d.ResidualError(i,j)=fread(fid,1,'int8');
            c3d.CameraInfo(i,j)=fread(fid,1,'int8');
        end
        if enable_waitbar
            waitbar(i/NvideoFrames)
        end
        for j=1:NanalogFramesPerVideoFrame,
            c3d.AnalogSignals(j+NanalogFramesPerVideoFrame*(i-1),1:NanalogChannels)=...
                fread(fid,NanalogChannels,'float32')';
        end
    end
end

if enable_waitbar
    close(h) % waitbar
end

fclose(fid);

disp(['Done reading ', FullFileName]);

