classdef hEdge < handle
    
    properties
        %Vertices
        startVert;
        endVert;
    end
    
    methods
        function obj = hEdge(startVert, endVert)
            obj.startVert = startVert;
            obj.endVert = endVert;
        end
    end
    
end

