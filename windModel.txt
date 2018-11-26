%% ME 231 project - Wind model
% Capabilities:
% - Compute two types of gust: Extreme Coherent gust (ECG) and extreme
% Operating Gust (EOG). 
% - Compute turbulent wind 
% - Compute corresponding drag force on the rocket to use as input in the MPC model.
clear;clc;
%% Parameters
% User parameters
Kwind = 1;              % 1: ECG, 2: EOG, 3: Turbulent wind
Kdrag = 1;              % 1/0: drag calculation on/off
Kplot = 1;              % 1/0: plots on/off

% Simulations parameters
t    = 0:0.1:100;       % Simulation length
Tini = 10;              % Time at which the gust occurs

% Wind parameters
Vref = 10;             % Reference wind speed 

Vecg = 5;              % ECG Parameters 
Tecg = 10;

Veog = 7;              % EOG Parameters
Teog = 10;

sigma = 0.11*Vref;     % Turbulent wind standard deviation

rho = 1.225;           % air density (kg/m3)
nu  = 1.48e-5;         % air kinematic viscosity (m2/s)

% Rocket parameters
l = 70;                % Rocket length
d = 3.7;               % Rocket diameter


%% Main

% Compute wind speed
if Kwind == 1
    V = computeECG(Vref,Vecg,Tecg,t,Tini);
elseif Kwind == 2
    V = computeEOG(Vref,Veog,Teog,t,Tini);
elseif Kwind == 3
    V = computeTURB(Vref,sigma,t);
end

% Compute drag force
if Kdrag == 1
    for i = 1:length(t)
        Re(i) = d*V(i)/nu;
        Cd(i) = computeDrag(Re(i));
        Fd(i) = 0.5*rho*V(i)^2*Cd(i)*d*l;
    end
end

% Plots

if Kplot == 1
    figure;
    subplot(2,1,1)                          % Plot wind
    plot(t,V,'LineWidth',2);
    ylabel('V (m/s)','FontSize',12);
    xlabel('time (s)','FontSize',12);
    title('Wind speed','FontSize',12);
    grid on;
    ax = gca; % current axes
    ax.FontSize = 12;
    if Kwind == 3
        hold on;
        plot(t,Vref*ones(1,length(t)),'LineWidth',2);
        legend('Turbulent wind','Steady wind');
    end
    if Kdrag == 1
        subplot(2,1,2)                          % Plot drag force
        plot(t,Fd*10^-3,'LineWidth',2);
        ylabel('Fd (kN)','FontSize',12);
        xlabel('time (s)','FontSize',12);
        title('Aerodynamic Drag','FontSize',12);
        grid on;
        ax = gca; % current axes
        ax.FontSize = 12;    
    end
end

%% Wind models

% Extreme Coherent Gust (ECG)
function V = computeECG(Vref,Vecg,Tecg,t,Tini)

    % Compute ECG speed
    V               = Vref*ones(1,length(t)) + 0.5 * Vecg *(1 - cos(pi * (t-Tini) / Tecg));
    V(t>=Tini+Tecg) = Vref+Vecg;
    V(t<=Tini)      = Vref;
    
end

% Extreme Operating Gust (EOG)
 function V = computeEOG(Vref,Veog,Teog,t,Tini)
  
    % Compute EOG speed
    V               = Vref  - 0.5*Veog* sin(3 * pi * (t-Tini)/ Teog).*(1 - cos(2 * pi * (t-Tini) / Teog));
    V(t>=Tini+Teog) = Vref;      
    V(t<=Tini)      = Vref;
    
 end 
 

% Turbulent wind
function V = computeTURB(Vref,sigma,t)

    % Parameters
    Lu   = 8.1*42;          % Longitudinal turbulent scale parameter
    fCut = 10;              % cut-off frequency
    
    % Compute turbulent spectrum (IEC Kaimal)
    T    = max(t);          % duration of time series
    df   = 1/T; 
    f    = 0:df:fCut;
    S    = 4*(sigma^2*Lu/Vref)./(1+6*(f*Lu/Vref)).^(5/3); 
    
    % Compute turbulent wind
    sigmaU = sqrt(T/(2*pi)*S);
    N      = T*fCut+1;
    X      = sigmaU.*randn(1,N);    
    X(1)   = 0;
    Vturb  = sqrt(2)*pi*fCut*real(ifft(X));
    V      = Vref + Vturb;

end


%% Drag model

% Compute drag on a cylinder
function Cd = computeDrag(Re)
   
    if Re<=10^4
        Cd = 1.1;    % Default value for Re < 1e4
    elseif Re>10^4 && Re<10^7
        Cd = interp1([1e4:1e4:1e5 2e5:1e5:1e6 2e6:1e6:1e7], ...
        [1.1*ones(1,11) 0.7 0.34 0.32 0.32 0.33 0.34 0.36 0.4 0.54 0.7 0.78 0.78 0.72 0.73 0.8 0.82 0.9],Re,'pchip');
    elseif Re >=10^7
        Cd = 0.9;
    end

end
















