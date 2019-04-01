% optimize_rotation_angle.m
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
clear adjacent_count;


%% define the criterion 

% N_permutations = 1307674368000  %  = 15!
N_permutations = 1000000;

permutations_opt_filename = 'Permutations_opt.csv';
if exist(permutations_opt_filename,'file')
    permutations_opt = csvread(permutations_opt_filename);
	% get the M_opt of last run. 
	X = permutations_opt(1,:);
	M = 0;
	for point_A = 1:16
		for point_B = adjacent_array(point_A,:)
			if abs(X(point_A) - X(point_B)) > M
				M = abs(X(point_A) - X(point_B));
			end
		end
	end
	M_opt = M;
else
    permutations_opt = [];
	M_opt = 15;
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

    % first criterion : every distance of adjcant elements is smaller than M.
	M = 0;
	for point_A = 1:16
		for point_B = adjacent_array(point_A,:)
			if abs(X(point_A) - X(point_B)) > M
				M = abs(X(point_A) - X(point_B));
			end
		end
	end

% 	if M < M_opt
% 		M_opt = M;
%         dlmwrite(permutations_opt_filename,X);
% 	else
% 		if M == M_opt
% 			dlmwrite(permutations_opt_filename,X,'-append');
% 		end
% 	end
	
	if M < M_opt
		permutations_opt = X;
        M_opt = M;
    else
        if M == M_opt
			permutations_opt = [permutations_opt;X];
        end
    end
	
	
	% backup and waitbar update
	if mod(curr_num,10000) == 0
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




