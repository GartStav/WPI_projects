#-------------------------------------------------------------------------------
# To execute a file change the filename in the main function.
# To use either Simulated Annealing, or the CSP uncomment one of those in the
# main function.
#-------------------------------------------------------------------------------
# Author: Artem Gritsenko
# Worcester Polytechnic Intitute, 2013
#-------------------------------------------------------------------------------


import random
import math
import copy
import timeit

#fill board with random variables
def fill_board(board, unit_peers_cop):
    n = len(unit_peers_cop)
    for i in range(n):
        for j in range(n):
            if unit_peers_cop[i][j][0] == 0:
                row = unit_peers_cop[i][j][1][0]
                col = unit_peers_cop[i][j][1][1]
                check = 1
                while (check):
                    check = 0
                    num = random.randint(1,n)
                    for l in range(n):
                        if unit_peers_cop[i][l][0] == num:
                            check = 1
                board[row][col] = num
                unit_peers_cop[i][j][0] = num
    return board

def random_change(board, unit_peers):
    n = len(board)
    unit_ind = random.randint(0,(n-1))
    rows_to_change = []
    cols_to_change = []
    for i in range(2):
        check = 1
        while check:
            num = random.randint(0,(n-1))
            if unit_peers[unit_ind][num][0] == 0:
                rows_to_change.append(unit_peers[unit_ind][num][1][0])
                cols_to_change.append(unit_peers[unit_ind][num][1][1])
                unit_peers[unit_ind][num][0] = 1
                check = 0
    x1 = rows_to_change[0]
    y1 = cols_to_change[0]
    x2 = rows_to_change[1]
    y2 = cols_to_change[1]
    temp1 = board[x1][y1]
    temp2 = board[x2][y2]
    board[x1][y1] = temp2
    board[x2][y2] = temp1
    return board


def compute_cost(board):
    n = len(board)
    cost = 0
    for i in range(n):
        for j in range(n):
            if i ==j:
                list_diff = []
                for k in range(n):
                    elem = board[i][k]
                    if list_diff.count(elem) == 0:
                        cost = cost - 1
                        list_diff.append(elem)
                list_diff.clear()
                for k in range(n):
                    elem = board[k][j]
                    if list_diff.count(elem) == 0:
                        cost = cost - 1
                        list_diff.append(elem)
            #print(cost)
    return cost

def simulated_annealing(sudoku_board, unit_peers):
    unit_peers_cpy = copy.deepcopy(unit_peers)
    init_board = fill_board(sudoku_board, unit_peers_cpy)
    #print(init_board)
    T0 = 500
    t = 0
    TN = 0
    N = 1000
    current_state = init_board
    best_cost = compute_cost(current_state)
    while (1):
        T = T0 - ((t/N)**2)*(T0-TN)
        if T == 0:
            return current_state
        unit_peers_cpy2 = copy.deepcopy(unit_peers)
        current_state_cpy = copy.deepcopy(current_state)
        next_state = random_change(current_state_cpy, unit_peers_cpy2)
        #print(next_state)
        #print(compute_cost(next_state))
        next_cost = compute_cost(next_state)
        delta = compute_cost(current_state) - next_cost
        #if next_cost < best_cost:
        #    best_cost = next_cost
        #delta = best_cost - next_cost
        prob = math.exp(delta*20/T)
        if (delta > 0) or (prob >= random.uniform(0,1)):
           current_state = next_state
        t += 1
        print (compute_cost(current_state))
    return current_state

def create_units(board):
    n = len(board)
    units = {}
    for i in range(n):
        for j in range(n):
            list_of_peers = []
            for k in range(n):
                if list_of_peers.count([i, k]) == 0:
                    list_of_peers.append([i, k])
            for k in range(n):
                if list_of_peers.count([k, j]) == 0:
                    list_of_peers.append([k, j])
            x_start = i // int(n**.5) * int(n**.5)
            y_start = j // int(n**.5) * int(n**.5)
            for l in range(x_start, x_start + int(n**.5)):
                for o in range(y_start, y_start + int(n**.5)):
                    if list_of_peers.count([l, o]) == 0:
                        list_of_peers.append([l, o])
            list_of_peers.remove([i,j])
            identifier = str(i)+str(j)
            units[identifier] = list_of_peers
    return units

def calc_possibilities(board, units):
    n = len(board)
    poss_board = []
    for i in range(n):
        prob_row = []
        for j in range(n):
            prob_list = []
            if board[i][j] == 0:
                for l in range(n):
                    prob_list.append(l+1)
                identifier = str(i) + str(j)
                list_of_peers = units[identifier]
                for k in range(len(list_of_peers)):
                    x = list_of_peers[k][0]
                    y = list_of_peers[k][1]
                    elem = board[x][y]
                    if prob_list.count(elem) != 0:
                        prob_list.remove(elem)
            prob_row.append([board[i][j], prob_list])
        poss_board.append(prob_row)
    return poss_board

def recalc_possibilities(board, units):
    n = len(board)
    poss_board = []
    for i in range(n):
        prob_row = []
        for j in range(n):
            prob_list = board[i][j][1]
            if board[i][j][0] == 0:
                identifier = str(i) + str(j)
                list_of_peers = units[identifier]
                for k in range(len(list_of_peers)):
                    x = list_of_peers[k][0]
                    y = list_of_peers[k][1]
                    elem = board[x][y][0]
                    if prob_list.count(elem) != 0:
                        prob_list.remove(elem)
                if len(prob_list) == 0:
                    return []
            prob_row.append([board[i][j][0], prob_list])
        poss_board.append(prob_row)
    return poss_board

def degree_heuristic(poss_board, units, smallest_list):
    min_unassigned = 1000
    for i in range(len(smallest_list)):
        count = 0
        identifier = str(smallest_list[i][0]) + str(smallest_list[i][1])
        list_of_peers = units[identifier]
        for j in range(len(list_of_peers)):
            x = list_of_peers[j][0]
            y = list_of_peers[j][1]
            if poss_board[x][y][0] == 0:
                count += 1
        if count <= min_unassigned:
            min_unassigned = count
            min_x = smallest_list[i][0]
            min_y = smallest_list[i][1]
    return [min_x, min_y]


def pick_the_value(poss_board, units):
    n = len(poss_board)
    smallest_list = []
    abs_min = len(poss_board[0][0][1])
    for i in range(n):
        for j in range(n):
            if poss_board[i][j][0] == 0:
                min_val = len(poss_board[i][j][1])
                if min_val != 0:
                    if min_val <= abs_min:
                        abs_min = min_val
                        smallest_list.clear()
                        smallest_list.append([i,j])
                    elif min_val == abs_min:
                        smallest_list.append([i,j])
    if len(smallest_list) > 1:
        min_coord = degree_heuristic(poss_board, units, smallest_list)
    elif len(smallest_list) == 1:
        min_coord = smallest_list[0]
    else:
        return []
    return min_coord


def pick_the_LCV(row, col, board, units):
    n = len(board)
    identifier = str(row)+str(col)
    list_of_peers = units[identifier]
    list_of_poss = board[row][col][1]
    min_index = 0
    min_counter = 0
    for i in range(len(list_of_poss)):
        counter = 0
        for j in range(len(list_of_peers)):
            peer_row = list_of_peers[j][0]
            peer_col = list_of_peers[j][1]
            if board[peer_row][peer_col][1].count(list_of_poss[i]) > 0:
                counter += 1
        if counter <= min_counter:
            min_counter = counter
            min_index = i
    return board[row][col][1][min_index]

def backtrack(poss_board, units):
    coord = pick_the_value(poss_board, units)
    if coord == []:
        board = []
        for i in range(len(poss_board)):
            row = []
            for j in range(len(poss_board)):
                row.append(poss_board[i][j][0])
            board.append(row)
        return board
    value_to_assign = pick_the_LCV(coord[0], coord[1], poss_board, units)

    poss_board_cpy = copy.deepcopy(poss_board)
    poss_board_cpy[coord[0]][coord[1]][0] = value_to_assign
    new_board = recalc_possibilities(poss_board_cpy, units)
    if len(new_board) == 0:
        poss_board[coord[0]][coord[1]][1].remove(value_to_assign)
        return backtrack(poss_board, units)
    else:
        #print(new_board)
        return backtrack(new_board, units)

def CSP(sudoku_board):
    units = create_units(sudoku_board)
    poss_board = calc_possibilities(sudoku_board, units)
    #print(poss_board)
    return backtrack(poss_board, units)


#assign units
def create_peers_structure(board):
    n = len(board)
    units = []
    sqrt_n = int(n**.5)
    for s in range(sqrt_n):
        for k in range(sqrt_n):
            unit = []
            for i in range(sqrt_n):
                for j in range(sqrt_n):
                    element = []
                    if board[i+sqrt_n*s][j+sqrt_n*k] == '?':
                        board[i+sqrt_n*s][j+sqrt_n*k] = 0
                    else:
                        board[i+sqrt_n*s][j+sqrt_n*k] = int(board[i+sqrt_n*s][j+sqrt_n*k])
                    element.append(board[i+sqrt_n*s][j+sqrt_n*k])
                    element.append([i+sqrt_n*s, j+sqrt_n*k])
                    unit.append(element)
            units.append(unit)
    return units

def parse(filename):
    sudoku_board = []
    infile = open(filename, "r")
    for line in infile:
        value = line.strip().split(",")
        sudoku_board.append(value)
    return sudoku_board

def board_check(sudoku_board):
    n = len(sudoku_board)
    if (n**.5)%int((n**.5)) != 0:
        print('Not a valid sudoku board')
        return 0
    for i in range(n):
        if len(sudoku_board[i]) != n:
            print('Not a valid sudoku board')
            return 0
    return 1

# A* pseudocode:
#
# Start_state = assign empty cells is squre units with unique numbers
# assign the init_closed_list with initial values
# assign open_list with start_state
# current = start_state
# while (open_list is not empty)
#   {
#   remove current from open_list
#   add current to closed_list
#   calculate neighbors // by permutating each possible pair of squares in square boxes
#   calculate g(x) for each neighbor // which is cost of path and equal g(current)+1
#   calculate h(x) for each neighbor // which is sum of number of duplicates in all rows and in all cols divided by 2
#   add g(x)+h(x) to get f(x)
#   add all neighbors to open_list
#   next = state with smallest f(x) from open list
#   if h(next) = 0 then return next // founded the solution
#   current = next
#   }
# return Faliure

def main():
    #timeit.timeit()
    random.seed()
    sudoku_board = parse("Easiest1.txt")
    #sudoku_board = parse("Average4x4.txt")
    #sudoku_board = parse("hard4x4.txt")
    #sudoku_board = parse("hard9x9.txt")
    if board_check(sudoku_board):
        #print(sudoku_board)
        unit_peers = create_peers_structure(sudoku_board)
        #print(unit_peers)

        #solution = simulated_annealing(sudoku_board, unit_peers)
        solution = CSP(sudoku_board)
        print(solution)


if __name__ == '__main__':
    main()
