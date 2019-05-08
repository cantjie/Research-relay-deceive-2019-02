#include <iostream>
#include <string.h>
#include <time.h>
#include <cmath>

#define DNA_LENGTH 16
#define POPULATION 20000
#define N_GENERATION 300
#define CROSSOVER_RATE_PERCENT 20
#define MUTATE_RATE_PERMILLAGE 20 

short G_perms_A[POPULATION][DNA_LENGTH] = {0};
short G_perms_B[POPULATION][DNA_LENGTH] = {0};
short *G_parents_ptr[POPULATION];
short *G_children_ptr[POPULATION];
double G_children_fitness[POPULATION] = { 0 };
double G_parents_fitness[POPULATION] = { 0 };

short G_adjacent_array[DNA_LENGTH][2] = {
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

double Pe1[DNA_LENGTH] = { 0.0564953,0.195519,0.5,0.804481,0.943505,0.98081,0.987499,0.98081,0.943505,0.804481,0.5,0.195519,0.0564953,0.0191905,0.0125008,0.0191905 };
	//at SNR = 4dB.
double Pe2[DNA_LENGTH] = { 0.0564953,0.0191905,0.0125008,0.0191905,0.0564953,0.195519,0.5,0.804481,0.943505,0.98081,0.987499,0.98081,0.943505,0.804481,0.5,0.195519 };

short G_adjacent_difference[DNA_LENGTH][2] = {0};

void calculateDifference(short *vector) 
{
	static short i = 0;
	static short j = 0;
	for (i = 0; i < DNA_LENGTH; i++) {
		for (j = 0; j < 2; j++) {
			G_adjacent_difference[i][j] = abs(vector[i] - vector[G_adjacent_array[i][j]]);
			G_adjacent_difference[i][j] = G_adjacent_difference[i][j] > 8 ? (16 - G_adjacent_difference[i][j]) : G_adjacent_difference[i][j];
		}
	}
}

void initPerms(short *vectors[]) 
{
	short base_perm[DNA_LENGTH] = { 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15 };
	int i = 0, j = 0, k = 0;
	short temp = 0;
	for (i = 0; i < POPULATION; i++) {
		memcpy(vectors[i], base_perm, DNA_LENGTH * sizeof(short));
		j = rand() % (DNA_LENGTH - 1) + 1; // to fix the first location
		k = rand() % (DNA_LENGTH - 1) + 1;
		temp = base_perm[j];
		base_perm[j] = base_perm[k];
		base_perm[k] = temp;
	}
}

void calculateFitness(short *vector[],double *fitness) 
{
	static int idx = 0; // idx of perms
	static int i = 0, j = 0, k = 0;
	double Pe = 0;
	double p1 = 0, p2 = 0;

	for (idx = 0; idx < POPULATION; idx++) {
		calculateDifference(vector[idx]);
		Pe = 0;
		for (i = 0; i < DNA_LENGTH; i++) {
			for (j = 0; j < 2; j++) {
				p1 = Pe1[G_adjacent_difference[i][j]];
				p2 = Pe2[G_adjacent_difference[i][j]];
				Pe += p1 + p2 - p1 * p2;
			}
		}
		fitness[idx] = -Pe;
	}
}

void crossover(short *parents_vector[], short *children_vector[]) 
{
	int father_idx = 0;
	int mother1_idx,mother2_idx = 0;
	int child_idx = 0;
	short i = 0, j = 0;
	short *father = NULL, mother1[DNA_LENGTH], mother2[DNA_LENGTH], *child = NULL;
	static short father_retain_A[DNA_LENGTH / 2] = { 0,1,6,7,8,9,14,15 };
	static short father_abandon_A[DNA_LENGTH / 2] = { 2,3,4,5,10,11,12,13 };
	static short father_retain_B[DNA_LENGTH / 2] = { 0,1,4,5,10,11,14,15 };
	static short father_abandon_B[DNA_LENGTH / 2] = { 2,3,6,7,8,9,12,13 };
	//todo there the mechanism of a male mates with two female randomly is not proper. may change it later.

	for (father_idx = 0; father_idx < POPULATION / 2; father_idx++) {
		// prepare for mating , one male randomly mates with two female
		father = parents_vector[father_idx];
		mother1_idx = POPULATION / 2 + rand() % (POPULATION / 2);
		mother2_idx = POPULATION / 2 + rand() % (POPULATION / 2);
		while (mother1_idx == mother2_idx){
			mother2_idx = POPULATION / 2 + rand() % (POPULATION / 2);
		}
		child = children_vector[child_idx];
		
		//// with mother1, father retain 0 1 6 7 8 9 14 15
		//if (rand() % 100 > CROSSOVER_RATE_PERCENT) {
		//	// there is some probability that they do not mate;
		//	memcpy(child, father, DNA_LENGTH * sizeof(short));
		//}
		//else {
			memcpy(mother1, parents_vector[mother1_idx], DNA_LENGTH * sizeof(short));
			memcpy(child, father, DNA_LENGTH * sizeof(short));
			for (i = 0; i < DNA_LENGTH / 2; i++) {
				for (j = 0; j < DNA_LENGTH; j++) {
					if (mother1[j] == father[father_retain_A[i]]) {
						mother1[j] = DNA_LENGTH;
						break;
					}
				}
			}
			j = 0;
			for (i = 0; i < DNA_LENGTH / 2; i++) {
				for (; j < DNA_LENGTH; j++) {
					if (DNA_LENGTH != mother1[j]) {
						child[father_abandon_A[i]] = mother1[j];
						mother1[j] = DNA_LENGTH;
						break;
					}
				}
			}
		//}
		child_idx++;
		child = children_vector[child_idx];

		//// with mother2, father retain 0 1 4 5 10 11 14 15
		//if (rand() % 100 > CROSSOVER_RATE_PERCENT) {
		//	// there is some probability that they do not mate;
		//	memcpy(mother2, parents_vector[mother2_idx], DNA_LENGTH * sizeof(short));
		//	memcpy(child, mother2, DNA_LENGTH * sizeof(short));
		//}
		//else {
			memcpy(mother2, parents_vector[mother2_idx], DNA_LENGTH * sizeof(short));
			memcpy(child, father, DNA_LENGTH * sizeof(short));
			for (i = 0; i < DNA_LENGTH / 2; i++) {
				for (j = 0; j < DNA_LENGTH; j++) {
					if (mother2[j] == father[father_retain_B[i]]) {
						mother2[j] = DNA_LENGTH;
						break;
					}
				}
			}
			j = 0;
			for (i = 0; i < DNA_LENGTH / 2; i++) {
				for (; j < DNA_LENGTH; j++) {
					if (DNA_LENGTH != mother2[j]) {
						child[father_abandon_B[i]] = mother2[j];
						mother2[j] = DNA_LENGTH;
						break;
					}
				}
			}
		//}
		child_idx++;
		//child = children_vector[child_idx];
	}
	
}

void mutate(short *vector[]) 
{
	int i = 0;
	int k = 0, j = 0;
	short temp;
	
	for (i = 0; i < POPULATION; i++) {
		if (rand() % 1000 < MUTATE_RATE_PERMILLAGE) {
			k = rand() % (DNA_LENGTH - 1) + 1;
			j = rand() % (DNA_LENGTH - 1) + 1;
			temp = vector[i][k];
			vector[i][k] = vector[i][j];
			vector[i][j] = temp;
		}
	}
}

void select()
{
	double sum = 0;
	int i = 0, j = 0;
	static short child_copy[POPULATION][DNA_LENGTH];
	short *temp = NULL;

	memcpy(child_copy, G_children_ptr[0], sizeof(short) * DNA_LENGTH * POPULATION);
	for (i = 0; i < POPULATION; i++) {
		G_parents_fitness[i] = exp(G_parents_fitness[i]+20);
		G_children_fitness[i] = exp(G_children_fitness[i]+20);
		sum += G_parents_fitness[i];
		sum += G_children_fitness[i];
	}
	for (i = 0; i < POPULATION; i++) {
		G_parents_fitness[i] = G_parents_fitness[i] / sum * POPULATION;
		G_children_fitness[i] = G_children_fitness[i] / sum * POPULATION;
	}
	
	i = 0;
	for (j = 0; j < POPULATION; j++) {
		if (rand() / (double)(RAND_MAX) < G_parents_fitness[j]) {
			memcpy(G_children_ptr[i], G_parents_ptr[j], sizeof(short)*DNA_LENGTH);
			i++;
		}
		if (i == POPULATION) { break; }
		if (rand() / (double)(RAND_MAX) < G_children_fitness[j]) {
			memcpy(G_children_ptr[i], child_copy[j], sizeof(short)*DNA_LENGTH);
			i++;
		}
		if (i == POPULATION) { break; }
	}

	for (i = 0; i < POPULATION; i++) {
		temp = G_parents_ptr[i];
		G_parents_ptr[i] = G_children_ptr[i];
		G_children_ptr[i] = temp;
	}
}

int main() {
	int i = 0, j = 0;
	int generation = 0;
	double max_fitness = 0;
	int max_fitness_idx = 0;

	time_t t;

	srand((unsigned)time(&t));

	for (i = 0; i < POPULATION; i++) {
		G_parents_ptr[i] = G_perms_A[i];
		G_children_ptr[i] = G_perms_B[i];
	}

	initPerms(G_parents_ptr);
	for (generation = 0; generation < N_GENERATION; generation++) {
		crossover(G_parents_ptr,G_children_ptr);
		calculateFitness(G_children_ptr,G_children_fitness);
		calculateFitness(G_parents_ptr,G_parents_fitness);
		mutate(G_children_ptr);
		select(); // new parents generated.

		printf("G:%d\n",generation+1);
		//find max
		calculateFitness(G_children_ptr, G_children_fitness);
		max_fitness_idx = 0;
		max_fitness = G_children_fitness[max_fitness_idx];
		for (i = 0; i < POPULATION; i++) {
			if (G_children_fitness[i] >= max_fitness) {
				max_fitness_idx = i;
				max_fitness = G_children_fitness[i];
			}
		}
		printf("fitness:%.7lf\n", max_fitness);
		for (i = 0; i < DNA_LENGTH; i++) {
			printf("%d,", G_children_ptr[max_fitness_idx][i]);
		}
		printf("\n");
	}
	


	system("pause");
	return 0;
}