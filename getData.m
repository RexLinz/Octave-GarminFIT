function data = getData(record, name)

switch name
  case "lat"
    fieldNum = 0;
    scale = 2^32*360; % to deg
  case "lon"
    fieldNum = 1;
    scale = 2^32*360; % to deg
  case "dist"
    fieldNum = 5;
    scale = 100;      % to m
  case "speed"
    fieldNum = 6;
    scale = 1000;     % to m/s
  case "time"
    fieldNum = 253;
    scale = 1;        % seconds from 01.01.1990
  otherwise
    error(["field " name " unknown"]);
end

fieldNum
for i=1:record.fields
  if record.field(i).fieldNum==fieldNum
    data = record.field(i).data/scale;
    break;
  end
end

i
