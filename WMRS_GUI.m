function varargout = WMRS_GUI(varargin)
% WMRS_GUI MATLAB code for WMRS_GUI.fig

% Last Modified by GUIDE v2.5 05-Jan-2017 11:21:08

% Begin initialization code - DO NOT EDIT

% by Copyright @ Mingzhou Chen, University of St Andrews, Email:
% mingzhou.chen@st-andrews.ac.uk. 26 August, 2016

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @WMRS_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @WMRS_GUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

function update_waitbar(handles,value,str,isRed)

if nargin<3
    str = [];
end
if nargin<4
    color = [0 0.5 0];
else
    color = [0.5 0 0];
end

h=handles.waitbar_axes;set(h,'Visible','On');

axes(h);cla; 
if isempty(str)
    prostr = sprintf('%2.0f%%',value/1*100);
    h = patch([0,value,value,0],[0,0,1,1],'b');
    text(value,0.6,prostr,'Color',color,'FontSize',12,'Interpreter','none');
else
    if value>0
        prostr = sprintf('%s,%2.0f%%',str,value/1*100);
        h = patch([0,value,value,0],[0,0,1,1],'b');
        text(0.3,0.6,prostr,'Color',[0 1 0],'FontSize',12,'Interpreter','none');
    else
        prostr = sprintf('%s',str);
        text(0.01,0.6,prostr,'Color',color,'FontSize',12,'Interpreter','none');
    end
end
axis([0,1,0,1]);axis off;drawnow;
%end of updata status bar


%%%%%%%%%%%SolsTis functions
%solstis initialization
function [sol, ii] = solstisINI()
% initializes solstis communication
msg1='{"message":{"transmission_id":[1], "op":"start_link","parameters":{"ip_address":"192.168.1.120"}}}';
sol=tcpip('192.168.1.222',39933);
try 
    fopen(sol);
catch
    sol = []; ii=2;
    return;
end
fwrite(sol,msg1);
mpause(.5)
ii=2;
mpause(1);

%tuning function
function ii = solstisWAVE( sol, ii, wave )
%Tune solstis to a wavelength 'wave';
ii=ii+1;
msg3=['{"message":{"transmission_id":[' num2str(ii) '], "op":"move_wave_t","parameters":{"wavelength":[' num2str(wave) ']}}}'];
fwrite(sol,msg3);
mpause(0.5);

function mpause(del)
mstart = tic;
while toc(mstart)<del
end
%%%end of Solstis function;    


%utilities
function fig = getBaseFigureHandle()
fig = gcbf();
if (isempty(fig))
    fig = gcf;
end
userData = get(fig,'userData');
if (isfield(userData,'mainFigure'))
    fig = userData.mainFigure;
end


function setUserData(fieldName,value)
if(nargin<2)
    value = fieldName;
    fieldName = inputname(1);
end
fig = getBaseFigureHandle();
userData = get(fig,'UserData');
userData.(fieldName) = value;
set(fig,'UserData',userData);

function value = getUserData(fieldName)
fig = getBaseFigureHandle();
userData = get(fig,'UserData');
value = userData.(fieldName);

function SetAllGUIButtons(handles,Enable)
if Enable
    set(handles.laserStart,'Enable','on');
    set(handles.laserEnd,'Enable','on');
    set(handles.exposureTime,'Enable','on');
    set(handles.scans,'Enable','on');
    set(handles.accums,'Enable','on');
    set(handles.cropHeight,'Enable','on');
    set(handles.centralWavelength,'Enable','on');
    set(handles.isWMRS,'Enable','on');
    set(handles.autoSuffix,'Enable','on');
    set(handles.isRealTimeImaging,'Enable','on');
    set(handles.acquireSpec,'Enable','on');
    set(handles.save,'Enable','on');
    set(handles.open,'Enable','on');
    set(handles.fileName,'Enable','on');
    set(handles.pickRamanPeak,'Enable','on');
    set(handles.browserSpec,'Enable','on');
%     set(handles.CamExposSlider,'Enable','on');
    set(handles.autoExposure,'Enable','on');
    set(handles.laserMarker,'Enable','on');
    set(handles.liveSpec,'Enable','on');
    set(handles.signalBackRef,'Enable','on');    
    set(handles.modulationMode,'Enable','on');  
    set(handles.slitWidth,'Enable','on'); 
    set(handles.readMode,'Enable','on'); 
    set(handles.laserSource,'Enable','on');  
    set(handles.abortAcquiring,'Enable','on'); 
    set(handles.cameraSelect,'Enable','on');
    set(handles.fileSaveOption,'Enable','on');
else    
    set(handles.laserStart,'Enable','off');
    set(handles.laserEnd,'Enable','off');
    set(handles.exposureTime,'Enable','off');
    set(handles.scans,'Enable','off');
    set(handles.accums,'Enable','off');
    set(handles.cropHeight,'Enable','off');
    set(handles.centralWavelength,'Enable','off');
    set(handles.isWMRS,'Enable','off');
    set(handles.autoSuffix,'Enable','off');
    set(handles.isRealTimeImaging,'Enable','off');
    set(handles.acquireSpec,'Enable','off');
    set(handles.save,'Enable','off');
    set(handles.open,'Enable','off');
    set(handles.fileName,'Enable','off');
    set(handles.pickRamanPeak,'Enable','off');
    set(handles.browserSpec,'Enable','off');
%     set(handles.CamExposSlider,'Enable','off');
    set(handles.autoExposure,'Enable','off');
    set(handles.laserMarker,'Enable','off');
    set(handles.liveSpec,'Enable','off');
    set(handles.signalBackRef,'Enable','off');    
    set(handles.modulationMode,'Enable','off'); 
    set(handles.slitWidth,'Enable','off'); 
    set(handles.readMode,'Enable','off'); 
    set(handles.laserSource,'Enable','off'); 
    set(handles.abortAcquiring,'Enable','off');
    set(handles.cameraSelect,'Enable','off');
    set(handles.fileSaveOption,'Enable','off');
end

%%%%%%%%%%%\

%
% --- Executes just before WMRS_GUI is made visible.
function WMRS_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to WMRS_GUI (see VARARGIN)

% Choose default command line output for WMRS_GUI
handles.output = hObject;
set(hObject, 'resize', 'off');
clc;

% Update handles structure
guidata(hObject, handles);
set(hObject, 'name', 'Wavelength Modulation Raman Spectroscopy (WMRS)');

fname = [pwd filesep 'systemInit.mat'];
if exist(fname,'file')
    load(fname);
else
    %init laser
    laser.src = 1;   %by default, Solstis;
    laser.smc = []; % smc100 controller on 3900s
    laser.sol = []; % solstis controller on M2 laser;
    laser.counter = []; 
    laser.start = [786.5 16.30];    %[nm mm]
    laser.end = [787.5 16.45];    %[nm mm]
    laser.continuous = 0; %step scanning;
    laser.marker = [];
    laser.markerCross = [];
    laser.ramanPeak = [];
        
    %init spectrometer
    spectrometer.exposureTime = 1;
    spectrometer.scans = 1;
    spectrometer.accums = 1;
    spectrometer.cropHeight = 256;
    spectrometer.centralWavelength = 924.1050; %nm;
    spectrometer.isWMRS = 0; %by default, show original spectra;
    spectrometer.slitWidth = 150; %by default, set slit width of spectrometer 150um;
    spectrometer.readMode = 0; %by default, Set spectrometer FVB mode;
    
    
    %init fileOpt
    fileOpt.saveOpt = 1; %save spectrum;
    fileOpt.fname = []; %
    fileOpt.specFolder = [];
    fileOpt.imgFolder = [];
    fileOpt.autoSuffix = 0;    
end
%init acquireOpt %will not be saved when quit.
acquireOpt.image = [];
acquireOpt.spectra = [];
acquireOpt.background = [];
acquireOpt.WMRSpectrum = [];
acquireOpt.andor = [];
acquireOpt.camera = [];
acquireOpt.isRealTimeImaging = 0;
acquireOpt.axisWavelength = [];
acquireOpt.signalBackRef = 0;
acquireOpt.acquiringAborted = 0; %flag for aborting acquiring;

%disable buttons
SetAllGUIButtons(handles,0);

%init all GUI components;
set(handles.laserStart,'String',num2str(laser.start)); 
set(handles.laserEnd,'String',num2str(laser.end));
set(handles.modulationMode,'Value',laser.continuous+1);
set(handles.isWMRS,'Value',spectrometer.isWMRS);set(handles.isWMRS,'Enable','off');
set(handles.autoSuffix,'Value',fileOpt.autoSuffix);
set(handles.isRealTimeImaging,'Value',1); acquireOpt.isRealTimeImaging = 1;
set(handles.ramanPeak,'String',num2str(laser.ramanPeak));

set(handles.fileSaveOption,'Value',fileOpt.saveOpt+1)

if ~isempty(fileOpt.fname)
    set(handles.fileName,'String',fileOpt.fname);
end
if ~isempty(fileOpt.specFolder)
    set(handles.specFolder,'String',fileOpt.specFolder);
end
% if ~isempty(fileOpt.imgFolder)
%     set(handles.imgFolder,'String',fileOpt.imgFolder);
% end  
axes(handles.specPlot);
xlabel('Raman shift (nm)');
ylabel('Raman intensity (counts)');


%initialize camera; %current support only imagingSource USB cam;
update_waitbar(handles,0,'Initializing ImagingSource camera.............Please wait......',1);
try 
    vid = videoinput('tisimaq_r2013', 1, 'RGB24 (1280x960)');
    camNum = 1;
catch 
    vid = [];src = []; image = []; hImage = [];
    axes(handles.imagePlot);axis off;
    update_waitbar(handles,0,'ImagingSource Camera is not connected!!',1);
end
if isempty(vid)
    update_waitbar(handles,0,'Initializing Hamamatsu camera.............Please wait......',1);
    try
        vid = videoinput('hamamatsu', 1, 'MONO8_1344x1024');
        camNum = 2;
    catch
        vid = [];src = []; image = []; hImage = [];
        axes(handles.imagePlot);axis off;
        update_waitbar(handles,0,'Hamamatsu Camera is not connected!!',1);
    end
end
set(handles.cameraSelect,'Value',camNum);
if ~isempty(vid)
    src = getselectedsource(vid);
    vid.FramesPerTrigger = 1;
    
    try
        start(vid);
    catch
        stop(vid);
        delete(vid);
        vid = []; src = [];    image = [];    hImage = [];
        axes(handles.imagePlot);axis off;
        update_waitbar(handles,0,'Camera is used by another application!!!',1);
    end
end
if ~isempty(vid)      
    switch camNum
        case 1 %imagingSource Camera;
            set(handles.CamExposSlider,'Min',0.0001,'Max',2,'SliderStep',[0.001 0.05]);
            set(handles.CamExposSlider,'Value',src.Exposure);
            src.ExposureAuto = 'On'; set(handles.CamExposSlider,'Enable','off');
            set(handles.autoExposure,'Visible','on'); set(handles.autoExposure,'Value',1); 
            set(handles.exposureTimeEdit,'Visible','off');  set(handles.expUnits,'Visible','off');  
            image = getdata(vid);
        case 2  %hamatsu camera;
            set(handles.CamExposSlider,'Min',1e-05,'Max',10,'SliderStep',[1e-05 0.001]);
            set(handles.CamExposSlider,'Value',src.ExposureTime);
            if src.ExposureTime<0.1 && src.ExposureTime>1e-04
                expTime = src.ExposureTime*10^3;
                set(handles.expUnits,'String','ms');
            elseif src.ExposureTime<=1e-04
                expTime = src.ExposureTime*10^6;
                set(handles.expUnits,'String','us');
            else
                set(handles.expUnits,'String','s');
            end
            set(handles.exposureTimeEdit,'String',num2str(expTime));
            src.ExposureTimeMode = 'Manual';
            set(handles.CamExposSlider,'Enable','on');
            set(handles.autoExposure,'Visible','off');            
            set(handles.exposureTimeEdit,'Visible','on');set(handles.expUnits,'Visible','on');  
            image = fliplr(getdata(vid));
        otherwise
    end
    axes(handles.imagePlot);
    hImage = imagesc(image);
    axis image;axis off;
%     if ~isempty(laser.marker)
%         x=laser.marker(1);y=laser.marker(2);
%         h=line([x-10 x+10],[y y],'LineStyle','-','Color',[1 0 0]);
%         laser.markerCross(1)=h;
%         h=line([x x],[y-10 y+10],'LineStyle','-','Color',[1 0 0]);
%         laser.markerCross(2)=h;
%     end 
end

dragzoom([handles.specPlot,handles.imagePlot]);

acquireOpt.camera.vid = vid;
acquireOpt.camera.src = src;
acquireOpt.image = image;
acquireOpt.hImage = hImage;

if ~isempty(vid) && acquireOpt.isRealTimeImaging == 1
    setappdata(acquireOpt.hImage,'UpdatePreviewWindowFcn',@mypreview_fcn);
    preview(acquireOpt.camera.vid, acquireOpt.hImage);
    update_waitbar(handles,0,'Camera in preview mode....',1);
end
if ~isempty(laser.marker)
    axes(handles.imagePlot);
    x=laser.marker(1);y=laser.marker(2);
    h=line([x-10 x+10],[y y],'LineStyle','-','Color',[1 0 0]);
    laser.markerCross(1)=h;
    h=line([x x],[y-10 y+10],'LineStyle','-','Color',[1 0 0]);
    laser.markerCross(2)=h;
end

setUserData('laser',laser);
setUserData('acquireOpt',acquireOpt);
setUserData('fileOpt',fileOpt);
setUserData('spectrometer',spectrometer);

%initialize andor;
update_waitbar(handles,0,'Initializing Anodr spectrometer.............Please wait......',1);
try
    ad = Andor();
catch
    ad = [];
    fprintf('\n');
    update_waitbar(handles,0,'Andor is not initialized successfully!',1);
end
if ~isempty(ad)
    ad.ExposureTime = spectrometer.exposureTime;
    ad.NumberAccumulations = spectrometer.accums;
    ad.NumberKinetics = spectrometer.scans;
    if ad.ReadMode ~= spectrometer.readMode
        ad.ReadMode = spectrometer.readMode;  %set to FVB mode;
    end
    if ad.SlitWidth ~= spectrometer.slitWidth 
        ad.SlitWidth = spectrometer.slitWidth; %set slitWidth;
    end
    ad.AcquisitionMode = 1; %single scan;
    ad.CropHeight = spectrometer.cropHeight;
    if abs(ad.CentralWavelength-spectrometer.centralWavelength)>0.0005
        ad.CentralWavelength = spectrometer.centralWavelength;
    end
end
acquireOpt.andor = ad;

%set GUIs;
set(handles.exposureTime,'String',num2str(spectrometer.exposureTime));
set(handles.scans,'String',num2str(spectrometer.scans));
set(handles.accums,'String',num2str(spectrometer.accums));
set(handles.cropHeight,'String',num2str(spectrometer.cropHeight));
set(handles.centralWavelength,'String',num2str(spectrometer.centralWavelength));
set(handles.slitWidth,'String',num2str(spectrometer.slitWidth));
if spectrometer.readMode == 0
    set(handles.slitWidth,'Value',1);
elseif spectrometer.readMode == 4
    set(handles.slitWidth,'Value',2);
else
end
%initialize laser;
if laser.src == 1 % SolsTis;
    update_waitbar(handles,0,'Initializing Solstis.............Please wait......',1);
    [sol,ii]=solstisINI();
    laser.sol = sol;
    if ~isempty(sol)        
        laser.counter = ii;
        laser.counter = solstisWAVE(sol,ii,(laser.start+laser.end)/2); %move to the middle position;
    else
        update_waitbar(handles,0,'No successful connection to Solstis!!!',1);
    end
    set(handles.laserSource,'Value',2); %set Solstis;
    set(handles.laserStart,'String',num2str(laser.start(1)));
    set(handles.laserEnd,'String',num2str(laser.end(1)));
else % 3900s
    smc = SMC100();    
    if ~isempty(smc.SMCobj)
        laser.smc = smc;
        set(handles.laserSource,'Value',1); %set 3900s;
    else
        laser.smc = [];
        update_waitbar(handles,0,'SMC100 is not initialized successfully!',1);
    end
    if length(laser.start)>1
        set(handles.laserStart,'String',num2str(laser.start(2)));
    else
        set(handles.laserStart,'String',num2str(16.30));%by default
    end
    if length(laser.end)>1
        set(handles.laserEnd,'String',num2str(laser.end(2)));
    else
        set(handles.laserEnd,'String',num2str(16.45));%by default
    end
end 

%set all user data;
setUserData('laser',laser);
setUserData('acquireOpt',acquireOpt);
setUserData('fileOpt',fileOpt);
setUserData('spectrometer',spectrometer);

%set window to centre;
set(handles.wmrs_figure,'Units', 'pixels' );
screenSize = get(groot, 'ScreenSize');
position = get(handles.wmrs_figure,'Position');
position(1) = (screenSize(3)-position(3))/2;
position(2) = (screenSize(4)-position(4))/2;
set(handles.wmrs_figure,'Position', position);
movegui('center'); %move window to the center of screen;
update_waitbar(handles,0,'System is ready for use...........................');
%Enable buttons
SetAllGUIButtons(handles,1);
set(handles.abortAcquiring,'Enable','off');
set(hObject,'CloseRequestFcn',@closeApp);
% UIWAIT makes WMRS_GUI wait for user response (see UIRESUME)
% uiwait(handles.wmrs_figure);


% --- Executes during object creation, after setting all properties.
function wmrs_figure_CreateFcn(hObject, eventdata, handles)
% hObject    handle to wmrs_figure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
movegui('center'); %move window to the center of screen;clc



function closeApp(obj,event)
%SaveAll training data
laser = getUserData('laser');
fileOpt = getUserData('fileOpt');
spectrometer = getUserData('spectrometer');
acquireOpt = getUserData('acquireOpt'); 
acquireOpt.hImage = [];
if ~isempty(acquireOpt.andor)
    acquireOpt.andor.releaseAndor();
end

if ~isempty(acquireOpt.camera)
    if ishandle(acquireOpt.camera.vid)
        if (strcmpi(acquireOpt.camera.vid.Running,'on'))
            stop(acquireOpt.camera.vid);
        end
        delete(acquireOpt.camera.vid);
        acquireOpt.camera = [];
    end
end

if ~isempty(laser.smc) %relase 3900s;
    laser.smc.releaseSMC();
end

if ~isempty(laser.sol) %release solstis;
    fclose(laser.sol);
    echotcpip('off');
end

save('systemInit.mat','laser','','fileOpt','spectrometer');
disp('GUI is terminated...');
closereq();


% --- Outputs from this function are returned to the command line.
function varargout = WMRS_GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function exposureTime_Callback(hObject, eventdata, handles)
% hObject    handle to exposureTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of exposureTime as text
%        str2double(get(hObject,'String')) returns contents of exposureTime as a double
acquireOpt = getUserData('acquireOpt');
% laser = getUserData('laser');
spectrometer = getUserData('spectrometer');
%fileOpt = getUserData('fileOpt');
expTime = str2num(get(hObject,'String'));
if ~isempty(expTime)
    spectrometer.exposureTime = expTime(1);
    set(hObject,'String',num2str(spectrometer.exposureTime));
    acquireOpt.andor.ExposureTime = spectrometer.exposureTime;
else
    set(hObject,'String',num2str(spectrometer.exposureTime))
end
setUserData('acquireOpt',acquireOpt);
setUserData('spectrometer',spectrometer);

% --- Executes during object creation, after setting all properties.
function exposureTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to exposureTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function scans_Callback(hObject, eventdata, handles)
% hObject    handle to scans (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of scans as text
%        str2double(get(hObject,'String')) returns contents of scans as a double
acquireOpt = getUserData('acquireOpt');
% laser = getUserData('laser');
spectrometer = getUserData('spectrometer');
%fileOpt = getUserData('fileOpt');
scans = str2num(get(hObject,'String'));
if ~isempty(scans)
    if scans<3
        scans = 1;
        update_waitbar(handles,0,'Invalid Scans number! Scans must be set to 1 or larger than 3, Reset to 1',1);
    end
    spectrometer.scans = round(scans(1));
    set(hObject,'String',num2str(spectrometer.scans));
    acquireOpt.andor.NumberKinetics = spectrometer.scans;
else
    set(hObject,'String',num2str(spectrometer.scans))
    update_waitbar(handles,0,' ');
end
    
setUserData('acquireOpt',acquireOpt);
setUserData('spectrometer',spectrometer);


% --- Executes during object creation, after setting all properties.
function scans_CreateFcn(hObject, eventdata, handles)
% hObject    handle to scans (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function accums_Callback(hObject, eventdata, handles)
% hObject    handle to accums (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of accums as text
%        str2double(get(hObject,'String')) returns contents of accums as a double
acquireOpt = getUserData('acquireOpt');
% laser = getUserData('laser');
spectrometer = getUserData('spectrometer');
%fileOpt = getUserData('fileOpt');
accums = str2num(get(hObject,'String'));
if ~isempty(accums)
    if accums<1
        accums = 1;
    end
    spectrometer.accums = round(accums(1));
    set(hObject,'String',num2str(spectrometer.accums));
    acquireOpt.andor.NumberAccumulations = spectrometer.accums;
else
    set(hObject,'String',num2str(spectrometer.accums))
end
setUserData('acquireOpt',acquireOpt);
setUserData('spectrometer',spectrometer);


% --- Executes during object creation, after setting all properties.
function accums_CreateFcn(hObject, eventdata, handles)
% hObject    handle to accums (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function modStart_Callback(hObject, eventdata, handles)
% hObject    handle to modStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of modStart as text
%        str2double(get(hObject,'String')) returns contents of modStart as a double


% --- Executes during object creation, after setting all properties.
function modStart_CreateFcn(hObject, eventdata, handles)
% hObject    handle to modStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function endMod_Callback(hObject, eventdata, handles)
% hObject    handle to endMod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of endMod as text
%        str2double(get(hObject,'String')) returns contents of endMod as a double


% --- Executes during object creation, after setting all properties.
function endMod_CreateFcn(hObject, eventdata, handles)
% hObject    handle to endMod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function cropHeight_Callback(hObject, eventdata, handles)
% hObject    handle to cropHeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cropHeight as text
%        str2double(get(hObject,'String')) returns contents of cropHeight as a double
acquireOpt = getUserData('acquireOpt');
% laser = getUserData('laser');
spectrometer = getUserData('spectrometer');
%fileOpt = getUserData('fileOpt');
cropHeight = str2num(get(hObject,'String'));
if ~isempty(cropHeight)
    if cropHeight(1)<1
        cropHeight = 1;
    end
    if cropHeight(1)>256
        cropHeight = 256;
    end
    spectrometer.cropHeight = round(cropHeight(1));
    set(hObject,'String',num2str(spectrometer.cropHeight));
    acquireOpt.andor.CropHeight = spectrometer.cropHeight;
else
    set(hObject,'String',num2str(spectrometer.cropHeight))
end
setUserData('acquireOpt',acquireOpt);
setUserData('spectrometer',spectrometer);


% --- Executes during object creation, after setting all properties.
function cropHeight_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cropHeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function centralWavelength_Callback(hObject, eventdata, handles)
% hObject    handle to centralWavelength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of centralWavelength as text
%        str2double(get(hObject,'String')) returns contents of centralWavelength as a double
acquireOpt = getUserData('acquireOpt');
% laser = getUserData('laser');
spectrometer = getUserData('spectrometer');
%fileOpt = getUserData('fileOpt');
centralWavelength = str2num(get(hObject,'String'));
if ~isempty(centralWavelength)
    spectrometer.centralWavelength = centralWavelength(1);    
    acquireOpt.andor.CentralWavelength = spectrometer.centralWavelength;
    set(hObject,'String',num2str(acquireOpt.andor.CentralWavelength));
    spectrometer.centralWavelength = acquireOpt.andor.CentralWavelength;
    update_waitbar(handles,0,sprintf('Central wavelength has been set to %fnm',acquireOpt.andor.CentralWavelength));
else
    set(hObject,'String',num2str(spectrometer.centralWavelength))
end
setUserData('acquireOpt',acquireOpt);
setUserData('spectrometer',spectrometer);

% --- Executes during object creation, after setting all properties.
function centralWavelength_CreateFcn(hObject, eventdata, handles)
% hObject    handle to centralWavelength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in save.
function save_Callback(hObject, eventdata, handles)
% hObject    handle to save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%     fileOpt.saveOpt = 1; %save spectrum;
%     fileOpt.fname = []; %
%     fileOpt.specFolder = [];
%     fileOpt.imgFolder = [];
%     fileOpt.autoSuffix = 0;
laser = getUserData('laser');
% spectrometer = getUserData('spectrometer');
acquireOpt = getUserData('acquireOpt');
fileOpt = getUserData('fileOpt');
if isempty(acquireOpt.andor)
    update_waitbar(handles,0,'Andor is not initialized!',1);
    return;
end
if fileOpt.saveOpt==1 || fileOpt.saveOpt == 2 %save spectra into sif file or both;    
    if fileOpt.autoSuffix
        suffix = str2num(fileOpt.fname(end-2:end));
        if isempty(suffix)
            update_waitbar(handles,0,'Please name the file with 3 digits at the end as *_001',1);
            return;
        else
            newfname = [fileOpt.fname(1:end-3) num2str(suffix+1,'%03d')];
        end 
    end
    fname = [fileOpt.specFolder filesep fileOpt.fname '.sif'];
    acquireOpt.andor.saveSIF(fname);
    if laser.continuous == 0 %step tuning, no kinetis used.
        ret = replaceSifData(fname,acquireOpt.spectra,size(acquireOpt.spectra,2)); %replace the data in the sif file as single scan mode used for WMRS;
        if ret == 0;
            update_waitbar(handles,0,'Please name the file with 3 digits at the end as *_001',1);
            return;
        end
    end        
    update_waitbar(handles,0,sprintf('Current spectra have been save into sif file: %s.........',fname));
    if fileOpt.autoSuffix
        fileOpt.fname = newfname;
        set(handles.fileName,'String',newfname);
        setUserData('fileOpt',fileOpt);
    end
end

if fileOpt.saveOpt==0 || fileOpt.saveOpt == 2  %save image or both;
   %stop and take an image;
   if acquireOpt.isRealTimeImaging
       set(handles.isRealTimeImaging,'Value',0);
       if ~isempty(acquireOpt.camera.vid)
           start(acquireOpt.camera.vid);
           acquireOpt.image = getdata(acquireOpt.camera.vid);
           stoppreview(acquireOpt.camera.vid);
           if (strcmpi(acquireOpt.camera.vid.Running,'on'))
               stop(acquireOpt.camera.vid);
           end
           update_waitbar(handles,0,' ');
       end
   end
    setUserData('acquireOpt',acquireOpt);
    if ~isempty(acquireOpt.image)
        if fileOpt.autoSuffix
            suffix = str2num(fileOpt.fname(end-2:end));
            if isempty(suffix)
                update_waitbar(handles,0,'Please name the file with 3 digits at the end as *_001',1);
                return;
            else
                fname = [fileOpt.imgFolder filesep fileOpt.fname(1:end-3) num2str(suffix-1,'%03d') '.tif'];
            end
        else
            fname = [fileOpt.imgFolder filesep fileOpt.fname '.tif'];
        end
        if exist(fileOpt.imgFolder,'dir') == 0
            mkdir(fileOpt.imgFolder);
        end
        imwrite(acquireOpt.image,fname,'tif');
        update_waitbar(handles,0,sprintf('Current image have been save into tif file: %s.........',fname));
    else
        update_waitbar(handles,0,'No image has been acquired or Camera is not ready!',1);
    end
end


function specFolder_Callback(hObject, eventdata, handles)
% hObject    handle to specFolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of specFolder as text
%        str2double(get(hObject,'String')) returns contents of specFolder as a double


% --- Executes during object creation, after setting all properties.
function specFolder_CreateFcn(hObject, eventdata, handles)
% hObject    handle to specFolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in browserSpec.
function browserSpec_Callback(hObject, eventdata, handles)
% hObject    handle to browserSpec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% acquireOpt = getUserData('acquireOpt');
% laser = getUserData('laser');
% spectrometer = getUserData('spectrometer');
fileOpt = getUserData('fileOpt');
if ~isempty(fileOpt.specFolder)
    start_path = fileOpt.specFolder;
else
    start_path = pwd;
end
folderName = uigetdir(start_path,'Choose a spectra file path');
if folderName ~= 0
    fileOpt.specFolder = folderName;
    set(handles.specFolder,'String',folderName); 
    fileOpt.imgFolder = [folderName filesep 'Images'];     
    setUserData('fileOpt',fileOpt);
end
    



% function imgFolder_Callback(hObject, eventdata, handles)
% % hObject    handle to imgFolder (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% % Hints: get(hObject,'String') returns contents of imgFolder as text
% %        str2double(get(hObject,'String')) returns contents of imgFolder as a double
% 
% 
% % --- Executes during object creation, after setting all properties.
% function imgFolder_CreateFcn(hObject, eventdata, handles)
% % hObject    handle to imgFolder (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    empty - handles not created until after all CreateFcns called
% 
% % Hint: edit controls usually have a white background on Windows.
% %       See ISPC and COMPUTER.
% if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
%     set(hObject,'BackgroundColor','white');
% end
% 
% 
% % --- Executes on button press in browserImg.
% function browserImg_Callback(hObject, eventdata, handles)
% % hObject    handle to browserImg (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% % acquireOpt = getUserData('acquireOpt');
% % laser = getUserData('laser');
% % spectrometer = getUserData('spectrometer');
% fileOpt = getUserData('fileOpt');
% if ~isempty(fileOpt.imgFolder)
%     start_path = fileOpt.imgFolder;
% else
%     start_path = pwd;
% end
% folderName = uigetdir(start_path,'Choose a spectra file path');
% if folderName ~= 0
%     fileOpt.imgFolder = folderName;
%     set(handles.imgFolder,'String',folderName); 
%     setUserData('fileOpt',fileOpt);
% end


function fileName_Callback(hObject, eventdata, handles)
% hObject    handle to fileName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fileName as text
%        str2double(get(hObject,'String')) returns contents of fileName as a double
fileOpt = getUserData('fileOpt');
fileOpt.fname = get(hObject,'String');
setUserData('fileOpt',fileOpt);

% --- Executes during object creation, after setting all properties.
function fileName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fileName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function status_Callback(hObject, eventdata, handles)
% hObject    handle to status (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of status as text
%        str2double(get(hObject,'String')) returns contents of status as a double


% --- Executes during object creation, after setting all properties.
function status_CreateFcn(hObject, eventdata, handles)
% hObject    handle to status (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function laserStart_Callback(hObject, eventdata, handles)
% hObject    handle to laserStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of laserStart as text
%        str2double(get(hObject,'String')) returns contents of laserStart as a double
%acquireOpt = getUserData('acquireOpt');
laser = getUserData('laser');
%spectrometer = getUserData('spectrometer');
%fileOpt = getUserData('fileOpt');
laserStart = str2double(get(hObject,'String'));
if ~isnan(laserStart)
    laserStart = laserStart(1);
    if laser.src == 1 %solstis
        %verify range
        startLowLimit = 770; startUpLimit = 800;
        if laserStart >= startLowLimit && laserStart <= startUpLimit
            laser.start(1) = laserStart;
            setUserData('laser',laser);
            update_waitbar(handles,0,sprintf('Laser tuning start has been set at %3.1fnm', laser.start(1)));
        else
            update_waitbar(handles,0,sprintf('Laser start setting range is %d - %d nm', startLowLimit,startUpLimit),1);
            set(hObject,'String',num2str(laser.start(1)));
        end
        setUserData('laser',laser);
%         if ~isempty(laser.sol)
%             laser.counter = solstisWAVE(laser.sol,laser.counter,(laser.start(1)+laser.end(1))/2); %set wavelength back to middle;
%         end
    else %3900s
        %verify range
        startLowLimit = 15; startUpLimit = 18; %need to check for each system;
        if laserStart >= startLowLimit && laserStart <= startUpLimit
            laser.start(2) = laserStart;
            setUserData('laser',laser);
            update_waitbar(handles,0,sprintf('SMC tuning start has been set at %2.4fmm', laser.start(2)));
        else
            update_waitbar(handles,0,sprintf('SMC tuning start setting range is %d - %d nm', startLowLimit,startUpLimit),1);
            set(hObject,'String',num2str(laser.start(2)));
        end
        setUserData('laser',laser);
%         if ~isempty(laser.smc)%set to the middle;
%             laser.smc.moveTo((laser.start(2)+laser.end(2))/2); %set wavelength back to middle;
%         end
    end
else
    update_waitbar(handles,0,'Please input correct wavelength in nm or position in mm!!!!!',1);
    if laser.src == 1 %solstis
        set(hObject,'String',num2str(laser.start(1)));
    else %3900s;
        set(hObject,'String',num2str(laser.start(2)));
    end
end

% --- Executes during object creation, after setting all properties.
function laserStart_CreateFcn(hObject, eventdata, handles)
% hObject    handle to laserStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function laserEnd_Callback(hObject, eventdata, handles)
% hObject    handle to laserEnd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of laserEnd as text
%        str2double(get(hObject,'String')) returns contents of laserEnd as a double
%acquireOpt = getUserData('acquireOpt');
laser = getUserData('laser');
%spectrometer = getUserData('spectrometer');
%fileOpt = getUserData('fileOpt');
laserEnd = str2double(get(hObject,'String'));
if ~isnan(laserEnd)
    laserEnd = laserEnd(1);
    if laser.src == 1 %solstis
        %verify range
        startLowLimit = 770; startUpLimit = 800;
        if laserEnd >= startLowLimit && laserEnd <= startUpLimit
            laser.end(1) = laserEnd;
            setUserData('laser',laser);
            update_waitbar(handles,0,sprintf('Laser tuning end has been set at %3.1fnm', laser.end(1)));
        else
            update_waitbar(handles,0,sprintf('Laser end setting range is %d - %d nm', startLowLimit,startUpLimit),1);
            set(hObject,'String',num2str(laser.end(1)));
        end
        setUserData('laser',laser);
%         if ~isempty(laser.sol)
%             laser.counter = solstisWAVE(laser.sol,laser.counter,(laser.start(1)+laser.end(1))/2); %set wavelength back to middle;            
%         end
    else %3900s
        startLowLimit = 15; startUpLimit = 18; %need to check for each system;
        if laserEnd >= startLowLimit && laserEnd <= startUpLimit
            laser.end(2) = laserEnd;
            setUserData('laser',laser);
            update_waitbar(handles,0,sprintf('SMC tuning end has been set to %2.4fmm', laser.end(2)));
        else
            update_waitbar(handles,0,sprintf('SMC tuning end setting range is %d - %d mm', startLowLimit,startUpLimit),1);
            set(hObject,'String',num2str(laser.end(2)));
        end
        setUserData('laser',laser);
%         if ~isempty(laser.smc) %set to the middle;
%             laser.smc.moveTo((laser.start(2)+laser.end(2))/2); %set wavelength back to middle;
%         end
    end
else
    update_waitbar(handles,0,'Please input correct wavelength in nm or position in mm!!!!!',1);
    if laser.src == 1 %solstis
        set(hObject,'String',num2str(laser.end(1)));
    else
        set(hObject,'String',num2str(laser.end(2)));
    end
end

% --- Executes during object creation, after setting all properties.
function laserEnd_CreateFcn(hObject, eventdata, handles)
% hObject    handle to laserEnd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in laserMarker.
function laserMarker_Callback(hObject, eventdata, handles)
% hObject    handle to laserMarker (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

acquireOpt = getUserData('acquireOpt');
% acquireOpt.isRealTimeImaging = get(handles.isRealTimeImaging,'Value');

if ~isempty(acquireOpt.image)
    laser = getUserData('laser');
%     acquireOpt = getUserData('acquireOpt');
    [x, y] = ginputax(handles.imagePlot,1);
    if gca == handles.imagePlot
        if ~isempty(laser.markerCross)
            if ishandle(laser.markerCross(1))
                delete(laser.markerCross(1));
            end
            if ishandle(laser.markerCross(2))
                delete(laser.markerCross(2));
            end
        end
        laser.marker(1)=x;
        laser.marker(2)=y;
        laser.markerCross(1)=line([x-10 x+10],[y y],'LineStyle','-','Color',[1 0 0]);
        laser.markerCross(2)=line([x x],[y-10 y+10],'LineStyle','-','Color',[1 0 0]);
        setUserData('laser',laser);
        update_waitbar(handles,0,'Laser marker has been changed!');
    else
        update_waitbar(handles,0,'Laser marker has been deleted! Please select a point in the image!',1);
        if ~isempty(laser.markerCross)
            if ishandle(laser.markerCross(1))
                delete(laser.markerCross(1));
            end
            if ishandle(laser.markerCross(2))
                delete(laser.markerCross(2));
            end
        end
        laser.marker=[];
        laser.markerCross=[];
        setUserData('laser',laser);
    end    
end




% --- Executes on button press in isWMRS.
function isWMRS_Callback(hObject, eventdata, handles)
% hObject    handle to isWMRS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of isWMRS
acquireOpt = getUserData('acquireOpt');
spectrometer = getUserData('spectrometer');
laser = getUserData('laser');
spectrometer.isWMRS = get(hObject,'Value');
if ~isempty(acquireOpt.spectra)
    acquireOpt.WMRSpectrum = calculateWMRspec(acquireOpt.spectra,laser.ramanPeak);
    if spectrometer.isWMRS
        updateWMRSpec(handles,acquireOpt.axisWavelength,acquireOpt.WMRSpectrum);
    else
        updateWMRSpec(handles,acquireOpt.axisWavelength,acquireOpt.spectra);
    end    
end
setUserData('spectrometer',spectrometer);
update_waitbar(handles,0,' ');


function mypreview_fcn(obj,event,himage)
% Display image data.
src = getselectedsource(obj);
if strcmp(src.SourceName,'input1'); 
    rotImg = fliplr(event.Data); %flip image;
    himage.CData = rotImg;
else
    himage.CData = event.Data;
end
    
% --- Executes on button press in isRealTimeImaging.
function isRealTimeImaging_Callback(hObject, eventdata, handles)
% hObject    handle to isRealTimeImaging (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
acquireOpt = getUserData('acquireOpt');
acquireOpt.isRealTimeImaging = get(hObject,'Value');
if acquireOpt.isRealTimeImaging
    if ~isempty(acquireOpt.camera.vid)        
        setappdata(acquireOpt.hImage,'UpdatePreviewWindowFcn',@mypreview_fcn);
        preview(acquireOpt.camera.vid, acquireOpt.hImage);
        update_waitbar(handles,0,'Camera in preview mode....',1);        
    end
else    
    if ~isempty(acquireOpt.camera.vid)  
        start(acquireOpt.camera.vid);
        acquireOpt.image = getdata(acquireOpt.camera.vid);     
        stoppreview(acquireOpt.camera.vid);
        if (strcmpi(acquireOpt.camera.vid.Running,'on'))
            stop(acquireOpt.camera.vid);
        end
        update_waitbar(handles,0,' ');
    end
end
setUserData('acquireOpt',acquireOpt);


% --- Executes on button press in autoSuffix.
function autoSuffix_Callback(hObject, eventdata, handles)
% hObject    handle to autoSuffix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of autoSuffix
fileOpt = getUserData('fileOpt');
fileOpt.autoSuffix = get(hObject,'Value');
setUserData('fileOpt',fileOpt);

% --- Executes on button press in open.
function open_Callback(hObject, eventdata, handles)
% hObject    handle to open (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
acquireOpt = getUserData('acquireOpt');
fileOpt = getUserData('fileOpt');
spectrometer = getUserData('spectrometer');
laser = getUserData('laser');

if fileOpt.saveOpt == 1 || fileOpt.saveOpt == 2  %open spectra into plot or both;    
    [FileName,PathName] = uigetfile([fileOpt.specFolder filesep '*.sif'],'Select a spectrum file','MultiSelect','on');    
    if iscell(FileName)
        for m=1:length(FileName)
            fname = [PathName cell2mat(FileName(m))];
            data = sifreadnk(fname);
            if isempty(data)
                update_waitbar(handles,0,sprintf('Can not find or open %s...',fname),1);
                return;
            end
            spec = squeeze(data.imageData);
            figure('Name',fname,'NumberTitle','off');
            if spectrometer.isWMRS && size(spec,2)>2
                plot(data.axisWavelength,calculateWMRspec(spec,laser.ramanPeak));
                title(cell2mat(FileName(m)),'interpreter','none');axis tight;grid on;
                xlabel('Raman shift (nm)');
                ylabel('Raman intensity (counts)');
            else
                plot(data.axisWavelength,spec);axis tight;
                title(cell2mat(FileName(m)),'interpreter','none');axis tight;grid on;
                xlabel('Raman shift (nm)');
                ylabel('Raman intensity (counts)');
            end
        end
    else       
        if FileName == 0
            return;
        end
        fname = [PathName FileName];
        data = sifreadnk(fname);
        if isempty(data)
            update_waitbar(handles,0,sprintf('Can not find or open %s...',fname),1);
            return;
        end
        acquireOpt.spectra = squeeze(data.imageData);
        acquireOpt.axisWavelength = data.axisWavelength;
        if size(acquireOpt.spectra,2)==1
            spectrometer.isWMRS = 0;
            set(handles.isWMRS,'Enable','off');
            set(handles.isWMRS,'Value',spectrometer.isWMRS);
            acquireOpt.WMRSpectrum = [];update_waitbar(handles,0,'Plotting spectrum.....');
            updateWMRSpec(handles,acquireOpt.axisWavelength,acquireOpt.spectra);
            update_waitbar(handles,0,' ');
        else
            if isempty(acquireOpt.spectra)
                acquireOpt.WMRSpectrum = [];
            else
                acquireOpt.WMRSpectrum = calculateWMRspec(acquireOpt.spectra,laser.ramanPeak);
                update_waitbar(handles,0,' ');
            end
            set(handles.isWMRS,'Enable','on');
            if spectrometer.isWMRS
                updateWMRSpec(handles,acquireOpt.axisWavelength,acquireOpt.WMRSpectrum);
            else
                updateWMRSpec(handles,acquireOpt.axisWavelength,acquireOpt.spectra);
            end
        end
        setUserData('spectrometer',spectrometer);
        setUserData('acquireOpt',acquireOpt);
        update_waitbar(handles,0,sprintf('Load spectra from sif file: %s.........',fname));
    end
end
if fileOpt.saveOpt == 0 || fileOpt.saveOpt == 2 %open image or both;
    [FileName,PathName] = uigetfile([fileOpt.specFolder filesep '*.tif'],'Select the tif image file');
    if FileName == 0 
        return;
    end
    %stop real time imaging;
    if acquireOpt.isRealTimeImaging
        set(handles.isRealTimeImaging,'Value',0);
        if ~isempty(acquireOpt.camera.vid)
            stoppreview(acquireOpt.camera.vid);
            if (strcmpi(acquireOpt.camera.vid.Running,'on'))
                stop(acquireOpt.camera.vid);
            end
            update_waitbar(handles,0,' ');
        end
    end  
    fname = [PathName FileName];
    if exist(fname,'file')        
        acquireOpt.image=imread(fname,'tif');
        if ~isempty(acquireOpt.image)
            axes(handles.imagePlot);
            acquireOpt.hImage = imagesc(acquireOpt.image); axis image;axis off;
            set(acquireOpt.hImage,'ButtonDownFcn',@imagePlot_ButtonDownFcn);
            %refresh the laser cross marker
            if ~isempty(laser.markerCross)
                if ishandle(laser.markerCross(1))
                    delete(laser.markerCross(1));
                end
                if ishandle(laser.markerCross(2))
                    delete(laser.markerCross(2));
                end
            end
            if ~isempty(laser.marker)
                x=laser.marker(1);y=laser.marker(2);
                h=line([x-10 x+10],[y y],'LineStyle','-','Color',[1 0 0]);
                laser.markerCross(1)=h;
                h=line([x x],[y-10 y+10],'LineStyle','-','Color',[1 0 0]);
                laser.markerCross(2)=h;
            end
            %refresh the laser cross marker, end
            setUserData('laser',laser);
            setUserData('acquireOpt',acquireOpt);
            update_waitbar(handles,0,sprintf('Image have been opened from: %s.........',fname));
        end
    else
        update_waitbar(handles,0,sprintf('can not have been opened image from: %s.........',fname),1);
    end
end

% --- Executes on button press in acquireSpec.
function acquireSpec_Callback(hObject, eventdata, handles)
% hObject    handle to acquireSpec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

modifiers = get(gcf,'currentModifier');
ctrlIsPressed = ismember('control',modifiers); %Press Ctrl button in order to take the backgrond spectra;
acquireOpt = getUserData('acquireOpt');
laser = getUserData('laser');
spectrometer = getUserData('spectrometer');
%fileOpt = getUserData('fileOpt');
ad = acquireOpt.andor;
if isempty(ad)
    update_waitbar(handles,0,'No Andor spectrometer was connected!',1);
    return;
end
if laser.src == 1 %solstis
    if isempty(laser.sol)
        update_waitbar(handles,0,'No SolsTis laser was connected!',1);
        return;
    end
else
    if isempty(laser.smc)
        update_waitbar(handles,0,'No 3900s laser was connected!',1);
        return;
    end
end

SetAllGUIButtons(handles,0);
set(handles.abortAcquiring,'Enable','on');
if laser.src == 1 %solstis    
    lambdamin=min(laser.start(1),laser.end(1));
    lambdamax=max(laser.start(1),laser.end(1));
else %3900s
    lambdamin=min(laser.start(2),laser.end(2));
    lambdamax=max(laser.start(2),laser.end(2));
end 
if ctrlIsPressed %take the background;
    acquireOpt.background = [];
else
    acquireOpt.spectra = [];
end
setUserData('acquireOpt',acquireOpt);

if spectrometer.scans > 1 %may WMRS
    set(handles.isWMRS,'Enable','on');
    lambdaincr=lambdamax-lambdamin;
    lambda = linspace(lambdamin,lambdamax,spectrometer.scans);
    if laser.src == 1 %solstis
        laser.counter = solstisWAVE(laser.sol,laser.counter,lambdamin); %move to min wavelength;
    else %3900s
        laser.smc.velocity = 0.1; %high speed;
        laser.smc.moveTo(lambdamin); %move to min wavelengh
        pause(lambdaincr/0.1);%wait to position;
    end
    if laser.continuous == 1 %continuous tuning;
        if ad.ReadMode ~=0  %set to FVB mode;
            update_waitbar(handles,0,'Changing acquisition to FVB mode.........')
            ad.ReadMode=0;
        end
        if ad.AcquisitionMode ~=3  %set to Kinetics mode;
            ad.AcquisitionMode=3;
        end
        scantime = spectrometer.accums*spectrometer.exposureTime*spectrometer.scans;
        if laser.src==0 %3900s;
            laser.smc.velocity = lambdaincr/scantime; %mm/s            
        end
        if ad.startAcquire == 1
            if laser.src == 1 %solstis
                tic;
                while toc<scantime
                    acquireOpt = getUserData('acquireOpt');
                    if acquireOpt.acquiringAborted == 1
                        break;
                    end
                    lam=lambdamin+toc/scantime*lambdaincr;
                    laser.counter = solstisWAVE(laser.sol, laser.counter, lam);
                    if toc/scantime<=1
                        perc = toc/scantime;
                    else
                        perc = 1;
                    end
                    if ctrlIsPressed %take the background;
                        update_waitbar(handles,perc,sprintf('Tune wavelength to %5.3fnm.........Acquiring background Raman spectrum...',lam));
                    else
                        update_waitbar(handles,perc,sprintf('Tune wavelength to %5.3fnm.........Acquiring Raman spectrum...',lam));
                    end
                end
            else %3900s
                laser.smc.moveTo(lambdamax);
                last = 0;
                while last<spectrometer.scans
                    acquireOpt = getUserData('acquireOpt');
                    if acquireOpt.acquiringAborted == 1
                        break;
                    end
                    [ret, first,last] = GetNumberNewImages(); %use andor SDK function directly here, 
                    if last == 0
                        if ctrlIsPressed %take the background;
                            update_waitbar(handles,0,sprintf('Tunning SMC from %2.4fmm to %2.4fmm.........Start aquiring background Raman spectra...',lambdamin,lambdamax));
                        else
                            update_waitbar(handles,0,sprintf('Tunning SMC from %2.4fmm to %2.4fmm.........Start aquiring Raman spectra...',lambdamin,lambdamax));
                        end
                    else
                        if ctrlIsPressed %take the background;
                            update_waitbar(handles,last/spectrometer.scans,sprintf('Tunning SMC from %2.4fmm to %2.4fmm.........Acquiring %d background Raman spectra...',lambdamin,lambdamax,last));
                        else
                            update_waitbar(handles,last/spectrometer.scans,sprintf('Tunning SMC from %2.4fmm to %2.4fmm.........Acquiring %d Raman spectra...',lambdamin,lambdamax,last));
                        end
                    end
                    pause(spectrometer.accums*spectrometer.exposureTime);
                end
            end
            while ad.isAndorIdle~=1
                %wait until acquisition finish;
            end
            
            if acquireOpt.acquiringAborted == 0 %abort button was not pressed;
                if ctrlIsPressed %take the background;
                    acquireOpt.background=(ad.getImage).';
                else
                    acquireOpt.spectra=(ad.getImage).';
                end
            end
        else
            if ctrlIsPressed %take the background;
                update_waitbar(handles,0,'Background pectra acquiring is not correctly started.........Please check and try again!',1);
                acquireOpt.background = [];
            else
                update_waitbar(handles,0,'Spectra acquiring is not correctly started.........Please check and try again!',1);
                acquireOpt.spectra = [];
            end
        end
    elseif laser.continuous == 0 %step tuning;
        if ad.ReadMode ~=0  %set to FVB mode;
            update_waitbar(handles,0,'Changing acquisition to FVB mode.........')
            ad.ReadMode=0;
        end
        if spectrometer.accums == 1
            if ad.AcquisitionMode ~=1  %set to single scan mode;
                ad.AcquisitionMode=1;
            end
        else
            if ad.AcquisitionMode ~=2  %set to accumulation mode;
                ad.AcquisitionMode = 2;
            end
        end
        if ctrlIsPressed
            acquireOpt.background = [];
        else
            acquireOpt.spectra=[];
        end
        if ctrlIsPressed %take the background;
            update_waitbar(handles,0,'Start acquiring background Raman spectra...........');
        else
            update_waitbar(handles,0,'Start acquiring Raman spectra...........');
        end
        [ret] = PrepareAcquisition();
        for mm = 1:spectrometer.scans
            acquireOpt = getUserData('acquireOpt');
            if acquireOpt.acquiringAborted == 1
                break;
            end
            if laser.src == 1 %solstis
                laser.counter = solstisWAVE(laser.sol, laser.counter, lambda(mm));
            else %3900s
                laser.smc.moveTo(lambda(mm));
            end   
            spec = ad.acquire0;cc=0;
            while isempty(spec)||(~all(spec)) && cc<5 %try 5 time to ensure acquire data;
                spec = ad.acquire0;
                cc=cc+1;
            end
            if ~isempty(spec)
                if ctrlIsPressed
                    acquireOpt.background = [acquireOpt.background spec];
                else
                    acquireOpt.spectra = [acquireOpt.spectra spec];
                end
                setUserData('acquireOpt',acquireOpt);
            end
            if ctrlIsPressed %take the background;
                update_waitbar(handles,mm/spectrometer.scans,sprintf('No.%d background Raman spectrum has been acquired @ wavelength %5.3fnm ',mm,lambda(mm)))
            else
                update_waitbar(handles,mm/spectrometer.scans,sprintf('No.%d Raman spectrum has been acquired @ wavelength %5.3fnm ',mm,lambda(mm)));
            end
        end
    elseif laser.continuous == 2 %no modulation tuning;        
        if laser.src == 1 %solstis
            laser.counter = solstisWAVE(laser.sol,laser.counter,(lambdamin+lambdamax)/2); %set wavelength back to middle;
        else %3900s
            laser.smc.velocity = 0.1; %high speed;
            laser.smc.moveTo((lambdamin+lambdamax)/2);%set wavelength back to middle;
            pause(lambdaincr/0.2); %wait to position;
        end
        if ad.ReadMode ~=0  %set to FVB mode;
            update_waitbar(handles,0,'Changing acquisition to FVB mode.........')
            ad.ReadMode=0;
        end
        if ad.AcquisitionMode ~=3  %set to Kinetics mode;
            ad.AcquisitionMode=3;
        end
        if ad.startAcquire == 1
            for m = 1:spectrometer.scans
                acquireOpt = getUserData('acquireOpt');
                if acquireOpt.acquiringAborted == 1
                    break;
                end
                if ctrlIsPressed %take the background;
                    update_waitbar(handles,0,sprintf('Start aquiring No. %d background Raman spectra...',m));
                else
                    update_waitbar(handles,0,sprintf('Start aquiring NO. %d Raman spectra...',m));
                end
                pause(spectrometer.accums*spectrometer.exposureTime);
            end
            while ad.isAndorIdle~=1
                %wait until acquisition finish;
            end
            if acquireOpt.acquiringAborted == 0
                if ctrlIsPressed %take the background;
                    acquireOpt.background=(ad.getImage).';
                else
                    acquireOpt.spectra=(ad.getImage).';
                end
            end
        else %acquiring is not started correctly. 
            if ctrlIsPressed %take the background;
                update_waitbar(handles,0,'Background pectra acquiring is not correctly started.........Please check and try again!',1);
                acquireOpt.background = [];
            else
                update_waitbar(handles,0,'Spectra acquiring is not correctly started.........Please check and try again!',1);
                acquireOpt.spectra = [];
            end
        end
        spectrometer.isWMRS = 0;
        set(handles.isWMRS,'Enable','off');
        set(handles.isWMRS,'Value',spectrometer.isWMRS);
    end
    if laser.continuous<2 
        if laser.src == 1 %solstis
            laser.counter = solstisWAVE(laser.sol,laser.counter,(lambdamin+lambdamax)/2); %set wavelength back to middle;
        else %3900s
            laser.smc.velocity = 0.1; %high speed;
            laser.smc.moveTo((lambdamin+lambdamax)/2);%set wavelength back to middle;
            pause(lambdaincr/0.2); %wait to position;
        end
    end
    if acquireOpt.acquiringAborted == 0 %not cancelled
        if isempty(acquireOpt.spectra)
            acquireOpt.WMRSpectrum = [];
        else
            if all(size(acquireOpt.spectra)==size(acquireOpt.background))&&acquireOpt.signalBackRef==2
                acquireOpt.WMRSpectrum = calculateWMRspec(acquireOpt.spectra-acquireOpt.background,laser.ramanPeak);
            else
                if acquireOpt.signalBackRef==1 %background
                    acquireOpt.WMRSpectrum = calculateWMRspec(acquireOpt.background,laser.ramanPeak);
                else
                    acquireOpt.WMRSpectrum = calculateWMRspec(acquireOpt.spectra,laser.ramanPeak);
                end
            end
            update_waitbar(handles,0,' ');
        end
        acquireOpt.axisWavelength = ad.AxisWavelength;
        if spectrometer.isWMRS
            updateWMRSpec(handles,acquireOpt.axisWavelength,acquireOpt.WMRSpectrum);
        else
            if acquireOpt.signalBackRef==1 %background
                updateWMRSpec(handles,acquireOpt.axisWavelength,acquireOpt.background);
            else
                updateWMRSpec(handles,acquireOpt.axisWavelength,acquireOpt.spectra);
            end
        end
    end
    if laser.continuous<2
        set(handles.isWMRS,'Enable','on');
    end
else %single spectra
    if ad.ReadMode ~=0  %set to FVB mode;
        update_waitbar(handles,0,'Changing acquisition to FVB mode.........')
        ad.ReadMode=0;
    end
    if spectrometer.accums == 1
        if ad.AcquisitionMode ~=1  %set to single scan mode;
            ad.AcquisitionMode=1;
        end
    else
        if ad.AcquisitionMode ~=2  %set to accumulation mode;
            ad.AcquisitionMode = 2;
        end
    end
    if laser.src == 1 %solstis
        laser.counter = solstisWAVE(laser.sol,laser.counter,(lambdamin+lambdamax)/2); %set wavelength back to middle;
    else %3900s
        laser.smc.moveTo((lambdamin+lambdamax)/2);%set wavelength back to middle;
    end
    if ctrlIsPressed %take the background;
        update_waitbar(handles,0,'Acquiring one background spectrum.....');
    else
        update_waitbar(handles,0,'Acquiring one spectrum.....');
    end
    spectrometer.isWMRS = 0;
    set(handles.isWMRS,'Enable','off');
    set(handles.isWMRS,'Value',spectrometer.isWMRS);
    
    if ad.startAcquire == 1        
        while ad.isAndorIdle~=1
            %wait until acquisition finish;
            acquireOpt = getUserData('acquireOpt');
            if acquireOpt.acquiringAborted
                break;
            end
        end
        if acquireOpt.acquiringAborted == 0%no cancellation
            if ctrlIsPressed %take the background;
                acquireOpt.background=(ad.getImage).';
            else
                acquireOpt.spectra=(ad.getImage).';
            end
            acquireOpt.axisWavelength = ad.AxisWavelength;
            acquireOpt.WMRSpectrum = [];            
            update_waitbar(handles,0,'Plotting spectrum.....');
            if all(size(acquireOpt.spectra)==size(acquireOpt.background))&&acquireOpt.signalBackRef==2
                updateWMRSpec(handles,acquireOpt.axisWavelength,acquireOpt.spectra-acquireOpt.background);
            else
                if acquireOpt.signalBackRef==1 %background
                    updateWMRSpec(handles,acquireOpt.axisWavelength,acquireOpt.background);
                else
                    updateWMRSpec(handles,acquireOpt.axisWavelength,acquireOpt.spectra);
                end
            end
            update_waitbar(handles,0,' ');
        end
    else
        if ctrlIsPressed %take the background;
            update_waitbar(handles,0,'Background pectra acquiring is not correctly started.........Please check and try again!',1);
            acquireOpt.background = [];
        else
            update_waitbar(handles,0,'Spectra acquiring is not correctly started.........Please check and try again!',1);
            acquireOpt.spectra = [];
        end
    end
end
if ctrlIsPressed %background
    set(handles.signalBackRef,'Value',2);
else %signal
    set(handles.signalBackRef,'Value',1);
end
SetAllGUIButtons(handles,1);
set(handles.abortAcquiring,'Enable','off');
acquireOpt.acquiringAborted = 0; %reset abortion flag;
if min(size(acquireOpt.spectra))==1
    set(handles.isWMRS,'Enable','off');
end
setUserData('acquireOpt',acquireOpt);
setUserData('spectrometer',spectrometer);
setUserData('laser',laser);

function updateWMRSpec(handles,axisWave,spec)
%update the plot spectra with new data;
axes(handles.specPlot);hold off;
plot(axisWave,spec);
axis tight;grid on;
xlabel('Raman shift (nm)');
ylabel('Raman intensity (counts)');
axes(handles.imagePlot);axis image;
dragzoom([handles.imagePlot handles.specPlot]);

% --- Executes on button press in pickRamanPeak.
function pickRamanPeak_Callback(hObject, eventdata, handles)
% hObject    handle to pickRamanPeak (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
acquireOpt = getUserData('acquireOpt');
laser = getUserData('laser');

[x, y] = ginputax(handles.specPlot,1);
axisWavelength = acquireOpt.andor.AxisWavelength;
if gca == handles.specPlot        
    laser.ramanPeak = find(axisWavelength>x,1);
    set(handles.ramanPeak,'String',num2str(laser.ramanPeak));
    update_waitbar(handles,0,sprintf('Reference Raman peak has been changed to %d pixels!',laser.ramanPeak));
    setUserData('laser',laser);
end

function ramanPeak_Callback(hObject, eventdata, handles)
% hObject    handle to ramanPeak (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ramanPeak as text
%        str2double(get(hObject,'String')) returns contents of ramanPeak as a double


% --- Executes during object creation, after setting all properties.
function ramanPeak_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ramanPeak (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in liveSpec.
function liveSpec_Callback(hObject, eventdata, handles)
% hObject    handle to liveSpec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles
acquireOpt = getUserData('acquireOpt');
if isempty(acquireOpt.andor)
    return;
end
SetAllGUIButtons(handles,0);
acquireOpt.andor.acquireLive;
SetAllGUIButtons(handles,1);


% --- Executes on selection change in SelectCam.
function SelectCam_Callback(hObject, eventdata, handles)
% hObject    handle to SelectCam (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns SelectCam contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SelectCam


% --- Executes during object creation, after setting all properties.
function SelectCam_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SelectCam (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on slider movement.
function CamExposSlider_Callback(hObject, eventdata, handles)
% hObject    handle to CamExposSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
acquireOpt = getUserData('acquireOpt'); 
camNum = get(handles.cameraSelect,'Value');
switch camNum
    case 1
        acquireOpt.camera.src.Exposure = get(hObject,'Value');
        if get(hObject,'Min') == get(hObject,'Value')
            acquireOpt.camera.src.GainAuto = 'Off'; %set auto Gain;
            acquireOpt.camera.src.Gain = 34; %set Gain as minimum too;
        else
            acquireOpt.camera.src.GainAuto = 'On'; %set auto Gain;
        end
    case 2
        expTime = get(hObject,'Value');
        acquireOpt.camera.src.ExposureTime = expTime;
        if expTime<0.1 && expTime>1e-04
            expTime = acquireOpt.camera.src.ExposureTime*10^3;
            set(handles.expUnits,'String','ms');
        elseif expTime<=1e-04
            expTime = acquireOpt.camera.src.ExposureTime*10^6;
            set(handles.expUnits,'String','us');
        else
            expTime = acquireOpt.camera.src.ExposureTime;
            set(handles.expUnits,'String','s');
        end
        set(handles.exposureTimeEdit,'String',num2str(expTime));
    otherwise
end
    
setUserData('acquireOpt',acquireOpt);

% --- Executes during object creation, after setting all properties.
function CamExposSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CamExposSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
 


% --- Executes on button press in autoExposure.
function autoExposure_Callback(hObject, eventdata, handles)
% hObject    handle to autoExposure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of autoExposure
acquireOpt = getUserData('acquireOpt');
if get(hObject,'Value')
    acquireOpt.camera.src.ExposureAuto = 'On';
    set(handles.CamExposSlider,'Enable','off');    
else
    acquireOpt.camera.src.ExposureAuto = 'off';
    acquireOpt.camera.src.Exposure = get(handles.CamExposSlider,'Value');
    set(handles.CamExposSlider,'Enable','on');    
end
setUserData('acquireOpt',acquireOpt);

% --- Executes during object creation, after setting all properties.
function autoExposure_CreateFcn(hObject, eventdata, handles)
% hObject    handle to autoExposure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in stageMoveUp.
function stageMoveUp_Callback(hObject, eventdata, handles)
% hObject    handle to stageMoveUp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in stageMoveRight.
function stageMoveRight_Callback(hObject, eventdata, handles)
% hObject    handle to stageMoveRight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in stageMoveLeft.
function stageMoveLeft_Callback(hObject, eventdata, handles)
% hObject    handle to stageMoveLeft (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in stageMoveDown.
function stageMoveDown_Callback(hObject, eventdata, handles)
% hObject    handle to stageMoveDown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pickPoint.
function pickPoint_Callback(hObject, eventdata, handles)
% hObject    handle to pickPoint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in calibStage.
function calibStage_Callback(hObject, eventdata, handles)
% hObject    handle to calibStage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in clearCalibration.
function clearCalibration_Callback(hObject, eventdata, handles)
% hObject    handle to clearCalibration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in emergStop.
function emergStop_Callback(hObject, eventdata, handles)
% hObject    handle to emergStop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SetAllGUIButtons(handles,1);



function stepSize_Callback(hObject, eventdata, handles)
% hObject    handle to stepSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of stepSize as text
%        str2double(get(hObject,'String')) returns contents of stepSize as a double


% --- Executes during object creation, after setting all properties.
function stepSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stepSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function stepSizeMicron_Callback(hObject, eventdata, handles)
% hObject    handle to stepSizeMicron (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of stepSizeMicron as text
%        str2double(get(hObject,'String')) returns contents of stepSizeMicron as a double


% --- Executes during object creation, after setting all properties.
function stepSizeMicron_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stepSizeMicron (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function slitWidth_Callback(hObject, eventdata, handles)
% hObject    handle to slitWidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of slitWidth as text
%        str2double(get(hObject,'String')) returns contents of slitWidth as a double
acquireOpt = getUserData('acquireOpt');
spectrometer = getUserData('spectrometer');
ad = acquireOpt.andor;
if isempty(ad)
    update_waitbar(handles,0,'No Andor spectrometer was connected!',1);
    return;
end
slitwidth = round(str2double(get(hObject,'String')));
if slitwidth >= 10 && slitwidth <= 2000
    ad.SlitWidth = slitwidth;
    spectrometer.slitWidth = slitwidth;
    setUserData('acquireOpt',acquireOpt);
    setUserData('spectrometer',spectrometer);
    str = sprintf('SlitWidth has been set to %d um!',slitwidth);
    update_waitbar(handles,0,str);
else 
    str = sprintf('SlitWidth can not set as %s!', get(hObject,'String'));
    update_waitbar(handles,0,str,1);
end



% --- Executes during object creation, after setting all properties.
function slitWidth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slitWidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in readMode.
function readMode_Callback(hObject, eventdata, handles)
% hObject    handle to readMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns readMode contents as cell array
%        contents{get(hObject,'Value')} returns selected item from readMode
acquireOpt = getUserData('acquireOpt');
spectrometer = getUserData('spectrometer');
ad = acquireOpt.andor;
if isempty(ad)
    update_waitbar(handles,0,'No Andor spectrometer was connected!',1);
    return;
end

contents = cellstr(get(hObject,'String'));
readmode = get(hObject,'Value');
if readmode == 1 %FVB 
    ad.ReadMode = 0;
    spectrometer.readMode = 0;    
elseif readmode == 2; %image
    ad.ReadMode = 4;
    spectrometer.readMode = 4;
else
end
update_waitbar(handles,0,sprintf('Spectrometer has been set to %s mode now.',contents{readmode}));
setUserData('acquireOpt',acquireOpt);
setUserData('spectrometer',spectrometer);

% --- Executes during object creation, after setting all properties.
function readMode_CreateFcn(hObject, eventdata, handles)
% hObject    handle to readMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in stageFlipLR.
function stageFlipLR_Callback(hObject, eventdata, handles)
% hObject    handle to stageFlipLR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of stageFlipLR


% --- Executes during object creation, after setting all properties.
function stageFlipLR_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stageFlipLR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in stageFlipUD.
function stageFlipUD_Callback(hObject, eventdata, handles)
% hObject    handle to stageFlipUD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of stageFlipUD


% --- Executes on button press in stageRot90.
function stageRot90_Callback(hObject, eventdata, handles)
% hObject    handle to stageRot90 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of stageRot90


% --- Executes on selection change in cameraSelect.
function cameraSelect_Callback(hObject, eventdata, handles)
% hObject    handle to cameraSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns cameraSelect contents as cell array
%        contents{get(hObject,'Value')} returns selected item from cameraSelect
acquireOpt = getUserData('acquireOpt');
laser = getUserData('laser');
if ~isempty(acquireOpt.camera.vid)
    if ~isempty(strfind(acquireOpt.camera.vid.Name,'tisimaq_r2013'))
        curCamNum = 1;
    elseif ~isempty(strfind(acquireOpt.camera.vid.Name,'hamamatsu'))
        curCamNum = 2;
    else
        curCamNum = 0;
    end
else
    curCamNum = 0;
end
camNum = get(hObject,'Value');

%stop current camera;
if ~isempty(acquireOpt.camera)
    if ishandle(acquireOpt.camera.vid)
        if (strcmpi(acquireOpt.camera.vid.Running,'on'))
            stop(acquireOpt.camera.vid);
        end
        delete(acquireOpt.camera.vid);
        acquireOpt.camera = [];
    end
end

if camNum == curCamNum% select current using cam
    vid = acquireOpt.camera.vid;
else
    switch camNum
        case 1%imagingSource camera
            update_waitbar(handles,0,'Initializing ImagingSource camera.............Please wait......',1);
            try
                vid = videoinput('tisimaq_r2013', 1, 'RGB24 (1280x960)');
            catch
                vid = [];src = []; image = []; hImage = [];
                axes(handles.imagePlot);axis off;
                update_waitbar(handles,0,'ImagingSource Camera is not connected!!',1);
                set(hObject,'Value',curCamNum);
                return;
            end
        case  2%hamatsu camera;
            update_waitbar(handles,0,'Initializing Hamamatsu camera.............Please wait......',1);
            try
                vid = videoinput('hamamatsu', 1, 'MONO8_1344x1024');
            catch
                vid = [];src = []; image = []; hImage = [];
                axes(handles.imagePlot);axis off;
                update_waitbar(handles,0,'Hamamatsu Camera is not connected!!',1);
                set(hObject,'Value',curCamNum);
                return;
            end
    end
end

if ~isempty(vid)
    src = getselectedsource(vid);
    vid.FramesPerTrigger = 1;    
    try
        start(vid);
    catch
        stop(vid);
        delete(vid);
        vid = []; src = [];    image = [];    hImage = [];
        axes(handles.imagePlot);axis off;
        update_waitbar(handles,0,'Camera is used by another application!!!',1);
        return;
    end
end
if ~isempty(vid)    
    switch camNum
        case 1 %imagingSource Camera;
            set(handles.CamExposSlider,'Min',0.0001,'Max',2,'SliderStep',[0.001 0.05]);
            set(handles.CamExposSlider,'Value',src.Exposure);
            src.ExposureAuto = 'On'; set(handles.CamExposSlider,'Enable','off');
            set(handles.autoExposure,'Visible','on'); set(handles.autoExposure,'Value',1); 
            set(handles.exposureTimeEdit,'Visible','off');  set(handles.expUnits,'Visible','off');  
        case 2  %hamatsu camera;
            src.ExposureTime = 0.001; %intial exp time;
            set(handles.CamExposSlider,'Min',max([src.ExposureTime/10 1e-05]),'Max',min([10 src.ExposureTime*100]),'SliderStep',[max([src.ExposureTime/10 1e-05]) src.ExposureTime*10]);
            set(handles.CamExposSlider,'Value',src.ExposureTime);
            if src.ExposureTime<0.1 && src.ExposureTime>1e-04
                expTime = src.ExposureTime*10^3;
                set(handles.expUnits,'String','ms');
            elseif src.ExposureTime<=1e-04
                expTime = src.ExposureTime*10^6;
                set(handles.expUnits,'String','us');
            else
                expTime = src.ExposureTime;
                set(handles.expUnits,'String','s');
            end
            set(handles.exposureTimeEdit,'String',num2str(expTime));
            src.ExposureTimeMode = 'Manual';
            set(handles.CamExposSlider,'Enable','on');
            set(handles.autoExposure,'Visible','off');            
            set(handles.exposureTimeEdit,'Visible','on');set(handles.expUnits,'Visible','on');  
        otherwise
    end
    if camNum == 1 %imagingSource
        image = getdata(vid);
    elseif camNum == 2%hamatsu
        image = fliplr(getdata(vid));
    end       
    axes(handles.imagePlot);
    hImage = imagesc(image);
    axis image;axis off;  
else
    update_waitbar(handles,0,' ');
end
dragzoom([handles.specPlot,handles.imagePlot]);
acquireOpt.camera.vid = vid;
acquireOpt.camera.src = src;
acquireOpt.image = image;
acquireOpt.hImage = hImage;
if ~isempty(laser.marker)
    x=laser.marker(1);y=laser.marker(2);
    h=line([x-10 x+10],[y y],'LineStyle','-','Color',[1 0 0]);
    laser.markerCross(1)=h;
    h=line([x x],[y-10 y+10],'LineStyle','-','Color',[1 0 0]);
    laser.markerCross(2)=h;
end
if ~isempty(vid) && get(handles.isRealTimeImaging,'Value')
    setappdata(acquireOpt.hImage,'UpdatePreviewWindowFcn',@mypreview_fcn);
    preview(acquireOpt.camera.vid, acquireOpt.hImage);
    update_waitbar(handles,0,'Camera in preview mode....',1);
end
setUserData('laser',laser);
setUserData('acquireOpt',acquireOpt);


% --- Executes during object creation, after setting all properties.
function cameraSelect_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cameraSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in signalBackRef.
function signalBackRef_Callback(hObject, eventdata, handles)
% hObject    handle to signalBackRef (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns signalBackRef contents as cell array
%        contents{get(hObject,'Value')} returns selected item from signalBackRef
acquireOpt = getUserData('acquireOpt');
spectrometer = getUserData('spectrometer');
flag = get(hObject,'Value');
switch flag
    case 1
        acquireOpt.signalBackRef = 0;
        if spectrometer.isWMRS
            acquireOpt.WMRSpectrum = calculateWMRspec(acquireOpt.spectra,laser.ramanPeak);
            updateWMRSpec(handles,acquireOpt.axisWavelength,acquireOpt.WMRSpectrum);
        else
            updateWMRSpec(handles,acquireOpt.axisWavelength,acquireOpt.spectra);
        end
    case 2
        acquireOpt.signalBackRef = 1;
        if spectrometer.isWMRS && max(size(acquireOpt.background)>=3)
            acquireOpt.WMRSpectrum = calculateWMRspec(acquireOpt.background,laser.ramanPeak);
            updateWMRSpec(handles,acquireOpt.axisWavelength,acquireOpt.WMRSpectrum);
        else
            if ~isempty(acquireOpt.background)
                updateWMRSpec(handles,acquireOpt.axisWavelength,acquireOpt.background);
            end
        end
    case 3
        acquireOpt.signalBackRef = 2;
        if spectrometer.isWMRS && all(size(acquireOpt.spectra)==size(acquireOpt.background))
            acquireOpt.WMRSpectrum = calculateWMRspec(acquireOpt.spectra-acquireOpt.background,laser.ramanPeak);
            updateWMRSpec(handles,acquireOpt.axisWavelength,acquireOpt.WMRSpectrum);
        else
            if all(size(acquireOpt.spectra)==size(acquireOpt.background))
                updateWMRSpec(handles,acquireOpt.axisWavelength,acquireOpt.spectra-acquireOpt.background);
            else
                updateWMRSpec(handles,acquireOpt.axisWavelength,acquireOpt.spectra);
            end
        end
    otherwise %reserved
end
setUserData('acquireOpt',acquireOpt); 


% --- Executes during object creation, after setting all properties.
function signalBackRef_CreateFcn(hObject, eventdata, handles)
% hObject    handle to signalBackRef (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in modulationMode.
function modulationMode_Callback(hObject, eventdata, handles)
% hObject    handle to modulationMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns modulationMode contents as cell array
%        contents{get(hObject,'Value')} returns selected item from modulationMode
laser = getUserData('laser');
contents = cellstr(get(hObject,'String'));
mode = contents{get(hObject,'Value')};
laser.continuous = get(hObject,'Value') - 1;
str = sprintf('Laser has be set as %s.',mode);
update_waitbar(handles,0,str);
setUserData('laser',laser);


% --- Executes during object creation, after setting all properties.
function modulationMode_CreateFcn(hObject, eventdata, handles)
% hObject    handle to modulationMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in laserSource.
function laserSource_Callback(hObject, eventdata, handles)
% hObject    handle to laserSource (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns laserSource contents as cell array
%        contents{get(hObject,'Value')} returns selected item from laserSource
laser = getUserData('laser');
contents = cellstr(get(hObject,'String'));
laser.src = get(hObject,'Value') - 1;
str = sprintf('Selecting %s as laser source now.',contents{get(hObject,'Value')});    
update_waitbar(handles,0,str);
if laser.src == 0 %3900s
    if length(laser.start)==2
        set(handles.laserStart,'String',num2str(laser.start(2)));
    else
        set(handles.laserStart,'String',num2str(16.3));
    end
    if length(laser.end)==2
        set(handles.laserEnd,'String',num2str(laser.end(2)));
    else
        set(handles.laserEnd,'String',num2str(16.45));
    end
    
    if isempty(laser.smc)
        smc = SMC100();
        if ~isempty(smc.SMCobj)
            laser.smc = smc;
        else
            laser.smc = [];
            update_waitbar(handles,0,'SMC100 cannot be initialized successfully!',1);
            return;
        end
    else %Check smc status;
        try
            status=query(laser.smc.SMCobj,'1mm?');
        catch
            if ~isempty(laser.smc.SMCobj)
                laser.smc.releaseSMC();
            end
            laser.smc = [];
            update_waitbar(handles,0,'SMC100 has been disconnected, retry!');
            return;
        end
        if length(status)<5 %wrong com device
            if ~isempty(laser.smc.SMCobj)
                laser.smc.releaseSMC();
            end
            laser.smc = [];
            update_waitbar(handles,0,'SMC100 has been disconnected!');
            return;
        elseif status(5) == '2'||status(5) == '3'|| status(5) == '4'
            update_waitbar(handles,0,[contents{get(hObject,'Value')} 'is selected as laser source now.']);
        else
            if ~isempty(laser.smc.SMCobj)
                laser.smc.releaseSMC();
            end
            laser.smc = [];
            update_waitbar(handles,0,'SMC100 is connected wrongly, please check!');
            return;
        end
    end
    laser.smc.velocity = 0.1; %high speed;
    laser.smc.moveTo((lambdamin+lambdamax)/2);%set wavelength back to middle;
    pause(lambdaincr/0.2); %wait to position;
    update_waitbar(handles,0,sprintf('Laser has been tuned to %3.1fnm',(laser.start(1)+laser.end(1))/2));
elseif laser.src == 1%Solstis;      
    set(handles.laserStart,'String',num2str(laser.start(1)));
    set(handles.laserEnd,'String',num2str(laser.end(1)));    
    if isempty(laser.sol)
        update_waitbar(handles,0,'Initializing Solstis now.............Please wait......');
        [sol,ii]=solstisINI();
        laser.sol = sol;
        laser.counter = ii;
        if isempty(laser.sol)
            update_waitbar(handles,0,'No successful connection to Solstis!!',1);
            return;
        end
    else
        laser.counter = solstisWAVE(laser.sol,laser.counter,(laser.start(1)+laser.end(1))/2); %move to the middle position;
        update_waitbar(handles,0,sprintf('Laser has been tuned to %3.1fnm',(laser.start(1)+laser.end(1))/2));
    end
end
setUserData('laser',laser);


% --- Executes during object creation, after setting all properties.
function laserSource_CreateFcn(hObject, eventdata, handles)
% hObject    handle to laserSource (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in abortAcquiring.
function abortAcquiring_Callback(hObject, eventdata, handles)
% hObject    handle to abortAcquiring (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
acquireOpt = getUserData('acquireOpt');
ad = acquireOpt.andor;
if isempty(ad)
    update_waitbar(handles,0,'No Andor spectrometer is not connected correctly!!',1);
    return;
end
if ad.isAndorIdle == 0
    ad.abortAcquire;
end
acquireOpt.acquiringAborted = 1;
setUserData('acquireOpt',acquireOpt);
SetAllGUIButtons(handles,1);
set(handles.abortAcquiring,'Enable','off');
update_waitbar(handles,0,'Acquiring is aborted manually!!',1);

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over abortAcquiring.
function abortAcquiring_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to abortAcquiring (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function exposureTimeEdit_Callback(hObject, eventdata, handles)
% hObject    handle to exposureTimeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of exposureTimeEdit as text
%        str2double(get(hObject,'String')) returns contents of exposureTimeEdit as a double
expTime = str2double(get(hObject,'String'));
acquireOpt = getUserData('acquireOpt');
vid = acquireOpt.camera.vid;
src = acquireOpt.camera.src;

if isempty(vid)
    update_waitbar(handles,0,'No camera is connected!!',1);
    return;
end;

if ~isnan(expTime)
    expUnits = get(handles.expUnits,'String');
    if strcmp(expUnits,'ms')
        expTime = expTime/10^3;
    elseif strcmp(expUnits,'us')
        expTime = expTime/10^6;
    end
    if expTime<10^(-5)
        expTime = 10^(-5);
        update_waitbar(handles,0,'Camera exposure time is set to be minimum!!',1);
    end
    src.ExposureTime = expTime;
    set(handles.CamExposSlider,'Min',max([expTime/10 1e-05]),'Max',min([10 expTime*100]),'SliderStep',[max([expTime/10 1e-05]) expTime*10]);
    set(handles.CamExposSlider,'Value',expTime);
    if src.ExposureTime<0.1 && src.ExposureTime>1e-04
        expTime = src.ExposureTime*10^3;
        set(handles.expUnits,'String','ms');
    elseif src.ExposureTime<=1e-04
        expTime = src.ExposureTime*10^6;
        set(handles.expUnits,'String','us');
    else
        expTime = src.ExposureTime;
        set(handles.expUnits,'String','s');
    end
    set(handles.exposureTimeEdit,'String',num2str(expTime));
else
    update_waitbar(handles,0,'Exposure time is not input correctly!!',1);
end
acquireOpt.camera.src = src;
acquireOpt.camera.vid = vid;
setUserData('acquireOpt',acquireOpt); 

% --- Executes during object creation, after setting all properties.
function exposureTimeEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to exposureTimeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in fileSaveOption.
function fileSaveOption_Callback(hObject, eventdata, handles)
% hObject    handle to fileSaveOption (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns fileSaveOption contents as cell array
%        contents{get(hObject,'Value')} returns selected item from fileSaveOption
fileOpt = getUserData('fileOpt');
fileOpt.saveOpt = get(hObject,'Value') - 1; %0 - image, 1 - spec, 2 - both; 
setUserData('fileOpt',fileOpt);

% --- Executes during object creation, after setting all properties.
function fileSaveOption_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fileSaveOption (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
