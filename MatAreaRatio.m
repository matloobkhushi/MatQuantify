% Feature Extraction: 
% Assign directory and define variable names
% Loop through each image file in the directory
% Create binary images and then crop images
% Create grayscale masks to measure properties such as intensity
% Loop through each spindle and measure various properties

%
% Code for RGB images only. Please DO NOT run this script with grayscale
% images
close all
% Objects less than this area will be removed
AreaThreshold = 25000;

% 24.8447 pixels = 1 micrometre
scale = 24.8447;

% Open a dialog box to select a folder
%folder_name = uigetdir('C:\Users\imraa\Documents\Internship - CMRI\Images');
folder_name = uigetdir('B:\Process\Bioinformatics\mkhushi\MatSpindleImages\');
% Directory of the images
directory = folder_name;

% List files in directory
files = dir(fullfile(directory,'*.tif'));

% Preallocate array for storing the number of satellite objects found in
% each image
sat_count = zeros(1,numel(files));

% Open file
fname = 'Results.csv';
fileID = fopen(fname,'w');

% Print the headers of the variables to the .txt file
fprintf(fileID,'%s,%s\r\n', 'Image', 'AreaRatio');
fclose(fileID);

% Open/Create error catch file for reading and writing, discard existing contents. 
fileID = fopen('error.txt', 'w+');
fclose(fileID);

% Lopp through each image file
for f = 1:numel(files)
    
    % Name of image file
    fname = files(f).name;

    try
        % Create a string that adds the path/folder to the image filename
        % Read the image file and the colormap
        imgFile = imread(strcat(directory,'\', fname));

        % Read the spindle image only (DNA = 1, Spindle = 2)
        img = imgFile(:,:,2);

        %% Create binary image and masked image
        %[ bw, bw2, s, maskedImg ] = mask( imgFile, AreaThreshold );
        [ bw, bwS, maskedImg, s, bwDNA ] = symmetry( imgFile, AreaThreshold);
        % imshow(bwDNA);
        % Loop through each spindle
        for k = 1:length(s)

            % Image properties of cropped and rotated images
            [ t, maskedImg_crop, bw3, grayImage, bw5, bwS_cropped, bwD_cropped ] = spindle( img, ...
            maskedImg, s, k, bwS, bwDNA );


            %% Analysing symmetry by comparing the area of each half of the spindle
            [ area_ratio ] = area_ratios( bwS_cropped );

            %% Gray-Level Co-Occurrence Matrix 

            % Create the GLCMs
            glcms = graycomatrix(grayImage);

            % Derive statistics from the GLCMs using the graycoprops function.
            stats = graycoprops(glcms,'Contrast Correlation Energy Homogeneity');

            %% Writing values to text file   
            % Output the value of the variables above in a row directly under the
            % corresponding variables
            fileID = fopen('Results.csv','a');
            fprintf(fileID,'%s,%8.4f\r\n', ...
                strcat(fname, '-', num2str(k)), area_ratio);
            fclose(fileID);    
        end
    catch me
        disp(me);
    end
end





 














