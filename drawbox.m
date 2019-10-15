function param = drawbox(varargin)
% function drawbox(width,height, param, properties)
%                 ([width,height], param, properties)
%
%   param, properties are optional
%

%% Copyright (C) Jongwoo Lim and David Ross.
%% All rights reserved.


%----------------------------------------------------------
% Process the input.
%----------------------------------------------------------
param = [];
%%***********acquire height and width***********%%
if (length(varargin{1}) == 2) 
  w = varargin{1}(1);
  h = varargin{1}(2);
  varargin(1) = [];
else
  [w,h] = deal(varargin{1:2});
  varargin(1:2) = [];      
end
%%***********acquire width and height***********%%

if (length(varargin) < 1 || any(length(varargin{1}) ~= 6))
  M = [0,1,0; 0,0,1];
else
  p = varargin{1};
  th = p(4);
  if (length(varargin) > 1 && strcmp(varargin{2},'geom'))
    p = affparam2mat(p);
    varargin(1:2) = [];
  else
    varargin(1) = [];
  end
  M = [p(1) p(3) p(4); p(2) p(5) p(6)];     %%affine parameters
end

%----------------------------------------------------------
% Draw the box.
%----------------------------------------------------------

corners = [ 1,-w/2,-h/2; 1,w/2,-h/2; 1,w/2,h/2; 1,-w/2,h/2; 1,-w/2,-h/2 ]';
corners = M * corners;      %%vertices

line(corners(1,:), corners(2,:), varargin{:});      %%draw lines that connect vertices 

center = mean(corners(:,1:4),2);
param = [w, h, th, center(1), center(2)];
hold_was_on = ishold; hold on;
plot(center(1),center(2),varargin{:});              %%draw central points 
if (~hold_was_on) hold off; end
