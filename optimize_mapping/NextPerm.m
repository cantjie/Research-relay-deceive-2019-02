function next_perm = NextPerm(X)
% given a vector, find the next permutation.
% input:
%   X is a vector.
% output:
%   next_perm is a vector, is the next permutation of X. the rule of find
%   next can be found in https://www.cnblogs.com/bakari/archive/2012/08/02/2620826.html
% Example:
% X = [1,2,3,4];
% next_perm = [1,2,4,3];
% Version 1, created at 2019/03/31;

L = length(X);
next_perm = X;

if L <= 1
    next_perm = X;
    return ;
end

for replace_index_A = L - 1:-1:1
    if X(replace_index_A) < X(replace_index_A + 1);
        break;
    end
end

if replace_index_A == 1 && X(1) > X(2)
   next_perm = 0;
   return
end

for replace_index_B = L:-1:2
    if X(replace_index_A) < X(replace_index_B)
        % swap A and B.
        next_perm(replace_index_A) = X(replace_index_B);
        next_perm(replace_index_B) = X(replace_index_A);
        next_perm(replace_index_A + 1:L) = fliplr(next_perm(replace_index_A + 1:L));
        break;
    end
end