% decoding Garmin FIT files
% protocol definition shown here
% https://developer.garmin.com/fit/protocol/

clear
GarminTypes = readGarminTypes();
GarminMessages = readGarminMessages();

switch 0
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

id = fopen(["data/" filename ".fit"],"rb");
if id<0 error("could not open input file"); end
fileInfo = stat(id);
fileSize = fileInfo.size;
FITheader = readFITheader(id);
message = {};

%while !feof(id)
%for r=1:35
while ftell(id)<fileSize-2 % read to CRC
  clear record;
  record.header = fread(id, 1);
  if feof(id) break; end;
  if bitand(record.header, 128)
    disp("compressed timestamp");
    record = readFITtimestamp(id, record); % TODO (untested)
  elseif bitand(record.header, 64)
    msgID = bitand(record.header, 15);
    record = readFITdefinition(id, record);
    % add names to message and fields
    record.messageName = findGarminType(GarminTypes,"mesg_num",record.messageNumber);
    for f=1:record.fields
      record.field(f).fieldName = ...
        findGarminMessage(GarminMessages, record.messageName, record.field(f).fieldNum);
    end
    % now save as new message definition
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
