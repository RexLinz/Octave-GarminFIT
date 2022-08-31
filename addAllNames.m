function message = addAllNames(message)

% function message = addAllNames(message)
%
% add message and field names to all messages
% in cell array message

disp("parsing the CSV files might take some time...");
for m=1:length(message)
  disp(["  processing " num2str(message{m}.fields) " fields of messageNumber " num2str(message{m}.messageNumber)]);
  message{m} = addNames(message{m});
end

