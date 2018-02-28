classdef tSpline < handle
%tSpline:Main T-Spline Class.
%Stores datatypes and handles evaluation and conversion to NURBS.

    properties
        kVertices;
        deg;
    end
    
    methods
        function obj = tSpline(kVertices,deg)
            obj.kVertices = kVertices;
            obj.deg = deg;
        end
        
        %Show the preimage of the t-spline
        function printPreImageColor(obj)
            hold on;
            for i=1:size(obj.kVertices)
                plot(obj.kVertices(i).t, obj.kVertices(i).s, 'ro');
                if ~isempty(obj.kVertices(i).top)
                    plot([obj.kVertices(i).t obj.kVertices(i).top.endVert.t], ...
                        [obj.kVertices(i).s obj.kVertices(i).top.endVert.s], ...
                        'b');
                end
                if ~isempty(obj.kVertices(i).right)
                    plot([obj.kVertices(i).t obj.kVertices(i).right.endVert.t], ...
                        [obj.kVertices(i).s obj.kVertices(i).right.endVert.s], ...
                        'b');
                end
                if ~isempty(obj.kVertices(i).bottom)
                    plot([obj.kVertices(i).t obj.kVertices(i).bottom.endVert.t], ...
                        [obj.kVertices(i).s obj.kVertices(i).bottom.endVert.s], ...
                        'b');
                end
                if ~isempty(obj.kVertices(i).left)
                    plot([obj.kVertices(i).t obj.kVertices(i).left.endVert.t], ...
                        [obj.kVertices(i).s obj.kVertices(i).left.endVert.s], ...
                        'b');
                end
            end
        end
        
               %Show the preimage of the t-spline
        function printPreImagePaper(obj)
            hold on;
            for i=1:size(obj.kVertices)
                scatter(obj.kVertices(i).s, obj.kVertices(i).t,17,'k','filled');
                if ~isempty(obj.kVertices(i).top)
                    plot([obj.kVertices(i).s obj.kVertices(i).top.endVert.s], ...
                    [obj.kVertices(i).t obj.kVertices(i).top.endVert.t], ...
                        'k-','linewidth',1.5);
                end
                if ~isempty(obj.kVertices(i).right)
                    plot([obj.kVertices(i).s obj.kVertices(i).right.endVert.s], ...
                    [obj.kVertices(i).t obj.kVertices(i).right.endVert.t], ...
                        'k-','linewidth',1.5);
                end
                if ~isempty(obj.kVertices(i).bottom)
                    plot([obj.kVertices(i).s obj.kVertices(i).bottom.endVert.s], ...
                    [obj.kVertices(i).t obj.kVertices(i).bottom.endVert.t], ...
                        'k-','linewidth',1.5);
                end
                if ~isempty(obj.kVertices(i).left)
                    plot([obj.kVertices(i).s obj.kVertices(i).left.endVert.s], ...
                    [obj.kVertices(i).t obj.kVertices(i).left.endVert.t], ...
                        'k-','linewidth',1.5);
                end
            end
        end
        
        %Update knot vectors for all control points.
        %This has to be done before evaluation and conversion!
        function updateKnotVecs(obj)
            for i=1:size(obj.kVertices,1)
                obj.kVertices(i).updateKnotVec(obj.deg);
            end
        end
        
        %Evaluate t-spline
        function P = evaluate(obj, s, t)
            sumPB = 0;
            sumB = 0;
            for i=1:size(obj.kVertices,1)
                %check if s,t is in parameter space of vertice
                if s >= obj.kVertices(i).knotVec(1,1) && ...
                   s <= obj.kVertices(i).knotVec(1,end) && ...
                   t >= obj.kVertices(i).knotVec(2,1) && ...
                   t <= obj.kVertices(i).knotVec(2,end)

                   knotspanS = 1;
                   knotspanT = 1;
                   bs = basisFunTSpl(s, obj.kVertices(i).knotVec(1,:), obj.deg, knotspanS);
                   bt = basisFunTSpl(t, obj.kVertices(i).knotVec(2,:), obj.deg, knotspanT);
                   
                   B = sum(bs)*sum(bt);
                   sumPB = sumPB + obj.kVertices(i).cPoint * B;
                   sumB = sumB + B;
                end
            end
            if sumB == 0
                P = sumPB;
            else
                P = sumPB/sumB;
            end
        end
        
        %Create a skinned t-spline based on results of tSplineApprox.m
        function skinnedTSpline(obj, contrP, knotsV, knotsU)
            
            kVerts = cell(size(knotsV,2)-(obj.deg+1),1);
            knotsV = knotsV(obj.deg:(end-(obj.deg-1)));
            for i=1:size(kVerts,1)
                kVertRow = cell(1,size(knotsU{i},2)-(obj.deg+1));
                for j=obj.deg:(size(contrP{i},2)-2)
                    v = kVertex(knotsU{i}(j),knotsV(i));
                    v.cPoint = contrP{i}(:,j);
                    obj.kVertices = [obj.kVertices; v];
                    vRInd = j-(obj.deg-1);
                    kVertRow{vRInd} = v;
                    %connect the t direction
                    if vRInd > 1
                        v.cnctLeftRight(kVertRow{vRInd-1});
                    end
                end
                kVerts{i} = kVertRow;
            end
            
            %connect bottom and top borders
            for i=size(kVerts,1):-1:2
                for j=1:obj.deg-1
                    kVerts{i}{j}.cnctBottomTop(kVerts{i-1}{j});
                    kVerts{i}{end-(j-1)}.cnctBottomTop(kVerts{i-1}{end-(j-1)});
                end
            end
            
            %look for inner vertices to connect
            for i=size(kVerts,1):-1:2
                s = size(kVerts{i},2)-(obj.deg-1);
                for j=3:(size(kVerts{i},2)-(obj.deg-1))
                    for k=3:(size(kVerts{i-1},2)-(obj.deg-1))
                        if kVerts{i-1}{k}.s == kVerts{i}{j}.s
                            kVerts{i}{j}.cnctBottomTop(kVerts{i-1}{k});
                        end
                    end
                end
            end
           
        end
        
        %Convert t-spline to nurbs surface => can be exported as iges.
        %!this only works for skinned tsplines
        function nrb = convertToNrb(obj)
           
            %create global knotvector
            globalS = [];
            globalT = [];
            for i=1:size(obj.kVertices);
                if ~ismember(obj.kVertices(i).s,globalS)
                    globalS = [globalS obj.kVertices(i).s];
                end
                if ~ismember(obj.kVertices(i).t,globalT)
                    globalT = [globalT obj.kVertices(i).t];
                end
            end
            
            globalS = sort(globalS);
            globalT = sort(globalT);
            
            lcVert = leftBottomCorner(obj);
            
            %start inserting knots
            curLeft = lcVert;
            while 1
                curVert = curLeft;
                for i=1:size(globalS,2)
                    if globalS(i) > curVert.right.endVert.s
                        curVert = curVert.right.endVert;
                    end
                    
                    if curVert.s == globalS(i)
                        if isempty(curLeft.right)
                          break;
                        end
                        continue;
                    end
                    
                    if curVert.s < globalS(i) && ...
                       curVert.right.endVert.s > globalS(i)
                        obj.insertTKnot(globalS(i),curVert,curVert.right.endVert);
                    end
                end
                if isempty(curLeft.top)
                    break;
                else
                    curLeft = curLeft.top.endVert;
                end
            end
            
            %build vertice map
            vertMap = containers.Map();
            for i=1:size(obj.kVertices)
                str = strcat(num2str(obj.kVertices(i).t),'_',num2str(obj.kVertices(i).s));
                vertMap(str) = obj.kVertices(i);
            end
            
            %make sure all knots are connected upwards
            disp(size(obj.kVertices));
            for i=1:size(obj.kVertices)
                if isempty(obj.kVertices(i).top)
                    [p, vertTop] = shootTop(obj.kVertices(i));
                    nextT = vertTop.t;
                    if nextT == obj.kVertices(i).t
                        continue;
                    end
                    
                    str = strcat(num2str(nextT),'_',num2str(obj.kVertices(i).s));
                    
                    if vertMap.isKey(str) 
                        vertMap(str).cnctBottomTop(obj.kVertices(i));
                    end
                end
            end
 
            lc = obj.leftBottomCorner();
            cPMat = cell(1,1);
            i = 1;
            while 1
                sv = lc;
                cPVec =  [];
                while 1
                    cPVec = [cPVec sv.cPoint];
                    if isempty(sv.right)
                        break;
                    else
                        sv = sv.right.endVert;
                    end
                end
                
                cPMat{i,1} = cPVec;
                
                if isempty(lc.top)
                    break;
                else
                    lc = lc.top.endVert;
                    i = i+1;
                end
            end
            
            cPs = zeros(3,size(cPMat{1},2),size(cPMat,1));
            for i=1:size(cPMat{1},2)
                for j=1:size(cPMat,1)
                    cPs(:,i,j) = cPMat{j}(:,i);
                end
            end
            
            knots = { [globalS(1) globalS(1) globalS(1) globalS ...
                globalS(end) globalS(end) globalS(end)] ...
                [globalT(1) globalT(1) globalT(1) globalT ...
                globalT(end) globalT(end) globalT(end)] };
            
            nrb = nrbmak(cPs,knots);
        end
        
        %Insert knot at s. Does not change surface.
        function insertTKnot(obj,s,leftVert,rightVert)
            %calc the d
            d1 = 0;
            d2 = 0;
            tmpVert = leftVert;
            if ~isempty(tmpVert.left)
                d2 = tmpVert.s-tmpVert.left.endVert.s;
                %step
                tmpVert = tmpVert.left.endVert;
                if ~isempty(tmpVert.left)
                    d1 = tmpVert.s-tmpVert.left.endVert.s;
                end
            end

            d5 = 0;
            d6 = 0;
            tmpVert = rightVert;
            if ~isempty(tmpVert.right)
                d5 = tmpVert.right.endVert.s-tmpVert.s;
                %step
                tmpVert = tmpVert.right.endVert;
                if ~isempty(tmpVert.right)
                    d6 = tmpVert.right.endVert.s-tmpVert.s;
                end
            end

            d3 = s-leftVert.s;
            d4 = rightVert.s-s;

            %calc new contr points

            %p2'
            if ~isempty(leftVert.left)
                a = d4*leftVert.left.endVert.cPoint + ...
                    (d1+d2+d3)*leftVert.cPoint;
                b = d1+d2+d3+d4;
                p2s = a/b;
            else
                a = d4*leftVert.cPoint + ...
                    (d1+d2+d3)*leftVert.cPoint;
                b = d1+d2+d3+d4;
                p2s = a/b;
            end

            %p4'
            if ~isempty(rightVert.right)
                a = d3*rightVert.right.endVert.cPoint + ...
                    (d4+d5+d6)*rightVert.cPoint;
                b = d3+d4+d5+d6;
                p4s = a/b;
            else
                a = d3*rightVert.cPoint + ...
                    (d4+d5+d6)*rightVert.cPoint;
                b = d3+d4+d5+d6;
                p4s = a/b;
            end

            %             hold on;
            %             pointsPl = [p2s p3 p4s];
            %             plot3(pointsPl(1,:),pointsPl(2,:),pointsPl(3,:),'r-');
            %             plot3(p3(1),p3(2),p3(3),'ro');

            %p3'
            a = (d4+d5)*leftVert.cPoint + ...
                (d2+d3)*rightVert.cPoint;
            b = d2+d3+d4+d5;
            p3s = a/b;
            
            %replace p2 and p4
            leftVert.cPoint = p2s;
            rightVert.cPoint = p4s;
            
            %             plot3(p3s(1),p3s(2),p3s(3),'mo');

            %             pointsPl = [p2s p3s p4s];
            %             plot3(pointsPl(1,:),pointsPl(2,:),pointsPl(3,:),'m-');

            %add p3' to the t-spline
            p3Vert = kVertex(s,leftVert.t);
            p3Vert.cPoint = p3s;
            p3Vert.cnctLeftRight(leftVert);
            rightVert.cnctLeftRight(p3Vert);
            obj.kVertices(end+1) = p3Vert;
            
        end
        
        %Get s and t boundary values
        function [sStart tStart sEnd tEnd] = tSplineBoundaryVals(obj)
    
            lcVert = leftBottomCorner(obj);

            tStart = lcVert.t;
            sStart = lcVert.s;
            %shoot up until border is reached
            tEnd = tStart;
            tTemp = -1;
            curVert = lcVert;
            while tTemp ~= tEnd
                tEnd = tTemp;
                [p curVert] = curVert.shootTop();
                tTemp = curVert.t;
            end

            %shoot right until border is reached
            sEnd = sStart;
            sTemp = -1;
            curVert = lcVert;
            while sTemp ~= sEnd
                sEnd = sTemp;
                [p curVert] = curVert.shootRight();
                sTemp = curVert.s;
            end
        end
    
        %Get left bottom corner of preimage.
        function lcVert = leftBottomCorner(obj)

            lcVert = obj.kVertices(1);
            %find left corner vertice
            for i=1:size(obj.kVertices);
                if isempty(obj.kVertices(i).left) && ...
                    isempty(obj.kVertices(i).bottom)
                    lcVert = obj.kVertices(i);
                end
            end

        end
        
    end
end

