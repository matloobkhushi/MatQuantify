function [ bw, bw2, s, maskedImg ] = mask( imgFile, AreaThreshold ) 

    % Computes a global threshold for conversion to binary
    level = graythresh(imgFile);
    
    % Convert to binary (black & white)
    bw = im2bw(imgFile,level);
    
    % Break apart small cellular noise
    bw2 = bwdist(~bw) <= 1;
    
    % Complement of the binary image
    bw2 = ~bw2;
   
    %%   remove objects within 5% of image border and border touching objects
    sf = size(bw2);
    
    % Find 3% of the number of pixels in the horizontal direction of the
    % image
    border = round(sf(1)*0.03);
    
    % Create an N-by-N matrix of logical zeros
    mask = false(sf);
    
    % Give a value of 1 to every value inside the border. Pixels that have
    % coordinates less than 51 (e.g. (1,1)) will remain equal to zero
    mask(border:end-border, border:end-border) = 1;
   
    % Assign a value of 1 to every pixel inside the mask
    bw2(~mask) = 1;
    
    % Remove objects touching border
    bw2 = imclearborder(bw2);
    
    %  Remove all objects in the image text.png containing fewer than
    %  'AreaThreshold' pixels.
    bw2 = bwareaopen(bw2, AreaThreshold);    
    
    %% Mask the original grayscale images by overlaying the complemented binary
    % image on top to convert the background to black (zero value) and leave
    % the spindle pixels with their original grayscale values
    imgFile(~bw2) = 0;
    
    % Set the imgFile equal to the maskedImg
    maskedImg = imgFile;

    % Calculate properties of the binary image
    
    % Label connected components in 2-D binary image.
    % [L, num] = bwlabel(bw2);
    s = regionprops(bw2,'Area', 'ConvexArea','BoundingBox','Orientation', 'MajorAxisLength', 'MinorAxisLength',  ...
            'EulerNumber', 'Perimeter', 'Solidity', 'Eccentricity', 'Centroid');
end