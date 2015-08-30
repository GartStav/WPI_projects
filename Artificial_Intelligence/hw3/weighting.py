#-------------------------------------------------------------------------------
# Performs Likelihood weighting
#
# Author: Artem Gritsenko
# Worcester Polytechnic Intitute, 2013

#-------------------------------------------------------------------------------
import random

def sample(sample_var, bn, CPT, sample_results, evident_var):
    parents = []
    prob = 0
    for i in range(len(bn[sample_var])):
        if bn[i][sample_var] == 1:
            if sample_results[i] == -1:
                print("Error: CPT inconsistences")
            else:
                parents.append([i, sample_results[i]])
    if parents == []:
        if evident_var:
            table_prob = CPT[sample_var][0][sample_var]
            if sample_results[sample_var] == 1:
                prob = table_prob
            else:
                prob = 1 - table_prob
        else:
            ran_prob = random.uniform(0,1)
            if CPT[sample_var][0][sample_var] >= ran_prob:
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
                if evident_var:
                    table_prob = CPT[sample_var][j][sample_var]
                    if sample_results[sample_var] == 1:
                        prob = table_prob
                    else:
                        prob = 1 - table_prob
                else:
                    ran_prob = random.uniform(0,1)
                    if CPT[sample_var][j][sample_var] >= ran_prob:
                        sample_results[sample_var] = 1
                    else:
                        sample_results[sample_var] = 0
                    break
    return prob


def sampling(nb, CPT, evidences):
    sample_results =[-1, -1, -1, -1]
    for j in range(len(evidences)):
        ind = evidences[j][0]
        sample_results[ind] = evidences[j][1]
    w = 1
    for i in range(len(nb)):
        dont_sample = False
        for j in range(len(evidences)):
            if evidences[j][0] == i:
                dont_sample = True
                break
        if dont_sample:
            w = w * sample(i, nb, CPT, sample_results, True)
        else:
            sample(i, nb, CPT, sample_results, False)
    return [sample_results, w]


def wieghted_sampling(nb, CPT, query, evidences, num_samples):
    num_true = 0
    num_false = 0
    result_true = 0.0
    result_false = 0.0
    for i in range(int(num_samples)):
        [sample, w] = sampling(nb, CPT, evidences)
        if sample[query] == 1:
            result_true += w
            num_true += 1
        else:
            result_false += w
            num_false += 1
    res = result_true/(result_true + result_false)
    #res = (result_true*num_true + result_false*num_false)/int(num_samples)
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
    print("Likelihood weighting")
    print(query, evidences, num_samples)
    prob = wieghted_sampling(nb, CPT, query, evidences, num_samples)
    print(prob)

if __name__ == '__main__':
    main()
