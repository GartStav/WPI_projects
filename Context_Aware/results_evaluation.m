C = [0 0 0; 1 0 0; 1 0 pi/2; 1 0 pi; 1 0 3*pi/2;  1 1 0; 1 1 pi/4; 1 1 pi/2; 1 1 pi; 1 1 3*pi/2];

%[start, goal, R_rob, obstacles, human, dimX, dimY] = CreateWorkspace(true,true, C(6,:));
% red should be the last one

%load('results');
load('results_new');
load('BSP_tr');

TrainedBSPs = [];
TestedBSPs = [];
DTW_Distances = [];

for i = 1:10

    [start, goal, R_rob, obstacles, human, dimX, dimY] = CreateWorkspace(true,true, C(i,:));
    
    %BSP1 = results(:, i);
    BSP1 = results_new(:, i);
    path1 = A_star(start, goal, R_rob, obstacles, human, dimX, dimY, BSP1', 0); %blue - my method
    
    name = strcat('Comparison reg results for context ',int2str(i));
    title(name,... 
        'FontWeight', 'bold');

    %A_star(start, goal, R_rob, obstacles, human, dimX, dimY, BSP2, 2); %green - regression only

    BSP3 = BSP(:,i,1);
    path3 =A_star(start, goal, R_rob, obstacles, human, dimX, dimY, BSP3', 1); %red - trained
    
    pflag=0;
    figname = strcat('Comparison_reg_results_for_context_',int2str(i));
    saveas(gcf, figname, 'jpg');
    %[dtw_Dist,D,dtw_k,w,s1w,s2w]=dtw(BSP1,BSP3,pflag);
    [dtw_Dist]=dtw_my(path1,path3,pflag);
    
    TrainedBSPs = [TrainedBSPs BSP1];
    TestedBSPs = [TestedBSPs BSP3];
    DTW_Distances = [DTW_Distances dtw_Dist];
end