function GarminTypes = readGarminTypes()

% function GarminTypes = readGarminTypes()
% read Type definitions from file Types.csv

if exist("GarminTypes")==2
  load GarminTypes;
  return
end

id = fopen("Types.csv","rt");
if id<0 error("could not open file Types.csv"); end

headerFields = strsplit(fgetl(id),";");
if !strcmp(headerFields{1},"Type Name")
  error("Type Name not found as column 1");
end
if !strcmp(headerFields{3},"Value Name")
  error("Value Name not found as column 3");
end

GarminTypes = {}; % cell array
while !feof(id)
  l = strsplit(fgetl(id),";");
  if length(l{1}>0)
    if exist("tempType")
      GarminTypes = [GarminTypes tempType];
      clear tempType;
    end
    tempType.TypeName = l{1};
    tempType.BaseType = l{2};
    numVal = 0;
  elseif length(l{2}>0)
    numVal = numVal+1;
    tempType.ValueName{numVal} = l{2};
    tempType.Value{numVal} = str2num(l{3});
  end
end

fclose(id);
save GarminTypes GarminTypes

