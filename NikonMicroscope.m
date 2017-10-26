classdef NikonMicroscope < handle
%function to control the Nikon Elipse TE2000-E Microscope via COM port
% properties

% Methods


%Example
% scope = NikonMicroscope('COM3'); %stage is connected to COM3;
    
% Copyright @ Mingzhou Chen, @University of St. Andrews. Email: mingzhou.chen@st-andrews.ac.uk, August 2016, Ver. 1.00

properties
    scopeObj; %microscope objective;
    lamp;     %lamp on/off;
    lampVoltage; %lamp vortages; 
    opticalPath; %optical path: 'left', 'right','front','bottom','eye';
end

properties(SetAccess = private)    
end

methods
    function NikonMicroscope = NikonMicroscope(ComPort)
        if nargin<1
            obj = instrfind;
            %don't close opened port for other devices;
            %                 for m = 1:size(obj,2)
            %                     if strcmp(obj(m).type,'serial')
            %                         fclose(obj(m));
            %                     end
            %                 end
            a = instrhwinfo('serial');
            if isempty(a.AvailableSerialPorts)
                fprintf('No proscan COM port has been detected....\n');
                NikonMicroscope.scopeObj = [];
                return;
            end
            
            for m = 1:size(a.AvailableSerialPorts,1)
                COMport = cell2mat(a.AvailableSerialPorts(m));
                obj=serial(COMport,'Terminator', {'CR','CR'},'BaudRate', 9600,'DataBits', 8,'InputBufferSize', 2048,'OutputBufferSize', 2048,'Timeout', 5.0);
                fprintf('Open Nikon Microscope on %s port....please wait.....\n',COMport);
                try
                    fopen(obj);
                    fprintf(obj, 'rVER');
                    ver= fscanf(obj, '%s\n');
                    if isempty(ver)
                        fprintf('Failed to connect Nikon Microscope on %s port!!!\n',COMport);
                        fclose(obj);
                    elseif ~isempty(strcmp(ver,'aVERV'))
                        NikonMicroscope.scopeObj = obj;
                        fprintf('Nikon Microscope is detected and connected on port %s!!\n',COMport);
                        fprintf('Microscope version %s\n',ver(5:9));
                        break;
                    else
                        fprintf('Error in sending commands to Nikon Microscope on %s port!!!\n',COMport);
                        fprintf('Please check the connection and software!\n');
                        fclose(obj);
                    end
                catch
                    continue;
                end
            end
            if strcmp(obj.Status,'closed')
                NikonMicroscope.scopeObj = [];
                fprintf('No Nikon Microscope has been detected....\n');
                return;
            end
        else
            obj = instrfind('Type', 'serial', 'Port', ComPort, 'Tag', '');
            % Create the serial port object if it does not exist
            if isempty(obj)
                obj = serial(ComPort);
            else
                fclose(obj);
                obj = obj(1);
            end
            % Connect to instrument object, obj1.
            set(obj, 'Terminator', {'CR','CR'},'BaudRate', 9600,'DataBits', 8,'InputBufferSize', 2048,'OutputBufferSize', 2048,'Timeout', 1.0);
            fopen(obj);
            fprintf(obj, 'rVER');
            ver= fscanf(obj, '%s\n');
            if isempty(ver)
                fprintf('Failed to connect Nikon Microscope on %s port!!!\n',COMport);
                fclose(obj);
                NikonMicroscope.scopeObj = [];
                return;
            elseif ~isempty(strcmp(ver,'aVERV'))
                NikonMicroscope.scopeObj = obj;
                fprintf('Nikon Microscope is detected and connected on port %s!!\n',COMport);
                fprintf('Microscope version %s, ',ver(4:8));
            else
                fprintf('Error in sending commands to Nikon Microscope on %s port!!!\n',COMport);
                fprintf('Please check the connection and software!\n');
                fclose(obj);
                NikonMicroscope.scopeObj = [];
                return;
            end
        end
        
        %% set to standard mode;
        flushinput(obj); %clean the com buffer;
        fprintf(obj, 'rVTR'); %check model
        model = fscanf(obj, '%s\n');
        if str2num(model(end))
            fprintf('A model.\n');
        else
            fprintf('M model.\n');
        end
    end
    function lamp = get.lamp(NikonMicroscope)
        lamp = getLampStatus(NikonMicroscope);
    end
    function NikonMicroscope = set.lamp(NikonMicroscope,newLamp)
        NikonMicroscope.lamp = SetLamp(NikonMicroscope,newLamp);
    end
    function lampVoltage = get.lampVoltage(NikonMicroscope)
        lampVoltage = getLamplampVoltage(NikonMicroscope);
    end
    function NikonMicroscope = set.lampVoltage(NikonMicroscope,newLampVoltage)
        NikonMicroscope.lampVoltage = SetLampVoltage(NikonMicroscope,newLampVoltage);
    end
    function opticalPath = get.opticalPath(NikonMicroscope)
        opticalPath = getOpticalPath(NikonMicroscope);
    end
    function NikonMicroscope = set.opticalPath(NikonMicroscope,newOpticalPath)
        NikonMicroscope.opticalPath = SetOpticalPath(NikonMicroscope,newOpticalPath);
    end
        
    function release(NikonMicroscope) %disconnect microscope
        if ~isempty(ishandle(NikonMicroscope.scopeObj))
            fclose(NikonMicroscope.scopeObj);
            NikonMicroscope.scopeObj = [];
            disp('NikonMicroscope has been released!');
        end
    end
end

methods (Access = private)
    function lamp = getLampStatus(NikonMicroscope)
        if ~isempty(ishandle(NikonMicroscope.scopeObj))
            fprintf(NikonMicroscope.scopeObj,'rLSR');
            status = fscanf(NikonMicroscope.scopeObj,'%s\n');
            if ~isempty(strfind(status,'aLSR'))
                lamp = str2num(status(end));
            else
                disp('can not detect the lamp status, communication problem!');
                lamp = [];
            end
            flushinput(NikonMicroscope.scopeObj); %clean the com buffer;
        end
    end
    function lamp = SetLamp(NikonMicroscope,newLamp)
        if ~isempty(ishandle(NikonMicroscope.scopeObj))
            if isempty(NikonMicroscope.lamp)
                fprintf(NikonMicroscope.scopeObj,'cLMS1');
            elseif NikonMicroscope.lamp ~= newLamp
                status = 1 - NikonMicroscope.lamp;
                status = sprintf('cLMS%d',status);
                fprintf(NikonMicroscope.scopeObj,status);
                status = fscanf(NikonMicroscope.scopeObj,'%s\n');
                if status(1) == 'n'
                    disp('Can not turn on/off lamp, communication problem!');
                else
                    lamp = newLamp;
                end
            else
                lamp = newLamp;
            end
            flushinput(NikonMicroscope.scopeObj); %clean the com buffer;
        end
    end
    function lampVoltage = getLamplampVoltage(NikonMicroscope)
        if ~isempty(ishandle(NikonMicroscope.scopeObj))
            fprintf(NikonMicroscope.scopeObj,'rLVR');
            voltage = fscanf(NikonMicroscope.scopeObj,'%s\n');
            if voltage(1)=='a'
                lampVoltage = str2num(voltage(5:7));
            else
                disp('Can not retrieve lamp voltage, comm error!');
            end
            flushinput(NikonMicroscope.scopeObj); %clean the com buffer;
        end
    end
    function lampVoltage = SetLampVoltage(NikonMicroscope,newLampVoltage)
        if ~isempty(ishandle(NikonMicroscope.scopeObj))
            if newLampVoltage>12
                newLampVoltage = 12;
            elseif newLampVoltage<3
                newLampVoltage = 3;
            end
            vt = sprintf('cLMC%1.1f',newLampVoltage);
            fprintf(NikonMicroscope.scopeObj,vt);
            reply = fscanf(NikonMicroscope.scopeObj,'%s\n'); 
            if reply(1) == 'o'
                lampVoltage = newLampVoltage;
            else
                lampVoltage = NikonMicroscope.lampVoltage;
            end
            flushinput(NikonMicroscope.scopeObj); %clean the com buffer;
        end
    end
    function opticalPath = getOpticalPath(NikonMicroscope)
        if ~isempty(ishandle(NikonMicroscope.scopeObj))
            fprintf(NikonMicroscope.scopeObj,'rPAR');
            path = fscanf(NikonMicroscope.scopeObj,'%s\n'); 
            if path(1) == 'a'
                path = str2num(path(5));
                switch path
                    case 1
                        opticalPath = 'eye';
                    case 2
                        opticalPath = 'right';
                    case 3
                        opticalPath = 'bottom';
                    case 4
                        opticalPath = 'front';
                    case 5
                        opticalPath = 'left';
                    otherwise
                        opticalPath = 'unknown';
                end
            else
                disp('can not know optical path, comm error!');
            end
            flushinput(NikonMicroscope.scopeObj); %clean the com buffer;
        end
    end
    function opticalPath = SetOpticalPath(NikonMicroscope,newOpticalPath)        
        if ~isempty(ishandle(NikonMicroscope.scopeObj));
            flushinput(NikonMicroscope.scopeObj); %clean the com buffer;
            switch newOpticalPath
                case 'eye'
                    fprintf(NikonMicroscope.scopeObj,'cPDM1');
                case 'right'
                    fprintf(NikonMicroscope.scopeObj,'cPDM2');
                case 'bottom'
                    fprintf(NikonMicroscope.scopeObj,'cPDM3');
                case 'front'
                    fprintf(NikonMicroscope.scopeObj,'cPDM4');
                case 'left'
                    fprintf(NikonMicroscope.scopeObj,'cPDM5');
            end            
            path = fscanf(NikonMicroscope.scopeObj,'%s\n'); 
            if path(1) == 'o'
                opticalPath = newOpticalPath;
            else
               opticalPath = NikonMicroscope.opticalPath;
            end
            flushinput(NikonMicroscope.scopeObj); %clean the com buffer;
        end
    end
end

methods (Static = true)
end
end