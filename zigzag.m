function [zigzag_indicator,zigzag_loc,zigzag_descriptor] = zigzag(data)
%%
zigzag_index = zeros(height(data),1);

for i = 2:height(data)
    if gt(data.high(i),data.high(i-1)) && gt(data.low(i),data.low(i-1))
        zigzag_index(i) = 1;
    elseif lt(data.high(i),data.high(i-1)) && lt(data.low(i),data.low(i-1))
        zigzag_index(i) = 2;
    else
        zigzag_index(i) = 3;
    end
end

for i = 2:height(data)-1
    if zigzag_index(i-1) == 1 && zigzag_index(i) == 3 && ...
            (zigzag_index(i+1) == 3 || zigzag_index(i+1) == 1)
        zigzag_index(i) = 1;
    elseif zigzag_index(i-1) == 2 && zigzag_index(i) == 3 && ...
            (zigzag_index(i+1) == 3 || zigzag_index(i+1) == 2)
        zigzag_index(i) = 2;
    end
end

for i = 3:height(data)-1
    if zigzag_index(i-2) == 1 && zigzag_index(i-1) == 3 && zigzag_index(i) == 2 && ...
            gt(max(data.high(i-2),data.high(i-1)),data.high(i-2))
        zigzag_index(i-1) = 1;
    elseif zigzag_index(i-2) == 2 && zigzag_index(i-1) == 3 && zigzag_index(i) == 1 && ...
            lt(min(data.low(i-2),data.low(i-1)),data.low(i-2))
        zigzag_index(i-1) = 2;
    end
end

m = 1;
for i=3:height(data)-1
    if ne(zigzag_index(i), zigzag_index(i-1))
        if zigzag_index(i-1) == 1
            zigzag_indicator(m,:) = [i-1 data.high(i-1)];
            m = m + 1;
        elseif zigzag_index(i-1) == 2
            zigzag_indicator(m,:) = [i-1 data.low(i-1)];
            m = m + 1;
        end
    end
end

% Last Line
if zigzag_index(end-1) == 1
    zigzag_indicator(m,:) = [height(data)-1 data.high(end-1)];
elseif zigzag_index(end-1) == 2
    zigzag_indicator(m,:) = [height(data)-1 data.low(end-1)];
end

% Determine Peaks(=1) and Troughs(=0)
zigzag_loc = NaN(height(zigzag_indicator),1);
for i=2:height(zigzag_indicator)
    if gt(zigzag_indicator(i-1,2),zigzag_indicator(i,2))
        zigzag_loc(i-1,1) = true;
    elseif lt(zigzag_indicator(i-1,2),zigzag_indicator(i,2))
        zigzag_loc(i-1,1) = false;
    end
end
if zigzag_loc(end-1,1) == false
    zigzag_loc(end,1) = 1;
elseif zigzag_loc(end-1,1) == true
    zigzag_loc(end,1) = 0;
end

%% TRIANGULATION
zigzag_descriptor = NaN(height(zigzag_indicator)-1,10);

for i = 1:height(zigzag_indicator)-1
    if zigzag_loc(i)==1
        zigzag_descriptor(i,1) = i;
        zigzag_descriptor(i,2) = zigzag_indicator(i+1,1);    %NE_x
        zigzag_descriptor(i,3) = zigzag_indicator(i,2);      %NE_y
        zigzag_descriptor(i,4) = zigzag_indicator(i+1,1);    %SE_x
        zigzag_descriptor(i,5) = zigzag_indicator(i+1,2);    %SE_y
        zigzag_descriptor(i,6) = zigzag_indicator(i,1);      %SW_x
        zigzag_descriptor(i,7) = zigzag_indicator(i+1,2);    %SW_y
        zigzag_descriptor(i,8) = zigzag_indicator(i,1);      %NW_x
        zigzag_descriptor(i,9) = zigzag_indicator(i,2);      %NW_y
        zigzag_descriptor(i,10) = abs(zigzag_indicator(i,2) - ... %Height
                                zigzag_indicator(i+1,2));                       
    elseif zigzag_loc(i)==0
        zigzag_descriptor(i,1) = i;
        zigzag_descriptor(i,2) = zigzag_indicator(i+1,1);    %NE_x
        zigzag_descriptor(i,3) = zigzag_indicator(i+1,2);    %NE_y
        zigzag_descriptor(i,4) = zigzag_indicator(i+1,1);    %SE_x
        zigzag_descriptor(i,5) = zigzag_indicator(i,2);      %SE_y
        zigzag_descriptor(i,6) = zigzag_indicator(i,1);      %SW_x
        zigzag_descriptor(i,7) = zigzag_indicator(i,2);      %SW_y
        zigzag_descriptor(i,8) = zigzag_indicator(i,1);      %NW_x
        zigzag_descriptor(i,9) = zigzag_indicator(i+1,2);    %NW_y
        zigzag_descriptor(i,10) = abs(zigzag_indicator(i+1,2) - ... %Height
                                zigzag_indicator(i,2));
    end
end


end