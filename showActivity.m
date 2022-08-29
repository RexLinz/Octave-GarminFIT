% evaluate activity

tStart = datestr(FITtime(t(1),2))
tEnd   = datestr(FITtime(t(end),2))
tAct   = t - t(1);

% scale map to distance
R = 6371000; % average earth radius
meanLat = mean(lat);
meanLon = mean(lon);
y = R*deg2rad(lat-meanLat);
x = R*cosd(lat).*deg2rad(lon-meanLon);
% distance from actual data
d = (diff(x).^2+diff(y).^2).^0.5;

% radius from 3 points
r = calcR(x,y);

% course
dx = diff(x);
dy = diff(y);
heading = atan2(dy,dx);
% remove points with dx and dy == 0
nh = find((dx==0) & (dy==0));
heading(nh) = heading(nh-1); % keep heading
deltaHeading = diff(unwrap(heading));

figure(1,"name","xy plot");
plot(
  x,y,
  x(1),   y(1),   'go', % mark start
  x(end), y(end), 'rx'  % mark end
);
grid on;
axis("equal");
xlabel("x [m]");
ylabel("y [m]");

figure(2,"name","data");
% speed
a(1) = subplot(4,1,1);
plot(tAct, speed);
grid on;
xlabel("t [s]");
ylabel("v [m/s]");
%
a(2) = subplot(4,1,2);
plot(tAct, 1./r);
grid on;
xlabel("t [s]");
ylabel("1/r [1/m]");
% heading
a(3) = subplot(4,1,3);
plot(tAct(2:end), rad2deg(heading));
grid on;
xlabel("t [s]");
ylabel("heading [deg]");
% heading change
a(4) = subplot(4,1,4);
plot(tAct(2:end-1), rad2deg(deltaHeading));
grid on;
xlabel("t [s]");
ylabel("heading change [delta deg]");

linkaxes(a,'x');
