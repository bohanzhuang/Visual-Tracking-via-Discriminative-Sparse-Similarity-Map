function [ L,W] = constructL( particle,param )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

F=particle';
options = [];
options.NeighborMode = 'KNN';
options.k = 10;
options.WeightMode = 'HeatKernel';
options.t = 2;
W = constructW(F,options);
W=full(W);
Ws = constructW(param.param',options);
Ws=full(Ws);
W=W.*Ws;
mz=eye(size(W));
mz=~mz;
W=W.*mz;
    
d=sum(W,2);
D=diag(d);
L=D-W;
end

