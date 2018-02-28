%Test-T-Spline
t = tSpline([],3);

vertices = [ kVertex(0,0)
             kVertex(0.2,0)
             kVertex(0.4,0)
             kVertex(0.6,0)
             kVertex(1,0)
             kVertex(0.2,0.2)
             kVertex(0.4,0.2)
             kVertex(0.6,0.2)
             kVertex(0.7,0.2)
             kVertex(1,0.2)
             kVertex(0.2,0.5)
             kVertex(0.4,0.5)
             kVertex(0.5,0.5)
             kVertex(0.7,0.5)
             kVertex(1,0.5)
             kVertex(0,0.65)
             kVertex(0.2,0.65)
             kVertex(0.5,0.7)
             kVertex(1,0.7)
             kVertex(0.2,0.8)
             kVertex(0.5,0.8)
             kVertex(0,1)
             kVertex(0.2,1)
             kVertex(0.5,1)
             kVertex(1,1) ];

%Edges

vertices(1).cnctRight(vertices(2));
vertices(1).cnctTop(vertices(16));

vertices(2).cnctTop(vertices(6));
vertices(2).cnctRight(vertices(3));
vertices(2).cnctLeft(vertices(1));

vertices(3).cnctTop(vertices(7));
vertices(3).cnctRight(vertices(4));
vertices(3).cnctLeft(vertices(2));

vertices(4).cnctTop(vertices(8));
vertices(4).cnctRight(vertices(5));
vertices(4).cnctLeft(vertices(3));

vertices(5).cnctTop(vertices(10));
vertices(5).cnctLeft(vertices(4));

vertices(6).cnctTop(vertices(11));
vertices(6).cnctRight(vertices(7));
vertices(6).cnctBottom(vertices(2));

vertices(7).cnctTop(vertices(12));
vertices(7).cnctRight(vertices(8));
vertices(7).cnctBottom(vertices(3));
vertices(7).cnctLeft(vertices(6));

vertices(8).cnctRight(vertices(9));
vertices(8).cnctBottom(vertices(4));
vertices(8).cnctLeft(vertices(7));

vertices(9).cnctTop(vertices(14));
vertices(9).cnctRight(vertices(10));
vertices(9).cnctLeft(vertices(8));

vertices(10).cnctTop(vertices(15));
vertices(10).cnctBottom(vertices(5));
vertices(10).cnctLeft(vertices(9));

vertices(11).cnctTop(vertices(17));
vertices(11).cnctRight(vertices(12));
vertices(11).cnctBottom(vertices(6));

vertices(12).cnctRight(vertices(13));
vertices(12).cnctBottom(vertices(7));
vertices(12).cnctLeft(vertices(11));

vertices(13).cnctTop(vertices(18));
vertices(13).cnctRight(vertices(14));
vertices(13).cnctLeft(vertices(12));

vertices(14).cnctRight(vertices(15));
vertices(14).cnctBottom(vertices(9));
vertices(14).cnctLeft(vertices(13));

vertices(15).cnctTop(vertices(19));
vertices(15).cnctBottom(vertices(10));
vertices(15).cnctLeft(vertices(14));

vertices(16).cnctTop(vertices(22));
vertices(16).cnctRight(vertices(17));
vertices(16).cnctBottom(vertices(1));

vertices(17).cnctTop(vertices(20));
vertices(17).cnctBottom(vertices(11));
vertices(17).cnctLeft(vertices(16));

vertices(18).cnctTop(vertices(21));
vertices(18).cnctRight(vertices(19));
vertices(18).cnctBottom(vertices(13));

vertices(19).cnctTop(vertices(25));
vertices(19).cnctBottom(vertices(15));
vertices(19).cnctLeft(vertices(18));

vertices(20).cnctTop(vertices(23));
vertices(20).cnctRight(vertices(21));
vertices(20).cnctBottom(vertices(17));

vertices(21).cnctTop(vertices(24));
vertices(21).cnctBottom(vertices(18));
vertices(21).cnctLeft(vertices(20));

vertices(22).cnctRight(vertices(23));
vertices(22).cnctBottom(vertices(16));

vertices(23).cnctRight(vertices(24));
vertices(23).cnctBottom(vertices(20));
vertices(23).cnctLeft(vertices(22));

vertices(24).cnctRight(vertices(25));
vertices(24).cnctBottom(vertices(21));
vertices(24).cnctLeft(vertices(23));

vertices(25).cnctBottom(vertices(19));
vertices(25).cnctLeft(vertices(24));

t.kVertices = vertices;

%Control Points
vertices(1).cPoint = [0;0;1];
vertices(2).cPoint = [0.2;0;1.3];
vertices(3).cPoint = [0.4;0;1.6];
vertices(4).cPoint = [0.6;0;1.1];
vertices(5).cPoint = [1;0;1];
vertices(6).cPoint = [0.2;0.2;1.2];
vertices(7).cPoint = [0.4;0.2;1.2];
vertices(8).cPoint = [0.6;0.2;1.5];
vertices(9).cPoint = [0.7;0.2;1.1];
vertices(10).cPoint = [1;0.2;1.3];
vertices(11).cPoint = [0.2;0.5;1.2];
vertices(12).cPoint = [0.4;0.5;1.3];
vertices(13).cPoint = [0.5;0.5;1.5];
vertices(14).cPoint = [0.7;0.5;1.5];
vertices(15).cPoint = [1;0.5;1.1];
vertices(16).cPoint = [0;0.65;1.5];
vertices(17).cPoint = [0.2;0.65;1.5];
vertices(18).cPoint = [0.5;0.7;1.3];
vertices(19).cPoint = [1;0.7;1.1];
vertices(20).cPoint = [0.2;0.8;1.3];
vertices(21).cPoint = [0.5;0.8;1.1];
vertices(22).cPoint = [0;1;1.5];
vertices(23).cPoint = [0.2;1;1.6];
vertices(24).cPoint = [0.5;1;1.2];
vertices(25).cPoint = [1;1;1.1];


%t.printPreImage();
sampleCount = 20;
t.updateKnotVecs();
ps = linspace(0,1,sampleCount);
pt = linspace(0,1,sampleCount);
hold on;
for i=1:sampleCount
    for j=1:sampleCount
        P = t.evaluate(ps(i),pt(j));
        plot3(P(1),P(2),P(3),'ro');
    end
end
