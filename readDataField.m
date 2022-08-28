function [data, bytesDone] = readDataField(id, field)

filePos = ftell(id);

switch field.baseType % binary representation
  case 0
    data = fread(id, 1, "uint8"); % enum
%    if data==255, data=NA; end
    bytesDone = 1;
  case 1
    data = fread(id, 1, "int8"); % int8
%    if data==127, data=NA; end
    bytesDone = 1;
  case 2
    data = fread(id, 1, "uint8"); % uint8
%    if data==255, data=NA; end
    bytesDone = 1;
  case 131 % 0x83
    data = fread(id, 1, "int16"); % int16
%    if data==32767, data=NA; end
    bytesDone = 2;
  case 132 % 0x84
    data = fread(id, 1, "uint16"); % uint16
%    if data==65536, data=NA; end
    bytesDone = 2;
  case 133 % 0x85
    data = fread(id, 1, "int32"); % int32
%    if data==hex2dec("7FFFFFFF"), data=NA; end
    bytesDone = 4;
  case 134 % 0x86
    data = fread(id, 1, "uint32"); % uint32
%    if data==hex2dec("FFFFFFFF"), data=NA; end
    bytesDone = 4;
  case 7
    % TODO null terminated string untested
    data = char(fread(id, record.field(f).fieldSize, "uchar")');
    bytesDone = record.field(f).fieldSize;
  case 136 % 0x88
    data = fread(id, 1, "float"); % float
    % TODO invalid if binary representation is 0xFFFFFFFF
    bytesDone = 4;
  case 137 % 0x89
    data = fread(id, 1, "double"); % double
    % TODO invalid if binary representation is 0xFFFFFFFFFFFFFFFF
    bytesDone = 8;
  case 10
    data = fread(id, 1, "uint8"); % uint8z
%    if data==0, data=NA; end
    bytesDone = 1;
  case 139 % 0x8B
    data = fread(id, 1, "uint16"); % uint16z
%    if data==0, data=NA; end
    bytesDone = 2;
  case 140 % 0x8C
    data = fread(id, 1, "uint32"); % uint32z
%    if data==0, data=NA; end
    bytesDone = 4;
  case 13
    data = fread(id, record.field(f).fieldSize, "uint8"); % array of byte
    % TODO invalid if byte is 0xFF
    bytesDone = record.fieldSize(f);
  case 142 % 0x8E
    data = fread(id, 1, "int64"); % int64
%    if data==hex2dec("7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF"), data=NA; end
    bytesDone = 8;
  case 134 % 0x8F
    data = fread(id, 1, "uint64"); % uint64
%    if data==hex2dec("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF"), data=NA; end
    bytesDone = 8;
  case 134 % 0x90
    data = fread(id, 1, "uint64"); % uint64z
%    if data==0, data=NA; end
    bytesDone = 8;
  otherwise
    data = fread(id, record.field(f).fieldSize, "uint8"); % unknown type
    warning(["unknown base type " num2str(field.baseType) " found"]);
end
if bytesDone != field.fieldSize
  warning("data read has different size than expected");
  fseek(id, filePos+field.fieldSize); % ensure to go on correct
end


