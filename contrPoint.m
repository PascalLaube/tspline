classdef contrPoint < handle

    properties
        x;
        y;
        z;
    end
    
    methods
        function obj = contrPoint(x,y,z)
            obj.x = x;
            obj.y = y;
            obj.z = z;
        end
    end
    
end

