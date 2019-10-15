% setTrackParam 
% function trackparam
% loads data and initializes variables

%*************************************************************
% 'title';
% choose the sequence you wish to run.

% 'p = [px, py, sx, sy, theta]';
% the location of the target in the first frame.
%
% px and py are the coordinates of the center of the box;
%
% sx and sy are the size of the box in the x (width) and y (height)
% dimensions, before rotation;
%
% theta is the rotation angle of the box;
%
% 'numsample';
% the number of samples used in the condensation algorithm/particle filter.
% Increasing this will likely improve the results, but make the tracker slower.
%
% 'affsig';
% these are the standard deviations of the dynamics distribution, and it controls the scale, size and area to
% sample the candidates.
%    affsig(1) = x translation (pixels, mean is 0)
%    affsig(2) = y translation (pixels, mean is 0)
%    affsig(3) = x & y scaling
%    affsig(4) = rotation angle
%    affsig(5) = aspect ratio
%    affsig(6) = skew angle
%
% 'forMat';
% the format of the input images in one video, for 
%% *************************************************************
 
% title= 'Occlusion1';  
% title= 'Jumping';   
% title= 'Girl';     
% title = 'Singer1';     
% title = 'Car11';   
% title= 'Deer';    
% title= 'Car4';    
% title= 'Woman';    
% title= 'Face';     
% title= 'DavidIndoorOld';   
% title= 'Caviar1';  
% title= 'Caviar2';  
% title= 'Sylvester2008b';
  title= 'Dudek';
%% *************************************************************
% image sequence folder
dataPath = [ 'Datasets\' title '\'];

dataInfo = importdata([dataPath 'datainfo.txt']);
imgSize = [dataInfo(1) dataInfo(2)];% [width height]
frameNum = dataInfo(3);
EXAMPLAR_NUM=10;
forMat = '.jpg';
condenssig=0.05;

%% *************************************************************
% 
switch (title)           %affsig = [center_x center_y width rotation aspect_ratio skew]     
        
 
   
case 'Deer'; p = [350, 40, 100, 70, 0];
        opt = struct('numsample',600, 'affsig',[15,15,.000,.000,.005,.000]);
    
     
case 'Singer1';  p = [100, 200, 100, 300, 0]; 
        opt = struct('numsample',570, 'condenssig',0.25, 'ff',1, ...
                  'batchsize',10, 'affsig',[4,4,.03,.000,.0005,.000]);
                          
case 'Jumping'; p = [163,126,33,32,0]; 
        opt = struct('numsample',600, 'affsig',[8,25,.000,.000,.000,.00]);
   
                      
case 'Car11';  p = [89 140 30 25 0];
        opt = struct('numsample',620, 'affsig',[4,4,.01,.005,.002,.001]);
        
       
case 'Girl'; p =   [180,109,104,127,0];
        opt = struct('numsample',620, 'affsig',[10,10,.01,.000,.002,.000]);
   
 
case 'Car4';  p = [245 180 200 150 0]; 
        opt = struct('numsample',600,'affsig',[4,4,.03,.00,.001,.001]); 
 
   
case 'DavidIndoorOld';  p = [160 112 60 92 -0.02];
        opt = struct('numsample',600, 'condenssig',0.75, 'ff',0.99, ...
                     'batchsize',5, 'affsig',[6,6,.02,.01,.00,.001]);
                 

case 'Face';  p = [293 283 94 114 0];
        opt = struct('numsample',600, 'condenssig',condenssig, 'ff',1.0,...
                     'batchsize',5, 'affsig',[30,30,.01,.00,.00,.00]); 
    
    
case 'Caviar1'; p = [145,112,30,79,0];
        opt = struct('numsample',600, 'condenssig',condenssig, 'ff',1.0,...
                     'batchsize',5, 'affsig',[3,3,.005,.00,.00,.00]);
    
    
case 'Caviar2'; p = [ 152, 68, 18, 61, 0.00 ];
         opt = struct('numsample',600, 'condenssig',condenssig, 'ff',1.0,...
                      'batchsize',5, 'affsig',[3,3,.005,.00,.00,.00]);  


case 'Occlusion1'; p = [177,147,115,145,0];
        opt = struct('numsample',600, 'condenssig',condenssig, 'ff',1.0,...
                     'batchsize',5, 'affsig',[3, 3,.02,.00,.00,.00]);  
       
         
case 'Woman'; p = [222 165 35 95 0.0];
      opt = struct('numsample', 600, 'affsig', [5,5,0.01,0.0,0.002,0]); 
    
    
case 'Sylvester2008b';  p = [328,168,80,88,0];
      opt = struct('numsample',600, 'condenssig',0.25, 'ff',1, ...
              'batchsize',5, 'affsig',[12, 8, .01, .01, .001, .00]);  

case 'Dudek';  p = [188,192,110,130,-0.08];
      opt = struct('numsample',630, 'condenssig',0.25, 'ff',0.95, ...
                      'batchsize',5, 'affsig',[8,8,.05,.02,.005,.001]); 
                
       
    otherwise;  
        error(['unknown title ' title]);
end


if ~isdir(['result\' ,title])
    mkdir('result\',title);
end
if ~isdir(['result\' ,title,'\Dict'])
    mkdir(['result\' ,title,'\Dict']);
end
if ~isdir(['result\' ,title,'\Result'])
    mkdir(['result\' ,title,'\Result']);
end
