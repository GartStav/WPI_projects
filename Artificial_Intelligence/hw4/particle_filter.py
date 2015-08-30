#-------------------------------------------------------------------------------
# Implements Particle Filtering algorithm
#
# Author: Artem Gritsenko
# Worcester Polytechnic Intitute, 2013

#-------------------------------------------------------------------------------
import random

def initial_sampling(num_samples, prior):
    samples = []
    for i in range(int(num_samples)):
        if random.uniform(0,1) > prior:
            samples.append(0)
        else:
            samples.append(1)
    return samples

def particle_resampling(samples, weights, num_samples):
    resampled = []
    i = 0
    while len(resampled) < num_samples:
        rand_prob = random.uniform(0,1)
        if rand_prob < weights[i]:
            resampled.append(samples[i])
        if i < num_samples-1:
            i += 1
        else:
            i = 0
    return resampled


def particle_filtering(prior, transition_model, observation_model, evidences, num_samples):
    samples = initial_sampling(num_samples, prior)
    t = 0
    weights = int(num_samples)*[0]
    l =len(evidences)
    while t < l:
        for i in range(int(num_samples)):
            if samples[i] == 1:
                trans_prob = transition_model[0]
            elif samples[i] == 0:
                trans_prob = transition_model[1]

            if random.uniform(0,1) < trans_prob:
                samples[i] = 1
            else:
                samples[i] = 0

            if evidences[t] == 't':
                if samples[i] == 1:
                    obs_prob = observation_model[0]
                elif samples[i] == 0:
                    obs_prob = observation_model[1]
            elif evidences[t] == 'f':
                if samples[i] == 1:
                    obs_prob = 1-observation_model[0]
                elif samples[i] == 0:
                    obs_prob = 1-observation_model[1]
            weights[i] = obs_prob
        samples = particle_resampling(samples, weights, int(num_samples))
        t += 1

    s = 0
    for i in range(int(num_samples)):
        if samples[i] == 1:
            s += 1
    return s/int(num_samples)

def parse(filename):
    infile = open(filename, "r")
    evidences = infile.readline().strip().split(",")
    num_samples = infile.readline()
    return [evidences, num_samples]

def main():
    random.seed()
    prior = 0.7
    transition_model = [0.7, 0.3]
    observation_model = [0.9, 0.2]
    [evidences, num_samples] = parse("umbrellas3.txt")
    for i in range(30):
        num_samples = 1.5**i
        prob = particle_filtering(prior, transition_model, observation_model, evidences, num_samples)
        #print(num_samples)
        print(prob)

if __name__ == '__main__':
    main()
