% decoding Garmin FIT files
% protocol definition shown here
% https://developer.garmin.com/fit/protocol/

filename = "C8BD3920.FIT"; % SUP with Markus surfing

id = fopen(filename,"rb");
if id<0 error("could not open input file"); end

FITheader = readFITheader(id);
messages = {};
data = NaN*zeros(256,1);

N = 3600; n = 0;
t = zeros(N,1); % seconds since 01.01.1990
lat = zeros(N,1);
lon = zeros(N,1);
speed = zeros(N,1);
dist = zeros(N,1);

while !feof(id)
%for n=1:35
  clear record;
  record.header = fread(id, 1);
  if feof(id) break; end;
  if bitand(record.header, 128)
    disp("compressed timestamp");
    record = readFITtimestamp(id, record); % TODO (untested)
  elseif bitand(record.header, 64)
    msgID = bitand(record.header, 15);
%    disp(["definition " num2str(msgID)]);
    record = readFITdefinition(id, record);
    if !feof(id) % eof will occour while reading CRC instead
      messages{msgID+1} = record;
    end
  else
    msgID = bitand(record.header, 15);
    record = messages{msgID+1};
    if record.messageNumber == 20 % parse "record" type only
      n = n+1;
      for f = 1:record.fields
        field = record.field(f);
        [temp, bytes] = readDataField(id, field);
        if (length(temp)==1) % we expect just one value read
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
            % 4 cadence
            % 53 fractional cadence
            % 87 unknown
          end
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
speed = speed(1:n);      % in m/s
dist= dist(1:n);         % distance in m

