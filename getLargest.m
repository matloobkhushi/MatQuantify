% This function extract one or two largest objects in bw
% Example
% bw = getLargest(bw, 2)

function bw = getLargest(bw, count)
    s = regionprops(bw, 'Area');
    A = [s.Area];
    [L num] = bwlabel(bw);
     % [b1,i1] = max(A);
    [~,i1] = max(A);
    if (count==1 )
        bw(L ~= i1) = 0;
    else
        
        [~,i2] = max(A([1:i1-1,i1+1:end]));
        if i2>=i1, i2 = i2+1; end   % correcting index if it is after i1
         % B = [b1,b2]; % <-- The two largest elements of A
         % ix = [i1,i2]; % <-- Their corresponding indices
        
        bw(L ~= i1 & L ~= i2) = 0;
    end