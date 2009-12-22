N=5;
Point(1) = {0.0, 0.0, 0, .03};
Point(2) = {1, 0.0, 0, .03};
Point(3) = {1, 1, 0, .03};
Point(4) = {0, 1, 0, .03};
Point(5) = {2, 0.0, 0, .03};
Point(6) = {2, 1, 0, .03};
Line(1) = {4, 3};
Line(2) = {3, 2};
Line(3) = {2, 1};
Line(4) = {1, 4};
Line Loop(5) = {2, 3, 4, 1};
Plane Surface(6) = {5};
Transfinite Line {1, 2, 4, 3} = N Using Progression 1;
Transfinite Surface {6};
Recombine Surface {6};
//Line(22) = {3, 2};
Line(7) = {3, 6};
Line(8) = {6, 5};
Line(9) = {5, 2};
Line Loop(10) = {8, 9, -2, 7};
Plane Surface(11) = {10};
Transfinite Line {7, 8, 9} = N Using Progression 1;
Transfinite Surface {11};
Physical Surface("Inside") = {6,11};
Physical Line("Border") = {1, 3, 4, 7, 8, 9};
