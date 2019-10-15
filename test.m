clc;
clear all;
rand('state',0);    randn('state',0);
addpath('./Affine Sample Functions');
setTrackParam;             % initial position and affine parameters
opt.tmplsize = [32 32];     % the size of each candidate
sz = opt.tmplsize;
max_whole=[];
min_whole=[];
coefficient=[];
result=[];
drawopt=[];
A_pos=[];
weight=[];
similarity_temp=[];
weight_pos=[];
weight_neg=[];
weighted_pos_selected=[];
weighted_neg_selected=[];
weighted_coefficient_pos=[];
weighted_coefficient_neg=[];
coefficient_result=[];
duration = 0; 
tic;
n_sample =opt.numsample;
patch_size =8;
step_size=8;

%the initial affine parameters
param0 = [p(1), p(2), p(3)/sz(2), p(5), p(4)/p(3), 0];
p0 = p(4)/p(3);
param0 = affparam2mat(param0);
param = [];
param.est = param0';
%define the vector to store the idx of the candidates that can not be  better represented by positive templates 
no_idx=zeros(opt.numsample,1);
 
%get the index of the pixels in one candidate in order to be used in the cropping stage
[patch_idx, patch_num] = img2patch(sz, patch_size, step_size); 
 

 %% read first frame
% read the first frame to find the position of the object 
begin = 1;
frame = imread([dataPath int2str(begin) forMat]);
if size(frame,3)==3
    grayframe = rgb2gray(frame);
else
    grayframe = frame;
    frame = double(frame)/255; 
end
frame_img = double(grayframe)/255; 
result = [result; param0]; 
exemplar = warpimg(frame_img, param0, sz);  
exemplar = exemplar.*(exemplar>0); 
A_pos = [A_pos, repmat(exemplar(:),[1,2])]; %  notice that these are not normalized using L2 norm
% draw the result
drawopt = drawtrackresult([], begin, frame, sz, result(end,:)'); % 
imwrite(frame2im(getframe(gcf)),sprintf('result/%s/Result/%d%s',title,begin,forMat));
 
 
% obtain positive and negative templates
num_p =8;                                                         
num_n =150;

[A_poso, A_nego] = affineTrainG(dataPath, sz, opt, param, num_p, num_n, forMat, p0,begin,frame);        
A_pos = [A_pos,A_poso];
A_neg = A_nego;  


coefficient_pos=zeros(num_p,opt.numsample); 
coefficient_neg=zeros(num_n,opt.numsample);

 
%% ************************************************tracking******************************************
 
for f = 2:frameNum
    negative_templates=cell(1,num_n);
   
    frame= imread([dataPath int2str(f) forMat]);
    if size(frame,3)==3
        frame_img= rgb2gray(frame);
    else
        frame_img= frame;
        frame=double(frame);
    end
  img=double(frame_img);
  
% draw N candidates with particle filter
[candidates Y param] = affineSample(double(img), sz, opt, param);   
 
Y_normalized=normalizeMat(Y);
A_pos_normalized=normalizeMat(A_pos);
A_neg_normalized=normalizeMat(A_neg);
 
% block the training set and the candidates
YY=Y_normalized(patch_idx,:);
AA_pos=A_pos_normalized(patch_idx,:);
AA_neg=A_neg_normalized(patch_idx,:);
 
YY_change=reshape(YY, patch_size*patch_size, patch_num*opt.numsample);
AA_pos_change=reshape(AA_pos, patch_size*patch_size, patch_num*(EXAMPLAR_NUM));
AA_neg_change=reshape(AA_neg, patch_size*patch_size, patch_num*num_n);
 
YYY_temp=normalizeMat(YY_change);
AAA_pos_temp=normalizeMat(AA_pos_change);
AAA_neg_temp=normalizeMat(AA_neg_change);
 
YYY=reshape(YYY_temp,size(YY,1), size(YY,2));
AAA_pos=reshape(AAA_pos_temp, size(AA_pos,1),size(AA_pos,2));
AAA_neg=reshape(AAA_neg_temp, size(AA_neg,1),size(AA_neg,2));
 
%optimize with the Laplacian constraint
eta=0.8;lambda=0.04;
itera_num=5;
[L,W] = constructL( YYY,param );

AAA=[AAA_pos AAA_neg];
coefficient = APG_l1_L(AAA,YYY,eta,lambda,L,itera_num);
coefficient = coefficient';
coefficient = full(coefficient);

coefficient_pos=coefficient(1:EXAMPLAR_NUM,:);
coefficient_neg=coefficient(EXAMPLAR_NUM+1:(EXAMPLAR_NUM+num_n),:);

[pos_value,pos_idx_temp]=sort(coefficient_pos,'descend');
[neg_value,neg_idx_temp]=sort(coefficient_neg,'descend');
 
pos_idx=pos_idx_temp(1:5,:);
neg_idx=neg_idx_temp(1:5,:);

%calculate adaptive weights for all candidates 
for q=1:EXAMPLAR_NUM
 for m=1:opt.numsample
weight_pos(q,m)=exp(-sum((YYY(:,m)-AAA_pos(:,q)).^2));
 end
end
 
for n=1:num_n
 for m=1:opt.numsample    
weight_neg(n,m)=exp(-sum((YYY(:,m)-AAA_neg(:,n)).^2));
 end
end
 
% calculate the score from the positive templates and negative templates
weighted_coefficient_pos=coefficient_pos.*weight_pos;
weighted_coefficient_neg=coefficient_neg.*weight_neg;

% sort the weighted coefficients of each candidate
[rec_f_temp,rec_f_idx_temp]=sort(weighted_coefficient_pos,'descend');
[rec_b_temp,rec_b_idx_temp]=sort(weighted_coefficient_neg,'descend');

rec_f=rec_f_temp(1:5,:);
rec_b=rec_b_temp(1:5,:);
rec_f_idx=rec_f_idx_temp(1:5,:);
rec_b_idx=rec_b_idx_temp(1:5,:);

con_pos_discriminative=sum(rec_f);
con_neg_discriminative=sum(rec_b);

con_discriminative=con_pos_discriminative-con_neg_discriminative; % confident scores
 
[max_value, max_idx]=max(con_discriminative);
  
%draw the result
param.est =affparam2mat(param.param(:,max_idx));      
result =[result; param.est'];   
 
drawopt = drawtrackresult(drawopt, f, frame, sz, result(end,:)'); % 
imwrite(frame2im(getframe(gcf)),sprintf('result/%s/Result/%d%s',title,f,forMat));

duration = duration + toc;      
fprintf('%d frames took %.3f seconds : %.3fps\n',f, duration, f/duration);
fps = f/duration;
%% *****************************************************update the negative templates****************************************
 
n = num_n;    % Sampling Number

param.param0 = zeros(6,n);      % Affine Parameter Sampling
param.param = zeros(6,n);
param.param0 = repmat(affparam2geom(param.est(:)), [1,n]);
randMatrix = randn(6,n);
sigma = [round(sz(2)*param.est(3)), round(sz(1)*param.est(3)*p0), .000, .000, .000, .000];
param.param = param.param0 + randMatrix.*repmat(sigma(:),[1,n]);
 
back = round(sigma(1)/5);
center = param.param0(1,1);
left = center - back;
right = center + back;
nono = param.param(1,:)<=right&param.param(1,:)>=center;
param.param(1,nono) = right;
nono = param.param(1,:)>=left&param.param(1,:)<center;
param.param(1,nono) = left;
 
back = round(sigma(2)/5);
center = param.param0(2,1);
top = center - back;
bottom = center + back;
nono = param.param(2,:)<=bottom&param.param(2,:)>=center;
param.param(2,nono) = bottom;
nono = param.param(2,:)>=top&param.param(2,:)<center;
param.param(2,nono) = top;
 
o = affparam2mat(param.param);     % Extract or Warp Samples which are related to above affine parameters
wimgs = warpimg(img, o, sz);
 
m = prod(opt.tmplsize);
A_neg = zeros(m, n);
for i = 1: n
    A_neg(:,i) = reshape(wimgs(:,:,i), m, 1);
end
 
%% ********************************************** update the positive templates************************************************
 
threshold=0.40;
for k=1:9   
   similarity_temp(:,k)=sqrt(sum((A_pos_normalized(:,k+1)-Y_normalized(:,max_idx)).^2));  
end 
[similarity,similarity_idx]=min(similarity_temp);
 
if similarity<threshold
    A_pos(:,similarity_idx+1)=Y(:,max_idx);
end

end

% save .mat file
fileName = sprintf('result/%s/Result/result.mat',title);
save(fileName,'result');

%% *******************************************************STD results***********************************************
ourCenterAll  = cell(1,frameNum);      
ourCornersAll = cell(1,frameNum);
for num = 1:frameNum
    if  num <= size(result,1)
        est = result(num,:);
        [ center corners ] = p_to_box([32 32], est);
    end
    ourCenterAll{num}  = center;      
    ourCornersAll{num} = corners;
end

fileName=sprintf('result/%s/Result/%s_our_rs.mat',title,title);
save( fileName, 'ourCenterAll', 'ourCornersAll', 'fps');
 
 
 
 

