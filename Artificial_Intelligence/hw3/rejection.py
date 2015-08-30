#-------------------------------------------------------------------------------
# Performs Rejection Sampling
#
# Author: Artem Gritsenko
# Worcester Polytechnic Intitute, 2013

#-------------------------------------------------------------------------------
import random

def sample(sample_var, bn, CPT, sample_results):
    parents = []
    for i in range(len(bn[sample_var])):
        if bn[i][sample_var] == 1:
            if sample_results[i] == -1:
                print("Error: CPT inconsistences")
            else:
                parents.append([i, sample_results[i]])
    if parents == []:
        ran_prob = random.uniform(0,1)
        event_prob = CPT[sample_var][0][sample_var]
        if event_prob >= ran_prob:
            sample_results[sample_var] = 1
        else:
            sample_results[sample_var] = 0
    else:
        for j in range(len(CPT[sample_var])):
            found = True
            k = 0
            while found:
                ind = parents[k][0]
                if CPT[sample_var][j][ind] == parents[k][1]:
                    k += 1
                else:
                    found = False
                if k > len(parents)-1:
                    break
            if found:
                ran_prob = random.uniform(0,1)
                event_prob = CPT[sample_var][j][sample_var]
                if event_prob >= ran_prob:
                    sample_results[sample_var] = 1
                else:
                    sample_results[sample_var] = 0
                break
    return sample_results


def prior_sampling(nb, CPT):
    sample_results =[-1, -1, -1, -1]
    for i in range(len(nb)):
        sample_results = sample(i, nb, CPT, sample_results)
    return sample_results

def rejection_sampling(nb, CPT, query, evidences, num_samples):
    num_true = 0
    n=0
    result = []
    for i in range(int(num_samples)):
        sample = prior_sampling(nb, CPT)
        for j in range(len(evidences)):
            ind = evidences[j][0]
            if sample[ind] == evidences[j][1]:
                good_sample = True
            else:
                good_sample = False
                n = n+1
                break
        if good_sample:
            result.append(sample[query])
            if sample[query] == 1:
                num_true += 1
    if len(result) > 0:
        res = num_true/len(result)
    else:
        res = 0.0
    return res


def set_the_network():
    bn = [[0, 1, 1, 0], [0, 0, 0, 1], [0, 0, 0, 1], [0, 0, 0, 0]]
    CPT_C = [[0.5, -1, -1, -1], [-1, -1, -1, -1], [-1, -1, -1, -1], [-1, -1, -1, -1]]
    CPT_S = [[1, 0.1, -1, -1], [0, 0.5, -1, -1], [-1, -1, -1, -1], [-1, -1, -1, -1]]
    CPT_R = [[1, -1, 0.8, -1], [0, -1, 0.2, -1], [-1, -1, -1, -1], [-1, -1, -1, -1]]
    CPT_W = [[-1, 1, 1, 0.99], [-1, 1, 0, 0.9], [-1, 0, 1, 0.9], [-1, 0, 0, 0.0]]
    CPT = [CPT_C, CPT_S, CPT_R, CPT_W]
    return [bn, CPT]

def parse(filename):
    infile = open(filename, "r")
    variables = infile.readline().strip().split(",")
    num_samples = infile.readline()
    evidences = []
    for i in range(len(variables)):
        if variables[i] == 'q':
            query = i
        if variables[i] == 't':
            evidences.append([i, 1])
        if variables[i] == 'f':
            evidences.append([i, 0])
    return [query, evidences, num_samples]

def main():
    random.seed()
    [nb, CPT] = set_the_network()
    [query, evidences, num_samples] = parse("inference.txt")
    print("Rejection sampling")
    print(query, evidences, num_samples)
    prob = rejection_sampling(nb, CPT, query, evidences, num_samples)
    print(prob)

if __name__ == '__main__':
    main()
