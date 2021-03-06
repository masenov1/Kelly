s = restartConnection();
figure;
axis([-400,400,-400,400]);
path_clear = 1;
low_threshold = 40;
high_threshold = 65;

%reset counts
sensors = zeros(1,8);
av_sensors = sensors;
x = 0;
y = 0;
phi = 0;
setCounts(s, 0, 0);
global_speed = 3;
go(s,global_speed);
current_time = clock;
map = ones(401,401);
countdown = 0;
while (av_sensors(8) < 300)
    
    
    if (abs(cl(6) - current_time(6)) > 0.5)
        [x,y,phi,countdown,map,current_time] = calculateOdometry(s,counts(1),counts(2),x,y,phi,countdown,map,current_time);
        if countdown > global_speed*400
            break;
        end
    end
    if path_clear
        if (av_sensors(4) > high_threshold)
            path_clear = 0;
        end
    else
        % Obstacle in front
        % We shouldn't use the third sensor, otherwise we keep fluctuating
        % between "Obstacle in front" and "Too far away from the wall"
        if (av_sensors(4) > high_threshold)
            % Turn left in place
            speed = [-global_speed,global_speed];
            turn(s,-global_speed,global_speed);
        % Too close to the wall
        elseif (av_sensors(6) > high_threshold*1.5)
            % Turn left curved
            sharpness = calculateTurn(av_sensors(6),high_threshold*1.5,high_threshold*1.5*2,global_speed);
            if (sum(speed == [sharpness,global_speed] < 1))
                speed = [sharpness,global_speed];
                turn(s,sharpness,global_speed);
            end
        % Too far away from the wall
        elseif (av_sensors(6) < low_threshold*1.5)
            % Turn right curved
            sharpness = calculateTurn(av_sensors(6),0,low_threshold*1.5,global_speed);
            if (sum(speed == [global_speed,sharpness] < 1))
                speed = [global_speed,sharpness];
                turn(s,global_speed,sharpness);
            end
        % Keep straight
        else
            if (sum(speed == [global_speed,global_speed] < 1))
                speed = [global_speed,global_speed];
                go(s,global_speed);
            end
        end
    end
    %imshow(flipdim(flipdim(map,1),2))
    %imshow(map)
end
stop(s);


go(s,global_speed);
speed = [global_speed,global_speed];
while (abs(x) + abs(y) > 4)
    %imshow(map)
    [sensors, av_sensors] = readIRAV(s,av_sensors);
    [x,y,phi,current_time] = calculateAngle(s,x,y,phi,map,current_time); 
    go(s,global_speed);
    while (av_sensors(4) < high_threshold && abs(x) + abs(y) > 100)
        abs(x) + abs(y)
        counts = readCounts(s);
        cl = clock;
        if (abs(cl(6) - current_time(6)) > 0.5)
            [x,y,phi,countdown,map,current_time] = calculateOdometry(s,counts(1),counts(2),x,y,phi,countdown,map,current_time);
        end
        [sensors, av_sensors] = readIRAV(s,av_sensors);
    end
    if (av_sensors(4) > high_threshold)
        turn(s,-global_speed,global_speed);
        while (av_sensors(4) > high_threshold)
            counts = readCounts(s);
            cl = clock;
            if (abs(cl(6) - current_time(6)) > 0.5)
                [x,y,phi,countdown,map,current_time] = calculateOdometry(s,counts(1),counts(2),x,y,phi,countdown,map,current_time);
            end
            [sensors, av_sensors] = readIRAV(s,av_sensors);
        end
        angle = phi;
        while (abs(angle-phi) < 100)
            counts = readCounts(s);
            cl = clock;
            if (abs(cl(6) - current_time(6)) > 0.5)
                [x,y,phi,countdown,map,current_time] = calculateOdometry(s,counts(1),counts(2),x,y,phi,countdown,map,current_time);
            end
            [sensors, av_sensors] = readIRAV(s,av_sensors);
            % Obstacle in front
            % We shouldn't use the third sensor, otherwise we keep fluctuating
            % between "Obstacle in front" and "Too far away from the wall"
            if (av_sensors(4) > high_threshold)
                % Turn left in place
                speed = [-global_speed,global_speed];
                turn(s,-global_speed,global_speed);
            % Too close to the wall
            elseif (av_sensors(6) > high_threshold*1.5)
                % Turn left curved
                sharpness = calculateTurn(av_sensors(6),high_threshold*1.5,high_threshold*1.5*2,global_speed);
                if (sum(speed == [sharpness,global_speed] < 1))
                    speed = [sharpness,global_speed];
                    turn(s,sharpness,global_speed);
                end
            % Too far away from the wall
            elseif (av_sensors(6) < low_threshold*1.5)
                % Turn right curved
                sharpness = calculateTurn(av_sensors(6),0,low_threshold*1.5,global_speed);
                if (sum(speed == [global_speed,sharpness] < 1))
                    speed = [global_speed,sharpness];
                    turn(s,global_speed,sharpness);
                end
            % Keep straight
            else
                if (sum(speed == [global_speed,global_speed] < 1))
                    speed = [global_speed,global_speed];
                    go(s,global_speed);
                end
            end
        end
    end
    
    pause(0.07);
    counts = readCounts(s);
    [x,y,phi,countdown,map,current_time] = calculateOdometry(s,counts(1),counts(2),x,y,phi,countdown,map,current_time);
end
stop(s);
%imshow(flipdim(flipdim(map,1),2));




