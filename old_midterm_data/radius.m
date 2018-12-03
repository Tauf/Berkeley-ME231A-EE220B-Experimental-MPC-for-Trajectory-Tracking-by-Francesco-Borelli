function r= radius(X)
    
    global profile
    
    l0=size(profile,1);
    
    r=profile(1,3);
    for i=1:l0-1
        if X >= profile(i,1) && X < profile(i+1,1)
            r= profile(i,3);
            break
        end
    end
    if X >= profile(l0,1)
       r= profile(l0,3);
    end

end

