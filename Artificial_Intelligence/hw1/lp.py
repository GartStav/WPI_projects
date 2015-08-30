#cvxopt example:

# the problem
# minimize      2x1 + x2
# subject to   -x1 + x2 <= 1
#               x1 + x2 >= 2
#               x2 >= 0
#               x1 - 2x2 <= 4

#from cvxopt import matrix, solvers
#
#A = matrix([ [-1.0, -1.0, 0.0, 1.0], [1.0, -1.0, -1.0, -2.0] ])
#b = matrix([ 1.0, -2.0, 0.0, 4.0 ])
#c = matrix([ 2.0, 1.0 ]) #this is the optimization function
#sol=solvers.lp(c,A,b)
#
#print(sol['x'])

from cvxopt import matrix, solvers

A = matrix([ [-400.0, -300.0, -70.0, -1., 0., 0., 0.], [-10.0, -15.0, -300.0, 0., -1., 0., 0.], [-600.0, -400.0, -50.0, 0., 0., -1., 0.], [-300.0, -200.0, -250.0, 0., 0., 0., -1.] ])
b = matrix([ -1000.0, -1500.0, -700.0, 0., 0., 0., 0.])
c = matrix([ 0.58, 0.8, 1.2, 2.6]) #this is the optimization function
sol=solvers.lp(c,A,b)

print(sol['x'])
