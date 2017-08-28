% s
function [ t, maskedImg_crop, bw3, grayImage, bw5 ] = spindle_gs( img, maskedImg, s, k )
    
    % Size of image
    [rows, cols] = size(img);
    
    % Crop the masked image
    maskedImg_crop = imcrop(maskedImg, s(k).BoundingBox);
    
    % Store bounding box array. [x_corner, y_corner, x_width, y_width]
    box = s(k).BoundingBox;
    
    % Expand the bounding box by 20% while keeping the centre the same
    % x_corner
    box(1) = box(1) - 0.2*box(3);
    
    % y_corner
    box(2) = box(2) - 0.2*box(4);
    
    % Increase x_width
    box(3) = 1.4*box(3); % x2 = 2*(0.4w) + w = 1.4w
    
    % Increase y_width
    box(4) = 1.4*box(4); % x2 = 2*(0.4h) + h = 1.4h
    
    % Condition used to stop the bounding box exceeding matrix dimensions
    % x_width + x_corner must not be greater than cols
    if box(1) + box(3) > cols
        
        % Changing the x_width to stop it exceeding the no. of cols in the
        % matrix
        box(3) = cols - box(1);
        
    % y_corner + y_length must not be greater than cols
    elseif box(2) + box(4) > rows
        
        % Changing the y_width to stop it exceeding the no. of rows in the
        % matrix
        box(4) = rows - box(2);
    end
    
    % Crop the original grayscale image using the expanded bounding box
    grayImage = imcrop( img, box ); 
    
    % Compute a level value to convert an image to black and white
    level_two = graythresh(maskedImg_crop);
    
    % Convert the cropped grayscale image into black and white
    bw3 = im2bw(maskedImg_crop,level_two);
    
    % Find the image features of the black and white file
    t = regionprops(bw3,'Area','BoundingBox','Orientation', 'MajorAxisLength', ...
    'MinorAxisLength', 'EulerNumber', 'Extent', 'Perimeter', 'Solidity', 'Eccentricity', ...
    'Centroid');
       
    % Compute a level value to convert an image to black and white
    level_three = graythresh(grayImage);
    
    % Convert the cropped grayscale image into black and white
    bw5 = im2bw(grayImage, level_three); 
    
end