function msgName = getMessageName(msg_num)

% function msgName = getMessageName(msg_num)
% get message name for given message number
% from file Types.csv
% (exported sheet from Profiles.xlsx in GARMIN Fit SDK)

id = fopen("Types.csv","rt");
if id<0 error("could not open file Types.csv"); end

% search for line starting with "mesg_num"
while !feof(id)
  l = fgetl(id);
  if strncmp(l,"mesg_num",8)
    break;
  end
end

while !feof(id)
  l = fgetl(id);
  f = strsplit(l,";");
  if length(f{1})>0 % found another definition
    break;
  end
  n = str2num(f{3});
  if msg_num==n
    msgName = f{2};
    fclose(id);
    return;
  end
end

fclose(id);
msgName = "unknown";

