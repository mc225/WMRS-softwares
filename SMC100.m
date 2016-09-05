classdef SMC100 < handle
    % Andor class
    %
    % constructor SMC100(COMports, velocity,miniLimit,maxLimit,currentPoss)
    %               
    %
    %                         
    % by default, SMC100();
    %
    % Example 
    %       SMC100('COM1',0.1,8,18,13.9);
    %
    %
    % Copyright @ Mingzhou Chen, @University of St. Andrews. Email: mingzhou.chen@st-andrews.ac.uk, July 2016, Ver. 1.00
    properties
        SMCobj;  %com port for communication;
        velocity; %moving speed;
        minLimit; %min position;
        maxLimit; %max position;
        currentPosition; %current Position;
    end
    
    properties(SetAccess = private)
        acceptedShift=0.0001;
    end
    
    methods
        function SMC100 = SMC100(COMport,velocity,minLimit,maxLimit,currentPos)            
            if nargin<1
                obj = instrfind;
                for m = 1:size(obj,2)
                    if strcmp(obj(m).type,'serial')
                        fclose(obj(m));
                    end
                end
                a = instrhwinfo('serial');
                if isempty(a.AvailableSerialPorts)
                    fprintf('No SMC controller has been connected....\n');
                    SMC100.SMCobj = [];
                    return;
                end
                for m = 1:size(a.AvailableSerialPorts,1)
                    COMport = cell2mat(a.AvailableSerialPorts(m));
                    obj=serial(COMport,'BaudRate',57600,'DataBits',8,'FlowControl','software','Terminator','CR/LF','Timeout', 1.0);
                    try
                        fprintf('Open SMC controller on %s port....please wait.....\n',COMport);
                        fopen(obj);
                        status=query(obj,'1mm?');
                        if isempty(status)
                            fprintf('Failed to open SMC controller on %s port!!!\n',COMport);
                            fclose(obj);
                        end
                    catch
                        continue;
                    end                    
                end
            else
                obj = instrfind;
                for m = 1:size(obj,2)
                    if strcmp(obj(m).name,COMport) %only reset this ports;
                        fclose(obj(m));
                    end
                end
                obj=serial(COMport,'BaudRate',57600,'DataBits',8,'FlowControl','software','Terminator','CR/LF','Timeout', 1.0);
                try
                    fprintf('Open SMC controller on %s port....please wait.....\n',COMport);
                    fopen(obj);
                    status=query(obj,'1mm?');
                    if isempty(status)
                        fprintf('Failed to open SMC controller on %s port!!!\n',COMport);
                        fprintf('No SMC controller has been connected!\n');
                        fclose(obj);
                        SMC100.SMCobj= [];
                        return;
                    end
                catch
                    fclose(obj);
                    fprintf('Cannot open SMC controller on %s port....please wait.....\n',COMport);
                end
            end
            status=query(obj,'1mm?');
            if length(status)<5 %wrong com device
                fclose(obj);
                SMC100.SMCobj=[];
                fprintf('No SMC controller has been connected!\n');
                SMC100.SMCobj = [];
                return;
            else
                if status(5) == '2'||status(5) == '3'|| status(5) == '4'
                    fprintf('SMC controller is open and ready on %s port!\n',COMport);
                    SMC100.SMCobj = obj;
                else
                    fclose(obj);
                    SMC100.SMCobj=[];
                    fprintf('SMC controller has not been connected correctly - code %d!\n',str2num(status(5)));
                    return;
                end
            end
            if nargin>1
                SMC100.velocity = velocity;
            end
            if nargin>2
                SMC100.minLimit = minLimit;
            end
            if nargin>3
                SMC100.maxLimit = maxLimit;
            end
            if nargin>4
                SMC100.currentPosition = currentPos;
            end
        end
        function SMC100 = set.SMCobj(SMC100,newobj)
            SMC100.SMCobj = newobj;
        end
        function currentPosition = get.currentPosition(SMC100)
            currentPosition=query(SMC100.SMCobj,'1tp?');
            currentPosition=str2double(currentPosition(4:length(currentPosition)));
        end
        function SMC100 = set.currentPosition(SMC100,newCurrentPos)
            SMC100.currentPosition = setCurrentPosition(SMC100,newCurrentPos);  
        end        
        function velocity = get.velocity(SMC100)
            velocity=query(SMC100.SMCobj,'1va?');
            velocity=str2double(velocity(4:length(velocity)));
        end
        function SMC100 = set.velocity(SMC100,newVelocity)            
            SMC100.velocity = setVelocity(SMC100,newVelocity);
        end
        function minLimit = get.minLimit(SMC100)
            minLimit=query(SMC100.SMCobj,'1sl?');
            minLimit=str2double(minLimit(4:length(minLimit)));
        end
        function SMC100 = set.minLimit(SMC100,newMinLimit)            
            SMC100.minLimit = setMinLimit(SMC100,newMinLimit);
        end
        function maxLimit = get.maxLimit(SMC100)
            maxLimit=query(SMC100.SMCobj,'1SR?');
            maxLimit=str2double(maxLimit(4:length(maxLimit)));
        end
        function SMC100 = set.maxLimit(SMC100,newMaxLimit)
            SMC100.maxLimit = setMaxLimit(SMC100,newMaxLimit);
        end
    end
    
    methods
        function moveTo(SMC100,newPosition)
            fprintf(SMC100.SMCobj,['1pa' num2str(newPosition)]);
        end
        function releaseSMC(SMC100)
            if ~isempty(SMC100.SMCobj)
                fclose(SMC100.SMCobj);
                fprintf('SMC controller is closed!\n');
                SMC100.SMCobj = [];
            end
        end
    end
    methods(Access = private)
        function currentPos = setCurrentPosition(SMC100,newCurrentPos)
%             if newCurrentPos<SMC100.minLimit
%                 newCurrentPos = SMC100.minLimit;
%             end
%             if newCurrentPos>SMC100.maxLimit
%                 newCurrentPos = SMC100.maxLimit;
%             end
            
            fprintf(SMC100.SMCobj,['1pa' num2str(newCurrentPos)]);
            
            fprintf(SMC100.SMCobj,'1tp?'); %send command to move to x absolute position
            tp=fscanf(SMC100.SMCobj);
            tp=str2double(tp(4:length(tp)));
            fprintf('Moving from %3.4f to %3.4f @%1.3fmm/s......',tp,newCurrentPos,SMC100.velocity);
            tt = [];            
            
%             pause(abs(newCurrentPos-tp)/SMC100.velocity);
            
            while abs(tp-newCurrentPos)>SMC100.acceptedShift
                fprintf(SMC100.SMCobj,'1tp?');
                tp=fscanf(SMC100.SMCobj);
                tp=str2double(tp(4:length(tp)));
                for mm = 1:size(tt,2)
                    fprintf('\b');
                end
                tt = sprintf('Now at %3.4f',tp);
                fprintf('%s',tt);                
            end
            fprintf('...Done!\n');
            currentPos = tp;
        end
        function velocity = setVelocity(SMC100,newVelocity)
            fprintf(SMC100.SMCobj,['1va' num2str(newVelocity)]);
            %velocity = SMC100.velocity;
            velocity=query(SMC100.SMCobj,'1va?');
            velocity=str2double(velocity(4:length(velocity)));
        end
        function minLimit = setMinLimit(SMC100,newMinLimit)
            fprintf(SMC100.SMCobj,['1sl' num2str(newMinLimit)]);
            minLimit=query(SMC100.SMCobj,'1sl?');
            minLimit=str2double(minLimit(4:length(minLimit)));
        end
        function maxLimit = setMaxLimit(SMC100,newMaxLimit)
            fprintf(SMC100.SMCobj,['1SR' num2str(newMaxLimit)]);
            maxLimit=query(SMC100.SMCobj,'1SR?');
            maxLimit=str2double(maxLimit(4:length(maxLimit)));
        end
    end
end