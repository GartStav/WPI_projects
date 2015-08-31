% cluster and plot data

format long g
T1=csvread('T12_agg.csv');
[m,n]=size(T1);

S=zeros(m,m);
np = 1;
if false
    %%%%%%%%%%%%%
    [idx,C]=dbscan([T1(:,2),T1(:,8)],20,0.1);

    cluster1 = idx == 1;
    cluster2 = idx == 2;
    outliers = C < 0;

    figure;
    scatter(T1(cluster2,2),T1(cluster2,8),'g','filled');
    hold on;
    scatter(T1(cluster1,2),T1(cluster1,8),'b','filled');
    hold on;
    scatter(T1(outliers,2),T1(outliers,8),'r','filled');
    hold off;
    legend('cluster1', 'cluster2', 'outliers');
    xlabel('nIPdst');
    ylabel('SYN ratio');


    %%%%%%%%%%%%%
    [idx,C]=dbscan([T1(:,2),T1(:,9)],20,0.1);
    cluster1 = idx == 1;
    cluster2 = idx == 2;
    outliers = C < 0;

    figure;
    scatter(T1(cluster2,2),T1(cluster2,9),'g','filled');
    hold on;
    scatter(T1(cluster1,2),T1(cluster1,9),'b','filled');
    hold on;
    scatter(T1(outliers,2),T1(outliers,9),'r','filled');
    hold off;
    legend('cluster1', 'cluster2', 'outliers');
    xlabel('nIPdst');
    ylabel('ICMP ratio');
end

if false
 for i=1:(n-1)
     for j=i+1:n
         
         [idx,C]=dbscan([T1(:,i),T1(:,j)],20,0.1);
         
         border = C >= 0;
         outliers = C < 0;
         
         subplot(6,6,np);
         np = np + 1;
         
         scatter(T1(border,i),T1(border,j), 15.0, 'b');
         hold on;
         scatter(T1(outliers,i),T1(outliers,j), 15.0, 'r');
         hold off;
         
         switch i
             case 1
                 xlabel('nIPsrc')
             case 2
                 xlabel('nIPdst')
             case 3
                 xlabel('nsPrt')
             case 4 
                 xlabel('ndPrt')
             case 5
                 xlabel('nIPsrc/nIPdst')
             case 6
                 xlabel('nPkt/sec')
             case 7
                 xlabel('nPkt/nIPdst')
             case 8
                 xlabel('SYN ratio')
             case 9
                 xlabel('ICMP ratio')
         end 
         
         switch j
             case 2
                 ylabel('nIPdst')
             case 3
                 ylabel('nsPrt')
             case 4
                 ylabel('ndPrt')
             case 5
                 ylabel('nIPsrc/nIPdst')
             case 6
                 ylabel('nPkt/sec')
             case 7
                 ylabel('nPkt/nIPdst')
             case 8
                 ylabel('SYN ratio')
             case 9
                 ylabel('ICMP ratio')
         end 
         
     end
 end
end
 
if true
    for i=2:(n-1)
        for j=i+1:n
            [idx,C]=dbscan([T1(:,i),T1(:,j)],20,0.1);
            
            cluster_size = [];
            weights = [];
            c = 1;
            while ( sum(idx(:)==c) ~= 0)
                temp = sum(idx(:)==c);
                cluster_size = [ cluster_size temp ];
                weights = [weights exp(-5*(temp - 20)/m) ];
                c = c + 1;
            end



            for x=1:(m-1)
                for y=x+1:m
                   if idx(1,x)==idx(1,y);
                       index = idx(1,x);
                       if (index ~= 0) && (index ~= -1)
                           S(x,y)=S(x,y)+weights(index);
                       end
                   end
                end
            end 
        end
    end
end


S_prime = S/max(max(S)); 
S_values = S >0;
S_new = S_prime(S_values);
h  = hist(S_new, 20);
figure;
bar(linspace(0,1,20), log(h));
xlabel('similarity values');
ylabel('logN');

save('Similarity_5.mat','S') 
 
 
 
             
       
