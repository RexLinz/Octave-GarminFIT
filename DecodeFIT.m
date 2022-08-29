% decoding Garmin FIT files
% protocol definition shown here
% https://developer.garmin.com/fit/protocol/

clear

switch 2
  case 0 % 11.08.2022, 13:39-14:02 / SUP (Surf Markus)
    filename = "C8BD3920.fit";
  case 1 % 12.08.2022, 10:32-12:07 / SUP (Surf Markus)
    filename = "C8CA3219.fit";
  case 2 % 31.07.2021, 09:06-09:54 / Surf max. speed
    filename = "7222065175_ACTIVITY.fit";
  case 3 % 06.08.2021, 14:27-16:06 / Surf 32,5 km
    filename = "7256738576_ACTIVITY.fit";
  otherwise
    error("no data selected");
end

id = fopen(filename,"rb");
if id<0 error("could not open input file"); end

FITheader = readFITheader(id);
message = {};

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
    record = readFITdefinition(id, record);
    if !feof(id) % eof will occour while reading CRC instead
      if (length(message)>=msgID+1) && (message{msgID+1}.header!=0)
        % redefinition of already used message, save backup at end of array
        message{length(message)+1} = message{msgID+1};
%        disp(["redefinition of " num2str(msgID)]);
      else
%        disp(["definition " num2str(msgID)]);
      end
      message{msgID+1} = record;
    end
  else
    msgID = bitand(record.header, 15);
    record = message{msgID+1};
%    disp(["data " num2str(msgID) ", messageNumber=" num2str(record.messageNumber) ", fields=" num2str(record.fields)]);
    nData = length(record.field(1).data);
    for f = 1:record.fields
      field = record.field(f);
      [temp, bytes] = readDataField(id, field);
      if feof(id)
        break
      else
        if length(temp)==1 % we expect just one value read
          message{msgID+1}.field(f).data(nData+1) = temp;
        else
          message{msgID+1}.field(f).data(nData+1) = temp(1);
%          warning("multiple data read");
        end
      end
    end
    % skip developer content if available
    if record.devFields>0
      for f=1:record.devFields
        [~,recSize] = fread(id, record.devField(f).fieldSize);
      end
    end
  end
end

fclose(id);

% TODO merge messages holding respective data
recMessages = findRecordMessages(message);

t = [];
lat = [];
lon = [];
speed = [];
dist = [];
for r=1:length(recMessages)
  msgNum = recMessages(r);
  if length(getRecordData(message{msgNum},"lat"))>0
    t     = [t getRecordData(message{msgNum}, "time")];  % seconds from 01.01.1990
    lat   = [lat getRecordData(message{msgNum}, "lat")];   % deg
    lon   = [lon getRecordData(message{msgNum}, "lon")];   % deg
    speed = [speed getRecordData(message{msgNum}, "speed")]; % in m/s
    dist  = [dist getRecordData(message{msgNum}, "dist")];  % distance in m
  end
end
% now sort all fields by timestamp
[t i] = sort(t);
lat   = lat(i);
lon   = lon(i);
speed = speed(i);
dist  = dist(i);

showActivity;
