function [start, goal, R_rob, obstacles, human, dimX, dimY] = CreateWorkspace(drawPlot, HardCoded, context)
    % context is the 3dimensional vector: [presense of the human(yes/no), task type(collab/non-collab), orientation of the human towards the robot start position]

	%dimensions of the workspace
	dimX = 300;
	dimY = dimX;
    step = 10;

    if (HardCoded == true)
        %initalize the obstacle regions
        num_obstacles = 3;
        R_obs = [dimX/6 dimX/4 dimX/4];
        X_obs = [dimX*7/20 dimX*17/20 dimX*19/20];
        Y_obs = [dimY/2 dimY/4 dimY*3/4];
        obstacles = [X_obs(1) X_obs(2) X_obs(3); Y_obs(1) Y_obs(2) Y_obs(3); R_obs(1) R_obs(2) R_obs(3)];
        
        %initalize the robot
        R_rob = 5;
        X_rob = round(dimX*11/20);
        Y_rob = round(dimY*16/20);
        start = [X_rob Y_rob];
        
        %initalize the human
        if (context(1) == 1)
            R_hum = dimX/20;
            X_hum = dimX*3/20;
            Y_hum = dimY*14/20;
            Angle_hum = context(3);
            human = [X_hum Y_hum R_hum Angle_hum];
        else 
            R_hum = -1;
            X_hum = -1;
            Y_hum = -1;
            Angle_hum = -1;
        end
        human = [X_hum Y_hum R_hum Angle_hum];
        
        %initalize the goal
         X_goal = round(dimX*3/20);
         Y_goal = round(dimY*5/20);
         goal = [X_goal Y_goal];
         
    else
        %initalize the obstacle regions
        num_obstacles = 3;
        R_obs = [unifrnd(dimX/10, dimX/3), unifrnd(dimX/10, dimX/3), unifrnd(dimX/10, dimX/3)];
        X_obs = [unifrnd(dimX/20, dimX*19/20),unifrnd(dimX/20, dimX*19/20),unifrnd(dimX/20, dimX*19/20)];
        Y_obs = [unifrnd(dimX/20, dimX*19/20),unifrnd(dimX/20, dimX*19/20),unifrnd(dimX/20, dimX*19/20)];
        obstacles = [X_obs(1) X_obs(2) X_obs(3); Y_obs(1) Y_obs(2) Y_obs(3); R_obs(1) R_obs(2) R_obs(3)];

        %initalize the robot
        while (1)
            R_rob = 5;
            X_rob = round(unifrnd(dimX/20, dimX*19/20));
            Y_rob = round(unifrnd(dimX/20, dimX*19/20));
            %Distances between the center of the robot and the centers of the obstacles
            Dist1 = sqrt( (X_rob - X_obs(1))^2 + (Y_rob - Y_obs(1))^2 );
            Dist2 = sqrt( (X_rob - X_obs(2))^2 + (Y_rob - Y_obs(2))^2 );
            Dist3 = sqrt( (X_rob - X_obs(3))^2 + (Y_rob - Y_obs(3))^2 );
            if ( (Dist1 > (R_rob + R_obs(1))) && (Dist2 > (R_rob + R_obs(2))) && (Dist3 > (R_rob + R_obs(3))))
                break;
            end
        end
        start = [X_rob Y_rob];

        %initalize the human
        while (1)
            R_hum = dimX/20;
            X_hum = unifrnd(dimX/20, dimX*19/20);
            Y_hum = unifrnd(dimX/20, dimX*19/20);
            Angle_hum = unifrnd(0, 2*pi);
            %Distances between the center of the human and the centers of the obstacles and robot
            Dist1 = sqrt( (X_hum - X_obs(1))^2 + (Y_hum - Y_obs(1))^2 );
            Dist2 = sqrt( (X_hum - X_obs(2))^2 + (Y_hum - Y_obs(2))^2 );
            Dist3 = sqrt( (X_hum - X_obs(3))^2 + (Y_hum - Y_obs(3))^2 );
            Dist4 = sqrt( (X_hum - X_rob)^2 + (Y_hum - Y_rob)^2 );
            if ( (Dist1 > (R_hum + R_obs(1))) && (Dist2 > (R_hum + R_obs(2))) && (Dist3 > (R_hum + R_obs(3))) && (Dist4 > (R_hum + R_rob)))
                break
            end
        end
        human = [X_hum Y_hum R_hum Angle_hum];

        %initalize the goal
        while (1)
            X_goal = round(unifrnd(dimX/20, dimX*19/20));
            Y_goal = round(unifrnd(dimX/20, dimX*19/20));

            %Distances between the center of the human and the centers of the obstacles and robot
            Dist1 = sqrt( (X_goal - X_obs(1))^2 + (Y_goal - Y_obs(1))^2 );
            Dist2 = sqrt( (X_goal - X_obs(2))^2 + (Y_goal - Y_obs(2))^2 );
            Dist3 = sqrt( (X_goal - X_obs(3))^2 + (Y_goal - Y_obs(3))^2 );
            Dist4 = sqrt( (X_goal - X_rob)^2 + (Y_goal - Y_rob)^2 );
            Dist5 = sqrt( (X_goal - X_hum)^2 + (Y_goal - Y_hum)^2 );
            if ( (Dist1 > (R_obs(1)+2*R_rob)) && (Dist2 > (R_obs(2)+2*R_rob)) && (Dist3 > (R_rob + 2*R_obs(3))) && (Dist4 > (R_rob + 2*R_rob))  && (Dist5 > (R_hum + R_rob)) )
                break
            end
        end
        goal = [X_goal Y_goal];        
    end
    
	%plot the scene

    if (drawPlot)
		t = linspace(0,2*pi,100)';
        for i = 1:num_obstacles
			circsx = R_obs(i).*cos(t) + X_obs(i);
			circsy = R_obs(i).*sin(t) + Y_obs(i);
			plot(circsx,circsy);
			hold on;
        end
		circsx = R_rob.*cos(t) + X_rob;
		circsy = R_rob.*sin(t) + Y_rob;
		fill(circsx,circsy, 'b');
		hold on;
		circsx = R_hum.*cos(t) + X_hum;
		circsy = R_hum.*sin(t) + Y_hum;
		fill(circsx,circsy, 'g');
        x(1) = X_hum;
        y(1) = Y_hum;
        x(2) = x(1) + R_hum * cos(Angle_hum);
        y(2) = y(1) + R_hum * sin(Angle_hum);
        plot(x',y');
        hold on;
        circsx = 5.*cos(t) + X_goal;
		circsy = 5.*sin(t) + Y_goal;
        fill(circsx,circsy, 'r');
		hold on
		axis([0,dimX,0,dimY]) 
        xlabel('x'), ylabel('y'), title('Robot task space')
    end
end
