#-------------------------------------------------------------------------------
# Runs simulation
#
# Author: Artem Gritsenko
# Worcester Polytechnic Intitute, 2013
#-------------------------------------------------------------------------------
import random

def main():
    num_trials = 10000
    trials = []
    sum = 0
    for i in range(num_trials):
        n_coins = 10
        random.seed()
        iterations = 0
        while (n_coins > 0):
            n_coins -= 1
            iterations += 1
            res = []
            for j in range(3):
                res.append(random.randint(1,4))
            if (res[0] == res[1] == res[2]):
                if res[0] == 1:
                    n_coins += 20
                if res[0] == 2:
                    n_coins += 15
                if res[0] == 3:
                    n_coins += 5
                if res[0] == 4:
                    n_coins += 3
            else:
                if (res[0] == res[1] == 4):
                    n_coins += 2
                else:
                    if (res[0] == 4):
                        n_coins += 1
        trials.append(iterations)
        sum += iterations
    trials.sort()
    mean = sum / num_trials
    median = trials[int(num_trials/2)]
    print("mean",mean, "median",median)

if __name__ == '__main__':
    main()
