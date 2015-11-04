function [av_sensors,x,y,phi,current_time,current_speed] = adjustAngle(s,goal_x,goal_y,x,y,phi,current_time,av_sensors,current_speed,global_speed)
    direction = rad2deg(atan2(y-goal_y,x-goal_x))+180;
    difference = min(abs(phi-direction),abs(direction-phi));
    [direction,phi,difference,current_speed]
    if (difference > 30)
        if (mod(direction-phi,360)<180)
            new_speed = [-global_speed,global_speed];
        else
            new_speed = [global_speed,-global_speed];
        end
    else
        steps = floor(difference/floor(30/global_speed));
        
        if (mod(direction-phi,360)<180)
            new_speed = [global_speed-steps,global_speed+steps];
        else
            new_speed = [global_speed+steps,global_speed-steps];
        end
    end
    if (sum(new_speed == current_speed)~=2)
        current_speed = new_speed;
        turn(s,current_speed(1),current_speed(2));
    end
    [av_sensors,x,y,phi,current_time] = updatePosition(s,av_sensors, current_time, x, y, phi);
end
