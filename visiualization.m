%{
This piece of code plots rocket trajectory on a figure with the rocket
picture as the marker
%}
% cleaning
clear;
%clf;
%close;
clc;
% Initial center and orientation of line ptured - see below)
x = 0; 
y = 0; 
theta = 0; 
L = 1;
% Create initial line object (xdata, and ydata)
%Lh = line([cx-L/2*cos(theta) cx+L/2*cos(theta)],[cy-L/2*sin(theta) cy+L/2*sin(theta)]);
nFrames = 1;
% Allocate a 1-by-nFrames STRUCT array with 2 fields
F(nFrames) = struct('cdata',[],'colormap',[]);
disp('Creating and recording frames...')
figure('Name','Trajectory No Wind','WindowState','maximized','MenuBar','figure','Scrollable','on');
I= imread('rocket2.png');%imresize(imread('rocket.png'),[100,25]);
%rocketBodyPic = I(1:(end/1.5),:,:);
rocketBodyPic = I;
thrustPic = imrotate(imread('arrow.png'),90);
%thrustPic = I((end/1.5):end,325:525,:);
%thrustPuc = I((end/1.5):end,:,:);
%imshow(thrustPic);
%create a new axes
rocketWidth = 0.01*2^4;
rocketHeight = 0.04*2^4;
rocketBodyPicHandle= axes('position',[0,0,rocketWidth,rocketHeight]);
%put an image on the axes
imagesc(thrustPic);
hold on;
imagesc(rocketBodyPic);
%turn off the axis ticks and labels
axis off
for j = 0:(0.01/2):nFrames
    if j == 0.01
        pause(1.5);
    end
    % Change center and angle, in a sensible manner, based on Frame#
    if x < nFrames-.2
        x = (j/nFrames+.5*6)/9+.2-L/2*cos(theta);%cos(j/nFrames*pi);
        y = sin(j/nFrames*pi)/10;
        theta =-pi*j/nFrames ;
    else
        if y > 0 || theta <= 0
            y = y - .01;     
            theta = theta + .1 ;
            if theta >= 0
                theta = 0;
                continue;
            end
            pause(.1)
            
        end
    end
    
    % Move the line to new location/orientation
    %set(Lh,'xdata',[cx-L/2*cos(theta) cx+L/2*cos(theta)],'ydata', [cy-L/2*sin(theta) cy+L/2*sin(theta)]);
    set(rocketBodyPicHandle,'position',[x,y-L/2*sin(theta),rocketWidth,rocketHeight])
    set(gcf,'color','black');
    rotatedRocketBodyPic = imrotate(rocketBodyPic,30*theta+90,'bilinear','loose');
    rotatedThrustPic= imrotate(thrustPic,16*30*theta+90,'bilinear','loose');
    wholePic = imfuse(rotatedRocketBodyPic,rotatedThrustPic,'montage');
    imagesc(imrotate(wholePic,-90));
    %imagesc(imrotate(rocketBodyPic,30*theta));
    %hold on;
    %imagesc(imrotate(thrustPic,2*30*theta));
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
