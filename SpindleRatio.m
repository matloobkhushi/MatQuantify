%
% function [ binary_spindle, bwS, maskedImg_spindle, s1, bwDNA ] = symmetry( imgFile, AreaThreshold )

%% Draw line through DNA to cut the spindle into two parts in the direction of DNA
close all;
AreaThreshold = 25000;
dirpath = 'B:\Process\Bioinformatics\mkhushi\MatSpindleImages\untreated\rgb';

files = dir(fullfile(dirpath,'*.tif'));


for i=1:numel(files)

    fname = files(i).name;
%     fname = 'HeLa-aCHC_MA568-RIF1_RbA5647-A488aTub-CHCkd-311014-07_R3D_D3D_PRJ_w435.tif';
    imgFile = imread( fullfile(dirpath, fname) );

% Red channel is DNA and green channel is spindle 

    imgDNA = imgFile(:,:,1);
    imgSpindle = imgFile(:,:,2);
    imSize = size(imgDNA);
    imTemp = false(imSize);
    imTemp = im2uint16(imTemp);
    % Pass the grayscale image of the DNA to the mask function
    

    % Pass the grayscale image of the spindle to the mask function
    [ binary_spindle, bwS, s1, maskedImg_spindle ] = mask( imgSpindle, AreaThreshold );
    try
        for j=1:length(s1)
%             disp(fname);
            rec = s1(j).BoundingBox;  
            %Rectangle around spindle, increase size, get DNA within this spindle
            x = round(rec(1) - 0.2*rec(3));  % xmin
            if x < 1 
                x = 1;
            end
            y  = round(rec(2) - 0.2*rec(4));   % ymin
            if y < 1
                y = 1;
            end
            w = round(1.4*rec(3)); % x2 = 2*(0.4w) + w = 1.4w       % increase width
%             colnos = x+w;
            if w > imSize(2)
                w = imSize(2);
            end
            h = round(1.4*rec(4)); % x2 = 2*(0.4h) + h = 1.4h        % Increase height
            % rownos = y + h;
            if h > imSize(1) 
                h = imSize(1);
            end
            bwSingleSpindle = imcrop(bwS, [x, y, w, h]);
            imDNA = imcrop(imgDNA, [x, y, w, h]);
            %imDNA = imgDNA(y:rownos, x:colnos);
            %imTemp(y:rownos, x:colnos) = imDNA;
            
            bwDNA = im2bw(imDNA,graythresh(imgDNA)); bwDNA = bwareaopen(bwDNA, AreaThreshold);
            ss = regionprops(bwDNA,'Orientation', 'MajorAxisLength', 'Centroid');
            [index, xcoords1, ycoords1, bwDNA] = drawAngledLine(bwDNA, ss(1).Centroid, ss(1).MajorAxisLength/2, ss(1).Orientation, 'horizontal');
    
            bwzero = false(size(bwSingleSpindle));
            bwzero(index) = 1;  
            bwzero = imdilate(bwzero,  ones(5,5));
            bwSingleSpindle(bwzero) = 0;
            
            st = regionprops(bwSingleSpindle, 'Area');
            if length(st)>1
                A = [st.Area];
                A = sort(A, 'descend');
                disp ( A(1)/A(2) );
                ctrl = cat(1, ctrl,A(1)/A(2));
            end
            %imshow(bwSingleSpindle); pause(0.5);
% 
%             imTemp = false(imSize);
%             imTemp = im2uint16(imTemp);
 
        end
    catch me
       disp(me); 
    end
    
    %if ~isempty(extractfield( ss, 'Orientation' )) || ~isempty(extractfield( s1, 'Orientation' ))
        %deg = (( abs(s1(1).Orientation) - 90) + ss(1).Orientation)/2;
    %else
    %end
%     if isempty(ss) == 0
%         [index, xcoords1, ycoords1, bwDNA] = drawAngledLine(bwD, ss(1).Centroid, ss(1).MajorAxisLength/2, ss(1).Orientation, 'horizontal');
%     else
%         return
%     end
% 
%         % Increase the thickness of the line
%         bwzero = false(size(bwS));
%         bwzero(index) = 1;  
%         bwzero = imdilate(bwzero,  ones(5,5));
%         bwS(bwzero) = 0;
% 
%         % Increase the thickness of the line
%         bwzero_DNA = false(size(bwDNA));
%         bwzero_DNA(index) = 1;  
%         bwzero_DNA = imdilate(bwzero_DNA,  ones(5,5));
%         bwDNA(bwzero_DNA) = 0;
    %bwS(index) = 0;
    % figure, imshow(binary_spindle);
    %line(xcoords1, ycoords1);

end

 
   