function [ C ] = APG_l1_L(X,B,eta,lambda,L,itera_num)
%% Object: C = argmin \|X-BC\|_F^2+lambda\|C\|1+eta*tr(CLC')
%%             
%% input arguments:
%%         X -------   Templates
%%         B -------   Particles
%%         para ------ Lambda: Sparsity Level
%%         itera_num----- Maximum iteraton time            
%%                     
%% output arguments:
%%         C ------  output Coefficient vetor

%% initialize the iterate parameters
alpha_km1=zeros(size(B,2),size(X,2));
alpha_k=alpha_km1;
t_k=1;
t_km1=1;
one1=ones(size(B,2),1);
one2=ones(size(X,2),1);
%% iterate
for k=0:itera_num
    beta_kp1=alpha_k+(t_km1-1)/t_k*(alpha_k-alpha_km1);
    g_kp1=beta_kp1-0.00018*(-1*B'*(X-B*beta_kp1)+eta*(L'+L)*beta_kp1+lambda*(one1)*(one2'));
    alpha_km1=alpha_k;    
    alpha_k=max(0,g_kp1);
    t=t_k;
    t_k=(1+(1+4*t_k^2)^0.5)/2;
    t_km1=t;
end
C=  alpha_k;  
   
end

