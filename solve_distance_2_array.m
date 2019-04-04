clc,clear
gray_ref_mat = [ 0,4,12,8;
    1,5,13,9;
    3,7,15,11;
    2,6,14,10;];

distance_2_array = zeros(16,6);
count = zeros(16,1);
for x = 1:16
    for y = 1:16
        distance = biterr(gray_ref_mat(x),gray_ref_mat(y),4);
        if distance == 2
            count(x) = count(x) + 1;
            distance_2_array(x,count(x)) = y;
        end
    end
end
distance_2_array
sum(sum(distance_2_array));

distance_2_array_copy = zeros(16,3);
count = zeros(16,1);
for x = 1:16
    for col = 1:6
        y = distance_2_array(x,col);
        temp_y = length(find(reshape(distance_2_array_copy,16*3,1) == y));
        temp_x = length(find(reshape(distance_2_array_copy,16*3,1) == x));
        if count(x)< 3 && temp_y < 3
            count(x) = count(x) + 1;
            distance_2_array_copy(x,count(x)) = y;
        else
            if count(y)<3 && temp_x < 3
                count(y) = count(y) + 1;
                distance_2_array_copy(y,count(y)) = x;
            end
        end
        
                
%         if count(x)<3 && ~ismember(y,distance_2_array_copy(x,:)) && ~ismember(x,distance_2_array_copy(y,:))
%             count(x) = count(x) + 1;
%             distance_2_array_copy(x,count(x)) = y;
%         else
%             if count(y)<3 && ~ismember(y,distance_2_array_copy(x,:)) && ~ismember(x,distance_2_array_copy(y,:))
%                 count(y) = count(y) + 1;
%                 distance_2_array_copy(y,count(y)) = x;
%             end
%         end
    end
end
distance_2_array = distance_2_array_copy

