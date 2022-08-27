function [data, bytesDone] = readDataField(id, field)

filePos = ftell(id);

switch field.baseType % binary representation
  case 0
    data = fread(id, 1, "uint8"); % enum
    bytesDone = 1;
  case 1
    data = fread(id, 1, "int8"); % int8
    bytesDone = 1;
  case 2
    data = fread(id, 1, "uint8"); % uint8
    bytesDone = 1;
  case 131 % 0x83
    data = fread(id, 1, "int16"); % int16
    bytesDone = 2;
  case 132 % 0x84
    data = fread(id, 1, "uint16"); % uint16
    bytesDone = 2;
  case 133 % 0x85
    data = fread(id, 1, "int32"); % int32
    bytesDone = 4;
  case 134 % 0x86
    data = fread(id, 1, "uint32"); % uint32
    bytesDone = 4;
  case 7
    data = fread(id, record.field(f).fieldSize, "uchar"); % TODO string
    bytesDone = record.field(f).fieldSize;
  case 136 % 0x88
    data = fread(id, 1, "float"); % float
    bytesDone = 4;
  case 137 % 0x89
    data = fread(id, 1, "double"); % double
    bytesDone = 8;
  case 10
    data = fread(id, 1, "uint8"); % uint8z
    bytesDone = 1;
  case 139 % 0x8B
    data = fread(id, 1, "uint16"); % uint16
    bytesDone = 2;
  case 140 % 0x8C
    data = fread(id, 1, "uint32"); % uint32
    bytesDone = 4;
  case 13
    data = fread(id, record.field(f).fieldSize, "uint8"); % array of byte
    bytesDone = record.fieldSize(f);
  case 142 % 0x8E
    data = fread(id, 1, "int64"); % int64
    bytesDone = 8;
  case 134 % 0x8F
    data = fread(id, 1, "uint64"); % uint64
    bytesDone = 8;
  case 134 % 0x90
    data = fread(id, 1, "uint64"); % uint64z
    bytesDone = 8;
  otherwise
    data = fread(id, record.field(f).fieldSize, "uint8"); % unknown type
    warning("unknown base type found");
end
if bytesDone != field.fieldSize
  warning("data read has different size than expected");
  fseek(id, filePos+field.fieldSize); % ensure to go on correct
end


