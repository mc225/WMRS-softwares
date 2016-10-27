%SIFREADNK Read SIF multi-channel image file.

%by Mingzhou Chen

%Synopsis:
%
%  data=sifread(file)
%     Read the image data from file.
%     Return the image data in the following structure.   
%      
%  .temperature            CCD temperature [�C]
%  .delayExpPeriod         delay after trigger [s]
%  .exposureTime           Exposure time [s]
%  .cycleTime              Time per full image take [s]
%  .accumulateCycles       Number of accumulation cycles
%  .accumulateCycleTime    Time per accumulated image [s]
%  .stackCycleTime         Interval in image series [s]
%  .pixelReadoutTime       Time per pixel readout [s]
%  .detectorType           CCD type
%  .detectorSize           Number of read CCD pixels [x,y]
%  .fileName               Original file name
%  .shutterTime            Time to open/close the shutter [s]
%  .frameAxis              Axis unit of CCD frame
%  .dataType               Type of image data
%  .imageAxis              Axis unit of image
%  .imageArea              Image limits [x1,y1,first image;
%                                        x2,y2,last image]
%  .frameArea              Frame limits [x1,y1;x2,y2]
%  .frameBins              Binned pixels [x,y]
%  .timeStamp              Time stamp in image series
%  .imageData              Image data (x,y,t) where t is the image # for a
%                          kinetic series
%  .kineticLength          number of images in kinetic series

%   Mingzhou @ St. Andrews November 2014, mingzhou.chen@st-andrews.ac.uk


function [data,reference,background] =sifreadnk(file)
f=fopen(file,'r');
if f < 0
   disp('Could not open the file.');
   data = []; reference = []; background = [];
   return;
end
if ~isequal(fgetl(f),'Andor Technology Multi-Channel File')
   fclose(f);
   disp('Not an Andor SIF imagdate file.');
   data = []; reference = []; background = [];
   return;
end

%treat the file contain only reference and background;
o=fscanf(f,'%d',2);
if o(2) == 1  %signal is available
    data=readSection(f);
    if nargout>1
        reference = readSection(f);
    end
    if nargout>2
        background = readSection(f);
    end
elseif o(2) == 0 %signal is not available
    data = [];
    o=fscanf(f,'%d',1);
    if o == 1   %reference is avaliable
        if nargout>1
            reference = readSection(f);
        end
        if nargout>2
            background = readSection(f);
        end
    elseif o == 0 %only background is available
        data = [];
        if nargout>1
            reference = [];
        end
        o=fscanf(f,'%d',1);
        if nargout>2
            background = readSection(f);
        end
    end
end

%skipLines(f,1); 
%

%read file date information;
% FileInfo = dir(file);
% [Y, M, D, H, MN, S] = datevec(FileInfo.datenum);
% data.fileName = FileInfo.name;
% data.datenum = FileInfo.datenum;
% data.fileDate = [Y, M, D, H, MN, S];


fclose(f);


%Read a file section.
%
% f      File handle 
% info   Section data
% next   Flags if another section is available
%
function info=readSection(f)
o=fscanf(f,'%d',1);
if o == 65567 %from new solis version >4.28
    ver = 1;
elseif o == 65566 %from old solis version <=4.28
    ver = 0;
else %testing if not data there.
    info = [];
    return;
end
o=fscanf(f,'%d',5); %% scan over the 5 Bytes
info.temperature=o(5); %o(5)
skipBytes(f,10);%% skip the space (why 10 not 11?)
%skipLines(f,1);
%info.whatisthis=readLine(f)
o=fscanf(f,'%f',5);%% Scan the next 5 bytes
info.delayExpPeriod=o(2);
info.exposureTime=o(3);
info.accumulateCycles=o(5);
info.accumulateCycleTime=o(4);
skipBytes(f,2); %% skip 2 more bytes
o=fscanf(f,'%f',2);
info.stackCycleTime=o(1);
info.pixelReadoutTime=o(2);
o=fscanf(f,'%d',3);
info.gainDAC=o(3);
skipLines(f,1);
info.detectorType=readLine(f);
%skipLines(f,1);
%info.whatisthis=readLine(f)
info.detectorSize=fscanf(f,'%d',[1 2]); %% I think everythings ok to here
info.fileName=readString(f);
sifFromSDK = 0;
if strcmp(info.fileName,'Acquisition')
    sifFromSDK = 1;
end
    
%skipLines(f,4); %% changed this from 26 from Ixon camera now works for Newton. %%%%%%%%%%%%%%%%%%%%%%% ALL YOU NEED TO CHANGE

skipUntil(f,'65538')
skipUntil(f,'65538')

% Added the following to extract the center wavelength and grating
o=fscanf(f,'%f',8);
info.centerWavelength = o(4);
info.grating = round(o(7));

%skipLines(f,10); % added this in 
if ver == 0 
    skipUntil(f,'65539');
else
    skipUntil(f,'65540');
end
% skipUntilChar(f,'.');
% backOneLine(f);

o=fscanf(f,'%f',4);
info.minWavelength = o(1);
info.stepWavelength = o(2);
info.step1Wavelength = o(3);
info.step2Wavelength = o(4);
info.maxWavelength = info.minWavelength + info.detectorSize(1)*info.stepWavelength;
pp=0;
if info.minWavelength == 0 % pixel number in X axis;
    pp=1;
end;
if o(2)>1 %stepWavelength must be smaller than 1, otherwise it is Raman shift cm-1;
    pp=2; %raman shift in x axis;
end
% Create wavelength, energy and frequency axes.
da = 1:(info.detectorSize(1));
info.axisWavelength = info.minWavelength + da.*(info.stepWavelength + da.*info.step1Wavelength + da.^2*info.step2Wavelength);
info.axisEnergy = convertUnits(info.axisWavelength,'nm','eV'); % energy in eV
info.axisGHz = convertUnits(info.axisWavelength,'nm','GHz');

%skipLines(f,6);
if ver%new version
    skipLines(f,3);
    o=fscanf(f,'%f',1);
    info.laserLine = o(1);
    skipLines(f,4);
    tp=fscanf(f,'%f',1);
    switch tp
        case 10
            info.frameAxis = 'Wavelength (nm)';
            skipUntil(f,'Wavelength');
        case 11
            info.frameAxis = 'Raman shift (cm^{-1})';
            skipUntil(f,'Raman shift');
            info.axisWavelength = (1/info.laserLine-1./info.axisWavelength).*10^7;
        case 12
            if sifFromSDK
                info.frameAxis = 'Wavelength (nm)';
            else
                info.frameAxis = 'Pixel number';
            end
            skipUntil(f,'Pixel number');
        otherwise
            info.frameAxis = 'Pixel number';
    end
    backOneLine(f);
    backOneLine(f);
    readString(f); %'Pixel number' 
else
    switch pp
        case 0
            skipUntil(f,'Wavelength');
        case 1
            skipUntil(f,'Pixel number');
        case 2
            skipUntil(f,'Raman shift');
        otherwise
            skipLines(f,6);
    end
    backOneLine(f);
    backOneLine(f);
    info.frameAxis=readString(f); %'Pixel number' 
    if strcmp(info.frameAxis,'Wavelength')
        info.frameAxis = 'Wavelength (nm)';
    elseif strcmp(info.frameAxis,'Raman shift')
        info.frameAxis = 'Raman shift (cm^{-1})';
    elseif strcmp(info.frameAxis,'Pixel number')
        info.frameAxis = 'Pixel number';
    end
end

info.dataType=readString(f);  %'Counts' %% gets this from andor file
info.imageAxis=readString(f);  %'Pixel number' %% gets this from andor file
o=fscanf(f,'65541 %d %d %d %d %d %d %d %d 65538 %d %d %d %d %d %d',14); %% 14 is lines in o?
temp = o;
info.imageArea=[o(1) o(4) o(6);o(3) o(2) o(5)];
info.frameArea=[o(9) o(12);o(11) o(10)];
info.frameBins=[o(14) o(13)];
s=(1 + diff(info.frameArea))./info.frameBins;
z=1 + diff(info.imageArea(5:6));

info.kineticLength = o(5);
if prod(s) ~= o(8) || o(8)*z ~= o(7);
   fclose(f);
   error('Inconsistent image header.');
end
% for n=1:z                       % Had to comment this section for kinetic
%    o=readString(f);
%    if numel(o)
%       fprintf( '%s\n',o);      % comments
%    end
% end

skipLines(f,2+info.kineticLength); % changed from 2 to 2+info.kineticLength. This is the trick to get kinetic mode to work.

%for ii = 1:info.kineticLength
%    info.imageData=reshape(fread(f,prod(s)*z,'single=>single'),[s z]); %Switched z and s around to flip image 90 degrees
info.imageData = reshape(fread(f,prod(s)*z,'single=>single'),[s z]);
    %info.imageData{ii} =fread(f,prod(s)*z);
    %size(info.imageData(:,:,ii));
%end

o=readString(f);           % read the whole file.
% if numel(o)
%    fprintf('%s\n',o);      % If the file has no elements, then return error?
% end




%Read a character string.
%
% f      File handle
% o      String
%
function o=readString(f)
n=fscanf(f,'%d',1);
if isempty(n) || n < 0 || isequal(fgetl(f),-1)
   fclose(f);
   error('Inconsistent string.');
end
o=fread(f,[1 n],'uint8=>char');


%Read a line.
%
% f      File handle
% o      Read line
%
function o=readLine(f)
o=fgetl(f);
if isequal(o,-1)
   fclose(f);
   error('Inconsistent image header.');
end
o=deblank(o);


%Skip bytes.
%
% f      File handle
% N      Number of bytes to skip
%
function skipBytes(f,N)
[ret,n]=fread(f,N,'uint8');
if n < N
   fclose(f);
   error('Inconsistent image header.');
end


%Skip lines.
%
% f      File handle
% N      Number of lines to skip
%
function skipLines(f,N)
for n=1:N
   if isequal(fgetl(f),-1)
      fclose(f);
      error('Inconsistent image header.');
   end
end





% Skip to the line starting with str.

function skipUntil(f,str)

ls = length(str);
stringFound = 0;
while ~stringFound
    % Read line
    s = readLine(f);
    
    if length(s)>=ls && strcmp(s(1:ls), str) % check if string found.
        stringFound = 1;
    else
        stringFound = 0;        
    end
end

% Skip to the first incidence of the character c.
function skipUntilChar(f,c)
stringFound = 0;
while ~stringFound
    % Read line
    cread=fscanf(f,'%c',1);
    if cread==c
        stringFound=1;
    end
end


function backOneLine(f)
newLineFound = 0;
numTimes = 0;
while ~newLineFound
    fseek(f,-2,'cof');
    c=fscanf(f,'%c',1);
    newLineFound = c==10;
    numTimes = numTimes+1; 
end
% 
% if numTimes<=2
% fseek(f,-4,'cof');
% numTimes = 0;
% while ~newLineFound
%     fseek(f,-2,'cof');
%     c=fscanf(f,'%d',1)
%     newLineFound = c==10;
%     numTimes = numTimes+1; 
% end
% end