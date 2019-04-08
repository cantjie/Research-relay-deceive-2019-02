% L2
clc,clear
permutations_opt_filename = 'Perms_opt_without_symmetry.csv';
permutations_opt_L2_filename = 'Perms_opt_L2.csv';
permutations_opt = csvread(permutations_opt_filename);
adjacent_array = csvread('adjacent_array.csv');
distance_2_array = csvread('distance_2_array.csv');


L2_opt = 0;
L2_cur = 0;
count = 0;
perms_opt_idx = [];

for idx = 1:length(permutations_opt)
    X = permutations_opt(idx,:);
    L2_cur = sum(sum(abs([X;X;X]'-X(distance_2_array(1:16,:)))));
    
    if L2_cur > L2_opt
        L2_opt = L2_cur;
		perms_opt_idx = [idx];
    end
    if L2_cur == L2_opt
		perms_opt_idx = [perms_opt_idx,idx];
	end
end

perms_opt = permutations_opt(perms_opt_idx,:);
csvwrite(permutations_opt_L2_filename,perms_opt);

% M1 = zeros(3648,1);
% M2 = zeros(3648,1);
% L1 = zeros(3648,1);
% 
% for idx = 1:length(permutations_opt)
% 	X = permutations_opt(idx,:);
% 	M1(idx) = max(max(abs([X;X]' - X(adjacent_array(1:16,:)))));
% 	M2(idx) = sum(sum(abs([X;X]' - X(adjacent_array(1:16,:)))));
% end