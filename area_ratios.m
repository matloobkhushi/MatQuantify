% % Calculate the ratio between the two sections of the mitotic spindles 
% Select the two highest area values in the image and divide one by the
% other to get a ratio
function [ area_ratio ] = area_ratios(bwS_cropped)

%figure, imshow(bwS_cropped);
w = regionprops( bwS_cropped,'Area' );

% Preallocate a matrix to store the two areas and sort it in descending
% order
areas = sort([w.Area],'descend');

if length(areas) > 1
    
    % Calculate ratio of two highest areas
    area_ratio = areas(1)/areas(2);
else
    
    % If the image contains two spindles, calculate the 
    area_ratio = NaN;
end
end