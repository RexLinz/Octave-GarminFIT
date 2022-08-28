function data = getRecordData(record, name)

% function data = getRecordData(record, name)
% read named data from activity records (messageNumber=20)
% accepted NAME values are lat, lon, alt, heart, cad, dist, speed,time
% output is converted to useful units, e.g. deg, m, m/s, ...

if record.messageNumber != 20 % "record"
  error("expect messageNumber==20 (record)");
end

switch name
  case "lat"
    fieldNum = 0;
    scale = 2^32*360; % to deg
  case "lon"
    fieldNum = 1;
    scale = 2^32*360; % to deg
  case "alt"
    fieldNum = 2;
    scale = 1;        % not known so far
  case "heart"
    fieldNum = 3;
    scale = 1;        % not known so far
  case "cad"
    fieldNum = 4;
    scale = 1;        % not known so far
  case "dist"
    fieldNum = 5;
    scale = 100;      % to m
  case "speed"
    fieldNum = 6;
    scale = 1000;     % to m/s
  % 53 fractional cadence
  % 87 unknown
  % 88 unknown
  case "time"
    fieldNum = 253;
    scale = 1;        % seconds from 01.01.1990
  otherwise
    error(["field " name " unknown"]);
end

for i=1:record.fields
  if record.field(i).fieldNum==fieldNum
    data = record.field(i).data/scale;
    break;
  end
end

