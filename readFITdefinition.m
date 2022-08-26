function record = readFITdefinition(id, record);

if bitand(record.header, 64) == 0
  error("no definition record");
end

record.reserved = fread(id, 1);
record.architecture = fread(id, 1);
record.messageNumber = fread(id, 1, "uint16");
record.fields = fread(id, 1);
record.fieldNum  = [];
record.fieldSize = [];
record.baseType  = [];
for f = 1:record.fields
  record.fieldNum  = [record.fieldNum;  fread(id, 1)];
  record.fieldSize = [record.fieldSize; fread(id, 1)];
  record.baseType  = [record.baseType;  fread(id, 1)];
end
if bitand(record.header,32) % developer data present
  record.developers = fread(id, 1);
  record.devNum   = [];
  record.devSize  = [];
  record.devIndex = [];
  for f = 1:record.fields
    record.devNum    = [record.devNum;   fread(id, 1)];
    record.devSize   = [record.devSize;  fread(id, 1)];
    record.devIndex  = [record.devIndex; fread(id, 1)];
  end
else
  record.developers = 0;
  record.devSize = 0;
end

