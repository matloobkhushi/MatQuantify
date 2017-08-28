% Feature Extraction: 
% Assign directory and define variable names
% Loop through each image file in the directory
% Create binary images and then crop images
% Create grayscale masks to measure properties such as intensity
% Loop through each spindle and measure various properties

% Program: Automatic feature extraction from mitotic spindle images
% (grayscale format)
%
% bw3(10:10:end,:,:) = 0;
%bw3(:,10:10:end,:) = 0;
close all
% Objects less than this area will be removed
AreaThreshold = 25000;

% 24.8447 pixels = 1 micrometre
scale = 24.8447;

% Open a dialog box to select a folder
dirpath = uigetdir('B:\Process\Bioinformatics\mkhushi\MatSpindlemages\');

% List files in directory
files = dir(fullfile(dirpath,'*.tif'));

% Open file. 'w' flag opens file for writing and discards existing contents
dirname = strsplit(dirpath,'\');
resultFile = strcat('ResultDNACHC_', char(dirname(end)),'.csv');
fileID = fopen(resultFile,'w');

% Print the headers of the variables to the .txt file
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
    

    %% Create binary image and masked image
    [ bw, bw2, s, maskedImg ] = mask( imgFile, AreaThreshold );
    imshow(bw2);
    % Loop through each spindle
    for k = 1:length(s)
    
    % Image properties of cropped and rotated images
    [ t, maskedImg_crop, bw3, grayImage, bw5] ...
    = spindle_gs( imgFile, maskedImg, s, k );
    
    
    % Calculate coordinates for the major axis' intersection with the
    % perimeter of the image
%     xMajor=u.Centroid(1) + [-1 1]*(u.MajorAxisLength/2)*cosd(u.Orientation);
%     yMajor=u.Centroid(2) + [-1 1]*(u.MajorAxisLength/2)*sind(u.Orientation);
%     
%     % Calculate coordinates for the minor axis' intersection with the
%     % perimeter of the image
%     xMinor=u.Centroid(1) + [-1 1]*(u.MinorAxisLength/2)*sind(u.Orientation);
%     yMinor=u.Centroid(2) + [-1 1]*(u.MinorAxisLength/2)*cosd(u.Orientation);

    %% Other properties of the image
    
    % Calculate intensity of pixels
    intensity = sum(grayImage(:));
    
    % Calculate mean intensity
    meanIntensity = mean(grayImage(:));
    
    % Calculate median intensity
    medianIntensity = median(grayImage(:));
    
    % Calculate standard deviation of grayscale values
    stdImage = std(double(grayImage(:)));
    
    % Calculate compactness and store it in the matrix
    compact = (s(k).Area/s(k).Perimeter^2);
    
    % Calculate entropy of the grayscale image
    entrop = entropy(grayImage(:));

    %% Percent_density
    % Calculate percentage density (PD). Number of pixels that have a
    % greater intensity value than 90% of the maximum intensity value
    % divided by total area (pixels)
    % same intensity value as the max intensity value
    % Call percentageDensity function to calculate the count value
    [ counter ] = percentageDensity( maskedImg_crop );
    
    % Sometimes Area contains more than 1 element, so this function ensures
    % that we use the highest Area value which is the Area of the spindle
    if length([t.Area]) > 1    
        percentDensity = counter/max([t.Area]);
    else
        percentDensity = counter/(max(t.Area));
    end
    
    %% Displaying images
%     figure()
%     subplot(1,2,1);
%     imshow(maskedImg_crop,[]);
%     subplot(1,2,2);
%     bw3(10:10:end,:,:) = 0;
%     bw3(:,10:10:end,:) = 0;
%     imshow(bw3);
     %% Fractal dimension
    fractal = hausDim(bw3);

    %% Satellite objects
    [ count, sat ] = satellite(bw5, grayImage, fname);

%     %Plot images that have satellite objects
%     if count > 0;
%         
%         % Print the file name
%         disp(fname);
%         
%         % Display images
%         figure, subplot(1,2,1); imshow(grayImage,[]);
%         subplot(1,2,2); imshow(sat);
%         colormap default;
%         colorbar;
%     end
    
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





 












