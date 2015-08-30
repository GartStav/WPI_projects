
C = [0 0 0; 1 0 0; 1 0 pi/2; 1 0 pi; 1 0 3*pi/2;  1 1 0; 1 1 pi/4; 1 1 pi/2; 1 1 pi; 1 1 3*pi/2];
load('BSP_tr');
BSP_ = BSP(:,:,1)';

results_reg = [];
%regression cross validation
% for i = 1:10
%     con_test = [];
%     BSP_test = [];
%     for j = 1:10
%         if j ~= i
%            con_test = [con_test C(j,:)'];
%            BSP_test = [BSP_test BSP_(j,:)'];
%         end
%     end
%     X = con_test';
%     Y = BSP_test';
%     %C = mat2cell(X, [1 1 1 1 1 1 1 1 1], [3]);
%     %betta = mvregress(C, Y);
%     beta1 = mvregress(X, Y(:,1));
%     beta2 = mvregress(X, Y(:,2));
%     beta3 = mvregress(X, Y(:,3)); 
%     beta4 = mvregress(X, Y(:,4));
% 
%     BSP1 = C(i,:)*beta1;
%     BSP2 = C(i,:)*beta2;
%     BSP3 = C(i,:)*beta3;
%     BSP4 = C(i,:)*beta4;
%     
%     BSP_res = [BSP1/(BSP1+BSP2+BSP3) BSP2/(BSP1+BSP2+BSP3) BSP3/(BSP1+BSP2+BSP3) BSP4];
%     
%     results_reg = [results_reg BSP_res'];
%     save('results_reg','results_reg');
% end

% multivariate prediction
Y = BSP_;
[n, d] = size(Y);
X = cell(n,1);
for i = 1:n
   X{i} = [eye(d), repmat(C(i,:), d, 1)]; 
end
[betas_tog, sigma, E, covB, logL] = mvregress(X, Y, 'covtype', 'diagonal');
m = mean(abs(E));
v = std(abs(E));

X2 = C;
beta1 = mvregress(X2, Y(:,1));
beta2 = mvregress(X2, Y(:,2));
beta3 = mvregress(X2, Y(:,3));
beta4 = mvregress(X2, Y(:,4));
betas_sep = [beta1, beta2, beta3, beta4];

% nonlinear regression
beta0 = [0.5;0.5;0.5;0.5;0.5];
opts = statset('nlinfit');
opts.RobustWgtFun = 'bisquare';
[beta1_nonlin, r] = nlinfit(X2,Y(:,1),@hougen,beta0, opts);

% fit polynomial
p = polyfit(X2, Y(:,1), 6);

prediction = zeros(10,4);
prediction_new = zeros(10,4);
for i = 1:10
    BSP1 = C(i,:)*beta1;
    BSP2 = C(i,:)*beta2;
    BSP3 = C(i,:)*beta3;
    BSP4 = C(i,:)*beta4;
    BSP_res = [BSP1/(BSP1+BSP2+BSP3) BSP2/(BSP1+BSP2+BSP3) BSP3/(BSP1+BSP2+BSP3) BSP4];
    prediction(i,:) = BSP_res;
    
    %results for correlated version of regression
    BSP_new1 = betas_tog(1) + C(i,:)*betas_tog(5:7);
    BSP_new2 = betas_tog(2) + C(i,:)*betas_tog(5:7);
    BSP_new3 = betas_tog(3) + C(i,:)*betas_tog(5:7);
    BSP_new4 = betas_tog(4) + C(i,:)*betas_tog(5:7);
    BSP_res_new = [BSP_new1/(BSP_new1+BSP_new2+BSP_new3) BSP_new2/(BSP_new1+BSP_new2+BSP_new3) BSP_new3/(BSP_new1+BSP_new2+BSP_new3) BSP_new4];
    prediction_new(i,:) = BSP_res_new;
end

X = C;
Y = BSP_;
%c_ = polyfit(X,

prediction_log = zeros(10,4);
for i = 1:10
    BSP1 = C(i,:)*beta1;
    BSP2 = C(i,:)*beta2;
    BSP3 = C(i,:)*beta3;
    BSP4 = C(i,:)*beta4;
    BSP_res = [BSP1/(BSP1+BSP2+BSP3) BSP2/(BSP1+BSP2+BSP3) BSP3/(BSP1+BSP2+BSP3) BSP4];
    
    prediction_log(i,:) = BSP_res;
end
a = 6;
