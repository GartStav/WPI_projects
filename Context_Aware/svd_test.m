
C = [0 0 0; 1 0 0; 1 0 pi/2; 1 0 pi; 1 0 3*pi/2;  1 1 0; 1 1 pi/4; 1 1 pi/2; 1 1 pi; 1 1 3*pi/2];
load('BSP_tr');
BSP_ = BSP(:,:,1)';

X = C;
Y = BSP_;

for i = 1:4
    subplot(2,2,i)
    plot(X(:,1),Y(:,i),'ro');
    hold on;
    plot(X(:,2),Y(:,i),'go');
    hold on;
    plot(X(:,3),Y(:,i),'bo');
    hold off;
    name = strcat('BSp component',int2str(i));
    title(name);
end
mean1 = mean(X(:,1));
mean2 = mean(X(:,2));
mean3 = mean(X(:,3));
m = [mean1; mean2; mean3];
h = zeros(10,1)+1;
b = h*m';
X_new = X - b;
test = [X Y];
[U, S, V] = svd(X_new);
T = U*S;
%plot(T(:,3), T(:,4), 'or');
%hold on;
%plot(X(:,3), Y(:,1), 'og');
%plot(T(:,2), T(:,4), 'g');
%hold on;
%plot(T(:,3), T(:,4), 'b');
%axis([-10 10 -1 1]);
%hold off;

for i = 1:4
    subplot(2,2,i)
    plot(T(:,1),Y(:,i),'ro');
    hold on;
    plot(T(:,2),Y(:,i),'go');
    hold on;
    plot(T(:,3),Y(:,i),'bo');
    hold off;
    name = strcat('BSp component',int2str(i));
    title(name);
end

beta1 = mvregress(T, Y(:,1));
beta2 = mvregress(T, Y(:,2));
beta3 = mvregress(T, Y(:,3));
beta4 = mvregress(T, Y(:,4));
results_svd = [];
for i = 1:10
    BSP1 = T(i,1:3)*beta1;
    BSP2 = T(i,1:3)*beta2;
    BSP3 = T(i,1:3)*beta3;
    BSP4 = T(i,1:3)*beta4;
    bsp = [BSP1 BSP2 BSP3]
    %bsp = bsp/sum(bsp);
    bsp = [bsp BSP4];
    results_svd = [results_svd bsp'];
end

plot(T(:,1),Y(:,1),'ro');
hold on;
plot(T(:,1), results_svd(1,:)', 'ko');
scatter3(X(:,1),X(:,2),X(:,3));
scatter3(T(:,1),T(:,2),T(:,3));

save('results_svd','results_svd');

