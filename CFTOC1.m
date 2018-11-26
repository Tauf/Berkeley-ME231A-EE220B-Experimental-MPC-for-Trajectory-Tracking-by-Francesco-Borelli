function [xopt,uopt,feas] = CFTOC1(A,B,N,Q,R,x0,xf,xmin,xmax,umin,umax)
    g = 9.8;        %gravity accerlation [m/s^2]
    Ts=0.1;
    
    nx=4;nu=2;
    x=sdpvar(nx,N+1);   %states variables
    u=sdpvar(nu,N);     %input variables
    
    const=[x(:,1)==x0;xmin<=x(:,1)<=xmax]; %inital conditions
    cost=0;
    for k=1:N
        const=const+[x(:,k+1)==A*x(:,k)+B*u(:,k)+[0;0;0;Ts*g]];  %next states
        const=const+[xmin<=x(:,k+1)<=xmax]; %states constraints
        const=const+[umin<=u(:,k)<=umax];   %input constraints
        cost=cost+x(:,k)'*Q*x(:,k)+u(:,k)'*R*u(:,k); %cost
    end    
    %const=const+[x(:,N+1)==xf];
    
    options=sdpsettings('solver','quadprog','verbose',0);
    result=optimize(const,cost,options);
    flag=result.problem;
        if flag==0 %solution found
            feas=1;
            xopt=double(x);    uopt=double(u);
        else
            feas=0; %no feasiable solution
            xopt=[];    uopt=[];
        end
end

