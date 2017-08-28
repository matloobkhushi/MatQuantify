% This script expect DNA on red and spindle on green channel
% Theref should be subfolders in the specified path representing groups to be analysed 

% MatSpindleDNA('B:\Process\Bioinformatics\mkhushi\MatSpindleImages\AllRGB');
function varargout = MatSpindleDNA (path)
% close all
% Objects less than this area will be removed
AreaThreshold = 25000;
 
d = dir(path);
isub = [d(:).isdir]; %# returns logical vector
nameFolds = {d(isub).name}';
nameFolds(ismember(nameFolds,{'.','..'})) = [];

for Fi=1:numel(nameFolds)           % sub-folders

    dirpath = strcat(path, '\',char(nameFolds(Fi)),'\');
    files =dir( fullfile( dirpath,'*.tif') );
    % Open file. 'w' flag opens file for writing and discards existing contents
    dirname = strsplit(dirpath,'\');
    dirname = char(dirname(end));

    resultFile = strcat('Results_ALL.csv');
    fileID = fopen(resultFile,'w');
    % Print the headers of the variables to the .csv file
    fprintf(fileID,'%s,%8s,%8s,%8s,%8s,%8s,%8s,%8s,%8s,%8s,%8s,%8s,%8s,%8s,%8s,%8s,%8s,%8s,%8s,%8s,%8s,%8s,%8s,%8s,%8s,%8s,%8s,%8s,%8s,%8s,%8s,%8s,%8s,%8s,%8s,%8s,%8s,%8s,%8s,s\r\n', ...
        'Image','Area', 'ConvexArea', 'Compactness', 'Eccentricity', ...
        'Entropy', 'EulerNumber', 'Fractal_Dim', ...
        'Intensity(mean)', 'Intensity(median)', 'Intensity(total)', 'x_width','y_width', ...
        'Orientation', 'PercentDensity', 'Perimeter', 'Solidity', 'STDev', 'Extent','Satellites', ...
        'DArea', 'DConvexArea', 'DCompactness', 'DEccentricity', ...
        'DEntropy', 'DEulerNumber', 'DFractal_Dim', ...
        'DIntensity(mean)', 'DIntensity(median)', 'DIntensity(total)', 'Dx_width','Dy_width', ...
        'DOrientation', 'DPercentDensity', 'DPerimeter', 'DSolidity', 'DSTDev', 'DExtent','DSatellites', ...
        'ImageType');
    fclose(fileID);


    % Loop through each image file
    for f = 1:numel(files)

        % Name of image file. Files is a struct array
        fname = files(f).name;
    %     fname = 'HeLa-aCHC_MA568-aEG5_RbA647-A499aTub_Luci-180814-05_R3D_D3D_PRJ_w523.tif';
        % Create a string that adds the path/folder to the image filename
        % Read the image file and the colormap
        imgFile = imread(strcat(dirpath,'\', fname));
        imgDNA = imgFile(:,:,1);  % DNA
        imgSpindle = imgFile(:,:,2); % Spindle        
        
        
        %% Create binary image and masked image
        [ bw, bw2, s, maskedImg ] = mask( imgSpindle, AreaThreshold );

        % Loop through each spindle
        for k = 1:length(s)
           
        % Spindle Properties Image properties of cropped and rotated images
        [t, maskedImg_crop, bw3, grayImage, bw5] = spindle_gs( imgSpindle, maskedImg, s, k );

        intensity = sum(maskedImg_crop(:));
        temp = maskedImg_crop(:); temp = temp(temp>0);  
        meanIntensity = mean(temp);             % MK changes
        medianIntensity = median(grayImage(:));
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

%% DNA Properties - measure bounding box from spindle and apply to DNA
        imgDNA = imcrop(imgDNA, s.BoundingBox);   %its cutting some DNA improve here 
        bwDNA = im2bw(imgDNA,graythresh(imgDNA));
        bwDNA = bwareaopen(bwDNA, AreaThreshold);    
        regionprops(bwDNA,'Area','Orientation', 'MajorAxisLength', 'MinorAxisLength', 'EulerNumber', 'Extent', 'Perimeter', 'Solidity', 'Eccentricity');
%         imshow(bwDNA);
        
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
end    




