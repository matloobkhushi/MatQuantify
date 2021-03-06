% MatQuantify automatically measures various properties from mitotic spindle or DNA images
% MatQuantify('/LocationOfRGBimages/', 'channelTobeProcessed', PixelArea)
% MatQuantify('B:\Process\Bioinformatics\mkhushi\MatSpindleImages\untreated\untreatedrgb', 'green', 25000);
function varargout = MatQuantify (dirpath, processchannel, AreaThreshold)
% close all
% Objects less than this area will be removed
 
if (strcmp(dirpath(end), filesep))
    dirpath = dirpath(1:end-1);         % remove last leading / or \
end
% List files in directory
files = dir(fullfile(dirpath,'*.tif'));

% Open file. 'w' flag opens file for writing and discards existing contents

dirname = strsplit(dirpath, filesep);
resultFile = strcat('Results_', char(dirname(end)),'_', processchannel,'.csv');
fileID = fopen(resultFile,'w');

% Print the headers of the variables to the .csv file
fprintf(fileID,'%s,%8s,%8s,%8s,%8s,%8s,%8s,%8s,%8s,%8s,%8s,%8s,%8s,%8s,%8s,%8s,%8s,%8s,%8s,%8s\r\n', ...
    'Image','Area', 'ConvexArea', 'Compactness', 'Eccentricity', ...
    'Entropy', 'EulerNumber', 'Fractal_Dim', ...
    'Intensity(mean)', 'Intensity(median)', 'Intensity(total)', 'x_width','y_width', ...
    'Orientation', 'PercentDensity', 'Perimeter', 'Solidity', 'STDev', 'Extent','Satellites');
fclose(fileID);

% Open/Create error catch file for reading and writing, discard existing contents. 
fileID = fopen('error.txt', 'w');
fclose(fileID);

% Loop through each image file
for f = 1:numel(files)
    
    % Name of image file. Files is a struct array
    fname = files(f).name;
%     fname = 'HeLa-aCHC_MA568-aEG5_RbA647-A499aTub_Luci-180814-05_R3D_D3D_PRJ_w523.tif';
    % Create a string that adds the path/folder to the image filename
    % Read the image file and the colormap
    imgFile = imread(strcat(dirpath,'\', fname));
    processchannel = lower(processchannel);
    
   if(ndims(imgFile)==3)                    %if the image is not single channel
        if(strcmp(processchannel,'red'))
            imgFile = imgFile(:,:,1);  
        elseif (strcmp(processchannel,'green'))
            imgFile = imgFile(:,:,2); 
        else
            imgFile = imgFile(:,:,3); 
        end
   end
    


    %% Create binary image and masked image
    % bw is simple binary form after apply Otsu 
    % bw2 is cleaned bw after apply threshold removing near border objects
    [ bw, bw2, s, maskedImg ] = mask( imgFile, AreaThreshold );
  
%% write segmented mask to a file.
    % imwrite(bw2, strcat('images/', fname, '.jpg'));
%% Loop through each spindle
    for k = 1:length(s)
    
    % Image properties of cropped and rotated images
    [t, maskedImg_crop, bw3, grayImage, bw5] = spindle_gs( imgFile, maskedImg, s, k );
    
    
    intensity = sum(maskedImg_crop(:));
    temp = maskedImg_crop(:); temp = temp(temp>0);  
    meanIntensity = mean(temp);             % MK changes
    medianIntensity = median(temp);
    stdImage = std(double(temp));    
    compact = (s(k).Area/s(k).Perimeter^2);     % compactness
    entrop = entropy(temp);
    [ counter ] = percentageDensity( maskedImg_crop );    
    % Sometimes Area contains more than 1 element, so this function ensures
    % that we use the highest Area value which is the Area of the spindle
    if length([t.Area]) > 1    
        percentDensity = counter/max([t.Area]);
    else
        percentDensity = counter/(max(t.Area));
    end

    fractal = hausDim(bw3);
     %% Satellite objects
    [ count, sat ] = satellite(bw5, grayImage, fname);


    %% Writing values to text file   
    % Output the value of the variables above in a row directly under the
    % corresponding variables
    fileID = fopen(resultFile,'a');
    fprintf(fileID,'%s,%8.4f,%8.4f,%8.4f,%8.4f,%8.4f,%8.4f,%8.4f,%8.4f,%8.4f,%8.4f,%8.4f,%8.4f,%8.4f,%8.4f,%8.4f,%8.4f,%8.4f,%8.4f,%8.4f\r\n', ...
        strcat(fname, '-', num2str(k)), s(k).Area, s(k).ConvexArea, compact, ...
        s(k).Eccentricity, entrop, ...
        s(k).EulerNumber, fractal, meanIntensity, medianIntensity, ...
        intensity, s(k).MajorAxisLength, s(k).MinorAxisLength, ...
        s(k).Orientation, percentDensity, s(k).Perimeter, s(k).Solidity, stdImage, ...
        t(1).Extent, count );
    fclose(fileID);    
    
    end
end





 












