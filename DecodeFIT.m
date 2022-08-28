% decoding Garmin FIT files
% protocol definition shown here
% https://developer.garmin.com/fit/protocol/

clear

switch 3
  case 0
    filename = "C8BD3920.fit"; % Surf Markus 11.08.2022, 13:39-14:02
  case 1
    filename = "C8CA3219.fit"; % Surf Markus 12.08.2022, 10:32-12:07
  case 2
    filename = "7222065175_ACTIVITY.fit"; % Surf max. speed, 31.07.2021, 09:06
  case 3
    filename = "7256738576_ACTIVITY.fit"; % Surf 32,5 km, 06.08.2021, 14:27
  otherwise
    error("no data selected");
end


id = fopen(filename,"rb");
if id<0 error("could not open input file"); end

FITheader = readFITheader(id);
messages = {};

N = 3600; n = 0;
t = NaN*zeros(N,1); % seconds since 01.01.1990
lat = NaN*zeros(N,1);
lon = NaN*zeros(N,1);
speed = NaN*zeros(N,1);
dist = NaN*zeros(N,1);

while !feof(id)
%for r=1:35
  clear record;
  record.header = fread(id, 1);
  if feof(id) break; end;
  if bitand(record.header, 128)
    disp("compressed timestamp");
    record = readFITtimestamp(id, record); % TODO (untested)
  elseif bitand(record.header, 64)
    msgID = bitand(record.header, 15);
    disp(["definition " num2str(msgID)]);
    record = readFITdefinition(id, record);
    if !feof(id) % eof will occour while reading CRC instead
      messages{msgID+1} = record;
    end
  else
    msgID = bitand(record.header, 15);
    record = messages{msgID+1};
    if record.messageNumber == 20 % parse "record" type only
%      disp(["data " num2str(msgID) ", messageNumber=" num2str(record.messageNumber) ", fields=" num2str(record.fields)]);
      n = n+1;
      for f = 1:record.fields
        field = record.field(f);
        [temp, bytes] = readDataField(id, field);
        if length(temp)==1 % we expect just one value read
          data(field.fieldNum+1) = temp;
          switch field.fieldNum
          case 0 % lat
            lat(n) = temp;
          case 1 % lon
            lon(n) = temp;
          case 5 % distance
            dist(n) = temp;
          case 6 % speed
            speed(n) = temp;
          case 253 % timestamp
            t(n) = temp;
          otherwise
            % 2 altitude
            % 3 heart rate
            % 4 cadence
            % 53 fractional cadence
            % 87 unknown
            % 88 unknown
          end
        else
          error("multiple data read");
        end
      end
    else % not "record" type, skip content
      for f=1:record.fields
        [dummy,recSize] = fread(id, record.field(f).fieldSize);
      end
    end

    % skip developer content if available
    if record.devFields>0
      for f=1:record.devFields
        [dummy,recSize] = fread(id, record.devField(f).fieldSize);
      end
    end
  end
end

fclose(id);

% cut data to length
t = t(1:n);              % seconds from 01.01.1990
lat = lat(1:n)/2^32*360; % to degrees
lon = lon(1:n)/2^32*360; % to degrees
speed = speed(1:n)/1000; % in m/s
dist= dist(1:n)/100;     % distance in m

% not all data records might hold lat/lon/...
% remove them
r = find(isnan(lat));
t(r) = [];
lat(r) = [];
lon(r) = [];
speed(r) = [];
dist(r) = [];
