classdef kVertex < handle

    properties
        s;
        t;
        knotVec;
        cPoint;
        %hEdges
        top;
        right;
        bottom;
        left;
    end
    
    methods
        function obj = kVertex(s, t, knotVec, top, right, bottom, left)
            obj.s = s;
            obj.t = t;
            if nargin < 3
                obj.knotVec = [];
                %hEdges
                obj.top = [];
                obj.right = [];
                obj.bottom = [];
                obj.left = [];   
            else
                obj.knotVec = knotVec;
                %hEdges
                obj.top = top;
                obj.right = right;
                obj.bottom = bottom;
                obj.left = left;   
            end         
        end
        
        function obj = cnctTop(obj, v)
            e = hEdge(obj,v);
            obj.top = e;
        end
        
        function obj = cnctRight(obj, v)
            e = hEdge(obj,v);
            obj.right = e;
        end
        
        function obj = cnctBottom(obj, v)
            e = hEdge(obj,v);
            obj.bottom = e;
        end
        
        function obj = cnctLeft(obj, v)
            e = hEdge(obj,v);
            obj.left = e;
        end
        
        %Connect obj with left vert and vert with right obj
        function obj = cnctLeftRight(obj, vert)
            obj.cnctLeft(vert);
            vert.cnctRight(obj);
        end
        
        %Connect obj with bottom vert and vert with top obj
        function obj = cnctBottomTop(obj, vert)
            obj.cnctBottom(vert);
            vert.cnctTop(obj);
        end
        
        function updateKnotVec(obj, deg)
            obj.knotVec = obj.getKnotVec(deg);
        end
        
        function knots = getKnotVec(obj, deg)
            %odd or even
            knotsS = [];
            knotsT = [];
            sCount = 0;
            if mod(deg,2) == 0
                sCount = deg/2+1;
            else
                sCount = (deg+1)/2;
                knotsS = [obj.s];
                knotsT = [obj.t];
            end
            
            %First for s
            curVert = obj;
            for i=1:sCount
                s = curVert.s;
                [p curVert] = shootLeft(curVert);
                s = s-p;
                knotsS = [s knotsS];
            end
            
            curVert = obj;
            for i=1:sCount
                s = curVert.s;
                [p curVert] = shootRight(curVert);
                s = s+p;
                knotsS = [knotsS s];
            end
            
            %Then for t
            curVert = obj;
            for i=1:sCount
                t = curVert.t;
                [p curVert] = shootBottom(curVert);
                t = t-p;
                knotsT = [t knotsT];
            end
            
            curVert = obj;
            for i=1:sCount
                t = curVert.t;
                [p curVert] = shootTop(curVert);
                t = t+p;
                knotsT = [knotsT t];
            end
            
            knots = [knotsS; knotsT];
        end
        
        function [p curVert] = shootLeft(startVert)
            if ~isempty(startVert.left)
                curVert = startVert.left.endVert;
                p = startVert.s-curVert.s;
                return;
            end
            %If no left turn => go down until there is a left turn
            curVert = startVert;
            while isempty(curVert.left)
                %We are on a border
                if isempty(curVert.bottom)
                    p = 0;
                    return;
                end
                curVert = curVert.bottom.endVert;
            end
            %Then left until there is a top turn
            curVert = curVert.left.endVert;
            while isempty(curVert.top)
                curVert = curVert.left.endVert;
            end
            p = startVert.s-curVert.s;
            
            %Get the vertex with larger t than startVert.t for the next shoot
            while curVert.t < startVert.t
                if  isempty(curVert.top)
                    error('Inconsistent t-mesh');
                end
                curVert = curVert.top.endVert;
            end
        end
        
        function [p curVert] = shootRight(startVert)
            if ~isempty(startVert.right)
                curVert = startVert.right.endVert;
                p = curVert.s-startVert.s;
                return;
            end
            %If no right turn => go down until there is a right turn
            curVert = startVert;
            while isempty(curVert.right)
                if isempty(curVert.bottom)
                    p = 0;
                    return;
                end
                curVert = curVert.bottom.endVert;
            end
            %Then right until there is a top turn
            curVert = curVert.right.endVert;
            while isempty(curVert.top)
                curVert = curVert.right.endVert;
            end
            p = curVert.s-startVert.s;
            
            %Get the vertex with larger t than startVert.t for the next shoot
            curVert = curVert.top.endVert;
            while curVert.t < startVert.t
                if  isempty(curVert.top)
                    error('Inconsistent t-mesh');
                end
                curVert = curVert.top.endVert;
            end
        end
        
        function [p curVert] = shootTop(startVert)
            if ~isempty(startVert.top)
                curVert = startVert.top.endVert;
                p = curVert.t-startVert.t;
                return;
            end
            %If no top turn => go left until there is a top turn
            curVert = startVert;
            while isempty(curVert.top)
                if isempty(curVert.left)
                    p = 0;
                    return;
                end
                curVert = curVert.left.endVert;
            end
            %Then top until there is a right turn
            curVert = curVert.top.endVert;
            while isempty(curVert.right)
                curVert = curVert.top.endVert;
            end
            p = curVert.t-startVert.t;
            
            %Get the vertex with larger s than startVert.s for the next shoot
            curVert = curVert.right.endVert;
            while isempty(curVert.t < startVert.t)
                if isempty(curVert.right)
                    error('Inconsistent t-mesh');
                end
                curVert = curVert.right.endVert;
            end
        end
        
        function [p curVert] = shootBottom(startVert)
            if ~isempty(startVert.bottom)
                curVert = startVert.bottom.endVert;
                p = startVert.t-curVert.t;
                return;
            end
            %If no bottom turn => go left until there is a bottom turn
            curVert = startVert;
            while isempty(curVert.bottom)
                if isempty(curVert.left)
                    p = 0;
                    return;
                end
                curVert = curVert.left.endVert;
            end
            %Then bottom until there is a right turn
            curVert = curVert.bottom.endVert;
            while isempty(curVert.right)
                curVert = curVert.bottom.endVert;
            end
            p = startVert.t-curVert.t;
            
            %Get the vertex with larger s than startVert.s for the next shoot
            curVert = curVert.right.endVert;
            while isempty(curVert.t < startVert.t)
                if isempty(curVert.right)
                    error('Inconsistent t-mesh');
                end
                curVert = curVert.right.endVert;
            end
        end
    end
    
end

