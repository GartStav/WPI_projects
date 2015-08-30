C = [0 0 0; 1 0 0; 1 0 pi/2; 1 0 pi; 1 0 3*pi/2;  1 1 0; 1 1 pi/4; 1 1 pi/2; 1 1 pi; 1 1 3*pi/2];
load('BSP_tr');
BSP_ = BSP(:,:,1)';

X = C;
Y = BSP_;
cx = corr(X);
cy = corr(Y);
call = corr([X Y]);
HeatMap(call);