function header = readFITheader(id)

header.len = fread(id, 1);                      % 14
if header.len != 14
  error("illegal length of FIT header");
end

header.protocol = fread(id, 1);                 % 16
header.profileVersion = fread(id, 1, "uint16"); % 2125
header.dataSize = fread(id, 1, "uint32");       % bytes excluding final CRC
header.dataType = char(fread(id, 4, "uchar"));  % .FIT
header.CRC = fread(id, 1, "uint16");            % CRC16

% TODO check more content

