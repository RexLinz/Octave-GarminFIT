function index = findRecordMessages(message)

% function index = findRecordMessages(message)
% find indices of "record" type messages

index = [];
for m=1:length(message)
  if message{m}.messageNumber == 20
    index = [index m];
  end
end

