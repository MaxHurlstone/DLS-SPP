function [X,Y,U,V,W,S_lon,S_sag,x,y,u,v,w] = sloper(fname,Nxx,Nyy,FID,order,sym)
%SLOPER Summary of this function goes here
%   Detailed explanation goes here

arguments (Input)
    fname (1,1) string
    Nxx (1,1) double = 100
    Nyy (1,1) double = 20
    FID (1,1) logical = 0
    order (1,1) int16 = 3
    sym (1,1) logical = 0
end

arguments (Output)
    X (:,:) double
    Y (:,:) double
    U (:,:) double
    V (:,:) double
    W (:,:) double
    S_lon (:,:) double
    S_sag (:,:) double
    x  (1,:) double
    y  (1,:) double
    u  (1,:) double
    v  (1,:) double
    w  (1,:) double
end

% Read ANSYS data
data0 = readmatrix(fname,'FileType','text','Delimiter','\t','NumHeaderLines',1);
data0 = unique(data0,'rows');

x = data0(:,2);
y = data0(:,3);
% z =
u = data0(:,5);
v = data0(:,6);
w = data0(:,7);

% Create regular grid
xmin = min(x) + 0.01;
xmax = max(x) - 0.01;
ymin = min(y) + 0.01;
ymax = max(y) - 0.01;

xv = linspace(xmin,xmax,Nxx);
yv = linspace(ymin,ymax,Nyy);

[X,Y] = meshgrid(xv,yv);

% Match original Python grid orientation
X = X.';
Y = Y.';

% Interpolate displacements onto regular grid
U = griddata(x,y,u,X,Y,'linear');
V = griddata(x,y,v,X,Y,'linear');
W = griddata(x,y,w,X,Y,'linear');

% If symmetric half-model
if sym
    xv = [xv, flip(xv)];
    yv = [yv, flip(yv)];
    X = [X; -1.*flipud(X)];
    Y = [Y; Y];
    W = [W; flipud(W)];
end

% Polynomial fitting of each longitudinal line
if FID
    for j = 1:Nyy
        c = polyfit(xv,W(:,j),order);
        W(:,j) = polyval(c,xv);
    end
end

% Grid spacing
dx = abs(xmax - xmin)/Nxx;
dy = abs(ymax - ymin)/Nyy;

% Calculate gradient
[dWdy,dWdx] = gradient(W,dy,dx);

% Longitudinal slope error
S_lon = 1e6 * atan(dWdy);
% Sagittal slope error
S_sag = 1e6 * atan(dWdx);