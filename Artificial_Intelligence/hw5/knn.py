#-------------------------------------------------------------------------------
# Implements k-nearest neighbor
#
# Author: Artem Gritsenko
# Worcester Polytechnic Intitute, 2013
#-------------------------------------------------------------------------------
import math
import operator

def readData(inputFile):
    examples = []
    infile = open(inputFile, "r")
    for line in infile:
        value = line.strip().split(" ")
        example = []
        example.append(float(value[0]))
        example.append(float(value[1]))
        example.append(float(value[2]))
        examples.append(example)
    return examples


def main():
    examples = readData("hw5data.txt")
    examples_tr = examples[40:]
    examples_test = examples[:40]
    size_tr = len(examples_tr)
    size_test = len(examples_test)

    for k in range(1,11):
        correct = 0
        for i in range(size_test):
            neighbors = []
            for j in range(size_tr):
                dist = math.sqrt((examples_test[i][0]-examples_tr[j][0])**2 + (examples_test[i][1]-examples_tr[j][1])**2)
                entry =[dist, examples_tr[j]]
                neighbors.append(entry)
            neighbors = sorted(neighbors, key=operator.itemgetter(0))
            sum = 0
            for p in range(k):
                sum += neighbors[p][1][2]
            if sum/k > 0.5:
                hyp = 1
            else:
                hyp = 0

            if examples_test[i][2] == hyp:
                correct += 1
        print("Correctly classified ", correct, " out of ", size_test)

if __name__ == '__main__':
    main()
