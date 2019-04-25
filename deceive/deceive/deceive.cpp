#include "pch.h"
#include <iostream>
#include <string.h>
#include <time.h>
//#define PERM_OPT_FILE "D:\\program\\matlabWorkspace\\research_2019_02\\deceive\\Permutations_opt.csv"
//#define PERM_CUR_FILE "D:\\program\\matlabWorkspace\\research_2019_02\\deceive\\Permutations_cur.csv"
//#define CRITERION_OPT_FILE "D:\\program\\matlabWorkspace\\research_2019_02\\deceive\\Criterion_cur.csv"
#define PERM_OPT_FILE "Permutations_opt.csv"
#define PERM_CUR_FILE "Permutations_cur.csv"
#define CRITERION_OPT_FILE "Criterion_cur.csv"

typedef struct Permutation
{
	short perm[16];
	struct Permutation* next;
}PermutationLink;
//PermutationLink permutations_opt;

short G_perm[16] = { 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16 };
short G_adjacent_array[16][2] = {
	{1,3},
	{2,5},
	{3,6},
	{7,15},
	{0,5},
	{6,9},
	{7,10},
	{4,11},
	{4,9},
	{10,13},
	{11,14},
	{8,15},
	{0,8},
	{1,12},
	{2,13},
	{12,14}
};
short G_distance_2_array[16][3] = {
	{2,5,7},
	{3,4,6},
	{5,7,10},
	{4,6,11},
	{6,9,11},
	{7,8,10},
	{9,11,14},
	{8,10,15},
	{0,13,15},
	{1,12,14},
	{8,13,15},
	{9,12,14},
	{1,3,4},
	{0,2,5},
	{1,3,12},
	{0,2,13}
};

//length is supposed to be less than 15
short* nextPerm(short* vector, short length) {
	static short replace_index_A = length - 1;
	static short replace_index_B = length - 1;
	static short rev_len = 0;
	static short i = 0;
	static short temp = 0;

	// find index A
	for (replace_index_A = length - 2; replace_index_A >= 0; replace_index_A--) {
		//if (*(vector + replace_index_A) < *(vector + replace_index_A + 1)) {
		if (vector[replace_index_A] < vector[replace_index_A + 1]){
			break;
		}
	}
	if (replace_index_A == -1 && vector[0] > vector[1]) {
		return 0;
	}
	//find index B and swap A and B
	for (replace_index_B = length - 1; replace_index_B >= 1; replace_index_B--) {
		if (vector[replace_index_A] < vector[replace_index_B]) {
			// swap A and B
			temp = vector[replace_index_B];
			vector[replace_index_B] = vector[replace_index_A];
			vector[replace_index_A] = temp;
			// reverse elements after A 
			rev_len = length - 1 - replace_index_A;
			rev_len /= 2;
			for (i = 1; i <= rev_len; i++) {
				temp = vector[replace_index_A + i];
				vector[replace_index_A + i] = vector[length - i];
				vector[length - i] = temp;
			}
			break;
		}
	}
	return vector;
}

//find the max difference based on criterion M1
short criterionM1(short* vector, short length) {
	static short M1 = 0;
	static short temp = 0;
	short i = 0;
	M1 = 0;
	for (i = 0; i<length; i++) { 
		temp = abs(vector[i] - vector[G_adjacent_array[i][0]]);
		temp = temp > 8 ? (16 - temp) : temp;
		M1 = temp > M1 ? temp : M1;

		temp = abs(vector[i] - vector[G_adjacent_array[i][1]]);
		temp = temp > 8 ? (16 - temp) : temp;
		M1 = temp > M1 ? temp : M1;

		//M1 = abs(vector[i] - vector[G_adjacent_array[i][0]]) > M1 ? abs(vector[i] - vector[G_adjacent_array[i][0]]) : M1;
		//M1 = abs(vector[i] - vector[G_adjacent_array[i][1]]) > M1 ? abs(vector[i] - vector[G_adjacent_array[i][1]]) : M1;
	}
	return M1;
}

//find the sum of difference based on criterion M2
short criterionM2(short* vector, short length) {
	static short M2 = 0;
	static short temp = 0;
	short i = 0;
	M2 = 0;
	for (i = 0; i < length; i++) {
		temp = abs(vector[i] - vector[G_adjacent_array[i][0]]);
		temp = temp > 8 ? (16 - temp) : temp;
		M2 += temp;
		temp = abs(vector[i] - vector[G_adjacent_array[i][1]]);
		temp = temp > 8 ? (16 - temp) : temp;
		M2 += temp;
		//M2 += abs(vector[i] - vector[G_adjacent_array[i][0]]);
		//M2 += abs(vector[i] - vector[G_adjacent_array[i][1]]);
	}
	return M2;
}

//only for length = 16. find the minmum difference of elements whose distance is 2, based on criterion L1
short criterionL1(short* vector) {
	static short L1 = 0;
	static short i = 0;
	static short temp = 0;
	static short length = 16;
	L1 = 200;
	for (i = 0; i < length; i++) {
		temp = abs(vector[i] - vector[G_distance_2_array[i][0]]);
		temp = temp > 8 ? (16 - temp) : temp;
		L1 = temp < L1 ? temp : L1;
		temp = abs(vector[i] - vector[G_distance_2_array[i][1]]);
		temp = temp > 8 ? (16 - temp) : temp;
		L1 = temp < L1 ? temp : L1;
		//L1 = abs(vector[i] - vector[G_distance_2_array[i][0]]) < L1 ? abs(vector[i] - vector[G_distance_2_array[i][0]]) : L1;
		//L1 = abs(vector[i] - vector[G_distance_2_array[i][1]]) < L1 ? abs(vector[i] - vector[G_distance_2_array[i][1]]) : L1;
	}
	return L1;
}


void printPerm(short* vector,short length){
	static short i = 0;
	for (i = 0; i < length; i++) {
		printf("%d ", vector[i]);
	}
	printf(";\n");
}

PermutationLink* createOptPerms(short* vector,short length) {
	PermutationLink* pointer = NULL;
	pointer = (PermutationLink*)malloc(sizeof(PermutationLink));
	if (pointer == NULL) {
		printf("Error.Failed to allocate memory for new PermutationLink node");
		return NULL;
	}
	memcpy(pointer, vector, length * sizeof(short));
	pointer->next = NULL;
	return pointer;
}

void freeOptPerms(PermutationLink* pointer) {
	PermutationLink* next_pointer;
	if (NULL == pointer) {
		return;
	}
	next_pointer = pointer->next;
	if (NULL == next_pointer) {
		free(pointer);
		return;
	}
	for (;;) {
		free(pointer);
		if (next_pointer->next == NULL) {
			free(next_pointer);
			break;
		}
		else {
			pointer = next_pointer;
			next_pointer = next_pointer->next;
		}
	}
}

//only for length = 16;
short saveOptPerms(FILE *fp, PermutationLink *pointer) {
	static short* perm;
	if (NULL == fp) {
		printf("Error! Failed to save opt perms");
		return 1;
	}
	
	for (perm = pointer->perm;;) {
		fprintf(fp, "%hd,%hd,%hd,%hd,%hd,%hd,%hd,%hd,%hd,%hd,%hd,%hd,%hd,%hd,%hd,%hd\n", perm[0], perm[1], perm[2], perm[3], perm[4], perm[5], perm[6], perm[7], perm[8], perm[9], perm[10], perm[11], perm[12], perm[13], perm[14], perm[15]);
		pointer = pointer->next;
		if (pointer) {
			perm = pointer->perm;
		}
		else {
			return 0;
		}
	}
}

//only for length = 16;
short saveCurPerm(FILE *fp,short* perm){
	if (NULL == fp) {
		printf("Error! Failed to save opt perms");
		return 1;
	}
	fprintf(fp, "%hd,%hd,%hd,%hd,%hd,%hd,%hd,%hd,%hd,%hd,%hd,%hd,%hd,%hd,%hd,%hd\n", perm[0], perm[1], perm[2], perm[3], perm[4], perm[5], perm[6], perm[7], perm[8], perm[9], perm[10], perm[11], perm[12], perm[13], perm[14], perm[15]);
	return 0;
}

short saveCriterion(FILE *fp, unsigned short M1, unsigned short M2,short L1) {
	if (NULL == fp) {
		printf("Error! Failed to save criterion");
		return 1;
	}
	fprintf(fp, "%hd,%hd,%hd\n", M1, M2,L1);
	return 0;
}

PermutationLink* readOptPerms(FILE *fp) {
	//todo
	return NULL;
}

short* readCriterion(FILE *fp) {
	//todo
	return 0;
}

void readCurPerm(FILE *fp, short* perm) {
	//todo
}

int main()
{
	short* cur_perm = G_perm;
	short length = 16;
	short length_except_first = length - 1;
	unsigned short M1_opt = 65535, M2_opt = 65535,L1_opt = 0;
	unsigned short M1 = 0, M2 = 0, L1 = 200;
	long long cur_num = 0; // i suppose it's enough.
	long long N_permutations = 1307674368000; // 15!
	//long long N_permutations = 100000000; // about 50s in my laptop
	PermutationLink *perm_opt_head = NULL,*perm_opt_tail = NULL;
	FILE *fp = NULL;

	clock_t start, finish;
	// todo, read backup files.
	
	float duration;
	start = clock();
	for (cur_num = 0;cur_num < N_permutations;cur_num++){
		M1 = criterionM1(cur_perm, length);
		// first compare M1. if M1 < M1_opt, certainly it's a better perm.
		if (M1 < M1_opt) {
			freeOptPerms(perm_opt_head);
			perm_opt_head = createOptPerms(cur_perm, length);
			perm_opt_tail = perm_opt_head;
			M1_opt = M1;
			M2 = criterionM2(cur_perm, length);
			M2_opt = M2;
			L1 = criterionL1(cur_perm);
			L1_opt = L1;
		}
		else {
			// if M1 == M1_opt, then compare M2;
			if (M1 == M1_opt) {
				M2 = criterionM2(cur_perm, length);
				// if M2<M2_opt, then it's a better perm.
				if (M2 < M2_opt) {
					freeOptPerms(perm_opt_head);
					perm_opt_head = createOptPerms(cur_perm, length);
					perm_opt_tail = perm_opt_head;
					M2_opt = M2;
					L1 = criterionL1(cur_perm);
					L1_opt = L1;
				}
				else {
					// but if M2==M2_opt, then compare L1.
					if (M2 == M2_opt) {
						L1 = criterionL1(cur_perm);
						// if L1 > L1_opt ,then it's a better one.
						if (L1 > L1_opt) {
							freeOptPerms(perm_opt_head);
							perm_opt_head = createOptPerms(cur_perm, length);
							perm_opt_tail = perm_opt_head;
							L1_opt = L1;
						}
						else {
							// if M1=opt,M2=opt,M3=opt, then it's the same good
							if (L1 == L1_opt) {
								perm_opt_tail->next = createOptPerms(cur_perm, length);
								perm_opt_tail = perm_opt_tail->next;
							}
						}
					}
				}
			}
		}
		//printf("%lld\n", cur_num);
		//printPerm(cur_perm, length);
		cur_perm = nextPerm(cur_perm + 1, length_except_first); //fix 1 at the position 1
		if (cur_perm == 0) {
			printf("all done!");
			break;
		}
		else {
			cur_perm--;
		}	
	}
	
	// save and backup
	printf("M1=%hd,M2=%hd,L1=%hd\n", M1_opt, M2_opt,L1_opt);
	fp = fopen(CRITERION_OPT_FILE, "w");
	saveCriterion(fp, M1_opt, M2_opt,L1_opt);
	fp = fopen(PERM_OPT_FILE,"w");
	saveOptPerms(fp, perm_opt_head);
	fclose(fp);
	if (0 != cur_perm) {
		fp = fopen(PERM_CUR_FILE, "w");
		saveCurPerm(fp, cur_perm);
		fclose(fp);
	}
	fp = NULL;

	finish = clock();
	duration = (float)(finish - start) / CLOCKS_PER_SEC;
	printf("%f seconds\n", duration);
	return 0;
}
