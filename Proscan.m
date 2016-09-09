classdef Proscan < handle
%function to control the Prior ProScan II microscope stage (X,Y) via COM port
% properties
%         stageObj;               %com port for communication;
%         stageStepResoltion;     %microsteps/um; Read only, 25steps/um for the stage in Lab137C
%         stageLimit;             %mm in x, y direction, [xlim ylim], Read only;
%         currentPosition;        %current Position, [x y z] in steps; %z = 0;    
%         stepSize;               %micro steps in unit step;
%         stepsOneMovement;       %user defined how many steps in one movement, [xu yu]; 
%         motorMaxSpeed;          %motor max speed using for movement; range [1:200]; doesn't affect the movement a lot;
%         motorAcceleration;      %motor acceleration using for movement; range [1:150];  doesn't affect the movement a lot;
%         umPerStep;              %one step in um, Read only;
% Methods
%     move(Proscan,direction,steps)  %direction = 'B', 'F', 'L', 'R' (back, forward, left, right in direction);
%     newPos = moveTo(Proscan,position); % move to absolute positions
%     joystickEable(Proscan, OnOff); %Enable/disable joystick;
%     emergencyStop(Proscan); % emergency stop, immediately stop all movement and clear the command list.
%     stop(Proscan); %Stop in a controlled manner to reduce the risk of losing position. The command list in queue will be emptied;
%     releaseProscan(Proscan);% relase COM obj
%Example
% pro = Proscan('COM4'); %stage is connected to COM4;    
% pro = Proscan(); %Check all possible COM port to find the first connected Proscan stage;
% Copyright @ Mingzhou Chen, @University of St. Andrews. Email: mingzhou.chen@st-andrews.ac.uk, August 2016, Ver. 1.00

properties
        stageObj;               %com port for communication;
        stageStepResoltion;     %microsteps/um; 25steps/um for the stage in Lab137C
        stageLimit;             %mm in x, y direction, [xlim ylim];
        currentPosition;        %current Position, [x y z] in steps; %z = 0;    
        stepSize;               %micro steps in unit step;
        stepsOneMovement;       %user defined how many steps in one movement, [xu yu]; 
        motorMaxSpeed;          %motor max speed using for movement; range [1:200]; 
        motorAcceleration;      %motor acceleration using for movement; range [1:150]; 
        umPerStep;               %one step in um;
    end
    
    properties(Access = private,  Constant = true)
        showMessage = 0;    %display messages; mainly for debug;
        movingRange = 4;    %move away from orig for 4mm, mainly limited by the objective and the hole on the microscope; stepsLimit
    end
    
    methods
        function Proscan = Proscan(ComPort)
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
                    Proscan.stageObj = [];
                    return;
                end
                
                for m = 1:size(a.AvailableSerialPorts,1)
                    COMport = cell2mat(a.AvailableSerialPorts(m));
                    obj=serial(COMport,'Terminator', {'CR','CR'},'BaudRate', 9600,'DataBits', 8,'InputBufferSize', 2048,'OutputBufferSize', 2048,'Timeout', 1.0);
                    fprintf('Open Proscan on %s port....please wait.....\n',COMport);
                    try                        
                        fopen(obj);
                        fprintf(obj, 'SERIAL');
                        sno= fscanf(obj, '%s\n');
                        if isempty(sno)
                            fprintf('Failed to connect ProScan on %s port!!!\n',COMport);
                            fclose(obj);
                        else
                            Proscan.stageObj = obj;
                            fprintf('ProScan stage is detected and connected on port %s!!\n',COMport);
                            break;
                        end
                    catch
                        continue;
                    end                    
                end
                if strcmp(obj.Status,'closed')
                    Proscan.stageObj = [];
                    fprintf('No ProScan has been detected....\n');
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
                fprintf(obj, 'SERIAL');
                sno= fscanf(obj, '%s\n');
                if isempty(sno)
                    fprintf('No ProScan stage is installed or connected on port %s!!\n',ComPort);
                    fclose(obj);
                    Proscan.stageObj = [];
                    return;
                else
                    fprintf('ProScan stage is detected and connected on port %s!!\n',ComPort);
                    Proscan.stageObj = obj;
                end
            end
            
            %% set to standard mode;
            flushinput(obj); %clean the com buffer;
            fprintf(obj, 'COMP,0');
            data = fscanf(obj, '%s\n');
            if ~strcmp(data,'0')
                disp('Cannot set the stage in standard mode! Please check!');
            end
            %%
            joystickEable(Proscan, 1); %enable joystick;
            fprintf('Prior stage (serial No. %s) is ready for use now......\n',sno);
            fprintf('Current position [%d %d]. One unit step is %2.2f um.........\n',Proscan.currentPosition(1:2), Proscan.stepSize/Proscan.stageStepResoltion);
        end
        function umPerStep = get.umPerStep(Proscan)
            umPerStep = GetumPerStep(Proscan);
        end
        function stepSize = get.stepSize(Proscan)
            stepSize = GetStepSize(Proscan);
        end
        function Proscan = set.stepSize(Proscan,newStepSize)
            Proscan.stepSize = SetStepSize(Proscan,newStepSize);
        end        
        function CurrentPosition = get.currentPosition(Proscan)
            CurrentPosition = GetCurrentPosition(Proscan);
        end
        function Proscan = set.currentPosition(Proscan,newCurrentPosition)
            Proscan.currentPosition = SetCurrentPosition(Proscan,newCurrentPosition);
        end
        function stageStepResoltion = get.stageStepResoltion(Proscan)
            stageStepResoltion = GetStageStepResoltion(Proscan);
        end
        function stageLimit = get.stageLimit(Proscan)
            stageLimit = GetStageLimit(Proscan);
        end
        function StepsOneMovement = get.stepsOneMovement(Proscan)
            StepsOneMovement = GetStepsOneMovement(Proscan);
        end
        function Proscan = set.stepsOneMovement(Proscan,newStepsOneMovement)
            Proscan.stepsOneMovement = SetStepsOneMovement(Proscan,newStepsOneMovement);
        end
        function motorMaxSpeed = get.motorMaxSpeed(Proscan)
            motorMaxSpeed = GetMotorMaxSpeed(Proscan);
        end
        function Proscan = set.motorMaxSpeed(Proscan,newMotorMaxSpeed)
            Proscan.motorMaxSpeed = SetMotorMaxSpeed(Proscan,newMotorMaxSpeed);
        end
        function motorAcceleration = get.motorAcceleration(Proscan)
            motorAcceleration = GetMotorAcceleration(Proscan);
        end
        function Proscan = set.motorAcceleration(Proscan,newMotorAcceleration)
            Proscan.motorAcceleration = SetMotorAcceleration(Proscan,newMotorAcceleration);
        end
        
        %% routine functions
        % Move once (defined in property: stepsOneMovement)
        function move(Proscan,direction,steps)  %direction = 'B', 'F', 'L', 'R' (back, forward, left, right in direction);            
            if nargin<2
                direction = 'B'; %backwards by default;
            else
                if ~ischar(direction)
                    disp('Please input in format of charater B, F, L or R. Now By default: B.');
                    direction = 'B';
                end
                direction=upper(direction);
                direction = direction(1);
            end
            if isempty(strfind('BFLR',direction))
                if Proscan.showMessage
                    disp('Please input in format of charater B, F, L or R. By default: B.');
                end
                direction = 'B';
            end
            if nargin<3
                if ~isempty(strfind('BF',direction))
                    steps = Proscan.stepsOneMovement(2);
                else
                    steps = Proscan.stepsOneMovement(1);
                end
            end
            flushinput(Proscan.stageObj); %clean the com buffer;
            cmd = sprintf('%s,%d',direction,round(steps));
            fprintf(Proscan.stageObj, cmd); %set to 1 microsteps per user unit step.
            data = fscanf(Proscan.stageObj, '%s\n');
            if Proscan.showMessage
                if ~strcmp(data,'R')
                    disp('Cannot move the stage correctly!');
                else
                    switch direction
                        case 'B'
                            direction = 'backward';
                        case 'F'
                            direction = 'forward';
                        case 'L'
                            direction = 'left';
                        case 'R'
                            direction = 'right';
                    end
                    fprintf('Stage has been moved %2.2fum to %s.\n', steps*(Proscan.stepSize/Proscan.stageStepResoltion), direction); % converted into um;
                end
            end
        end
        % move to absolute positions
        function newPos = moveTo(Proscan,position)            
            if length(position)<2
                if Proscan.showMessage
                    disp('Need to input position in format of [x y]!');
                end
                if nargout == 1
                    newPos = [];
                end
                return;
            end
            posx = round(position(1));
            posy = round(position(2));
            distance = sqrt(posx^2+posy^2)*(Proscan.stepSize/Proscan.stageStepResoltion)/1000;
            if distance >=Proscan.movingRange   %move away too much;
                if Proscan.showMessage
                    fprintf('Steps %2.2fmm is larger than the limit moving range %2.2fmm! Please reduce them!\n',distance, Proscan.movingRange);
                end
                if nargout == 1
                    newPos = [];
                end
                return;
            end
            curPos = Proscan.currentPosition;
            if curPos(1) == posx && curPos(2) == posy
                if Proscan.showMessage
                    disp('Distination is the same as current position!');
                end
                if nargout==1
                    newPos = [posx posy];
                end
                return;
            elseif  curPos(1) == posx
                cmd = sprintf('Gy,%d',posy);                
            elseif curPos(2) == posy
                cmd = sprintf('GX,%d',posx);
            else
                cmd = sprintf('G,%d,%d',posx,posy);
            end
            flushinput(Proscan.stageObj); %clean the com buffer;
            fprintf(Proscan.stageObj,cmd); %set to 1 microsteps per user unit step.
            data = fscanf(Proscan.stageObj, '%s\n'); 
            if strcmp(data,'R')
                if Proscan.showMessage
                    fprintf('Stage has been moved to [%d, %d] successfully...\n',posx,posy);
                end
                if nargout==1
                    newPos = [posx posy];
                end
            end
        end
        % enable joystick
        function joystickEable(Proscan, OnOff) 
            if OnOff
                flushinput(Proscan.stageObj); %clean the com buffer;
                fprintf(Proscan.stageObj, 'J');
                data = fscanf(Proscan.stageObj, '%s\n'); %in format [100,100];
                if strcmp(data,'0')
                    disp('Joystick is enabled now!');
                end
            else
                flushinput(Proscan.stageObj); %clean the com buffer;
                fprintf(Proscan.stageObj, 'H');
                data = fscanf(Proscan.stageObj, '%s\n'); %in format [100,100];
                if strcmp(data,'0') && Proscan.showMessage
                    disp('Joystick is disanabled now!');
                end
            end
        end    
        % emergency stop, immediately stop all movement and clear the command list.
        function emergencyStop(Proscan)
            flushinput(Proscan.stageObj); %clean the com buffer;
            fprintf(Proscan.stageObj, 'K');
            data = fscanf(Proscan.stageObj, '%s\n'); %in format [100,100];
            if strcmp(data,'R') && Proscan.showMessage
                disp('Stage has been stopped emmergently!');
            end
        end
        % Stop in a controlled manner to reduce the risk of losing position. The command list in queue will be emptied;
        function stop(Proscan)
            flushinput(Proscan.stageObj); %clean the com buffer;
            fprintf(Proscan.stageObj, 'I');
            data = fscanf(Proscan.stageObj, '%s\n'); %in format [100,100];
            if strcmp(data,'R')&& Proscan.showMessage
                disp('Stage has been stopped successfullys!');
            end
        end
        % relase COM obj
        function releaseProscan(Proscan)
            if ~isempty(ishandle(Proscan.stageObj))
                fclose(Proscan.stageObj);
                Proscan.stageObj = [];
                if Proscan.showMessage
                    disp('Stage objective has be released!');
                end
            end
        end
    end
    methods (Access = private)
        function umPerStep = GetumPerStep(Proscan) % calculate um movement every step;
            umPerStep = sprintf('%2.2fum',Proscan.stepSize/Proscan.stageStepResoltion);% in um;
        end
        function stepSize = SetStepSize(Proscan,newStepSize)
            if nargin<2
                newStepSize = Proscan.stageStepResoltion;
            else
                newStepSize = round(abs(newStepSize));
            end
            cmd = sprintf('SS,%d',newStepSize);
            flushinput(Proscan.stageObj); %clean the com buffer;            
            fprintf(Proscan.stageObj, cmd); %set to microsteps per user unit step.
            data = fscanf(Proscan.stageObj, '%s\n');            
            if ~strcmp(data,'0')
                if Proscan.showMessage
                    disp('Cannot set step size!');
                end
            else
                stepSize = newStepSize;
                if Proscan.showMessage
                    fprintf('Step size has been set to %d corresponding to %2.2fum\n',newStepSize, newStepSize/Proscan.stageStepResoltion);
                end
            end
        end
        function stepSize = GetStepSize(Proscan)             
            flushinput(Proscan.stageObj); %clean the com buffer;      
            fprintf(Proscan.stageObj, 'SS');
            pause(0.02);
            data = fscanf(Proscan.stageObj, '%s\n');
            stepSize = str2num(data);
        end
        function CurrentPosition = GetCurrentPosition(Proscan)
            flushinput(Proscan.stageObj); %clean the com buffer;            
            fprintf(Proscan.stageObj, 'P');
            data = fscanf(Proscan.stageObj, '%s\n'); %in format [100,100];
            CurrentPosition = str2num(data);
        end
        function  currentPosition = SetCurrentPosition(Proscan,newCurrentPosition)
            newPos = Proscan.MoveTo(newCurrentPosition);
            if ~isempty(newPos)
                 currentPosition = newPos;
            end
        end
        function stageStepResoltion = GetStageStepResoltion(Proscan)
            fprintf(Proscan.stageObj, 'STAGE');
            while 1
                data = fscanf(Proscan.stageObj, '%s\n'); 
                if ~isempty(strfind(data,'MICROSTEPS/MICRON=')) %check step/per um;
                    stageStepResoltion = str2double(data(19:end));
                    break;
                end
            end
            flushinput(Proscan.stageObj); %clean the com buffer;
            pause(0.04); %make sure the buffer is cleaned;
        end
        function stageLimit = GetStageLimit(Proscan)
            fprintf(Proscan.stageObj, 'STAGE');
            while 1
                data = fscanf(Proscan.stageObj, '%s\n');
                if ~isempty(strfind(data,'SIZE_X='))
                    stageLimit(1) = str2double(data(8:end-2));
                end
                if ~isempty(strfind(data,'SIZE_Y=')) %check y limit in mm
                    stageLimit(2) = str2double(data(8:end-2));
                    break;
                end
            end
            flushinput(Proscan.stageObj); %clean the com buffer;
            stageLimit = sprintf('[%d,%d]mm',stageLimit);
            pause(0.04); %make sure the buffer is cleaned;
        end
        function StepsOneMovement = GetStepsOneMovement(Proscan)
            flushinput(Proscan.stageObj); %clean the com buffer;
            fprintf(Proscan.stageObj, 'X');
            data = fscanf(Proscan.stageObj, '%s\n'); %in format [100,100];
            pause(0.02);
            StepsOneMovement = str2num(data);
            flushinput(Proscan.stageObj); %clean the com buffer;
        end
        function StepsOneMovement = SetStepsOneMovement(Proscan,newStepsOneMovement)
            if length(newStepsOneMovement)<1
                if Proscan.showMessage
                    disp('Please input in format [xu yu]! By default [100 100]');
                end
                newStepsOneMovement = [100 100];
            elseif length(newStepsOneMovement)<2
                if Proscan.showMessage
                    fprintf('Both direction will be set as the same, [%d %d]!\n',newStepsOneMovement,newStepsOneMovement);
                end
                newStepsOneMovement = [newStepsOneMovement(1) newStepsOneMovement(1)];
            end
            flushinput(Proscan.stageObj); %clean the com buffer;
            cmd = sprintf('X,%d,%d',newStepsOneMovement);
            fprintf(Proscan.stageObj, cmd);
            data = fscanf(Proscan.stageObj, '%s\n'); %in format [100,100];
            if strcmp(data,'0');
                StepsOneMovement = newStepsOneMovement;
            end
        end 
        function motorMaxSpeed = GetMotorMaxSpeed(Proscan)
            flushinput(Proscan.stageObj); %clean the com buffer;
            fprintf(Proscan.stageObj, 'SMS');
            data = fscanf(Proscan.stageObj, '%s\n'); 
            motorMaxSpeed = str2num(data);
            flushinput(Proscan.stageObj); %clean the com buffer;
        end
        function motorMaxSpeed = SetMotorMaxSpeed(Proscan,newMotorMaxSpeed) 
            newMotorMaxSpeed = round(abs(newMotorMaxSpeed));
            if newMotorMaxSpeed>200 || newMotorMaxSpeed == 0%range [1:200];
                if Proscan.showMessage
                    disp('Motor speed range [1 200],by default as 50!');
                end
                newMotorMaxSpeed = 50;
            end
            flushinput(Proscan.stageObj); %clean the com buffer;
            cmd = sprintf('SMS,%d',newMotorMaxSpeed);
            fprintf(Proscan.stageObj, cmd);
            data = fscanf(Proscan.stageObj, '%s\n');
            if strcmp(data,'0')
                motorMaxSpeed = newMotorMaxSpeed;
            else
                if Proscan.showMessage
                    disp('Failure to set motor speed param!');
                end
            end            
        end
        function motorAcceleration = GetMotorAcceleration(Proscan)
            flushinput(Proscan.stageObj); %clean the com buffer;
            fprintf(Proscan.stageObj, 'SAS');
            data = fscanf(Proscan.stageObj, '%s\n');             
            motorAcceleration = str2num(data);
            flushinput(Proscan.stageObj); %clean the com buffer;
        end
        function motorAcceleration = SetMotorAcceleration(Proscan,newMotorAcceleration)
            newMotorAcceleration = round(abs(newMotorAcceleration));
            if newMotorAcceleration>150 || newMotorAcceleration == 0%range [1:150];
                if Proscan.showMessage
                    disp('Motor acceleration range [1 150], by default as 50!');
                end
                newMotorAcceleration = 50;
            else
                flushinput(Proscan.stageObj); %clean the com buffer;
                cmd = sprintf('SAS,%d',newMotorAcceleration);
                fprintf(Proscan.stageObj, cmd);
                data = fscanf(Proscan.stageObj, '%s\n');
                if strcmp(data,'0')
                    motorAcceleration = newMotorAcceleration;
                else
                    if Proscan.showMessage
                        disp('Failure to set motor acceleration param!');
                    end
                end
            end
        end
    end
    methods (Static = true)
    end
end