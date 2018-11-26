%% Parameters
m = 27648;      %rocket mass [kg]
l = 70;         %rocket length [m]
J = 1/16*m*l^2; %moment of inertia [kg*m^2]
g = 9.8;        %gravity accerlation [m/s^2]

%% Constraints
nx=4;   nu=2;   %# of states && # of input
Fmax = 1690*1000;
%Original input = [F;d]
%umin = [   0; -5*pi/180];  %original minimum input constraints
%umax = [Fmax;  5*pi/180];  %original maximum input constraints

%Input = [F;ubar],ubar=F*d
umin = [   0; -5*pi/180*Fmax];  %new minimum input constraints
umax = [Fmax;  5*pi/180*Fmax];  %new maximum input constraints

%States = [t;w;h;v]
xmin = [-20*pi/180; -100; -3000; -100];   %minimum states constraints
xmax = [ 20*pi/180;  100;     0;  500];   %maximum states constraints

%% Initial conditions & terminal states
t0 = 10*pi/180; %inital angle
alt0 = -1228;   %initial CG height
v0 = 205.2;     %initial velocity

x0 = [t0; 0; alt0; v0];
xf = [0;0;0;0];

%% Define sampling time
Ts = 0.1; %[s]

%% Define horizon
N = 10/Ts; %[s]
n = 10;
xt=nan(nx,N+1);     xt(:,1)=x0;     %store actual states data
ut=nan(nu,N);                       %store input data
x=nan(nx,N+1);                      %store xopt

%% Cost parameters
%P=eyes(nx);     %terminal cost
Q=10*eye(nx);     %states cost
R=[1/(Fmax^2), 0; 0,1];     %input cost

%% Define dynamic system model
%original system, non-linear
sys=@(x,u) [x(1)+Ts*x(2);
            x(2)-Ts*l/(2*J)*u(1)*u(2);
            x(3)+Ts*x(4);
            x(4)+Ts*(g-(1/m)*u(1))];
        %x3 is positive underground 
%linearlization
%x(k+1)=Ax(k)+Bu(k)+[0;0;0;Ts*g]
A=[1,Ts,0,0;
    0,1,0,0;
    0,0,1,Ts;
    0,0,0,1];
B=[0,0;
   0,-Ts*l/(2*J);
   0,0;
   -Ts/m,0];

%% Using CFTOC

for t=1:N
    [xopt,uopt,feas] = CFTOC1(A,B,n,Q,R,xt(:,t),xf,xmin,xmax,umin,umax);
    if feas==0
        error(['not feasiable at t=' num2str(t-1)])
    end
    x(:,t+1)=xopt(:,1);
    ut(:,t)=[uopt(1,1);uopt(2,1)/uopt(1,1)];
    %Actual rocket landing (with disturbance) model
    
    
    %Actual rocket landing (perfect) model
    xt(:,t+1)=sys(xt(:,t),ut(:,t));
end

%% Simulation
time=0:Ts:10;
xi=['t[deg]' 'w[rad/s]' 'h[m]' 'v[m/s]'];
for i=1:4
    subplot(4,1,i)
    plot(time,xt(i,:),'*','displayName','x actual');
    hold on
    plot(time,x(i,:),'displayName','x opt');
    ylabel(xi(i));
    legend('location','best')
end

   