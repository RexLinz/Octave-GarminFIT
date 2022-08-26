% decoding Garmin FIT files
% protocol definition shown here
% https://developer.garmin.com/fit/protocol/

filename = "C8BD3920.FIT"; % SUP with Markus surfing

id = fopen(filename,"rb");
if id<0 error("could not open input file"); end

FITheader = readFITheader(id);
messages = {};
data = NaN*zeros(256,1);
%while !feof(id)
for n=1:2
  clear record;
  record.header = fread(id, 1);
  if bitand(record.header, 128)
    record = readFITtimestamp(id, record); % TODO (untested)
    disp("compressed timestamp");
  elseif bitand(record.header, 64)
    msgID = bitand(record.header, 15);
    record = readFITdefinition(id, record);
    if !feof(id) % eof will occour while reading CRC instead
      messages{msgID+1} = record;
      disp(["definition " num2str(msgID)]);
    end
  else
    msgID = bitand(record.header, 15);
    record = messages{msgID+1};
    if 1
      for f=1:record.fields
        [dummy,recSize] = fread(id, record.field(f).fieldSize); % skip record content
      end
    else
      totalDone = 0;
      filePos = ftell(id);
      for f = 1:record.fields
        switch record.baseType(f)
          case 0
            data(record.fieldNum(f)+1) = fread(id, 1, "uint8"); % enum
            dataDone = 1;
          case 1
            data(record.fieldNum(f)+1) = fread(id, 1, "int8"); % int8
            dataDone = 1;
          case 2
            data(record.fieldNum(f)+1) = fread(id, 1, "uint8"); % uint8
            dataDone = 1;
          case 131 % 0x83
            data(record.fieldNum(f)+1) = fread(id, 1, "int16"); % int16
            dataDone = 2;
          case 132 % 0x84
            data(record.fieldNum(f)+1) = fread(id, 1, "uint16"); % uint16
            dataDone = 2;
          case 133 % 0x85
            data(record.fieldNum(f)+1) = fread(id, 1, "int32"); % int32
            dataDone = 4;
          case 134 % 0x86
            data(record.fieldNum(f)+1) = fread(id, 1, "uint32"); % uint32
            dataDone = 4;
          case 7
            [dummy,dataDone] = fread(id, record.fieldSize(f), "uchar"); % TODO string
            dataDone = record.fieldSize(f);
          case 136 % 0x88
            data(record.fieldNum(f)+1) = fread(id, 1, "float"); % float
            dataDone = 4;
          case 137 % 0x89
            data(record.fieldNum(f)+1) = fread(id, 1, "double"); % double
            dataDone = 8;
          case 10
            data(record.fieldNum(f)+1) = fread(id, 1, "uint8"); % uint8z
            dataDone = 1;
          case 139 % 0x8B
            data(record.fieldNum(f)+1) = fread(id, 1, "uint16"); % uint16
            dataDone = 2;
          case 140 % 0x8C
            data(record.fieldNum(f)+1) = fread(id, 1, "uint32"); % uint32
            dataDone = 4;
          case 13
            [dummy,dataDone] = fread(id, record.fieldSize(f), "uint8"); % array of byte
            dataDone = record.fieldSize(f);
          case 142 % 0x8E
            data(record.fieldNum(f)+1) = fread(id, 1, "int64"); % int64
            dataDone = 8;
          case 134 % 0x8F
            data(record.fieldNum(f)+1) = fread(id, 1, "uint64"); % uint64
            dataDone = 8;
          case 134 % 0x90
            data(record.fieldNum(f)+1) = fread(id, 1, "uint64"); % uint64z
            dataDone = 8;
          otherwise
            [dummy,dataDone] = fread(id, record.fieldSize(f), "uint8"); % unknown type
            warning("unknown base type found");
        end
        if dataDone != record.fieldSize(f)
          warning("data read has different size than expected");
        end
        totalDone += dataDone;
      end
      if totalDone != sum(record.fieldSize)
        warning("total record read does not match sum of field sizes");
      end
      fseek(id, filePos+sum(record.fieldSize)); % ensure to go on correct
    end

%    [dummy,devSize] = fread(id, sum(record.devSize)); % skip developer content
    if record.devFields>0
      for f=1:record.devFields
        [dummy,recSize] = fread(id, record.devField(f).fieldSize); % skip record content
      end
    end

    if !feof(id) % eof will occour while reading CRC instead
      disp(["data " num2str(msgID)]);
    end
    % 0 lat
    % 1 lon
    % 4 cadence
    % 5 distance
    % 53
    % 87 ???
    % 6 speed
    % 253 timestamp
  end
end

fclose(id);
