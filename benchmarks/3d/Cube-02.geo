/*****************************  
cube meshed  
non uniformly  
*****************************/  
Point(1) = {0.0,0.0,0.0,.04};          
Point(2) = {1,0.0,0.0,.2};          
Point(3) = {1,1,0.0,.1};          
Point(4) = {0,1,0.0,.2};          
Line(1) = {4,3};          
Line(2) = {3,2};          
Line(3) = {2,1};          
Line(4) = {1,4};          
Line Loop(5) = {2,3,4,1};          
Plane Surface(6) = {5};          
Extrude Surface {6, {0,0.0,1}};          
     
Surface Loop(29) = {23,6,15,19,28,27};    
Complex Volume(30) = {29};    
