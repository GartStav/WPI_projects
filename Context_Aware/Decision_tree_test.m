C = [0 0 0; 1 0 0; 1 0 pi/2; 1 0 pi; 1 0 3*pi/2;  1 1 0; 1 1 pi/4; 1 1 pi/2; 1 1 pi; 1 1 3*pi/2];
load('BSP_tr');
BSP_ = BSP(:,:,1)';

X = C
Y = BSP_
tree1 = RegressionTree.fit(X(:,:),Y(:,4), 'Minparent', 2, 'Prune', 'off', 'CategoricalPredictors', [1 2]);
view(tree1,'mode','graph');
results_tree = [];
for i = 1:10
    b = predict(tree1, X(i,:));
    results_tree = [results_tree b'];
end
save('results_tree','results_tree');
