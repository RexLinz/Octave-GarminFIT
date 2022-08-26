function record = readFITdefinition(id, record);

if bitand(record.header, 64) == 0
  error("no definition record");
end

record.reserved = fread(id, 1);
record.architecture = fread(id, 1);
record.messageNumber = fread(id, 1, "uint16");
record.fields = fread(id, 1);
record.field = [];
for f = 1:record.fields
  temp.fieldNum  = fread(id, 1);
  temp.fieldSize = fread(id, 1);
  temp.baseType  = fread(id, 1);
  record.field   = [record.field temp];
end
if bitand(record.header,32) % developer data present
  record.devFields = fread(id, 1);
  record.devField  = [];
  clear temp;
  for f = 1:record.fields
    temp.fieldNum  = fread(id, 1);
    temp.fieldSize = fread(id, 1);
    temp.dataIndex = fread(id, 1);
    record.devField = [record.devField temp];
  end
else
  record.devFields = 0;
end

