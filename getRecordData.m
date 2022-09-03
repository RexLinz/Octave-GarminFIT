function data = getRecordData(record, name)

% function data = getRecordData(record, name)
% read named data from activity records (messageNumber=20)
% accepted NAME values are field names as defined in GARMIN Fit SDK
% output is converted to useful units, e.g. deg, m, m/s, ...

if record.messageNumber != 20 % "record"
  error("expect messageNumber==20 (record)");
end

scale  = 1; % default
offset = 0; % default
switch name
  case "position_lat"
    fieldNum = 0;
    scale = 360/2^32; % to deg
  case "position_long"
    fieldNum = 1;
    scale = 360/2^32; % to deg
  case "altitude"
    fieldNum = 2;
    scale = 1/5;        % not known so far
    offset = 500;
  case "heart_rate"
    fieldNum = 3;
  case "cadence"
    fieldNum = 4;
  case "distance"
    fieldNum = 5;
    scale = 0.01;     % to m
  case "speed"
    fieldNum = 6;
    scale = 0.001;    % to m/s
  % 53 fractional_cadence
  % 87 unknown
  % 88 unknown
  case "timestamp" % seconds from 01.01.1990
    fieldNum = 253;
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

