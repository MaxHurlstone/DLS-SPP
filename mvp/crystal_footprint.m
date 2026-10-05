% Clear and close all
clear
close all
%% Crystal Footprint Slope Error Calculator
% This live script will enable you to interactively analyse the slope error 
% at the beam footprint. It uses |*uvectors*| data from the ANSYS model, scoped 
% to the beam power input area.
%% File Selection and Exporting
% Select the input ANSYS file and the target export directory.

% Data input and export directory
fname = "F:\Coding\DLS-Simulink\spp\test_data\test.txt";
expdir = "F:\Coding\DLS-Simulink\spp\test_export";
dver = "TEST";
blname = "X";
optname = "X";
scename = "X";
exp = true;
date = string(datetime('now','TimeZone','local','Format','dMMMyy'));
name = ["FEA",dver,blname,optname,scename,date];

expname = strjoin(name,'-');
%% Calculation Config
%% 
% * |*Nxx*| - number of grid points in x direction
% * |*Nyy*| - number of grid points in y direction
% * |*FID*| - use polynomial line of best fit
% * |*Order*| - order of polynomial line of best fit
% * |*sym*| - data is symmetrical in x plane.

Nxx = 100;
Nyy =20;
FID = false;
order = 3;
sym = false;
 
%% Plot Results

% Run slope error calculator
[X,Y,U,V,W,S_lon,S_sag,x,y,u,v,w] = sloper(fname,Nxx,Nyy,FID,order,sym);

% Plotting
figure()
sg = sgtitle('Slope Contour Plots');
sg.FontSize = 11;
sg.FontWeight = 'bold';

subplot(2,1,1)
contourf(X,Y,S_sag)
xlabel('Sag. (x) [mm]',FontSize=11)
ylabel('Lon. (y) [mm]',FontSize=11)

colormap bone
cb = colorbar;
ylabel(cb,'Slope [urad]','FontSize',11,'Rotation',270)

subplot(2,1,2)
contourf(X,Y,S_lon)
xlabel('Sag. (x) [mm]',FontSize=11)
ylabel('Lon. (y) [mm]',FontSize=11)

colormap bone
cb = colorbar;
ylabel(cb,'Slope [urad]','FontSize',11,'Rotation',270)

figure()
Np = 10;
sg = sgtitle('Slope and Displacement Line Plots');
sg.FontSize = 11;
sg.FontWeight = 'bold';

for i=1:Np
    idx = i*floor(size(S_lon,1)/Np);
    idy = i*floor(size(S_sag,2)/Np);

    subplot(2,2,1)
    plot(X(:,idy),W(:,idy)); hold on;
    xlabel('Sag. (x) [mm]',FontSize=11)
    ylabel('Normal Disp. [mm]',FontSize=11)
    grid on

    subplot(2,2,2)
    plot(Y(idx,:),W(idx,:)); hold on;
    xlabel('Lon. (y) [mm]',FontSize=11)
    ylabel('Normal Disp. [mm]',FontSize=11)
    grid on

    subplot(2,2,3)
    plot(X(:,idy),S_sag(:,idy)); hold on;
    xlabel('Sag. (x) [mm]',FontSize=11)
    ylabel('Sag. (x) Slope [urad]',FontSize=11)
    grid on

    subplot(2,2,4)
    plot(Y(idx,:),S_lon(idx,:)); hold on;
    xlabel('Lon. (y) [mm]',FontSize=11)
    ylabel('Tan. (y) Slope [urad]',FontSize=11)
    grid on
end

figure()
scatter3(x,y,w,75,w,'.')
xlabel('x [mm]')
ylabel('y [mm]')
zlabel('z [mm]')
title('Normal Displacements [mm]')

figure()
surf(X,Y,W,'EdgeAlpha',0.3)
xlabel('x [mm]')
ylabel('y [mm]')
zlabel('z [mm]')
title('Normal Displacements on regular grid [mm]')
% Export
if exp
    sloper_export(expdir,expname,x,y,X,Y,u,v,w,U,V,W);
end