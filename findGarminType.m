function type = findGarminType(GarminTypes, TypeName, Value)

% function type = findGarminType(GarminTypes, TypeName, Value)
%
% find TypeName in GarminTypes and return name or value of
% requested item. Value to be searched for could be either
%   ValueName -> return Value
%   Value     -> return ValueName

type = [];

for n=1:length(GarminTypes)
  if strcmp(GarminTypes{n}.TypeName, TypeName)
    temp = GarminTypes{n};
    if ischar(Value)
      for n=1:length(temp.ValueName)
        if strcmp(temp.ValueName{n}, Value)
          type = temp.Value{n};
          return
        end
      end
      return % not found
    else
      for n=1:length(temp.ValueName)
        if temp.Value{n}==Value
          type = temp.ValueName{n};
          return
        end
      end
      return % not found
    end
  end
end

