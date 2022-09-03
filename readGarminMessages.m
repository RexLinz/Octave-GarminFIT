function GarminMessages = readGarminMessages()

% function GarminMessages = readGarminMessages()
% read Message definitions from file GarminMessages.csv

if exist("GarminMessages")==2
  load GarminMessages;
  return
end

id = fopen("GarminMessages.csv","rt");
if id<0 error("could not open file GarminMessages.csv"); end

headerFields = strsplit(fgetl(id),";");
if !strcmp(headerFields{1},"Message Name")
  error("Message Name not found as column 1");
end
if !strcmp(headerFields{3},"Field Name")
  error("Field Name not found as column 3");
end

GarminMessages = {}; % cell array
while !feof(id)
  l = strsplit(fgetl(id),";");
  if length(l{1}>0)
    if exist("tempMessage")
      GarminMessages = [GarminMessages tempMessage];
      clear tempMessage;
    end
    tempMessage.MessageName = l{1};
    numVal = 0;
  elseif length(l{2}>0) && exist("tempMessage")
    numVal = numVal+1;
    tempMessage.FieldNum{numVal} = str2num(l{2});
    tempMessage.FieldName{numVal} = l{3};
  end
end

fclose(id);
save GarminMessages GarminMessages
