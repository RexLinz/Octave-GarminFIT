% decoding Garmin FIT files
% protocol definition shown here
% https://developer.garmin.com/fit/protocol/

clear

switch 6
  case 0 % 11.08.2022, 13:39-14:02 / SUP (Surf Markus)
    filename = "C8BD3920";
  case 1 % 12.08.2022, 10:32-12:07 / SUP (Surf Markus)
    filename = "C8CA3219";
  case 2 % 31.07.2021, 09:06-09:54 / Surf max. speed
    filename = "7222065175_ACTIVITY";
  case 3 % 06.08.2021, 14:27-16:06 / Surf 32,5 km
    filename = "7256738576_ACTIVITY";
  case 4 % 20.08.2020, 08:42-12:08 / Bike
    filename = "5413024300_ACTIVITY";
  case 5 % 13.02.2022, 14:07-16:58 / Ski
    filename = "8290730284_ACTIVITY";
  case 6 % 15.01.2022, 14:54-15:49 / Walk
    filename = "8223780486_ACTIVITY";
  otherwise
    error("no data selected");
end

message = readFIT(["data/" filename]);

% optional, useful for analyzing a file, but takes much time
% add text message and field names
% message = addAllNames(message);

% merge messages holding respective data
recMessages = findRecordMessages(message);
t     = [];
lat   = [];
lon   = [];
alt   = [];
speed = [];
dist  = [];
for r=1:length(recMessages)
  msgNum = recMessages(r);
  if length(getRecordData(message{msgNum},"position_lat"))>0
    t     = [t     getRecordData(message{msgNum}, "timestamp")];     % seconds from 01.01.1990
    lat   = [lat   getRecordData(message{msgNum}, "position_lat")];  % deg
    lon   = [lon   getRecordData(message{msgNum}, "position_long")]; % deg
    alt   = [alt   getRecordData(message{msgNum}, "altitude")];      % m
    speed = [speed getRecordData(message{msgNum}, "speed")];         % in m/s
    dist  = [dist  getRecordData(message{msgNum}, "distance")];      % m
  end
end
% now sort all fields by timestamp
[t i] = sort(t);
lat   = lat(i);
lon   = lon(i);
if length(alt)==length(t) alt=alt(i); end
speed = speed(i);
dist  = dist(i);

%showActivity;
