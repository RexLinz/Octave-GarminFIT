function fieldName = getFieldName(messageName, fieldDefNum)

% function fieldName = getFieldName(messageName, fieldDefNum)
% get message name for given messageName and field definition number
% from file Types.csv
% (exported sheet from Profiles.xlsx in GARMIN Fit SDK)

if strcmp(messageName,"unknown")
  fieldName = "unknown";
  return
end

id = fopen("Messages.csv","rt");
if id<0 error("could not open file Messages.csv"); end

% search for line starting with "messageName"
while !feof(id)
  l = fgetl(id);
  if strncmp(l,messageName,length(messageName))
    break;
  end
end

while !feof(id)
  l = fgetl(id);
  f = strsplit(l,";");
  if length(f{1})>0 % found another message definition
    break;
  end
  n = str2num(f{2});
  if n==fieldDefNum
    fieldName = f{3};
    fclose(id);
    return;
  end
end

fclose(id);
fieldName = "unknown";

