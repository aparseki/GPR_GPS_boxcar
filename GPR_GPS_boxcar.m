function GPR_GPS_boxcar(inname,flen)
% GPR GPS boxcar 
% this fuction reads the MALA 'cor' file, applies a moving average filter
% to the elevations, then exports a smoothed cor file and a KML. This
% requires the mapping toolbox of MATLAB to produce the KML. Also produces
% a figure (just to screen, not saved) showing the input data BLUE and
% smoothed result RED to evaluate the effectiveness of the smoothing.

% input
% inname = the name of the datafile without the suffix, eg: 'DAT_0003_A1'
% flen   = length of the boxcar filter, suggest '10'

% execute as, for example
% GPR_GPS_boxcar('DAT_0003_A1',10);


% Load the COR data
[v1,v2,v3,lat,lon,alt] = loadcor([inname '.cor']);

if length(lat)>flen+1; %check to make sure there are enough data to do smoothing
    
    for i = 1:length(lat)-1
        dist(i) = (sqrt(((lat(i)-lat(i+1))^2)+((lon(i)-lon(i+1))^2))); %euclidian distance
    end
    dist = cumsum(dist);
    dist = [dist dist(end)]; %calculate a "distance along the line" vector
    

    
    %% Moving average calcluation
    
    for i = 1:length(alt)-flen
        alt_sm(i) = mean(alt(i:i+flen));
    end
    
    alt_sm = [ones(1,flen/2).*alt_sm(1) alt_sm ones(1,flen/2).*alt_sm(end)]';
    
    %% plotting
    plot(dist,alt); hold on %plot raw data
    plot(dist,alt_sm,'r','linewidth',2) %plot smoothed data
    legend('raw','filtered')
    
    %% Write new COR datafile
    fid = fopen([pwd '/' inname '_smooth.cor'],'wt');
 
    v2 = cell2mat(v2); %convert cells to matrices for writing to TXT/cor
    v3 = cell2mat(v3);
    
    for i= 1:length(alt) %produce the TXT/cor output
    fprintf(fid,'%d %s %s %0.9f %s %0.9f %s %0.5f %s %d',v1(i),v2(i,:),v3(i,:),lat(i),'N',lon(i),'W',alt_sm(i),'M',2);
    fprintf(fid,'\n');
    end
    
    fclose(fid);
end
%% Write KML

kmlwrite([inname],lat,-lon)
end

%% ==== only embedded function below here ====

%% function to load the MalaGPR '*.cor' file

function [VarName1, VarName2, VarName3, VarName4,VarName6,VarName8] = loadcor(filename)

%% Initialize variables.
delimiter = '\t';
if nargin<=2
    startRow = 1;
    endRow = inf;
end

formatSpec = '%f%s%s%f%s%f%s%f%s%f%[^\n\r]';

%% Open the text file.
fileID = fopen(filename,'r');

%% Read columns of data according to format string.
dataArray = textscan(fileID, formatSpec, endRow(1)-startRow(1)+1, 'Delimiter', delimiter, 'HeaderLines', startRow(1)-1, 'ReturnOnError', false);
for block=2:length(startRow)
    frewind(fileID);
    dataArrayBlock = textscan(fileID, formatSpec, endRow(block)-startRow(block)+1, 'Delimiter', delimiter, 'HeaderLines', startRow(block)-1, 'ReturnOnError', false);
    for col=1:length(dataArray)
        dataArray{col} = [dataArray{col};dataArrayBlock{col}];
    end
end

%% Close the text file.
fclose(fileID);
%% Allocate imported array to column variable names
VarName1 = dataArray{:, 1};
VarName2 = dataArray{:, 2};
VarName3 = dataArray{:, 3};
VarName4 = dataArray{:, 4};
N = dataArray{:, 5};
VarName6 = dataArray{:, 6};
W = dataArray{:, 7};
VarName8 = dataArray{:, 8};
M = dataArray{:, 9};
VarName10 = dataArray{:, 10};
end
