/*****************************    
cube with a hole  
*****************************/ 
lv = .1; 
lc = .04;    
Point(1) = {0.0,0.0,0.0,lv};            
Point(2) = {1,0.0,0.0,lv};            
Point(3) = {1,1,0.0,lv};            
Point(4) = {0,1,0.0,lv};            
Line(1) = {4,3};            
Line(2) = {3,2};            
Line(3) = {2,1};            
Line(4) = {1,4};            
Point(11) = {0.5,0.5,0.0,lc};            
Point(12) = {0.5,0.7,0.0,lc};            
Point(13) = {0.5,0.3,0.0,lc};            
Point(14) = {0.3,0.5,0.0,lc};            
Point(15) = {0.7,0.5,0.0,lc};            
Circle(5) = {15,11,12};  
Circle(6) = {12,11,14};  
Circle(7) = {14,11,13};  
Circle(8) = {13,11,15};  
Line Loop(9) = {1,2,3,4};  
Line Loop(10) = {7,8,5,6};  
Plane Surface(11) = {9,10};  
Extrude Surface {11, {.0,0.0,.5} };  
Coherence;  
Surface Loop(54) = {24,11,28,32,36,53,40,44,48,52};  
Complex Volume(55) = {54};  
