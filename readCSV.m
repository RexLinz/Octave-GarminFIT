% read data from CSV exported using JAVA conversion tool

switch 2
  case 0
    filename = "C8BD3920.csv"; % Surf Markus 11.08.2022, 13:39-14:02
  case 1
    filename = "C8CA3219.csv"; % Surf Markus 12.08.2022, 10:32-12:07
  case 2
    filename = "7222065175_ACTIVITY.csv"; % Surf Höchsgeschwindigkeit, 31.07.2021, 09:06
  case 3
    filename = "7256738576_ACTIVITY.csv"; % Surf 32,5 km, 06.08.2021, 14:27
  otherwise
    error("no data selected");
end

id = fopen(filename,"rt");
if id<0 error("could not open input file"); end

N = 3600; n = 0;
t = zeros(N,1); _t = 0; % seconds since 01.01.1990
lat = zeros(N,1); _lat = 0;
lon = zeros(N,1); _lon = 0;
speed = zeros(N,1); _speed = 0;
dist = zeros(N,1); _dist = 0;
while !feof(id)
  l = strsplit(fgetl(id),",");
  if strcmp(l(1),"Data") && strcmp(l(3),"record")
    b = l;
    % update data if found in record
    _t     = CSVvalue(b,"timestamp",     _t);     % time
    _lat   = CSVvalue(b,"position_lat",  _lat);   % latitude
    _lon   = CSVvalue(b,"position_long", _lon);   % longitude
    _speed = CSVvalue(b,"speed",         _speed); % speed
    _dist  = CSVvalue(b,"distance",      _dist);  % dist
    n = n+1;
    t(n) = _t;
    lat(n) = _lat;
    lon(n) = _lon;
    speed(n) = _speed;
    dist(n)  = _dist;
  end
end

% cut data to length
t = t(1:n);              % seconds from 01.01.1990
lat = lat(1:n)/2^32*360; % to degrees
lon = lon(1:n)/2^32*360; % to degrees
speed = speed(1:n);      % in m/s
dist= dist(1:n);         % distance in m

