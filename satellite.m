%% Isolate satellite objects

function [ count, sat ] = satellite(bw, grayImage, fname )
    
    % Filter image, retaining only those objects with areas between 200 and
    % 1800
    bw = imclearborder(bw);
    sat = bwareafilt(bw,[200 1800]);
    %figure, imshow(satellite);
    % Remove objects touching border
    
    bw = bwareaopen(bw, 25000);
    %figure, imshow(bw);
    % Run regionprops for the binary image
    y = regionprops(bw,'Extent','Area','Centroid','BoundingBox');

    % Calculate its connected regions
    [ L, NUM ] = bwlabel(sat);

    % Run regionprops for the binary image containing the satellite objects
    v = regionprops(sat,'Extent','Area','Centroid');

    %% Distance between centroids
    % Calculate centroid of the binary image that contains the spindle
    % If no error occurs in try block, skip entire catch block and proceed
    % with function
    try
        y_Centroid = y.Centroid;
        
        % Preallocate an array to store euclidean distance values
        euclid_dist = zeros(1,length(v));
        
        % Intialise count variable
        count = 0;
        
        % Define the minimum extent value.
        % Returns a scalar that specifies the ratio of pixels in the region
        %to pixels in the total bounding box. Computed as the Area divided by the area of the bounding box.
        minExtent = 0.3;
        
        % Produce a logical array which gives true (1) to values that are greater
        % than minExtent
        keepMask = [v.Extent] > minExtent;
        
        % Looping through each object picked up by regionprops
        for i = 1:numel(v)
            
            % Find centroid of a satellite object
            v_Centroid = v(i).Centroid;
            
            % Calculate euclidean distance of satellite object and centroid of
            % spindle
            euclid_dist(i) = pdist([y_Centroid; v_Centroid],'euclidean');
            
            % Loop through each satellite object
            for z = 1:NUM
                
                % Store cropped image into a new variable
                img = grayImage;
                
                % Intensity condition
                img(L ~= z) = 0;
                
                % Calculate the sum of the satellite object's intensity values
                intensity_sum = sum(grayImage(:));
                
                % Satellite object must satisfy these three conditions to be
                % counted
                if euclid_dist(i) <= 250 && keepMask(i) == 1 && intensity_sum >= 50000;
                    
                    % Count satellite object
                    count = count + 1;
                else
                    
                    % If the object is not counted, change the value to zero
                    keepMask(i) = 0;
                end
                
            end
        end
        
        % Using imerode
        %     %v(i).Extent >= minExtent
        %     output = ismember(L, find(keepMask));
        %     se = strel('disk',3);
        %     bww = imerode(output,se);
        
    catch err
        
        % Output error message to file
        fileID = fopen('error.txt','a');
        fprintf(fileID, '%s \r\n %s', err.getReport('extended', 'hyperlinks','off'),fname);
        fclose(fileID);
        % If error occurs in try block, execute these commands in the catch
        % block
        msg = ('Error has occured with one or more files. Refer to error.txt in this folder to see the error and name of file(s). Please remove the image(s) from the folder if you do not wish to see this message again');
        disp(msg);
        count = 0;
        return
    end
    
    
end

%% Original code

%     %% Distance between centroids
%     % Calculate centroid of the binary image that contains the spindle
%     % If no error occurs in try block, skip entire catch block and proceed
%     % with function
%     try
%         y_Centroid = y.Centroid;
%         
%         % Preallocate an array to store euclidean distance values
%         euclid_dist = zeros(1,length(v));
%         
%         % Intialise count variable
%         count = 0;
%         
%         % Define the minimum extent value.
%         % Returns a scalar that specifies the ratio of pixels in the region
%         %to pixels in the total bounding box. Computed as the Area divided by the area of the bounding box.
%         minExtent = 0.3;
%         
%         % Produce a logical array which gives true (1) to values that are greater
%         % than minExtent
%         keepMask = [v.Extent] > minExtent;
%         
%         % Looping through each object picked up by regionprops
%         for i = 1:numel(v)
%             
%             % Find centroid of a satellite object
%             v_Centroid = v(i).Centroid;
%             
%             % Calculate euclidean distance of satellite object and centroid of
%             % spindle
%             euclid_dist(i) = pdist([y_Centroid; v_Centroid],'euclidean');
%             
%             % Loop through each satellite object
%             for z = 1:NUM
%                 
%                 % Store cropped image into a new variable
%                 img = grayImage;
%                 
%                 % Intensity condition
%                 img(L ~= z) = 0;
%                 
%                 % Calculate the sum of the satellite object's intensity values
%                 intensity_sum = sum(grayImage(:));
%                 
%                 % Satellite object must satisfy these three conditions to be
%                 % counted
%                 if euclid_dist(i) <= 200 && keepMask(i) == 1 && intensity_sum >= 50000;
%                     
%                     % Count satellite object
%                     count = count + 1;
%                 else
%                     
%                     % If the object is not counted, change the value to zero
%                     keepMask(i) = 0;
%                 end
%                 
%             end
%         end
%         
%         % Using imerode
%         %     %v(i).Extent >= minExtent
%         %     output = ismember(L, find(keepMask));
%         %     se = strel('disk',3);
%         %     bww = imerode(output,se);
%         
%     catch err
%         
%         % Output error message to file
%         fileID = fopen('error.txt','a');
%         fprintf(fileID, '%s \r\n %s', err.getReport('extended', 'hyperlinks','off'),fname);
%         fclose(fileID);
%         % If error occurs in try block, execute these commands in the catch
%         % block
%         msg = ('Error has occured with one or more files. Refer to error.txt in this folder to see the error and name of file(s). Please remove the image(s) from the folder if you do not wish to see this message again');
%         disp(msg);
%         count = 0;
%         return
%     end
%     
%     
% end

