C = [0 0 0; 1 0 0; 1 0 pi/2; 1 0 pi; 1 0 3*pi/2;  1 1 0; 1 1 pi/4; 1 1 pi/2; 1 1 pi; 1 1 3*pi/2];

%[start, goal, R_rob, obstacles, human, dimX, dimY] = CreateWorkspace(true,true, C(6,:));
% red should be the last one

load('results');
load('BSP_tr');

TrainedBSPs = [];
TestedBSPs = [];
DTW_Distances = [];

%for i = 1:10
i=4;
    [start, goal, R_rob, obstacles, human, dimX, dimY] = CreateWorkspace(true,true, C(i,:));
    
    name = strcat('Top vectors for context ',int2str(i));
    title(name,... 
        'FontWeight', 'bold');
    
    BSP0 = results(:, i);
    
    BSP1 = BSP(:,i,1);
    path1 = A_star(start, goal, R_rob, obstacles, human, dimX, dimY, BSP1', 0); %blue

    BSP1 = BSP(:,i,2);
    path2 = A_star(start, goal, R_rob, obstacles, human, dimX, dimY, BSP1', 2); %green

    BSP3 = BSP(:,i,3);
    path3 =A_star(start, goal, R_rob, obstacles, human, dimX, dimY, BSP3', 4); %yellow
    
    BSP1 = BSP(:,i,4);
    path4 = A_star(start, goal, R_rob, obstacles, human, dimX, dimY, BSP1', 3); %black
    
    BSP5 = BSP(:,i,5);
    path5 = A_star(start, goal, R_rob, obstacles, human, dimX, dimY, BSP1', 1); %red
    
    pflag=0;
    figname = strcat('Top_vectors_for_context_',int2str(i));
    saveas(gcf, figname, 'jpg');
    %[dtw_Dist_vectors]=dtw_my(BSP0,BSP1,pflag);
    
    %TrainedBSPs = [TrainedBSPs BSP1];
    %TestedBSPs = [TestedBSPs BSP3];
    %dtw_Distances_vectors = [DTW_Distances_vectors dtw_Dist_vectors];
%end