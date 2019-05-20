% optimize_rotation_angle.m
% Attention! This file is only used to produce adjacent array. As for the
% original purpose, due to the performance of matlab, I decided to
% implement it by C. So this file is actually abandoned.

% purpose: to optimize the mapping from bits(symbol)to rotation angle.
% To make the adjacent symbols(hamming distance = 1) have the least
% difference.
%
% version 1, created at 2019/03/27, author:Cantjie(cantjie@163.com)

clc,clear

% being used to calculate the distance of two point (Hamming distance)
gray_ref_mat = [ 0,4,12,8;
    1,5,13,9;
    3,7,15,11;
    2,6,14,10;];

%% find the adjacent array 
%((index in X) => [{index of adjacent point in X}])

adjacent_array = zeros(16,4);
adjacent_count = zeros(16,1);
for x = 1:16
    for y = 1:16
        distance = biterr(gray_ref_mat(x),gray_ref_mat(y),4);
        if distance == 1
            adjacent_count(x) = adjacent_count(x) + 1;
            adjacent_array(x,adjacent_count(x)) = y;
        end
    end
end

adjacent_array_copy = zeros(16,2);
adjacent_count = zeros(16,1);
for x = 1:16
    for col =1:4
        y = adjacent_array(x,col);
        if adjacent_count(x) < 2 && ~ismember(y,adjacent_array_copy(x,:)) && ~ismember(x,adjacent_array_copy(y,:))
            adjacent_count(x) = adjacent_count(x) + 1;
            adjacent_array_copy(x,adjacent_count(x)) = y;
        else 
            if adjacent_count(y) < 2 &&  ~ismember(y,adjacent_array_copy(x,:)) && ~ismember(x,adjacent_array_copy(y,:))
                adjacent_count(y) = adjacent_count(y) + 1;
                adjacent_array_copy(y,adjacent_count(y)) = x;
            end
        end
    end
end

adjacent_array = adjacent_array_copy;

clear adjacent_count;
clear adjacent_array_copy;

%% define the criterion 
tic
% N_permutations = 1307674368000  %  = 15!
N_permutations = 1e5;  % about 43s for 10000000 (1e7)  1.1h for 1e8, 1.1e4 for 1.3e12
M_criterion = 1;  % use 1st or 2nd M criterion.

permutations_opt_filename = 'Permutations_opt.csv';
if exist(permutations_opt_filename,'file')
    permutations_opt = csvread(permutations_opt_filename);
    % get the M_opt of last run. 
    if M_criterion == 1
        X = permutations_opt(1,:);
        M_opt = max(max(abs([X;X]' - X(adjacent_array(1:16,:)))))
    else
        if M_criterion == 2
            M_opt = sum(sum(abs([X;X]' - X(adjacent_array(1:16,:)))));
        end
    end
else
    permutations_opt = [];
    if M_criterion == 1
        M_opt = 15;
    else
        if M_criterion == 2
            M_opt = 9999999;
        end % end M_criterion == 2
    end % end M_criterion == 1
end

% get the current permutation of last run.
permutations_cur_filename = 'Permutations_cur.csv';
if exist(permutations_cur_filename,'file')
    X = csvread(permutations_cur_filename);
	X_except_fist = X(2:16);
else
	X_except_fist = 2:16;
	X = [1,X_except_fist];
end


h = waitbar(0);
for curr_num = 1: N_permutations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % first M criterion : every distance of adjcant elements is smaller than M.
% 	M = 0;
%     for point_A = 1:16
%         if abs(X(point_A) - X(adjacent_array(point_A,1))) > M
%             M = abs(X(point_A) - X(adjacent_array(point_A,1)));
%         end
%         if abs(X(point_A) - X(adjacent_array(point_A,2))) > M
%             M = abs(X(point_A) - X(adjacent_array(point_A,2)));
%         end
%         if M > M_opt
%             break;
%         end
%     end
    M = max(max(abs([X;X]' - X(adjacent_array(1:16,:)))));

    % end of first M criterion 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % second M criterion: sum distance of adjcant elements up to be M, find
    % the minmum M
%     M = sum(sum(abs([X;X]' - X(adjacent_array(1:16,:)))));
    
    % end of second M criterion.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    if M < M_opt
		permutations_opt = X;
        M_opt = M;
    else
        if M == M_opt
			permutations_opt = [permutations_opt;X];
        end
    end

    
% 	backup and waitbar update
	if mod(curr_num,1e5) == 0
		waitbar(curr_num/N_permutations,h);
 		% dlmwrite(permutations_cur_filename,X);
    end
	
	X_except_fist = NextPerm(X_except_fist);
	X = [1,X_except_fist];
	if X_except_fist == 0
		'all done'
		break;
	end
	
end

dlmwrite(permutations_cur_filename,X);
dlmwrite(permutations_opt_filename,permutations_opt);
toc


