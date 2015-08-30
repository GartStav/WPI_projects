function [res_coord] = A_star(start, goal, R_rob, obstacles, human, dimX, dimY, coef, color)
	% BSP coefficients is the 3dimensional vector: [state cost,
	% distance to the human (the far is better), orientation of the human
	% (if oriented towards the human, the bigger cost)]

    
	%set up the index that is unique for each node
	gindex = 1;
	%set up the step
	step = 10;
    coef_for_cost = coef(1,1:3);
    %coef_for_cost = [0.4111    0.3214    0.2675];

    s = 0;
    for i = 1:3
        s = coef_for_cost(i) + s;
    end
    if s ~= 1
        coef_for_cost = coef_for_cost/s;
    end
    
    if human(1) == -1
        coef_for_cost = [1 0 0];
    end

	%set the cost function for start node
	G_cost = 0;
	H_cost = heuristic_estimation(start, goal);
	F_cost = coef_for_cost(1)*G_cost + H_cost + coef_for_cost(2)*dist_to_human_cost(start, human, dimX) + coef_for_cost(3)*orient_of_human_cost(start, human, dimX);

	%the form of the vector for 2dimensional problem is [index X Y G_cost H_cost F_cost parent_index]
	start = [gindex start G_cost H_cost F_cost 0];

	%initialize the openset with start point
	openset = start';
	closedset = [];
	calculated_path = [];
    
    n_op = size(openset);
    while (n_op(2) > 0)
        %n = size(openset);
		[~, ind_current] = min(openset(6,:));
		current = openset(:, ind_current);
        if ( if_goal_reached(current(2:3), goal', step) )
			%execute calc_path and return it
			calculated_path = [calculated_path current];
			calculated_path = calculate_the_path(calculated_path, current, closedset);
			res_coord = [];
            for i = 1:size(calculated_path,2)
				res_coord = [res_coord calculated_path(2:3, i)]; 	
            end
            if (color == 1)
                plot( res_coord(1, :), res_coord(2, :), 'xr');
            elseif (color == 0)
                plot( res_coord(1, :), res_coord(2, :), 'ob');
            elseif (color == 2)
                plot( res_coord(1, :), res_coord(2, :), '*g');
            elseif (color == 3)
                plot( res_coord(1, :), res_coord(2, :), 'dk');
            elseif (color == 4)
                plot( res_coord(1, :), res_coord(2, :), 'sy');
            end
            hold on;
            move_robot(res_coord(1, :), res_coord(2, :), coef(4), color);
            if (color == 1)
                hold off;
            else
                hold on;
            end
			break;
        end
		
		%remove current from openset
        n = size(openset);
		openset = [openset(:, 1:ind_current-1) openset(:, ind_current+1:n(2))];
		%add current to close set
		closedset = [closedset current];

		%find neighbors for the current node
		neighbor_set = find_neighbors(current, step, true, R_rob, obstacles, human, dimX, dimY, coef_for_cost, goal);
        
        n_ns = size(neighbor_set);
        for i = 1:n_ns(2)
            neighbor = neighbor_set(:, i);
            %plot( neighbor(2, :), neighbor(3, :), 'og');
            %hold on;
        end
        for neighbor_ind = 1:n_ns(2)
			
			neighbor = neighbor_set(:, neighbor_ind);

			%if node is in closed set do nothing
			%found_cols1_cs and found_cols2_cs means columns indecies found according to X and Y coordaintes

            found_in_closed = false;
			found_cols1_cs = find( closedset(2, :) == neighbor(2) );
            n = size(found_cols1_cs);
            if (n(2) > 0)
                for i = 1:n(2)
                    if ( closedset(3, found_cols1_cs(i) ) == neighbor(3) )
						%c = "the same elemenet found is closedlist"
						found_in_closed = true;
                        break;
                    end
                end
            end
			
			%if node is in open set compare the G_scores
						
            if ~found_in_closed
                node_edited = false;
                found_cols1_os = find( openset(2, :) == neighbor(2) );
                n = size(found_cols1_os);
                if (n(2) > 0)
                    for i = 1:n(2)
                        if ( openset(3, found_cols1_os(i) ) == neighbor(3) )
                            %compare g_scores and update it if necessary
                            %c = "the same elemenet found is openlist"
                            node_edited = true;
                            if ( openset(6, found_cols1_os(i) ) > neighbor(6) )
                                openset(4, found_cols1_os(i)) = neighbor(4);
                                openset(5, found_cols1_os(i)) = neighbor(5);
                                openset(6, found_cols1_os(i)) = neighbor(6);
                                %update the parent
                                openset(7, found_cols1_os(i)) = neighbor(1);
                            end

                        end

                    end
                end	

                %otherwise calculate heristic and add to open set
                if node_edited == false
                    gindex = gindex + 1;
                    neighbor(1) = gindex;			
                    %neighbor(5) = coef_for_cost(1)*heuristic_estimation(neighbor(2:3), goal');
                    %neighbor(6) = neighbor(4) + neighbor(5) + coef_for_cost(2)*dist_to_human_cost(neighbor(2:3), human, dimX) + coef_for_cost(3)*orient_of_human_cost(start, human, dimX);
                    %set up the parent
                    neighbor(7) = current(1);
                    openset = [openset neighbor];
                end
                %openset
            end
        end
        %plot( current(2, :), current(3, :), 'og');
        %hold on;
    end
	if (color == 1)
       hold off;
    else
       hold on;
    end
end

% function that moves the robot
function move_robot(X, Y, move_coef, color)
    DELAY = move_coef*0.5;
    size_x = size(X);
    
    if color == 1
       colorstr = 'r'; 
    elseif color == 0
        colorstr = 'b';
    elseif color == 2
        colorstr = 'g';
    elseif color == 3
        colorstr = 'k';
    elseif color == 4
        colorstr = 'y';
    end
    
    robot_mv = line('XData', X(size_x(2)), 'YData', Y(size_x(2)), 'Color','k', ...
    'Marker','s', 'MarkerSize',6, 'LineWidth',2);

    for i = 1:size_x(2)
        set(robot_mv, 'XData',X(size_x(2)+1-i), 'YData',Y(size_x(2)+1-i));
        drawnow;
        pause(DELAY);
    end
end

%function that computes if we reached the goal or not
function [result] = if_goal_reached(node, goal, step) 
    if ( ((goal(1)-step/2) <= node(1)) && (node(1) <= (goal(1)+step/2)) && ((goal(2)-step/2) <= node(2)) && (node(2) <= (goal(2)+step/2)) ) 
		result = true;
	else
		result = false;
    end
end

%function that estimates the heuristic
function [heuristic_est] = heuristic_estimation(node, goal)
	%distance from the expanded node to the goal	
    if (size(node) == size(goal))
		heuristic_est = sqrt((node(1) - goal(1))^2 + (node(2) - goal(2))^2);
	else
		'Error: The dimensions of expanded node and goal vectors are different'
    end
end

function [add_cost] = dist_to_human_cost(node, human, dimX)
    if human(1) == -1
        add_cost = 0;
    else
        dist_to_human = sqrt( (node(1) - human(1))^2 + (node(2) - human(2))^2 );
        add_cost = (-1./(1+exp(-dist_to_human/10))+1) * dimX;
        %add_cost = 1./dist_to_human;
        %add_cost = -dist_to_human/(sqrt(2)*2) + dimX/2;
    end
end

function [add_cost] = orient_of_human_cost(start, human, dimX)
    if human(4) == -1
        add_cost = 0;
    else
        dist_to_X = start(1) - human(1);
        dist_to_Y = start(2) - human(2);
        x = abs(dist_to_Y) / abs(dist_to_X);
        ang = atan(dist_to_Y / dist_to_X);
        angle_to_X = atan(x);
        uni_angle = 0;
        if dist_to_X > 0 && dist_to_Y > 0
            uni_angle = angle_to_X;
        elseif dist_to_X > 0 && dist_to_Y < 0
            uni_angle = 2*pi - angle_to_X;
        elseif dist_to_X < 0 && dist_to_Y < 0
            uni_angle = pi + angle_to_X;
        elseif dist_to_X < 0 && dist_to_Y > 0
            uni_angle = pi - angle_to_X;
        end
        res_angle = abs(uni_angle - human(4));
        if res_angle > pi 
            res_angle = 2*pi - res_angle;
        end
        %add_cost = (-1./(1+exp(-5*res_angle))+1)*dimX;
       add_cost = log(1+res_angle)*dimX/4;
    end
end

%find neighbors for the node, the value of connected defines if the space is 4 or 8 connected 
function [neighbor_set] = find_neighbors(node, step, connected8, R_rob, obstacles, human, dimX, dimY, coef_for_cost, goal)

	candidates = [];
	neighbor_set = [];
    for i = 1:4
		candidates = [candidates node];
		%set the G_score
		candidates(4,i) = candidates(4,i) + coef_for_cost(1)*step;
    end
	candidates(2,1) = candidates(2,1) + step;
	candidates(3,2) = candidates(3,2) + step;
	candidates(2,3) = candidates(2,3) - step;
	candidates(3,4) = candidates(3,4) - step;
	
	%initialize diagonal neigbors
    if (connected8)
        for i = 5:8
			candidates = [candidates node];
			%set the G_score
			candidates(4,i) = candidates(4,i) + coef_for_cost(1)*(step * sqrt(2));
        end
		candidates(2,5) = candidates(2,5) + step;
		candidates(3,5) = candidates(3,5) + step;

		candidates(2,6) = candidates(2,6) + step;
		candidates(3,6) = candidates(3,6) - step;
	
		candidates(2,7) = candidates(2,7) - step;
		candidates(3,7) = candidates(3,7) + step;
	
		candidates(2,8) = candidates(2,8) - step;
		candidates(3,8) = candidates(3,8) - step;
    end

	%check for collisions candidates(:,i)
	%if collision check successfull add candidate to the neighbor set
    
    n = size(candidates);
    
    %koef = 0.5;
    %add dist_to_human
    % for j = 1:n(2)
        %dist_to_human = sqrt( (candidates(2,j) - human(1))^2 + (candidates(3,j) - human(2))^2 );
        %candidates(4,j) = candidates(4,j) - koef*dist_to_human;
        %if candidates(4,j) < 0
        %    candidates(4,j) = 0;
        %end
    %end
    
    for j = 1:n(2)
        
        if ( (0 < candidates(2,j)) && (candidates(2,j) < dimX) && (0 < candidates(3,j)) && (candidates(3,j) < dimY) )
        
            Dist1 = sqrt( (candidates(2,j) - obstacles(1,1))^2 + (candidates(3,j) - obstacles(2,1))^2 );
            Dist2 = sqrt( (candidates(2,j) - obstacles(1,2))^2 + (candidates(3,j) - obstacles(2,2))^2 );
            Dist3 = sqrt( (candidates(2,j) - obstacles(1,3))^2 + (candidates(3,j) - obstacles(2,3))^2 );
            Dist4 = sqrt( (candidates(2,j) - human(1))^2 + (candidates(3,j) - human(2))^2 );

            if ( (Dist1 > (R_rob + obstacles(3,1))) && (Dist2 > (R_rob + obstacles(3,2))) && (Dist3 > (R_rob + obstacles(3,3))) && (Dist4 > (R_rob + human(3))) )
                candidates(5, j) = coef_for_cost(1)*heuristic_estimation(candidates(2:3, j), goal');
                candidates(6, j) = candidates(4, j) + candidates(5, j) + coef_for_cost(2)*dist_to_human_cost(candidates(2:3, j), human, dimX) + coef_for_cost(3)*orient_of_human_cost(candidates(2:3, j), human, dimX);
                neighbor_set = [neighbor_set candidates(:, j)];
            end
        end
		
    end
	%neighbor_set = candidates;
    end

%recursive function to calculate the path
function [new_path] = calculate_the_path(calculated_path, next_node, closedset)
    if (next_node(7) > 0)
		parent_index = find(closedset(1, :) == next_node(7));
		new_path = [ calculated_path closedset(:, parent_index) ];
		new_path = calculate_the_path(new_path, closedset(:, parent_index), closedset);
	else
		new_path = calculated_path;
    end
	
end
