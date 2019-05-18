% min_var.m 
% to find permutations whose variance of differences of adjacent array
clc,clear

permutations_opt_without_symmetry_filename = 'Perms_opt_without_symmetry.csv';
adjacent_array_filename = 'adjacent_array.csv';
permutations_opt_min_var_filename = 'Perms_opt_min_var.csv';

perms_opt = csvread(permutations_opt_without_symmetry_filename);
adjacent_array = csvread(adjacent_array_filename);

difference = zeros(32,1);
D_opt = 99;
D_cur = 0;
count = 0;
perms_opt_idx = [];
differences = [];


% calculate variance of difference and choose the smaller one
for idx = 1:length(perms_opt)
	count = 0;
	perm_cur = perms_opt(idx,:);
	for i = 1:16
		count = count + 1;
		difference(count) = abs(perm_cur(i) - perm_cur(adjacent_array(i,1)));
		count = count + 1;
		difference(count) = abs(perm_cur(i) - perm_cur(adjacent_array(i,2)));
	end	
	D_cur = var(difference);
	
	if D_cur < D_opt
		D_opt = D_cur;
		perms_opt_idx = [idx];
		differences = [difference];
	end
	if D_cur == D_opt
		perms_opt_idx = [perms_opt_idx,idx];
		differences = [differences,difference];
	end
end

perms_opt = perms_opt(perms_opt_idx,:);
csvwrite(permutations_opt_min_var_filename,perms_opt);

% length(find(differences(:,idx) == 1));
% todo