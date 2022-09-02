function message = findGarminMessage(GarminMessages, MessageName, Field)

% function message = findGarminMessage(GarminMessages, MessageName, Field)
%
% find MessageName in GarminMessages and return name or value of
% requested item. Field to be searched for could be either
%   FieldName -> return FieldNum
%   FieldNum  -> return FieldName

message = [];

for n=1:length(GarminMessages)
  if strcmp(GarminMessages{n}.MessageName, MessageName)
    temp = GarminMessages{n};
    if ischar(Field)
      for n=1:length(temp.FieldName)
        if strcmp(temp.FieldName{n}, Field)
          message = temp.FieldNum{n};
          return
        end
      end
      return % not found
    else
      for n=1:length(temp.FieldNum)
        if temp.FieldNum{n}==Field
          message = temp.FieldName{n};
          return
        end
      end
      return % not found
    end
  end
end

