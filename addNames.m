function record = addNames(record, GarminTypes, GarminMessages)

% function record = addNames(record, GarminTypes, GarminMessages)
%
% add message and field names to record structure

% record name
record.messageName = findGarminType(GarminTypes,"mesg_num",record.messageNumber);

% field names
for f=1:record.fields
  record.field(f).fieldName = ...
    findGarminMessage(GarminMessages, record.messageName, record.field(f).fieldNum);
end

