%% Percent_density
% Initialise a variable to store the number of pixels that share the
% same intensity value as the max intensity value
function [ count ] = percentageDensity( maskedImg_crop )
    
    % initialize count variable
    count = 0;
    
    % Highest intensity in grayscale image
    max_intensity = max(maskedImg_crop(:));
    
    % Loop through matrix
    for rrr = 1:size(maskedImg_crop,1)
        for ccc = 1:size(maskedImg_crop,2)
            
            % Check if the current element is greater than 90% of 
            % the maximum intensity value
            if maskedImg_crop(rrr,ccc) >= (0.9*max_intensity)
                
                % Count number of pixels higher than 90% of the maximum
                % intensity
                count = count + 1;

            end
        end
    end
end
    