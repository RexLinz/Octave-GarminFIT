function message = addAllNames(message)

% function message = addAllNames(message)
%
% add message and field names to all messages
% in cell array message

GarminTypes = readGarminTypes();
GarminMessages = readGarminMessages();

for m=1:length(message)
%  disp(["  processing " num2str(message{m}.fields) " fields of messageNumber " num2str(message{m}.messageNumber)]);
  message{m} = addNames(message{m}, GarminTypes, GarminMessages);
end

