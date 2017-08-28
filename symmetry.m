%
function [ binary_spindle, bwS, maskedImg_spindle, s1, bwDNA ] = symmetry( imgFile, AreaThreshold )

%% Draw line through spindle

% Read the spindle image only (DNA = 1, Spindle = 2)
% Read the DNA or spindle images from the RGB image
imgDNA = imgFile(:,:,1);
imgSpindle = imgFile(:,:,2);

% Pass the grayscale image of the DNA to the mask function
[ ~, bwD, ss, ~ ] = mask( imgDNA, AreaThreshold );

% Pass the grayscale image of the spindle to the mask function
[ binary_spindle, bwS, s1, maskedImg_spindle ] = mask( imgSpindle, AreaThreshold );


if isempty(ss) == 0
    
    [index, xcoords1, ycoords1, bwDNA] = drawAngledLine(bwD, ss(1).Centroid, ss(1).MajorAxisLength/2, ss(1).Orientation, 'horizontal');
else
    return
end
    
    % Increase the thickness of the line
    bwzero = false(size(bwS));
    bwzero(index) = 1;  
    bwzero = imdilate(bwzero,  ones(5,5));
    bwS(bwzero) = 0;
    
    % Increase the thickness of the line
    bwzero_DNA = false(size(bwDNA));
    bwzero_DNA(index) = 1;  
    bwzero_DNA = imdilate(bwzero_DNA,  ones(5,5));
    bwDNA(bwzero_DNA) = 0;
%bwS(index) = 0;
%figure, imshow(bwS);
%line(xcoords1, ycoords1);

end
 
     
