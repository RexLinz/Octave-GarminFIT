function message = readFIT(filename)

% function message = readFIT(filename)
%
% read messages from FIT file

if exist(filename)==2
  load(filename);
  return
end

id = fopen([filename ".fit"], "rb");
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
message = addAllNames(message); % add record and field names
save(filename,"message"); % save converted file
