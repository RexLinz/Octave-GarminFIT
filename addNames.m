function record = addNames(record)

% function record = addNames(record)
%
% add message and field names to record structure

messageName = getMessageName(record.messageNumber);
record.messageName = messageName;

for f = 1:record.fields
  fieldName = getFieldName(messageName,record.field(f).fieldNum);
  record.field(f).fieldName = fieldName;
end

