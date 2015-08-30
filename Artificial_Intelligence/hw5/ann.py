#-------------------------------------------------------------------------------
# Implements Artificial Neural Network

# Author: Artem Gritsenko
# Worcester Polytechnic Intitute, 2013
#-------------------------------------------------------------------------------


from copy import deepcopy
import re
import random
import math

def backPropagation(a, W, k, in_j, data_points):
    w = [[0.0 for x in range(3 + k + 1)] for x in range(3 + k + 1)]
    in_j = [0.0] * (3 + k + 1)
    a = [0.0] * (3 + k + 1)
    delta = [0.0] * (3 + k + 1)

    best_classification = 0

    for y in range(0, 50):
        for i in range(0, 3 + k + 1):
            for j in range(0, 3 + k + 1):
                w[i][j] = random.randint(1, 1000) / 1000
        for l in range(0, 25):
            classifications = 0
            for m in range(0, len(data_points)):
                # Forward propagation
                a[0] = float(data_points[m].x)
                a[1] = float(data_points[m].y)
                a[2] = 1.0
                label = float(data_points[m].label)
                for j in range(3, (3 + k)):
                    in_j[j] = (w[0][j]*a[0]) + (w[1][j]*a[1]) + (w[2][j]*a[2])
                    a[j] = g(in_j[j])
                in_j[3 + k] = 0.0
                for i in range(3, (3 + k)):
                    in_j[3 + k] = in_j[3 + k] + w[i][3 + k]*a[i]
                a[3 + k] = g(in_j[3 + k])
                a[3 + k] = roundOff(a[3 + k])

                if (a[3 + k] == label):
                    classifications = classifications + 1

                # Backward propagation
                delta[3 + k] = gPrime(in_j[3 + k])*(label - a[3 + k])
                for i in range(3, (3 + k)):
                    delta[i] = gPrime(in_j[i])*(w[i][3 + k]*delta[3 + k])
                delta[0] = 0.0
                delta[1] = 0.0
                delta[2] = 0.0

                for i in range(0, 3 + k + 1):
                    for j in range(0, 3 + k + 1):
                        #if ((i == 0) or (i == 1)):
                        #    alpha = 0.5
                        #elif (i < (3 + k)):
                        #    alpha = 1 / k
                        #else:
                        #    alpha = 1
                        alpha = 0.1
                        w[i][j] = w[i][j] + alpha * a[i] * delta[j]

        classifications = 0
        for m in range(0, len(data_points)):
            # Forward propagation
            a[0] = float(data_points[m].x)
            a[1] = float(data_points[m].y)
            a[2] = 1.0
            label = float(data_points[m].label)
            for j in range(3, (3 + k)):
                in_j[j] = (w[0][j]*a[0]) + (w[1][j]*a[1]) + (w[2][j]*a[2])
                a[j] = g(in_j[j])
            in_j[3 + k] = 0.0
            for i in range(3, (3 + k)):
                in_j[3 + k] = in_j[3 + k] + w[i][3 + k]*a[i]
            a[3 + k] = g(in_j[3 + k])
            a[3 + k] = roundOff(a[3 + k])

            if (a[3 + k] == label):
                classifications = classifications + 1

        #print(y, ". Classifications - ", classifications)
        if(classifications > best_classification):
            best_classification = classifications
        if (classifications == best_classification):
            W = deepcopy(w)

        if (classifications == 150):
            break

    #print("Best classification - ", best_classification)
    return W

#dataType for the data
class dataType:
    def __init__(self, valueX = 0.0, valueY = 0.0, label = 0.0):
        self.x = valueX
        self.y = valueY
        self.label = label

global data_array
def Parse(file_name, data_points):
    global data_array

    data_file = open(file_name, "r")
    data_file.seek(0, 0)
    data_raw = data_file.read()

    data_array = data_raw.replace('\n', ',')
    data_array = (re.split(',', data_array))
    data_length = len(data_array)

    temp_array = []
    for i in range(0, data_length):
        temp_array = data_array[i].replace(' ', ',')
        temp_array = re.split(',', temp_array)
        m = len(temp_array)
        if (m == 3):
            data = dataType(temp_array[0], temp_array[m - 2], temp_array[m - 1])
            data_points.add(data)

    data_file.close()

def g(in_j):
    return (1 / (1 + (math.e**(-(in_j)))))

def gPrime(in_j):
    return (1 / (2 + (math.e**(-(in_j))) + (math.e**((in_j)))))
    #return ((math.e^(-in_j)) / ((1 + (math.e^(-in_j)))^2))

def roundOff(number):
    if (number < 0.5):
        return 0.0
    else:
        return 1.0



def computeLabel(data_points, w, k):
    in_j = [0.0] * (3 + k + 1)
    a = [0.0] * (3 + k + 1)
    classifications = 0
    for m in range(0, len(data_points)):
        # Forward propagation
        a[0] = float(data_points[m].x)
        a[1] = float(data_points[m].y)
        a[2] = 1.0
        label = float(data_points[m].label)
        for j in range(3, (3 + k)):
            in_j[j] = (w[0][j]*a[0]) + (w[1][j]*a[1]) + (w[2][j]*a[2])
            a[j] = g(in_j[j])
        in_j[3 + k] = 0.0
        for i in range(3, (3 + k)):
            in_j[3 + k] = in_j[3 + k] + w[i][3 + k]*a[i]
        a[3 + k] = g(in_j[3 + k])
        a[3 + k] = roundOff(a[3 + k])

        if (a[3 + k] == label):
            classifications = classifications + 1

    return classifications

class Points:
    def __init__(self):
        self.data = []
        self.size = 0

    def add(self, data):
        self.data.append(data)
        self.size = len(self.data)

    def remove(self, index):
        del self.data[index]

    def __len__(self):
        return self.size

def main():
    tr_data = []
    test_data = []
    data_points = Points()
    Parse("hw5data.txt", data_points)
    for i in range(0, int((4 * len(data_points)) / 5)):
        tr_data.append(data_points.data[i])
    for i in range(int((4 * len(data_points)) / 5), len(data_points)):
        test_data.append(data_points.data[i])
    a = []
    w = []
    in_j = []
    for num_hidden_nodes in range(2,11):
        w = backPropagation(a, w, num_hidden_nodes, in_j, tr_data)
        computeLabel(tr_data, w, num_hidden_nodes)
        res = computeLabel(test_data, w, num_hidden_nodes)
        print("Correctly classified ", res, " out of ", len(test_data), " using ", num_hidden_nodes, " nodes")


if __name__ == '__main__':
    main()
