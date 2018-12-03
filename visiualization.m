clear;
clf;
close;
clc;
% Initial center and orientation of line (uncaptured - see below)
cx = 1; cy = 1; theta = 0; L = 0.5;
% Create initial line object (xdata, and ydata)
%Lh = line([cx-L/2*cos(theta) cx+L/2*cos(theta)],[cy-L/2*sin(theta) cy+L/2*sin(theta)]);
nFrames = 4;
% Allocate a 1-by-nFrames STRUCT array with 2 fields
F(nFrames) = struct('cdata',[],'colormap',[]);
disp('Creating and recording frames...')
figure('WindowState','maximized');
I= imread('rocket.png');%imresize(imread('rocket.png'),[100,25]);
%create a new axes
h= axes('position',[0,0,0.01,0.04]);
%put an image on the axes
imagesc(I);
%turn off the axis ticks and labels
axis off

for j = 1:.01:nFrames
    % Change center and angle, in a sensible manner, based on Frame#
    cx = cos(j/nFrames*pi);
    cy = sin(j/nFrames*pi)/3;
    theta = 3*pi*j/nFrames;
    % Move the line to new location/orientation
    %set(Lh,'xdata',[cx-L/2*cos(theta) cx+L/2*cos(theta)],'ydata', [cy-L/2*sin(theta) cy+L/2*sin(theta)]);
    set(h,'position',[cx+L/2*cos(theta),cy+L/2*sin(theta),0.1,0.4])
    imagesc(imrotate(I,30*theta));
    set(gcf,'color','black');
    axis off
    axis auto
    % Make sure the axis stays fixed (and square)
    %axis([0.5 523.5 0.5 700]); 
    axis square
    % Flush the graphics buffer to ensure the line is moved on screen
    drawnow
    refreshdata
    %pause(.2)
    % Capture frame
    %F(j) = getframe;
end
disp('Playing movie...')
Fps = 100;
nPlay = 1;
%movie(F,nPlay,Fps)
