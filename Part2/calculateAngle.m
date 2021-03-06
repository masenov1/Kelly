function [x,y,phi,current_time] = calculateAngle(s,x,y,phi,current_time,av_sensors,high_threshold)
    if (av_sensors(4) > high_threshold)
        angle = mod(phi-90,360);
    else
        angle = phi;
    end
    difference = directionDifference(0,0,x,y,angle)/53;
    if (av_sensors(6) > high_threshold*1.5 || av_sensors(1) > high_threshold*1.5)
        difference = 0;
        0
    elseif (av_sensors(1) > high_threshold*1.5)
        difference = 0.7;
        1
    elseif (av_sensors(6) > high_threshold*1.5)
        difference = -0.7;
        2
    end
        
    if (difference>0)
        turn(s,3,-3);
    else
        turn(s,-3,3);
    end
    difference = abs(difference);
    while(difference>0)
         cl = clock;
        if (abs(cl(6) - current_time(6)) > 0.5)
            counts = readCounts(s);
            [x,y,phi,current_time] = calculateOdometry(s,counts(1),counts(2),x,y,phi,current_time);
            difference = difference - 0.5;
        end
    end
end
