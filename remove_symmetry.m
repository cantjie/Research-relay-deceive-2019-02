% remove_symmetry.m,
% after we get the optimal permutations by criterion M1/M2/(simplified)L1
% we should remove symmetric permutations before further analysis

clc,clear
tic;
permutations_opt_filename = 'Permutations_opt.csv';
permutations_opt = csvread(permutations_opt_filename);
permutations_opt_without_symmetry_filename = 'Perms_opt_without_symmetry.csv';


symmetric_idx = [];
for i = 1:length(permutations_opt)
	perm_a = permutations_opt(i,:);
	mat_a = reshape(perm_a,4,4);
	
	% counter-diagonal symmetric
	perm_a_s1 = perm_a;
	perm_a_s1(1) = perm_a(1);
	perm_a_s1(2) = perm_a(13);
	perm_a_s1(3) = perm_a(9);
	perm_a_s1(4) = perm_a(5);
	perm_a_s1(5) = perm_a(4);
	perm_a_s1(6) = perm_a(16);
	perm_a_s1(7) = perm_a(12);
	perm_a_s1(8) = perm_a(8);
	perm_a_s1(9) = perm_a(3);
	perm_a_s1(10) =perm_a(15);
	perm_a_s1(11) =perm_a(11);
	perm_a_s1(12) =perm_a(7);
	perm_a_s1(13) =perm_a(2);
	perm_a_s1(14) =perm_a(14);
	perm_a_s1(15) =perm_a(10);
	perm_a_s1(16) =perm_a(6);
	
	% clockwise 90 degree
	perm_a_s2(1) = perm_a(1);
	perm_a_s2(2) = perm_a(5);
	perm_a_s2(3) = perm_a(9);
	perm_a_s2(4) = perm_a(13);
	perm_a_s2(5) = perm_a(4);
	perm_a_s2(6) = perm_a(8);
	perm_a_s2(7) = perm_a(12);
	perm_a_s2(8) = perm_a(16);
	perm_a_s2(9) = perm_a(3);
	perm_a_s2(10) =perm_a(7);
	perm_a_s2(11) =perm_a(11);
	perm_a_s2(12) =perm_a(15);
	perm_a_s2(13) =perm_a(2);
	perm_a_s2(14) =perm_a(6);
	perm_a_s2(15) =perm_a(10);
	perm_a_s2(16) =perm_a(14);

	% clockwise 180 degree
	perm_a_s3(1) = perm_a(1);
	perm_a_s3(2) = perm_a(4);
	perm_a_s3(3) = perm_a(3);
	perm_a_s3(4) = perm_a(2);
	perm_a_s3(5) = perm_a(13);
	perm_a_s3(6) = perm_a(16);
	perm_a_s3(7) = perm_a(15);
	perm_a_s3(8) = perm_a(14);
	perm_a_s3(9) = perm_a(9);
	perm_a_s3(10) =perm_a(12);
	perm_a_s3(11) =perm_a(11);
	perm_a_s3(12) =perm_a(10);
	perm_a_s3(13) =perm_a(5);
	perm_a_s3(14) =perm_a(8);
	perm_a_s3(15) =perm_a(7);
	perm_a_s3(16) =perm_a(6);

	% clockwise 270 degree
	perm_a_s4(1) = perm_a(1);
	perm_a_s4(2) = perm_a(13);
	perm_a_s4(3) = perm_a(9);
	perm_a_s4(4) = perm_a(5);
	perm_a_s4(5) = perm_a(2);
	perm_a_s4(6) = perm_a(14);
	perm_a_s4(7) = perm_a(10);
	perm_a_s4(8) = perm_a(6);
	perm_a_s4(9) = perm_a(3);
	perm_a_s4(10) =perm_a(15);
	perm_a_s4(11) =perm_a(11);
	perm_a_s4(12) =perm_a(7);
	perm_a_s4(13) =perm_a(4);
	perm_a_s4(14) =perm_a(16);
	perm_a_s4(15) =perm_a(12);
	perm_a_s4(16) =perm_a(8);

	% vertical mirror
	perm_a_s5(1) = perm_a(1);
	perm_a_s5(2) = perm_a(2);
	perm_a_s5(3) = perm_a(3);
	perm_a_s5(4) = perm_a(4);
	perm_a_s5(5) = perm_a(13);
	perm_a_s5(6) = perm_a(14);
	perm_a_s5(7) = perm_a(15);
	perm_a_s5(8) = perm_a(16);
	perm_a_s5(9) = perm_a(9);
	perm_a_s5(10) =perm_a(10);
	perm_a_s5(11) =perm_a(11);
	perm_a_s5(12) =perm_a(12);
	perm_a_s5(13) =perm_a(5);
	perm_a_s5(14) =perm_a(6);
	perm_a_s5(15) =perm_a(7);
	perm_a_s5(16) =perm_a(8);

	% horizontal mirror
	perm_a_s6(1) = perm_a(1);
	perm_a_s6(2) = perm_a(4);
	perm_a_s6(3) = perm_a(3);
	perm_a_s6(4) = perm_a(2);
	perm_a_s6(5) = perm_a(5);
	perm_a_s6(6) = perm_a(8);
	perm_a_s6(7) = perm_a(7);
	perm_a_s6(8) = perm_a(6);
	perm_a_s6(9) = perm_a(9);
	perm_a_s6(10) =perm_a(12);
	perm_a_s6(11) =perm_a(11);
	perm_a_s6(12) =perm_a(10);
	perm_a_s6(13) =perm_a(13);
	perm_a_s6(14) =perm_a(16);
	perm_a_s6(15) =perm_a(15);
	perm_a_s6(16) =perm_a(14);


	for j = i + 1 : length(permutations_opt)
		perm_b = permutations_opt(j,:);
		
		% transpose symmetric
		mat_b = reshape(perm_b,4,4);
		if mat_a' == mat_b
			symmetric_idx = [symmetric_idx,j];
		end
		
		if perm_a_s1 == perm_b
			symmetric_idx = [symmetric_idx,j];
		end
		if perm_a_s2 == perm_b
			symmetric_idx = [symmetric_idx,j];
		end
		if perm_a_s3 == perm_b
			symmetric_idx = [symmetric_idx,j];
		end
		if perm_a_s4 == perm_b
			symmetric_idx = [symmetric_idx,j];
		end
		if perm_a_s5 == perm_b
			symmetric_idx = [symmetric_idx,j];
		end
		if perm_a_s6 == perm_b
			symmetric_idx = [symmetric_idx,j];
		end
	end
end
symmetric_idx = unique(symmetric_idx);
permutations_opt(symmetric_idx,:) = [];
csvwrite(permutations_opt_without_symmetry_filename, permutations_opt);
toc
