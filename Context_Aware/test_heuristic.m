
C = [1 0 3.14];
BSP = [0.2 0.3 0.0 0.1];
[start, goal, R_rob, obstacles, human, dimX, dimY] = CreateWorkspace(true,true, C);
A_star(start, goal, R_rob, obstacles, human, dimX, dimY, BSP, 0);
