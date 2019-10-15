function wimg = warpimg(img, p, sz)
% function wimg = warpimg(img, p, sz)
%
%    img(h,w)   :   the initial image 
%    p(6,n)     :   affine parameters (mat format)
%    sz(th,tw)  ��  the size of the patch
%

%% Copyright (C) 2005 Jongwoo Lim and David Ross.
%% All rights reserved.

if (nargin < 3)
    sz = size(img);
end
if (size(p,1) == 1)
    p = p(:);
end
w = sz(2);  h = sz(1);  n = size(p,2);
[x,y] = meshgrid([1:w]-w/2, [1:h]-h/2);
pos = reshape(cat(2, ones(h*w,1),x(:),y(:)) ...
              * [p(1,:) p(2,:); p(3:4,:) p(5:6,:)], [h,w,n,2]);
wimg = squeeze(interp2(img, pos(:,:,:,1), pos(:,:,:,2)));
                                %%pos(:,:,:,1)    :   x coordinate matrix
                                %%pos(:,:,:,2)    ��  y coordinate matrix
wimg(find(isnan(wimg))) = 0;    %%remove bad points 

%   B = SQUEEZE(A) returns an array B with the same elements as
%   A but with all the singleton dimensions removed.  A singleton
%   is a dimension such that size(A,dim)==1;

