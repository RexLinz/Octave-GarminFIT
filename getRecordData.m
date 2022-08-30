function data = getRecordData(record, name)

% function data = getRecordData(record, name)
% read named data from activity records (messageNumber=20)
% accepted NAME values are lat, lon, alt, heart, cad, dist, speed,time
% output is converted to useful units, e.g. deg, m, m/s, ...

if record.messageNumber != 20 % "record"
  error("expect messageNumber==20 (record)");
end

offset = 0; % if not defined
switch name
  case "lat"
    fieldNum = 0;
    scale = 360/2^32; % to deg
  case "lon"
    fieldNum = 1;
    scale = 360/2^32; % to deg
  case "alt"
    fieldNum = 2;
    scale = 1/5;        % not known so far
    offset = 500;
  case "heart"
    fieldNum = 3;
    scale = 1;        % not known so far
  case "cad"
    fieldNum = 4;
    scale = 1;        % not known so far
  case "dist"
    fieldNum = 5;
    scale = 0.01;     % to m
  case "speed"
    fieldNum = 6;
    scale = 0.001;    % to m/s
  % 53 fractional cadence
  % 87 unknown
  % 88 unknown
  case "time"
    fieldNum = 253;
    scale = 1;        % seconds from 01.01.1990
  otherwise
    error(["field " name " unknown"]);
end

data = [];
for i=1:record.fields
  if record.field(i).fieldNum==fieldNum
    data = record.field(i).data*scale-offset;
    break;
  end
end

