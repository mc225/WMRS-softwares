function ret = replaceSifData(siffile,imageData,kineticsLength)
% Replace all the imageData into an exist sif file
%make sure only the %kinetics length is different. 
%
%Mingzhou Chen @ University of St Andrews, mingzhou.chen@st-andrews.ac.uk;

%read out all data from sif
FID = fopen(siffile, 'r');
ret = 1;
if FID == -1
    warning(sprintf('Cannot open file: %s',siffile));
    ret = 0;
    return;
end
Data = textscan(FID, '%s', 'delimiter', '\n', 'whitespace', '');
CStr = Data{1};
fclose(FID);

searchSt1 = 'Pixel number65541';       %lines before data;
searchSt2 = '<?xml version="1.0" ?>'; %last line

IndexC = strfind(CStr, searchSt1);
Index1 = find(~cellfun('isempty', IndexC), 1);

IndexC = strfind(CStr, searchSt2);
Index2 = find(~cellfun('isempty', IndexC), 1);

%delete data;
if ~isempty(Index1)
    bb = sscanf(cell2mat(CStr(Index1)),'Pixel number65541 %d %d %d %d %d %d %d %d %d');
    bb(5)=kineticsLength;
    bb(7)=kineticsLength*bb(8);
	CStr(Index1) = mat2cell(sprintf('Pixel number65541 %d %d %d %d %d %d %d %d %d',bb),1);
else
    ret = 0;
    return;
end

CopyCStr = CStr(1:Index1+2);
for m = 1:kineticsLength-1
    CopyCStr = [CopyCStr;CStr(Index1+2)];
end

ftemp = fopen('temp.tmp', 'w');
fwrite(ftemp,imageData,'single');
fclose(ftemp);
ftemp = fopen('temp.tmp', 'r');
Data = textscan(FID, '%s', 'delimiter', '\n', 'whitespace', '');
CStrTemp = Data{1};
fclose(ftemp);
delete('temp.tmp');

CopyCStr = [CopyCStr;CStr(Index1+3)];
CopyCStr = [CopyCStr;CStrTemp];
CopyCStr = [CopyCStr;CStr(Index2-3:end)];

CStr = CopyCStr;

% Save the file again:
FID = fopen(siffile, 'w');
if FID == -1
    warning(sprintf('Cannot open file: %s',siffile));
    ret = 0;
    return;
end
fprintf(FID, '%s\n', CStr{:});
fclose(FID);
end