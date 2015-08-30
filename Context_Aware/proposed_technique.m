% AI_Project
% Create a regression that utilizes the multiple ordered output

% generate contexts for training
% auto generation

% manual generation (10 train samples/contexts)
In = [0 0 0; 1 0 0; 1 0 pi/2; 1 0 pi; 1 0 3*pi/2;  1 1 0; 1 1 pi/4; 1 1 pi/2; 1 1 pi; 1 1 3*pi/2];

% generate BSP for training
% Generate the BSP matrix: dim1 - data samples
%                          dim2 - BSP components. Length is set by BSP_size
%                          dim3 - ordered structure (top 1st, top 2nd, top
%                          3rd values, etc.). Length is set by Num_BSPs
% set the number of elements in the BSP vector
BSP_size = 4;
% set the number of top BSP vectors that we interested in
Num_BSPs = 5;
BSP_temp = [];

for i = 1:10
    name = strcat('mat_files/BSP_',int2str(i));
    load(name);
    BSP_temp = [BSP_temp BSP'];
end
load('mat_files/BSP_1');
BSP_1 = BSP;
load('mat_files/BSP_2');
BSP_2 = BSP;
load('mat_files/BSP_3');
BSP_3 = BSP;
load('mat_files/BSP_4');
BSP_4= BSP;
load('mat_files/BSP_5');
BSP_5 = BSP;
load('mat_files/BSP_6');
BSP_6 = BSP;
load('mat_files/BSP_7');
BSP_7 = BSP;
load('mat_files/BSP_8');
BSP_8 = BSP;
load('mat_files/BSP_9');
BSP_9 = BSP;
load('mat_files/BSP_10');
BSP_10= BSP;

% import Ranking
load('mat_files/Ranks_1');
Ranking = Ranks;
for i = 2:10
    name = strcat('mat_files/Ranks_',int2str(i));
    load(name);
    Ranking(:,:,i) = Ranks; 
end

% manual generation
i = 1;
BSP = [BSP_1(:,Ranking(i,1,1)) BSP_2(:,Ranking(i,1,2)) BSP_3(:,Ranking(i,1,3)) BSP_4(:,Ranking(i,1,4)) BSP_5(:,Ranking(i,1,5)) BSP_6(:,Ranking(i,1,6)) BSP_7(:,Ranking(i,1,7)) BSP_8(:,Ranking(i,1,8)) BSP_9(:,Ranking(i,1,9)) BSP_10(:,Ranking(i,1,10))];
for i = 2:5
    BSP(:,:,i) = [BSP_1(:,Ranking(i,1,1)) BSP_2(:,Ranking(i,1,2)) BSP_3(:,Ranking(i,1,3)) BSP_4(:,Ranking(i,1,4)) BSP_5(:,Ranking(i,1,5)) BSP_6(:,Ranking(i,1,6)) BSP_7(:,Ranking(i,1,7)) BSP_8(:,Ranking(i,1,8)) BSP_9(:,Ranking(i,1,9)) BSP_10(:,Ranking(i,1,10))];
end

save('BSP_tr','BSP');

% multivariate regression


% calulate the parameters of the Gaussian models
GM_mat = zeros(size(In,1), BSP_size, 2);
% alpha = zeros(1,Num_BSPs)
% s=0;
% assign weights
% for i = 1:Num_BSPs
%    alpha(i) = 1/(2*Num_BSPs + exp(alpha(i)));
%    s = s + alpha(i);
% end
%normalize
% for i = 1:Num_BSPs
%    alpha(i) = alpha(i)/s;
% end
for i = 1:size(In,1)
    for j =1:BSP_size
        temp = zeros(1,Num_BSPs);
        weights = 0;
        for k = 1:Num_BSPs
            %temp(k) = BSP(j, i, k)*(Num_BSPs+1-k);
            temp(k) = BSP(j, i, k)*(1./(exp(k)));
            weights(k) = 1./(exp(k));
            temp1(k) =  BSP(j, i, k);
        end
        sum_of_weights = sum(weights);
        my_mean = sum(temp)/sum_of_weights;
        mean1 = mean(temp1);
        std1 = sqrt(var(temp1));
        my_std = 0;
        for l = 1:5
            my_std(l) = (1./(exp(l)))*(BSP(j, i, l) - my_mean)^2;
        end
        my_std = sqrt(sum(my_std)/sum_of_weights); 
        %my_mean = BSP(j, i, 1);
        %my_std = 1;
        
        GM_mat(i, j, 1) = my_mean;
        GM_mat(i, j, 2) = my_std;
    end
end

% leave one out cross validation

results = [];
for i = 1:10
    test_context_index = i;
    temp_mean11 = 0;
    temp_var11 = 0;
    counter11 = 0;
    
    temp_mean21 = 0;
    temp_var21 = 0;
    counter21 = 0;
    
    temp_mean31 = 0;
    temp_var31 = 0;
    counter31 = 0;
    
    temp_mean41 = 0;
    temp_var41 = 0;
    counter41 = 0;
    
    temp_mean12 = 0;
    temp_var12 = 0;
    counter12 = 0;
    
    temp_mean22 = 0;
    temp_var22 = 0;
    counter22 = 0;
    
    temp_mean32 = 0;
    temp_var32 = 0;
    counter32 = 0;
    
    temp_mean42 = 0;
    temp_var42 = 0;
    counter42 = 0;
    
    context3_values = [];
    BSP1_mean_values = [];
    BSP2_mean_values = [];
    BSP3_mean_values = [];
    BSP4_mean_values = [];
    BSP1_var_values = [];
    BSP2_var_values = [];
    BSP3_var_values = [];
    BSP4_var_values = [];
    for j = 1:10
        %picking contexts one by one
        if j ~= i
            
            %the first components are equal
            if In(j,1) == In(test_context_index, 1)
                %first BSP coef
                temp_mean11 = temp_mean11 + GM_mat(j,1,1);
                temp_var11 = temp_var11 + GM_mat(j,1,2);
                counter11 = counter11 + 1;
                %second BSP coef
                temp_mean21 = temp_mean21 + GM_mat(j,2,1);
                temp_var21 = temp_var21 + GM_mat(j,2,2);
                counter21 = counter21 + 1;
                %third BSP coef
                temp_mean31 = temp_mean31 + GM_mat(j,3,1);
                temp_var31 = temp_var31 + GM_mat(j,3,2);
                counter31 = counter31 + 1;
                %forth BSP coef
                temp_mean41 = temp_mean41 + GM_mat(j,4,1);
                temp_var41 = temp_var41 + GM_mat(j,4,2);
                counter41 = counter41 + 1;
            end
            
            %the second components are equal
            if In(j,2) == In(test_context_index, 2)
                %first BSP coef
                temp_mean12 = temp_mean12 + GM_mat(j,1,1);
                temp_var12 = temp_var12 + GM_mat(j,1,2);
                counter12 = counter12 + 1;
                %second BSP coef
                temp_mean22 = temp_mean22 + GM_mat(j,2,1);
                temp_var22 = temp_var22 + GM_mat(j,2,2);
                counter22 = counter22 + 1;
                %third BSP coef
                temp_mean32 = temp_mean32 + GM_mat(j,3,1);
                temp_var32 = temp_var32 + GM_mat(j,3,2);
                counter32 = counter32 + 1;
                %forth BSP coef
                temp_mean42 = temp_mean42 + GM_mat(j,4,1);
                temp_var42 = temp_var42 + GM_mat(j,4,2);
                counter42 = counter42 + 1;
            end
            
            %regression for the third component here
            context3_values = [context3_values [In(j,3)]];
            
            BSP1_mean_values = [BSP1_mean_values [GM_mat(j,1,1)]];
            BSP1_var_values = [BSP1_var_values [GM_mat(j,1,2)]];
            
            BSP2_mean_values = [BSP2_mean_values [GM_mat(j,2,1)]];
            BSP2_var_values = [BSP2_var_values [GM_mat(j,2,2)]];
            
            BSP3_mean_values = [BSP3_mean_values [GM_mat(j,3,1)]];
            BSP3_var_values = [BSP3_var_values [GM_mat(j,3,2)]];
            
            BSP4_mean_values = [BSP4_mean_values [GM_mat(j,4,1)]];
            BSP4_var_values = [BSP4_var_values [GM_mat(j,4,2)]];
            
        end
    end
    
    % new_edit_Jan15_start
    % reduce the size of context3 values by aggragating the points with the
    % same value
    context3_values_ = [];
    BSP1_mean_values_ = [];
    BSP2_mean_values_ = [];
    BSP3_mean_values_ = [];
    BSP4_mean_values_ = [];
    BSP1_var_values_ = [];
    BSP2_var_values_ = [];
    BSP3_var_values_ = [];
    BSP4_var_values_ = [];
    
    [c, ia, ic] = unique(context3_values);
    
    % find identical context values and store their indexes
    n = size(context3_values);
    n_ = size(c);
    indexes = [];
    for k = 1:n_(2)
        counter = 0;
        temp_mean1 = 0;
        temp_var1 = 0;
        temp_mean2 = 0;
        temp_var2 = 0;
        temp_mean3 = 0;
        temp_var3 = 0;
        temp_mean4 = 0;
        temp_var4 = 0;
        for j = 1:n(2)
           if context3_values(j) == c(k)
               counter = counter + 1;
               temp_mean1 = temp_mean1 + BSP1_mean_values(j);
               temp_var1 = temp_var1 + BSP1_var_values(j);
               temp_mean2 = temp_mean2 + BSP2_mean_values(j);
               temp_var2 = temp_var2 + BSP2_var_values(j);
               temp_mean3 = temp_mean3 + BSP3_mean_values(j);
               temp_var3 = temp_var3 + BSP3_var_values(j);
               temp_mean4 = temp_mean4 + BSP4_mean_values(j);
               temp_var4 = temp_var4 + BSP4_var_values(j);
               
           end
        end
        
        context3_values_ = [context3_values_ context3_values(ia(k))];
        BSP1_mean_values_ = [BSP1_mean_values_ temp_mean1/counter];
        BSP1_var_values_ = [BSP1_var_values_ temp_var1/counter];
        BSP2_mean_values_ = [BSP2_mean_values_ temp_mean2/counter];
        BSP2_var_values_ = [BSP2_var_values_ temp_var2/counter];
        BSP3_mean_values_ = [BSP3_mean_values_ temp_mean3/counter];
        BSP3_var_values_ = [BSP3_var_values_ temp_var3/counter];
        BSP4_mean_values_ = [BSP4_mean_values_ temp_mean4/counter];
        BSP4_var_values_ = [BSP4_var_values_ temp_var4/counter];
        

    end
    
    % interpolate the values
    xq = 0:.01:7;
    interp_1 = interp1(context3_values_, BSP1_mean_values_, xq);
    test_x1 = In(test_context_index, 3);
    ind = test_x1/0.01;
    if ind == 0
       ind = 1;
    end
    mean13 = interp_1(ceil(ind));

    interp_2 = interp1(context3_values_, BSP2_mean_values_, xq);
    test_x2 = In(test_context_index, 3);
    ind = test_x2/0.01;
    if ind == 0
       ind = 1;
    end
    mean23 = interp_2(ceil(ind));

    interp_3 = interp1(context3_values_, BSP3_mean_values_, xq);
    test_x3 = In(test_context_index, 3);
    ind = test_x3/0.01;
    if ind == 0
       ind = 1;
    end
    mean33 = interp_3(ceil(ind));
    
    interp_4 = interp1(context3_values_, BSP4_mean_values_, xq);
    test_x4 = In(test_context_index, 3);
    ind = test_x4/0.01;
    if ind == 0
       ind = 1;
    end
    mean43 = interp_4(ceil(ind));
    
    %plotting mean
    %plot(context3_values_, BSP3_mean_values_, 'o', xq, interp);
    %hold on;
    %plot(test_x, mean33, 'rx');
    %hold off;
    
    interp_5 = interp1(context3_values_, BSP1_var_values_, xq);
    test_x5 = In(test_context_index, 3);
    ind = test_x5/0.01;
    if ind == 0
       ind = 1;
    end
    var13 = interp_5(ceil(ind));

    interp_6 = interp1(context3_values_, BSP2_var_values_, xq);
    test_x6 = In(test_context_index, 3);
    ind = test_x6/0.01;
    if ind == 0
       ind = 1;
    end
    var23 = interp_6(ceil(ind));

    interp_7 = interp1(context3_values_, BSP3_var_values_, xq);
    test_x7 = In(test_context_index, 3);
    ind = test_x7/0.01;
    if ind == 0
       ind = 1;
    end
    var33 = interp_7(ceil(ind));
    
    interp_8 = interp1(context3_values_, BSP4_var_values_, xq);
    test_x8 = In(test_context_index, 3);
    ind = test_x8/0.01;
    if ind == 0
       ind = 1;
    end
    var43 = interp_8(ceil(ind));

    %plotting var
    %plot(context3_values_, BSP3_var_values_, 'o', xq, interp);
    %hold on;
    %plot(test_x, var33, 'rx');
    %hold off;
    

%     plot(context3_values_, BSP1_mean_values_, xq, interp_1);
%     hold on;
%     for l = 1:size(context3_values_, 2)
%         x = [context3_values_(l) context3_values_(l)];
%         y = [BSP1_mean_values_(l)-BSP1_var_values_(l)/2, BSP1_mean_values_(l)+BSP1_var_values_(l)/2];
%         plot(x, y);
%         plot([context3_values_(l)-0.05 context3_values_(l)+0.05],[y(1) y(1)]);
%         plot([context3_values_(l)-0.05 context3_values_(l)+0.05],[y(2) y(2)]);
%         hold on;
%     end
%     plot(test_x1, mean13, 'rx');
%     x=[test_x1, test_x1];
%     y=[mean13-var13/2, mean13+var13/2];
%     plot(x, y, 'r');
%     hold on;
%     plot([test_x1-0.05 test_x1+0.05],[y(1) y(1)], 'r');
%     plot([test_x1-0.05 test_x1+0.05],[y(2) y(2)], 'r');
%     axis([-1, 7, -0.1, 1]);
%     name = strcat('Interpolation results for context ',int2str(test_context_index));
%     title(name,... 
%         'FontWeight', 'bold');
%     xlabel('Context component 3');
%     ylabel('BSP component 1');
%     hold off;

    plot(context3_values_, BSP3_mean_values_, xq, interp_3);
    hold on;
    for l = 1:size(context3_values_, 2)
        x = [context3_values_(l) context3_values_(l)];
        y = [BSP3_mean_values_(l)-BSP3_var_values_(l)/2, BSP3_mean_values_(l)+BSP3_var_values_(l)/2];
        plot(x, y);
        plot([context3_values_(l)-0.05 context3_values_(l)+0.05],[y(1) y(1)]);
        plot([context3_values_(l)-0.05 context3_values_(l)+0.05],[y(2) y(2)]);
        hold on;
    end
    plot(test_x3, mean33, 'rx');
    x=[test_x3, test_x3];
    y=[mean33-var33/2, mean33+var33/2];
    plot(x, y, 'r');
    hold on;
    plot([test_x3-0.05 test_x3+0.05],[y(1) y(1)], 'r');
    plot([test_x3-0.05 test_x3+0.05],[y(2) y(2)], 'r');
    axis([-1, 7, -0.1, 1]);
    name = strcat('Interpolation results for context ',int2str(test_context_index));
    title(name,... 
        'FontWeight', 'bold');
    xlabel('Context component 3');
    ylabel('BSP component 3');
    hold off;
     
    % new_edit_Jan15_end
    
    if (counter11 ~= 0)
        mean11 = temp_mean11/counter11;
        var11 = temp_var11/counter11;
        mean21 = temp_mean21/counter21;
        var21 = temp_var21/counter21;
        mean31 = temp_mean31/counter31;
        var31 = temp_var31/counter31;
        mean41 = temp_mean41/counter41;
        var41 = temp_var41/counter41;
    else
        mean11 = 0;
        var11 =1000;
        mean21 = 0;
        var21 = 1000;
        mean31 = 0;
        var31 = 1000;
        mean41 = 0;
        var41 = 1000;
    end
    
    if (counter12 ~= 0)
        mean12 = temp_mean12/counter12;
        var12 = temp_var12/counter12;
        mean22 = temp_mean22/counter22;
        var22 = temp_var22/counter22;
        mean32 = temp_mean32/counter32;
        var32 = temp_var32/counter32;
        mean42 = temp_mean42/counter42;
        var42 = temp_var42/counter42;
    else
        mean12 = 0;
        var12 = 1000;
        mean22 = 0;
        var22 = 1000;
        mean32 = 0;
        var32 = 1000;
        mean42 = 0;
        var42 = 1000;
    end
    
    % substituted by interpolation
    
    %b_mean1 = regress(BSP1_mean_values', context3_values');
    %%b_var1 = regress( BSP1_var_values', context3_values');
    %mean13 = b_mean1*In(test_context_index, 3);
    %var13 = b_var1*In(test_context_index, 3);
    
%     b_mean2 = regress(BSP2_mean_values', context3_values');
%     b_var2 = regress( BSP2_var_values', context3_values');
%     mean23 = b_mean2*In(test_context_index, 3);
%     var23 = b_var2*In(test_context_index, 3);
    
    %b_mean3 = regress(BSP3_mean_values', context3_values');
    %b_var3 = regress( BSP3_var_values', context3_values');
    %mean33 = b_mean3*In(test_context_index, 3);
    %var33 = b_var3*In(test_context_index, 3);
    
    if  var13 == 0
        var13 = 1000;
    end
    if  var23 == 0
        var23 = 1000;
    end
    if  var33 == 0
        var33 = 1000;
    end
    if  var43 == 0
        var43 = 1000;
    end
    
%             temp_mean22 = ;
%             temp_var22 = b_var1;
%             
%             b_mean2
%             b_var2
%             
%             b_mean3
%             b_var3

    Res_BSP_1 = ((1/var11)/(1/var11+1/var12+1/var13))*mean11 +  ((1/var12)/(1/var11+1/var12+1/var13))*mean12 + ((1/var13)/(1/var11+1/var12+1/var13))*mean13;
    Res_BSP_2 =  (1/var21/(1/var21+1/var22+1/var23))*mean21 +  (1/var22/(1/var21+1/var22+1/var23))*mean22 + (1/var23/(1/var21+1/var22+1/var23))*mean23;
    Res_BSP_3 =  (1/var31/(1/var31+1/var32+1/var33))*mean31 +  (1/var32/(1/var31+1/var32+1/var33))*mean32 + (1/var33/(1/var31+1/var32+1/var33))*mean33;
    Res_BSP_4 =  (1/var41/(1/var41+1/var42+1/var43))*mean41 +  (1/var42/(1/var41+1/var42+1/var43))*mean42 + (1/var43/(1/var41+1/var42+1/var43))*mean43;
    temp_res = [Res_BSP_1; Res_BSP_2; Res_BSP_3];
    temp_res = temp_res/sum(temp_res);
    temp_res = [temp_res; Res_BSP_4];
    results = [results [temp_res]];
    results_new = results;
    save('results', 'results');
end
results

% interpolation
% Build linear interpolation function for each of the BSP vector'
% components
% x = [1, 2,  3, 0, -1, 4, 5, 6, -2];
% y = [0, .15, 1.12, 2.36, 2.36, 1.46, .49, .06, 0];
% xq = -3:.01:7;
% interp = interp1(x, y, xq);
% cs = spline(x,[0 y 0]);
% xx = linspace(-3, 7);
% plot(x, y, 'o', xq, interp);
%plot(x,y,'o',xx,ppval(cs,xx),'-');

%for k = 1: Num_BSPs