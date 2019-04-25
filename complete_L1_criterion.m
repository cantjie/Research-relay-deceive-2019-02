% complete_L1_criterion.m
clc,clear
permutations_opt_filename = 'Perms_opt_without_symmetry.csv';
permutations_after_L1_without_symmetry_filename = 'Perms_opt_after_L1_without_symmetry.csv';
permutations_opt = csvread(permutations_opt_filename);

distance_3_array = csvread('distance_3_array.csv');
distance_4_array = csvread('distance_4_array.csv');

L1_3_opt = 0;
L1_4_opt = 0;
L1_3_cur = 0;
L1_4_cur = 0;
count = 0;
perms_opt_idx = [];
for idx = 1:length(permutations_opt)
	X = permutations_opt(idx,:);
	L1_3_cur = min(min(abs([X;X]' - X(distance_3_array(1:16,:)))));
	L1_4_cur = min(abs(X - X(distance_4_array(1:16,:))));
	if L1_3_cur > L1_3_opt 
		L1_3_opt = L1_3_cur;
		perms_opt_idx = [idx];
	else
		if L1_3_cur == L1_3_opt	
			if L1_4_cur > L1_4_opt
				L1_4_opt = L1_4_cur;
				perms_opt_idx = [idx];
			else
				if L1_4_cur == L1_4_opt
					perms_opt_idx = [perms_opt_idx,idx];
				end
			end
		end	

	end
end
perms_opt = permutations_opt(perms_opt_idx,:);
csvwrite(permutations_after_L1_without_symmetry_filename,perms_opt);